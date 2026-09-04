package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

func cleanEnv(t *testing.T) {
	t.Helper()
	for _, name := range []string{"BARK_CONFIG", "BARK_SERVER", "BARK_KEY", "BARK_KEY_FILE"} {
		old, existed := os.LookupEnv(name)
		os.Unsetenv(name)
		t.Cleanup(func() {
			if existed {
				os.Setenv(name, old)
			} else {
				os.Unsetenv(name)
			}
		})
	}
}

func configFile(t *testing.T, content string) string {
	t.Helper()
	path := filepath.Join(t.TempDir(), "config.json")
	if err := os.WriteFile(path, []byte(content), 0600); err != nil {
		t.Fatal(err)
	}
	return path
}

func invoke(t *testing.T, args []string, input io.Reader) (int, result, string) {
	t.Helper()
	var out bytes.Buffer
	code := run(context.Background(), args, input, &out)
	var decoded result
	if err := json.Unmarshal(out.Bytes(), &decoded); err != nil {
		t.Fatalf("not one JSON result: %q: %v", out.String(), err)
	}
	return code, decoded, out.String()
}

func TestPushPrecedenceAndStdin(t *testing.T) {
	cleanEnv(t)
	received := make(chan map[string]any, 1)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != "POST" || r.URL.Path != "/base/push" || r.Header.Get("Content-Type") != "application/json" {
			t.Errorf("unexpected request: %s %s", r.Method, r.URL.Path)
		}
		var payload map[string]any
		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			t.Error(err)
		}
		received <- payload
		fmt.Fprint(w, `{"code":200,"message":"secret reflected content"}`)
	}))
	defer server.Close()
	path := configFile(t, fmt.Sprintf(`{"server":%q,"key":"default-secret"}`, server.URL+"/base/"))
	cases := []struct {
		name  string
		args  []string
		input string
		want  map[string]any
	}{
		{"flags override JSON", []string{"--json", `{"body":"json body","title":"old","badge":9,"volume":8,"id":"old"}`, "--title=", "--badge=0", "--volume=0", "--id=new", "positional"}, "", map[string]any{"body": "positional", "title": "", "badge": float64(0), "volume": "0", "id": "new", "device_key": "default-secret"}},
		{"piped body", nil, "piped\nbody\n", map[string]any{"body": "piped\nbody\n", "device_key": "default-secret"}},
		{"explicit stdin", []string{"--body", "-"}, "explicit", map[string]any{"body": "explicit", "device_key": "default-secret"}},
		{"JSON stdin batch", []string{"--json", "-"}, `{"body":"batch","device_keys":["one-secret","two-secret"],"ttl":0,"autoCopy":"1"}`, map[string]any{"body": "batch", "device_keys": []any{"one-secret", "two-secret"}, "ttl": float64(0), "autoCopy": "1"}},
		{"JSON single", []string{"--json", `{"body":"single","device_key":"override-secret"}`}, "", map[string]any{"body": "single", "device_key": "override-secret"}},
		{"JSON numeric volume", []string{"--json", `{"body":"volume","volume":8}`}, "", map[string]any{"body": "volume", "volume": "8", "device_key": "default-secret"}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			args := append([]string{"--config", path, "push"}, tc.args...)
			code, got, output := invoke(t, args, strings.NewReader(tc.input))
			if code != 0 || !got.OK || got.Code == nil || *got.Code != 200 {
				t.Fatalf("code=%d: %s", code, output)
			}
			payload := <-received
			actual, _ := json.Marshal(payload)
			expected, _ := json.Marshal(tc.want)
			if string(actual) != string(expected) {
				t.Fatalf("payload=%s want=%s", actual, expected)
			}
			if strings.Contains(output, "secret") {
				t.Fatalf("secret output: %s", output)
			}
		})
	}
}

func TestFailuresAreJSONAndDoNotReflectSecrets(t *testing.T) {
	cleanEnv(t)
	for _, tc := range []struct {
		name     string
		status   int
		response string
	}{
		{"HTTP", 401, `{"code":200,"message":"one-secret two-secret https://credentials.example"}`},
		{"business", 200, `{"code":400,"message":"one-secret two-secret"}`},
		{"invalid", 200, "one-secret two-secret"},
		{"absent code", 200, `{"message":"one-secret"}`},
		{"oversize", 200, strings.Repeat("one-secret", maxResponse)},
	} {
		t.Run(tc.name, func(t *testing.T) {
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { w.WriteHeader(tc.status); fmt.Fprint(w, tc.response) }))
			defer server.Close()
			path := configFile(t, fmt.Sprintf(`{"server":%q}`, server.URL))
			code, got, output := invoke(t, []string{"push", "--config", path, "--json", `{"body":"hi","device_keys":["one-secret","two-secret"]}`}, nil)
			if code != 1 || got.OK || got.HTTPStatus != tc.status {
				t.Fatalf("code=%d: %s", code, output)
			}
			if strings.Contains(output, "secret") || strings.Contains(output, "https://") {
				t.Fatalf("unsafe diagnostic: %s", output)
			}
		})
	}
}

