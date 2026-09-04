# bark-cli

A small, original, MIT-licensed Go client for [Bark](https://github.com/Finb/Bark).
Standard library only, with one JSON result per command and meaningful exit
codes for agents and scripts. Supports Apple Silicon macOS and Linux amd64/arm64.

```sh
brew install Yibo-Zhang/tap/bark-cli
bark-cli --help
bark-cli push --title 'Task complete' --group agent 'Build and tests passed'
printf 'Build log summary\n' | bark-cli push --title 'Summary'
bark-cli push --markdown '**Done**' --image https://example.com/result.png
bark-cli push --id build-42 'Started'
bark-cli push --id build-42 'Finished'
bark-cli push --delete --id build-42
```

Put flags **before** the positional body. Boolean flags such as `--archive`
take no following value; use `--archive=false` to explicitly disable them.
Markdown, images, existing ciphertext and deletion requests do not require a
dummy body. Deletion requires an ID and the app's Background App Refresh.

The complete option, JSON-field, configuration, result and example reference is
[help.txt](https://github.com/Yibo-Zhang/homebrew-tap/blob/main/tools/bark-cli/help.txt).
It is embedded in the binary: **`bark-cli --help` works without this repository or
network access**. Agents with terminal access can discover the supported syntax
there. No separate MCP server, agent framework or automatic notification hook
is required; the caller decides when to send a notification.

## Configuration

Default file: `~/.config/bark-cli/config.json` on Linux (or
`$XDG_CONFIG_HOME/bark-cli/config.json`), and
`~/Library/Application Support/bark-cli/config.json` on macOS.

```json
{
  "server": "https://api.day.app",
  "key_file": "/absolute/private/bark-device-key",
  "timeout": "10s"
}
```

Keep the device key in a private file, for example mode `0600`. The CLI reads
configuration and keys at runtime; it never writes them or registers devices.
It accepts `key` instead of `key_file`, but not both nonempty. Configuration
fields are case-sensitive. Relative key paths resolve from the working directory.

Precedence: defaults < config < environment < explicit flags. `--config` or
`BARK_CONFIG` selects another file. Environment overrides are `BARK_SERVER`,
`BARK_KEY_FILE` and `BARK_KEY` (the latter wins over the former). `--key-file`
overrides both environment credentials. Explicit JSON `device_key` or
`device_keys` replaces the default recipient and skips loading its key file.

## Advanced payloads and batch results

All fields in the [official push parameter reference](https://github.com/Finb/Bark/blob/master/docs/en-us/tutorial.md)
are supported. Use `--json STRING` or `--json -` for a JSON payload. Unknown
fields, wrong types, duplicates and nulls fail with exit 2. Explicit flags
override valid JSON, including zero, empty strings and false.

```sh
bark-cli push --json '{"body":"Hello","badge":5,"isArchive":1}' --badge 0
bark-cli push --json - < notification.json
```

Batch JSON uses `device_keys: ["KEY_A", "KEY_B"]`; keep such inputs private.
The CLI checks every recipient's result and matches it to the input array,
even when the server returns results out of order. A partial failure exits 1:

```json
{
  "ok": false,
  "http_status": 200,
  "code": 200,
  "error": "server",
  "message": "At least one notification failed; inspect results by input index.",
  "results": [
    {"index": 0, "ok": true, "code": 200},
    {"index": 1, "ok": false, "code": 400}
  ]
}
```

Indices are zero-based. Device keys and raw server messages are never included
in output. Missing, malformed or unmatched results fail closed. A success is
service acceptance, not proof that someone read the notification. Requests are
never retried automatically; choose failed recipients deliberately to avoid
duplicate notifications after an uncertain or partial result.

## Encrypted notifications

Match the encryption mode and key configured in the Bark app. The AES key is
separate from the device key: store its exact printable ASCII bytes in a private file
(16/24/32 bytes for AES-128/192/256, with one optional trailing LF or CRLF).

```sh
bark-cli push --encrypt --encryption-key-file /private/bark-aes-key \
  --encryption-mode cbc --title 'Private result' 'Build passed'
```

Modes are `cbc` (default), `ecb` and `gcm`, matching Bark's implementation.
Match the app's padding: CBC/ECB use PKCS#7 and GCM uses no padding. CBC/GCM
send a fresh per-message ASCII `iv` (16/12 characters respectively). GCM
encodes ciphertext followed by its 16-byte tag; the nonce is sent separately.
ECB supports existing app configurations. Recipients and routing `id`/`delete`
remain outside; `id`/`delete` are also preserved inside for app processing.
Batch recipients must use the same encryption settings and key.

Optional config fields `encryption_key_file` and `encryption_mode`, or
environment variables `BARK_ENCRYPTION_KEY_FILE` and `BARK_ENCRYPTION_MODE`,
provide defaults. **Encryption still requires `--encrypt` on the command.**
Invalid keys/modes fail before HTTP. Existing ciphertext can be sent with
`--ciphertext` and an optional `--iv` instead of `--encrypt`; only recipients
and `id`/`delete` routing fields can accompany existing ciphertext.

## Results and limits

All output, including help and errors, is one JSON object on stdout. Normal
stderr is empty. Exit 0 means success/help/version, 2 means usage/configuration
failure, and 1 means request/server failure. A single success is:

```json
{"ok":true,"http_status":200,"code":200}
```

Stdin, configuration and the combined wire request are limited to 1 MiB;
responses and key files to 64 KiB. Bark/APNs can impose a smaller payload limit.
The timeout covers stdin and HTTP after configuration loads. SIGINT/SIGTERM
cancels the operation. Self-hosted HTTP(S) and URL base paths work; redirects
are disabled and URL userinfo, queries and fragments are rejected.
Config/key files must be regular files, including symlinks to regular files;
FIFOs, devices and directories are rejected without waiting for a writer.

## Development

Requires Go 1.25 or newer:

```sh
go test ./...
go vet ./...
go build -trimpath -ldflags="-s -w -X main.version=$(cat VERSION)" -o bark-cli .
```

Tests use local mock HTTP servers and dummy credentials, including encrypted
wire compatibility, reordered/partial batch responses and production-binary
execution. They do not send real notifications. The [MIT license](LICENSE)
applies only to this tool directory.
