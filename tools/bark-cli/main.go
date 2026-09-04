// bark-cli is a small, JSON-output client for the Bark push API.
package main

import (
	"bytes"
	"context"
	_ "embed"
	"encoding/json"
	"errors"
	"flag"
	"io"
	"net/http"
	"net/url"
	"os"
	"os/signal"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"
	"time"
)

var version = "dev"

const maxInput = 1 << 20
const maxResponse = 64 << 10

type result struct {
	OK         bool              `json:"ok"`
	Version    string            `json:"version,omitempty"`
	Error      string            `json:"error,omitempty"`
	Message    string            `json:"message,omitempty"`
	HTTPStatus int               `json:"http_status,omitempty"`
	Code       *int              `json:"code,omitempty"`
	Help       string            `json:"help,omitempty"`
	Results    []recipientResult `json:"results,omitempty"`
}

type config struct {
	Server            string `json:"server"`
	Key               string `json:"key"`
	KeyFile           string `json:"key_file"`
	Timeout           string `json:"timeout"`
	EncryptionKeyFile string `json:"encryption_key_file"`
	EncryptionMode    string `json:"encryption_mode"`
}

//go:embed help.txt
var help string

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	var input io.Reader
	if stat, err := os.Stdin.Stat(); err == nil && stat.Mode()&os.ModeCharDevice == 0 {
		input = os.Stdin
	}
	// Explicit stdin also works for an interactive terminal.
	for _, arg := range os.Args[1:] {
		if arg == "-" || arg == "--body=-" || arg == "--json=-" {
			input = os.Stdin
		}
	}
	os.Exit(run(ctx, os.Args[1:], input, os.Stdout))
}

