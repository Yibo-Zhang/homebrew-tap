package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestDocumentedPushFields(t *testing.T) {
	cleanEnv(t)
	received := make(chan map[string]any, 1)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var payload map[string]any
		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			t.Error(err)
		}
		received <- payload
		acceptedResponse(w, payload)
	}))
	defer server.Close()
	path := configFile(t, fmt.Sprintf(`{"server":%q,"key":"feature-secret"}`, server.URL))
	for _, tc := range []struct {
		name string
		args []string
		want map[string]any
	}{
		{"markdown only", []string{"--markdown", "**Done**"}, map[string]any{"markdown": "**Done**"}},
		{"image only", []string{"--image", "https://example.com/photo.png"}, map[string]any{"image": "https://example.com/photo.png"}},
		{"title only", []string{"--title", "Done"}, map[string]any{"title": "Done"}},
		{"delete only", []string{"--delete", "--id", "build-1"}, map[string]any{"delete": "1", "id": "build-1"}},
		{"pre-encrypted only", []string{"--ciphertext", "dummy-base64", "--iv", "1111111111111111"}, map[string]any{"ciphertext": "dummy-base64", "iv": "1111111111111111"}},
		{"all flags", []string{"--icon", "https://example.com/icon.png", "--copy", "copy me", "--action", "alert", "--call", "--auto-copy", "--archive", "--ttl=60", "--badge=-1", "hi"}, map[string]any{"body": "hi", "icon": "https://example.com/icon.png", "copy": "copy me", "action": "alert", "call": "1", "autoCopy": "1", "isArchive": "1", "ttl": float64(60), "badge": float64(-1)}},
		{"numeric JSON switches", []string{"--json", `{"body":"hi","delete":0,"isArchive":1,"call":0,"autoCopy":1}`}, map[string]any{"body": "hi", "delete": "0", "isArchive": "1", "call": "0", "autoCopy": "1"}},
		{"false overrides JSON", []string{"--json", `{"body":"hi","delete":"1","call":1,"autoCopy":1,"isArchive":1,"ttl":99}`, "--delete=false", "--call=false", "--auto-copy=false", "--archive=false", "--ttl=0"}, map[string]any{"body": "hi", "delete": "0", "call": "0", "autoCopy": "0", "isArchive": "0", "ttl": float64(0)}},
	} {
		t.Run(tc.name, func(t *testing.T) {
			code, got, output := invoke(t, append([]string{"--config", path, "push"}, tc.args...), nil)
			if code != 0 || !got.OK {
				t.Fatalf("exit=%d %s", code, output)
			}
			actual := <-received
			tc.want["device_key"] = "feature-secret"
			a, _ := json.Marshal(actual)
			b, _ := json.Marshal(tc.want)
			if string(a) != string(b) {
				t.Fatalf("got %s want %s", a, b)
			}
		})
	}
}

func TestContentValidationBeforeHTTP(t *testing.T) {
	cleanEnv(t)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { t.Error("invalid input reached server") }))
	defer server.Close()
	path := configFile(t, fmt.Sprintf(`{"server":%q,"key":"validation-secret"}`, server.URL))
	for _, payload := range []string{
		`{}`, `{"markdown":""}`, `{"delete":1}`, `{"delete":1,"id":""}`, `{"body":"hi","image":1}`,
		`{"body":"hi","iv":"secret"}`, `{"ciphertext":"secret","body":"private"}`,
		`{"body":"hi","call":true}`, `{"body":"hi","delete":2.5}`, `{"body":"hi","isArchive":[]}`,
		`{"body":"hi","device_key":"a-secret","device_keys":["b-secret"]}`,
	} {
		code, got, output := invoke(t, []string{"--config", path, "push", "--json", payload}, nil)
		if code != 2 || got.OK || strings.Contains(output, "secret") {
			t.Errorf("exit=%d %s", code, output)
		}
	}
}

func TestBatchResponseValidation(t *testing.T) {
	cleanEnv(t)
	for _, tc := range []struct {
		name, response string
		exit           int
		codes          []int
	}{
		{"all success reordered", `{"code":200,"data":[{"device_key":"second-secret","code":200},{"device_key":"first-secret","code":200}]}`, 0, []int{200, 200}},
		{"partial failure reordered", `{"code":200,"data":[{"device_key":"second-secret","code":400,"message":"first-secret second-secret"},{"device_key":"first-secret","code":200}]}`, 1, []int{200, 400}},
		{"all failed", `{"code":200,"data":[{"device_key":"first-secret","code":400},{"device_key":"second-secret","code":500}]}`, 1, []int{400, 500}},
		{"missing data", `{"code":200}`, 1, nil},
		{"null data", `{"code":200,"data":null}`, 1, nil},
		{"empty data", `{"code":200,"data":[]}`, 1, nil},
		{"missing result", `{"code":200,"data":[{"device_key":"first-secret","code":200}]}`, 1, nil},
		{"duplicate recipient", `{"code":200,"data":[{"device_key":"first-secret","code":200},{"device_key":"first-secret","code":200}]}`, 1, nil},
		{"unknown recipient", `{"code":200,"data":[{"device_key":"first-secret","code":200},{"device_key":"other-secret","code":200}]}`, 1, nil},
		{"missing recipient", `{"code":200,"data":[{"code":200},{"device_key":"second-secret","code":200}]}`, 1, nil},
		{"bad result type", `{"code":200,"data":[{"device_key":"first-secret","code":"200"},{"device_key":"second-secret","code":200}]}`, 1, nil},
		{"null entry", `{"code":200,"data":[null,{"device_key":"second-secret","code":200}]}`, 1, nil},
		{"duplicate top code", `{"code":400,"code":200}`, 1, nil},
		{"duplicate item code", `{"code":200,"data":[{"device_key":"first-secret","code":400,"code":200},{"device_key":"second-secret","code":200}]}`, 1, nil},
	} {
		t.Run(tc.name, func(t *testing.T) {
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { fmt.Fprint(w, tc.response) }))
			defer server.Close()
			path := configFile(t, fmt.Sprintf(`{"server":%q,"key_file":"/nonexistent-secret"}`, server.URL))
			code, got, output := invoke(t, []string{"--config", path, "push", "--json", `{"body":"hi","device_keys":["first-secret","second-secret"]}`}, nil)
			if code != tc.exit || got.OK != (tc.exit == 0) || len(got.Results) != len(tc.codes) || strings.Contains(output, "secret") {
				t.Fatalf("exit=%d %s", code, output)
			}
			for i, want := range tc.codes {
				if got.Results[i].Index != i || got.Results[i].Code != want || got.Results[i].OK != (want == 200) {
					t.Fatalf("bad per-recipient result: %s", output)
				}
			}
		})
	}
}

func TestHelpIsSelfContained(t *testing.T) {
	code, got, _ := invoke(t, []string{"push", "--help"}, nil)
	if code != 0 || !got.OK {
		t.Fatal("help failed")
	}
	for _, term := range []string{"--markdown", "--image", "--delete", "--encrypt", "--encryption-key-file", "device_keys", "autoCopy", "isArchive", "BARK_CONFIG", "config.json", "zero-based", "Exit 1", "--archive=false", "bark-cli push"} {
		if !strings.Contains(got.Help, term) {
			t.Errorf("help missing %s", term)
		}
	}
}
