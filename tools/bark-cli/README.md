# bark-cli

A small, original, MIT-licensed Go client for sending [Bark](https://github.com/Finb/Bark)
notifications. Standard library only. Every invocation prints one JSON object to
stdout, including help and failures. No configuration writes, background process,
automatic retries, or built-in agent/LLM integration.

```sh
bark-cli --version
# {"ok":true,"version":"0.1.0"}
bark-cli --help
bark-cli push --title 'Build complete' --group builds 'Ready to review'
printf 'Build log summary\n' | bark-cli push --title 'Build complete'
bark-cli push --body - < summary.txt
bark-cli push --json '{"body":"Hello","badge":5}' --badge 0
bark-cli push --json - < notification.json
```

Put flags before the positional body. Global flags may appear before `push` or
among its flags. `--body` and a positional body are mutually exclusive. An
explicit body overrides a JSON body; `-` reads stdin. Piped stdin is used
automatically only when neither a body nor `--json` is supplied. JSON stdin and
body stdin cannot be combined. A nonempty body is required; stdin newlines are
preserved. Text containing a leading dash can follow `--` or use `--body=TEXT`.

## Configuration

The optional default file is `bark-cli/config.json` under Go's user configuration
directory: `$XDG_CONFIG_HOME` or `~/.config` on Linux, and `~/Library/Application
Support` on macOS. Select another file using `--config PATH` or `BARK_CONFIG`.
An explicitly selected file must exist. Malformed files, unknown fields, null
fields, duplicate fields, and ambiguous credentials are rejected. Configuration
field names are case-sensitive and must use the exact lowercase names below.

```json
{
  "server": "https://api.day.app",
  "key_file": "/absolute/path/to/bark-device-key",
  "timeout": "10s"
}
```

Store the device key as plain text in a private file, readable only by your user
(for example, mode `0600`). A trailing newline is trimmed. The file is read at
runtime; it is never printed. Configuration can instead contain a `key` string,
but cannot contain both nonempty `key` and `key_file`. Relative key file paths
are resolved from the current working directory.

Defaults are `https://api.day.app` and `10s`. Precedence, from lowest to highest:

1. Defaults, then the selected configuration file.
2. `BARK_SERVER`; `BARK_KEY_FILE` replaces configured credentials; `BARK_KEY`
   replaces both configured and environment key files if both variables are set.
3. `--server`, `--key-file`, and `--timeout`. An explicit key file replaces the
   environment key. Timeout uses a positive Go duration such as `500ms` or `10s`.
4. Payload `device_key` or `device_keys` selects recipients directly. Default
   credentials and their key file are unused when either field is present.

An empty environment variable is an explicit override. There is no `--key` flag;
prefer a key file to avoid putting credentials in process arguments. Treat JSON
payloads with device keys as secrets as well; stdin avoids shell history exposure.

Self-hosted HTTP(S) servers and URL base paths are supported: `--server
http://127.0.0.1:8080/bark` sends to `/bark/push`. Server URLs containing userinfo,
queries, or fragments are rejected. Redirects are never followed.

## Payload and flags

`--json` accepts one object, either inline or from stdin with `--json -`. All
fields listed below are retained; unsupported fields fail with exit code 2.
Duplicate keys, nulls, and invalid types fail before flag overrides are applied.
Explicit flags override valid JSON fields, including empty strings and zero.

| JSON fields | Accepted types | CLI flags |
| --- | --- | --- |
| `title`, `body`, `subtitle`, `group`, `url`, `level`, `sound`, `id` | String | Same names |
| `badge` | Nonnegative integer | `--badge INT` |
| `volume` | Integer 0–10 or its string representation; sent as a string | `--volume INT` |
| `device_key` | Nonempty string | JSON only |
| `device_keys` | Nonempty array of nonempty strings | JSON only |
| `call`, `autoCopy`, `copy`, `icon`, `ciphertext`, `isArchive`, `action` | String | JSON only |
| `ttl` | Nonnegative integer | JSON only |

`level` values include `critical`, `active`, `timeSensitive`, and `passive`.
Server and client versions determine support for individual notification options,
including `id`. See the [Bark server API documentation](https://github.com/Finb/bark-server/blob/v2.3.5/docs/API_V2.md)
for option semantics. This client does not encrypt `ciphertext` for you.

## Results and limits

Success requires HTTP 2xx and an integer Bark `code` of 200:

```json
{"ok":true,"http_status":200,"code":200}
```

Failures contain `ok:false`, a stable category (`usage`, `config`, `request`, or
`server`), and a diagnostic `message`. Server failures also include `http_status`
and, when an HTTP-success response has a valid code, `code`. Exit status is 0 for
success/help/version, 2 for usage/configuration failures, and 1 for request/server
failures. Diagnostics never echo request data, server response text, device keys,
URLs, paths, or underlying transport errors. No stderr output is produced during
normal command handling.

Stdin, configuration, and the combined request are limited to 1 MiB; device key
files to 64 KiB; responses to 64 KiB. The timeout covers stdin and the HTTP
request after configuration is loaded. SIGINT/SIGTERM cancel that operation.
Input errors, including a stdin timeout, use exit 2. Filesystem reads are intended
for ordinary files. No notification is retried automatically.

## Development

Requires Go 1.25 or newer:

```sh
go test ./...
go vet ./...
go build -trimpath -ldflags="-s -w -X main.version=$(cat VERSION)" -o bark-cli .
```

Tests use local HTTP servers and include building and executing the production
binary for success, rejection, help, version, and usage failure. They do not send
real notifications. The [MIT license](LICENSE) applies to this tool directory
only, not to other software distributed by this tap.