func run(ctx context.Context, args []string, input io.Reader, output io.Writer) int {
	emit := func(r result, exit int) int {
		if json.NewEncoder(output).Encode(r) != nil {
			return 1
		}
		return exit
	}
	fail := func(kind, message string, exit int) int {
		return emit(result{Error: kind, Message: message}, exit)
	}
	fs := flag.NewFlagSet("bark-cli", flag.ContinueOnError)
	fs.SetOutput(io.Discard) // flag errors can contain secret values.
	var opts config
	var configPath, jsonArg string
	var showVersion, showHelp, encrypt bool
	fs.StringVar(&configPath, "config", "", "configuration file")
	fs.StringVar(&opts.Server, "server", "", "Bark server")
	fs.StringVar(&opts.KeyFile, "key-file", "", "device key file")
	fs.StringVar(&opts.Timeout, "timeout", "", "request timeout")
	fs.StringVar(&opts.EncryptionKeyFile, "encryption-key-file", "", "AES key file")
	fs.StringVar(&opts.EncryptionMode, "encryption-mode", "", "AES mode")
	fs.BoolVar(&encrypt, "encrypt", false, "encrypt notification content")
	fs.StringVar(&jsonArg, "json", "", "JSON payload or -")
	fs.BoolVar(&showVersion, "version", false, "version")
	fs.BoolVar(&showHelp, "help", false, "help")
	fs.BoolVar(&showHelp, "h", false, "help")
	stringsFlags := map[string]*string{}
	for _, name := range strings.Fields("title body subtitle group url level sound id markdown image icon copy action ciphertext iv") {
		stringsFlags[name] = fs.String(name, "", name)
	}
	boolFlags := map[string]*bool{}
	for _, name := range strings.Fields("call auto-copy archive delete") {
		boolFlags[name] = fs.Bool(name, false, name)
	}
	badge := fs.Int("badge", 0, "badge")
	volume := fs.Int("volume", 0, "volume")
	ttl := fs.Int("ttl", 0, "archive retention in seconds")
	if err := fs.Parse(args); err != nil {
		return fail("usage", "Invalid flags; use --help.", 2)
	}
	rest := fs.Args()
	command := ""
	if len(rest) > 0 {
		command = rest[0]
		if command != "push" || fs.Parse(rest[1:]) != nil {
			return fail("usage", "Expected push followed by flags and an optional body; use --help.", 2)
		}
	}
	if showHelp {
		return emit(result{OK: true, Help: help}, 0)
	}
	if showVersion {
		return emit(result{OK: true, Version: version}, 0)
	}
	if command != "push" || fs.NArg() > 1 {
		return fail("usage", "Expected push and at most one positional body; use --help.", 2)
	}
	seen := map[string]bool{}
	fs.Visit(func(f *flag.Flag) { seen[f.Name] = true })
	cfg, err := loadConfig(configPath, seen["config"], opts, seen)
	if err != nil {
		return fail("config", err.Error(), 2)
	}
	endpoint, err := serverEndpoint(cfg.Server)
	if err != nil {
		return fail("config", "Server must be an HTTP(S) URL without userinfo, query, or fragment.", 2)
	}
	duration, err := time.ParseDuration(cfg.Timeout)
	if err != nil || duration <= 0 {
		return fail("config", "Timeout must be a positive duration, such as 10s.", 2)
	}
	ctx, cancel := context.WithTimeout(ctx, duration)
	defer cancel()
	payload := map[string]json.RawMessage{}
	if seen["json"] {
		data := []byte(jsonArg)
		if jsonArg == "-" {
			data, err = readInput(ctx, input)
		}
		if err != nil || len(data) > maxInput || decodeObject(data, &payload) != nil {
			return fail("usage", "JSON input must be one object of at most 1 MiB; stdin must be readable within the timeout.", 2)
		}
	}
	// Validate supplied fields before merging so invalid input is never silently ignored.
	if err := validatePayload(payload); err != nil {
		return fail("usage", err.Error(), 2)
	}
	set := func(name string, value any) { payload[name], _ = json.Marshal(value) }
	for name, value := range stringsFlags {
		if seen[name] {
			set(name, *value)
		}
	}
	for name, value := range boolFlags {
		if seen[name] {
			field := name
			if name == "auto-copy" {
				field = "autoCopy"
			}
			if name == "archive" {
				field = "isArchive"
			}
			text := "0"
			if *value {
				text = "1"
			}
			set(field, text)
		}
	}
	if seen["badge"] {
		set("badge", *badge)
	}
	if seen["volume"] {
		set("volume", strconv.Itoa(*volume))
	}
	if seen["ttl"] {
		set("ttl", *ttl)
	}
	if fs.NArg() == 1 {
		if seen["body"] {
			return fail("usage", "Use either --body or a positional body.", 2)
		}
		set("body", fs.Arg(0))
	}
	var body string
	_ = json.Unmarshal(payload["body"], &body)
	_, bodySet := payload["body"]
	stdinBody := (seen["body"] || fs.NArg() == 1) && body == "-"
	if stdinBody || (!bodySet && !hasAlternativeContent(payload) && !seen["json"] && input != nil) {
		if seen["json"] && jsonArg == "-" {
			return fail("usage", "Stdin cannot supply both JSON and body.", 2)
		}
		data, readErr := readInput(ctx, input)
		if readErr != nil {
			return fail("usage", "Body stdin must be readable within the timeout and at most 1 MiB.", 2)
		}
		body = string(data)
		set("body", body)
	}
	if err := validateNotification(payload); err != nil {
		return fail("usage", err.Error(), 2)
	}
	if encrypt {
		if _, exists := payload["ciphertext"]; exists {
			return fail("usage", "--encrypt cannot be combined with ciphertext or iv.", 2)
		}
		if _, exists := payload["iv"]; exists {
			return fail("usage", "--encrypt cannot be combined with ciphertext or iv.", 2)
		}
	}
	_, single := payload["device_key"]
	_, batch := payload["device_keys"]
	if !single && !batch {
		key := cfg.Key
		if cfg.KeyFile != "" {
			data, readErr := readFile(cfg.KeyFile, 64<<10)
			if readErr != nil {
				return fail("config", "Cannot read device key file (maximum 64 KiB).", 2)
			}
			key = strings.TrimSpace(string(data))
		}
		if strings.TrimSpace(key) == "" {
			return fail("config", "A device key or device_keys array is required.", 2)
		}
		set("device_key", key)
	}
	if err := validatePayload(payload); err != nil {
		return fail("usage", err.Error(), 2)
	}
	if raw, exists := payload["volume"]; exists {
		var numeric int
		if json.Unmarshal(raw, &numeric) == nil {
			set("volume", strconv.Itoa(numeric))
		}
	}
	if encrypt {
		payload, err = encryptPayload(payload, cfg)
		if err != nil {
			return fail("config", err.Error(), 2)
		}
	}
	data, _ := json.Marshal(payload)
	if len(data) > maxInput {
		return fail("usage", "Combined payload exceeds 1 MiB.", 2)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, endpoint, bytes.NewReader(data))
	if err != nil {
		return fail("config", "Cannot construct request for configured server.", 2)
	}
	req.Header.Set("Content-Type", "application/json")
	// This command sends once. Avoid the transport's idle-connection logger,
	// which can print unsolicited server bytes (including reflected secrets).
	req.Close = true
	client := &http.Client{Timeout: duration, CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
	response, err := client.Do(req)
	if err != nil {
		if ctx.Err() != nil {
			return fail("request", "Request timed out or was canceled.", 1)
		}
		return fail("request", "Request failed; check server connectivity and TLS configuration.", 1)
	}
	defer response.Body.Close()
	data, err = readLimited(response.Body, maxResponse)
	status := result{HTTPStatus: response.StatusCode}
	// Never return response messages or transport errors: either can reflect keys or URLs.
	if response.StatusCode < 200 || response.StatusCode >= 300 {
		status.Error, status.Message = "server", "Server returned an unsuccessful HTTP status."
		return emit(status, 1)
	}
	if err != nil {
		status.Error, status.Message = "server", "Server returned an invalid or oversized JSON response."
		return emit(status, 1)
	}
	status, exitCode := parseResponse(data, payload, response.StatusCode)
	return emit(status, exitCode)
}

func loadConfig(path string, explicit bool, opts config, seen map[string]bool) (config, error) {
	cfg := config{Server: "https://api.day.app", Timeout: "10s", EncryptionMode: "cbc"}
	if !explicit {
		if value, exists := os.LookupEnv("BARK_CONFIG"); exists {
			path, explicit = value, true
		} else {
			dir, err := os.UserConfigDir()
			if err != nil {
				return cfg, errors.New("Cannot locate user configuration directory; set --config.")
			}
			path = filepath.Join(dir, "bark-cli", "config.json")
		}
	}
	data, err := readFile(path, maxInput)
	if err != nil && (explicit || !errors.Is(err, os.ErrNotExist)) {
		return cfg, errors.New("Cannot read configuration file (maximum 1 MiB).")
	}
	if err == nil {
		if decodeObject(data, &cfg, "server", "key", "key_file", "timeout", "encryption_key_file", "encryption_mode") != nil {
			return cfg, errors.New("Configuration must contain only the documented lowercase fields and string values; use --help.")
		}
		if cfg.Key != "" && cfg.KeyFile != "" {
			return cfg, errors.New("Configuration must specify either key or key_file, not both.")
		}
	}
	if value, exists := os.LookupEnv("BARK_SERVER"); exists {
		cfg.Server = value
	}
	if value, exists := os.LookupEnv("BARK_KEY_FILE"); exists {
		cfg.KeyFile, cfg.Key = value, ""
	}
	if value, exists := os.LookupEnv("BARK_KEY"); exists {
		cfg.Key, cfg.KeyFile = value, ""
	}
	if seen["server"] {
		cfg.Server = opts.Server
	}
	if seen["key-file"] {
		cfg.KeyFile, cfg.Key = opts.KeyFile, ""
	}
	if seen["timeout"] {
		cfg.Timeout = opts.Timeout
	}
	if value, exists := os.LookupEnv("BARK_ENCRYPTION_KEY_FILE"); exists {
		cfg.EncryptionKeyFile = value
	}
	if value, exists := os.LookupEnv("BARK_ENCRYPTION_MODE"); exists {
		cfg.EncryptionMode = value
	}
	if seen["encryption-key-file"] {
		cfg.EncryptionKeyFile = opts.EncryptionKeyFile
	}
	if seen["encryption-mode"] {
		cfg.EncryptionMode = opts.EncryptionMode
	}
	return cfg, nil
}

func serverEndpoint(server string) (string, error) {
	u, err := url.Parse(server)
	if err != nil || (u.Scheme != "http" && u.Scheme != "https") || u.Hostname() == "" || u.User != nil || u.RawQuery != "" || u.ForceQuery || u.Fragment != "" || strings.Contains(server, "#") || u.Opaque != "" {
		return "", errors.New("invalid server")
	}
	u.Path = strings.TrimRight(u.Path, "/") + "/push"
	u.RawPath = ""
	return u.String(), nil
}

func decodeObject(data []byte, target any, allowedFields ...string) error {
	if trimmed := bytes.TrimSpace(data); len(trimmed) == 0 || trimmed[0] != '{' {
		return errors.New("expected object")
	}
	decoder := json.NewDecoder(bytes.NewReader(data))
	// Reject duplicate keys and nulls before decoding into either a map or struct.
	if _, err := decoder.Token(); err != nil {
		return err
	}
	seen := map[string]bool{}
	allowed := map[string]bool{}
	for _, name := range allowedFields {
		allowed[name] = true
	}
	for decoder.More() {
		token, err := decoder.Token()
		if err != nil {
			return err
		}
		name, ok := token.(string)
		if !ok || seen[name] {
			return errors.New("duplicate or invalid field")
		}
		// encoding/json matches struct names case-insensitively; configuration
		// accepts only the exact documented spelling, including before decoding.
		if len(allowed) != 0 && !allowed[name] {
			return errors.New("unsupported field")
		}
		seen[name] = true
		var value json.RawMessage
		if decoder.Decode(&value) != nil || bytes.Equal(bytes.TrimSpace(value), []byte("null")) {
			return errors.New("invalid field value")
		}
	}
	if _, err := decoder.Token(); err != nil {
		return err
	}
	decoder = json.NewDecoder(bytes.NewReader(data))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(target); err != nil {
		return err
	}
	var extra any
	if decoder.Decode(&extra) != io.EOF {
		return errors.New("trailing JSON")
	}
	return nil
}

func validatePayload(payload map[string]json.RawMessage) error {
	for name, raw := range payload {
		if bytes.Equal(bytes.TrimSpace(raw), []byte("null")) {
			return errors.New("Payload fields cannot be null.")
		}
		switch name {
		case "title", "subtitle", "body", "device_key", "level", "copy", "sound", "icon", "group", "ciphertext", "url", "action", "id", "markdown", "image", "iv":
			var value string
			if json.Unmarshal(raw, &value) != nil {
				return errors.New("Payload text fields must be strings.")
			}
			if name == "device_key" && strings.TrimSpace(value) == "" {
				return errors.New("device_key must be nonempty.")
			}
		case "call", "autoCopy", "isArchive", "delete":
			var value string
			if json.Unmarshal(raw, &value) != nil {
				var numeric int
				if json.Unmarshal(raw, &numeric) != nil {
					return errors.New("Switch fields must be strings or integers; 1 enables the option.")
				}
				value = strconv.Itoa(numeric)
			}
			payload[name], _ = json.Marshal(value)
		case "badge", "ttl":
			var value int
			if json.Unmarshal(raw, &value) != nil || (name == "ttl" && value < 0) {
				return errors.New("badge must be an integer; ttl must be a nonnegative integer.")
			}
		case "volume":
			var value int
			var text string
			if json.Unmarshal(raw, &text) == nil {
				var err error
				value, err = strconv.Atoi(text)
				if err != nil {
					return errors.New("volume must be an integer from 0 to 10, or its string representation.")
				}
			} else if json.Unmarshal(raw, &value) != nil {
				return errors.New("volume must be an integer from 0 to 10, or its string representation.")
			}
			if value < 0 || value > 10 {
				return errors.New("volume must be between 0 and 10.")
			}
		case "device_keys":
			var values []string
			if json.Unmarshal(raw, &values) != nil || len(values) == 0 {
				return errors.New("device_keys must be a nonempty array of nonempty strings.")
			}
			for _, value := range values {
				if strings.TrimSpace(value) == "" {
					return errors.New("device_keys must contain nonempty strings.")
				}
			}
		default:
			return errors.New("Unsupported JSON field; use --help for supported fields.")
		}
	}
	if _, single := payload["device_key"]; single {
		if _, batch := payload["device_keys"]; batch {
			return errors.New("Use either device_key or device_keys, not both.")
		}
	}
	return nil
}

func readFile(path string, limit int64) ([]byte, error) {
	// Open nonblocking before checking the descriptor: a pre-open path check
	// alone can race with replacement by a FIFO and hang outside the timeout.
	// All supported platforms (Linux and macOS) provide O_NONBLOCK.
	f, err := os.OpenFile(path, os.O_RDONLY|syscall.O_NONBLOCK, 0)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	info, err := f.Stat()
	if err != nil {
		return nil, err
	}
	if !info.Mode().IsRegular() {
		return nil, errors.New("expected a regular file")
	}
	return readLimited(f, limit)
}

func readLimited(reader io.Reader, limit int64) ([]byte, error) {
	data, err := io.ReadAll(io.LimitReader(reader, limit+1))
	if int64(len(data)) > limit {
		return nil, errors.New("input too large")
	}
	return data, err
}

func readInput(ctx context.Context, input io.Reader) ([]byte, error) {
	if input == nil {
		return nil, errors.New("stdin unavailable")
	}
	type readResult struct {
		data []byte
		err  error
	}
	ready := make(chan readResult, 1)
	go func() { data, err := readLimited(input, maxInput); ready <- readResult{data, err} }()
	select {
	case result := <-ready:
		return result.data, result.err
	case <-ctx.Done():
		return nil, ctx.Err()
	}
}