func TestInvalidInput(t *testing.T) {
	cleanEnv(t)
	path := configFile(t, `{}`)
	for _, payload := range []string{
		`[]`, `null`, `{"body":1}`, `{"body":"x","unknown-secret":"x"}`, `{"body":"x","badge":"0"}`,
		`{"body":"x","device_keys":[]}`, `{"body":"x","device_keys":[null]}`, `{"body":"x","device_keys":[1]}`,
		`{"body":"x","device_key":null}`, `{"body":"x","device_key":" "}`, `{"body":"x","volume":11}`,
		`{"body":"x","ttl":-1}`, `{"body":"x","body":"duplicate"}`, `{"body":"x"} {}`, `{`,
	} {
		code, got, output := invoke(t, []string{"push", "--config", path, "--json", payload}, nil)
		if code != 2 || got.OK || got.Error != "usage" || strings.Contains(output, "secret") {
			t.Errorf("payload=%s code=%d output=%s", payload, code, output)
		}
	}
	for _, args := range [][]string{
		{"push", "--config", path, "--badge=secret", "body"},
		{"push", "--config", path, "--body", "one", "two"},
		{"push", "--config", path, "one", "--title", "later"},
		{"push", "--config", path, "--json", "-", "--body", "-"},
		{"push", "--config", path, "--json", `{"body":"x"}`, "--body="},
		{"unknown-secret"},
	} {
		code, got, output := invoke(t, args, strings.NewReader(`{"body":"x"}`))
		if code != 2 || got.OK || got.Error != "usage" || strings.Contains(output, "secret") {
			t.Errorf("code=%d output=%s", code, output)
		}
	}
}

func TestConfiguration(t *testing.T) {
	cleanEnv(t)
	for _, configText := range []string{`{}`, `{"key":"a","key_file":"b"}`, `{"timeout":"0s"}`, `{"key_file":"/missing/bark-secret"}`, `{"secret":"x"}`, `{"key":null}`, `[]`, `{broken`} {
		path := configFile(t, configText)
		code, got, output := invoke(t, []string{"push", "--config", path, "hello"}, nil)
		if code != 2 || got.Error != "config" || strings.Contains(output, "secret") {
			t.Errorf("config=%s code=%d %s", configText, code, output)
		}
	}
	code, _, _ := invoke(t, []string{"push", "--config", filepath.Join(t.TempDir(), "missing"), "hello"}, nil)
	if code != 2 {
		t.Fatal("explicit missing config accepted")
	}
	for _, server := range []string{"https://key-secret@example.com", "https://example.com?key=secret", "https://example.com/#secret", "https://example.com/#", "file:///tmp/key-secret"} {
		path := configFile(t, `{}`)
		code, _, output := invoke(t, []string{"push", "--config", path, "--server", server, "hello"}, nil)
		if code != 2 || strings.Contains(output, "secret") {
			t.Errorf("unsafe URL accepted/leaked: %s", output)
		}
	}
}

func TestConfigOverridesAndBatchSkipsKeyFile(t *testing.T) {
	cleanEnv(t)
	received := make(chan map[string]any, 1)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var payload map[string]any
		json.NewDecoder(r.Body).Decode(&payload)
		received <- payload
		fmt.Fprint(w, `{"code":200}`)
	}))
	defer server.Close()
	path := configFile(t, `{"server":"https://unused.invalid","key":"config-secret"}`)
	t.Setenv("BARK_CONFIG", path)
	t.Setenv("BARK_SERVER", server.URL)
	t.Setenv("BARK_KEY_FILE", "/missing/key-secret")
	t.Setenv("BARK_KEY", "environment-secret")
	code, _, output := invoke(t, []string{"push", "hello"}, nil)
	if code != 0 {
		t.Fatal(output)
	}
	if (<-received)["device_key"] != "environment-secret" {
		t.Fatal("environment key did not win")
	}
	keyFile := configFile(t, "file-secret\n")
	code, _, output = invoke(t, []string{"push", "--key-file", keyFile, "hello"}, nil)
	if code != 0 {
		t.Fatal(output)
	}
	if (<-received)["device_key"] != "file-secret" {
		t.Fatal("flag key file did not win")
	}
	code, _, output = invoke(t, []string{"push", "--key-file", "/missing/key-secret", "--json", `{"body":"hi","device_keys":["batch-secret"]}`}, nil)
	if code != 0 {
		t.Fatal(output)
	}
	if _, exists := (<-received)["device_key"]; exists {
		t.Fatal("batch acquired default key")
	}
}

func TestConfigFieldNames(t *testing.T) {
	cleanEnv(t)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, `{"code":200}`)
	}))
	defer server.Close()
	for _, fields := range []string{
		`"KEY":"uppercase-secret"`,
		`"key":"first-secret","KEY":"second-secret"`,
		`"KEY":"first-secret","key":"second-secret"`,
	} {
		path := configFile(t, fmt.Sprintf(`{"server":%q,%s}`, server.URL, fields))
		code, got, output := invoke(t, []string{"push", "--config", path, "hello"}, nil)
		if code != 2 || got.Error != "config" || strings.Contains(output, "secret") {
			t.Errorf("noncanonical configuration fields: exit=%d output=%s", code, output)
		}
	}
}

func TestTimeoutCancellationAndRedirect(t *testing.T) {
	cleanEnv(t)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(100 * time.Millisecond)
		fmt.Fprint(w, `{"code":200}`)
	}))
	defer server.Close()
	path := configFile(t, fmt.Sprintf(`{"server":%q,"key":"secret"}`, server.URL))
	code, got, output := invoke(t, []string{"push", "--config", path, "--timeout", "10ms", "hello"}, nil)
	if code != 1 || got.Error != "request" {
		t.Fatalf("timeout: %d %s", code, output)
	}
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	var out bytes.Buffer
	if code := run(ctx, []string{"push", "--config", path, "hello"}, nil, &out); code != 1 {
		t.Fatalf("cancel: %d %s", code, out.String())
	}
	reader, writer := io.Pipe()
	defer reader.Close()
	defer writer.Close()
	code, _, _ = invoke(t, []string{"push", "--config", path, "--timeout", "10ms", "--body", "-"}, reader)
	if code != 2 {
		t.Fatalf("stdin timeout exit = %d", code)
	}
	target := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Error("redirect was followed")
		fmt.Fprint(w, `{"code":200}`)
	}))
	defer target.Close()
	redirect := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, target.URL, http.StatusTemporaryRedirect)
	}))
	defer redirect.Close()
	code, got, output = invoke(t, []string{"push", "--config", path, "--server", redirect.URL, "hello"}, nil)
	if code != 1 || got.HTTPStatus != 307 {
		t.Fatalf("redirect: %d %s", code, output)
	}
}

func TestInputBound(t *testing.T) {
	cleanEnv(t)
	path := configFile(t, `{}`)
	code, _, _ := invoke(t, []string{"push", "--config", path}, strings.NewReader(strings.Repeat("a", maxInput+1)))
	if code != 2 {
		t.Fatal("oversized stdin accepted")
	}
}

// Build and invoke the untouched production main, not a test-process helper.
func TestRealBinary(t *testing.T) {
	cleanEnv(t)
	binary := filepath.Join(t.TempDir(), "bark-cli")
	build := exec.Command("go", "build", "-ldflags=-X main.version=0.1.0", "-o", binary, ".")
	if output, err := build.CombinedOutput(); err != nil {
		t.Fatalf("build: %v: %s", err, output)
	}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var payload map[string]any
		json.NewDecoder(r.Body).Decode(&payload)
		if payload["device_key"] != "binary-secret" {
			t.Error("missing binary credential")
		}
		if payload["body"] == "reject" {
			w.WriteHeader(403)
			fmt.Fprint(w, "binary-secret")
			return
		}
		if payload["body"] == "trailing" {
			// Write raw HTTP with unsolicited bytes outside the declared body.
			// The default transport can log these bytes while reusing a connection.
			conn, wire, err := w.(http.Hijacker).Hijack()
			if err != nil {
				t.Error(err)
				return
			}
			defer conn.Close()
			fmt.Fprint(wire, "HTTP/1.1 200 OK\r\nContent-Length: 12\r\n\r\n"+`{"code":200}`+"dummy-reflected-secret")
			if err := wire.Flush(); err != nil {
				t.Error(err)
			}
			return
		}
		fmt.Fprint(w, `{"code":200}`)
	}))
	defer server.Close()
	path := configFile(t, fmt.Sprintf(`{"server":%q,"key":"binary-secret"}`, server.URL))
	for _, tc := range []struct {
		args []string
		exit int
	}{
		{[]string{"--version"}, 0}, {[]string{"--help"}, 0},
		{[]string{"push", "--config", path, "--title", "subprocess", "success"}, 0},
		{[]string{"push", "--config", path, "reject"}, 1},
		{[]string{"push", "--config", path, "trailing"}, 0},
		{[]string{"push", "--config", path, "--badge=bad-secret", "reject"}, 2},
	} {
		cmd := exec.Command(binary, tc.args...)
		var stdout, stderr bytes.Buffer
		cmd.Stdout, cmd.Stderr = &stdout, &stderr
		err := cmd.Run()
		exit := 0
		if err != nil {
			if ee, ok := err.(*exec.ExitError); ok {
				exit = ee.ExitCode()
			} else {
				t.Fatal(err)
			}
		}
		var decoded result
		if exit != tc.exit || json.Unmarshal(stdout.Bytes(), &decoded) != nil || stderr.Len() != 0 || strings.Contains(stdout.String(), "secret") {
			t.Fatalf("exit=%d expected=%d stdout=%s stderr=%s", exit, tc.exit, &stdout, &stderr)
		}
		if tc.args[0] == "--version" && (!decoded.OK || decoded.Version != "0.1.0") {
			t.Fatal(stdout.String())
		}
	}
}
