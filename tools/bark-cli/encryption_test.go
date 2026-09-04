package main

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestEncryptionCompatibilityVectors(t *testing.T) {
	// CBC is the published Finb/Bark docs/en-us/encryption.md example. ECB
	// and GCM were independently calculated with OpenSSL/Python cryptography.
	plain := []byte(`{"body": "test", "sound": "birdsong"}`)
	key := []byte("1234567890123456")
	for _, tc := range []struct{ mode, iv, want string }{
		{"cbc", "1111111111111111", "d3QhjQjP5majvNt5CjsvFWwqqj2gKl96RFj5OO+u6ynTt7lkyigDYNA3abnnCLpr"},
		{"ecb", "", "nyEyuyYwoV+3IkEm9QUUzAOy8Je44anatLeIjsP2cnKV7j1c3K4CXoWCF2gES5SK"},
		{"gcm", "111111111111", "6tYNu2g3cLxgtGfoTkrAowzP4jSygr/U3UIWl4eWBJz6prKiIRx/F3qhojjqnwAq/9HT7yQ="},
	} {
		t.Run(tc.mode, func(t *testing.T) {
			got, err := encryptBytes(plain, key, tc.mode, []byte(tc.iv))
			if err != nil || base64.StdEncoding.EncodeToString(got) != tc.want {
				t.Fatalf("incompatible %s encryption: %v", tc.mode, err)
			}
		})
	}
}

func decryptWire(t *testing.T, wire map[string]json.RawMessage, key []byte, mode string) map[string]json.RawMessage {
	t.Helper()
	ct, err := base64.StdEncoding.DecodeString(payloadText(wire, "ciphertext"))
	if err != nil {
		t.Fatal(err)
	}
	iv := []byte(payloadText(wire, "iv"))
	block, err := aes.NewCipher(key)
	if err != nil {
		t.Fatal(err)
	}
	var plain []byte
	if mode == "gcm" {
		if len(iv) != 12 {
			t.Fatal("GCM IV must be twelve ASCII bytes")
		}
		gcm, err := cipher.NewGCM(block)
		if err != nil {
			t.Fatal(err)
		}
		plain, err = gcm.Open(nil, iv, ct, nil)
		if err != nil {
			t.Fatal(err)
		}
		// The combined authentication tag must reject tampering.
		ct[len(ct)-1] ^= 1
		if _, err := gcm.Open(nil, iv, ct, nil); err == nil {
			t.Fatal("GCM tag failed to detect tampering")
		}
	} else {
		if len(ct) == 0 || len(ct)%aes.BlockSize != 0 {
			t.Fatal("invalid CBC/ECB ciphertext size")
		}
		plain = make([]byte, len(ct))
		if mode == "cbc" {
			if len(iv) != 16 {
				t.Fatal("CBC IV must be sixteen ASCII bytes")
			}
			cipher.NewCBCDecrypter(block, iv).CryptBlocks(plain, ct)
		} else {
			if _, exists := wire["iv"]; exists {
				t.Fatal("ECB must not send IV")
			}
			for offset := 0; offset < len(ct); offset += aes.BlockSize {
				block.Decrypt(plain[offset:offset+aes.BlockSize], ct[offset:offset+aes.BlockSize])
			}
		}
		padding := int(plain[len(plain)-1])
		if padding < 1 || padding > 16 || !bytes.Equal(plain[len(plain)-padding:], bytes.Repeat([]byte{byte(padding)}, padding)) {
			t.Fatal("invalid PKCS#7 padding")
		}
		plain = plain[:len(plain)-padding]
	}
	var decoded map[string]json.RawMessage
	if err := json.Unmarshal(plain, &decoded); err != nil {
		t.Fatal(err)
	}
	return decoded
}

func TestEncryptedPushWireAndRouting(t *testing.T) {
	cleanEnv(t)
	received := make(chan map[string]json.RawMessage, 1)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var payload map[string]json.RawMessage
		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			t.Error(err)
		}
		received <- payload
		fmt.Fprint(w, `{"code":200}`)
	}))
	defer server.Close()
	for _, mode := range []string{"cbc", "ecb", "gcm"} {
		for _, keySize := range []int{16, 24, 32} {
			t.Run(fmt.Sprintf("%s/%d", mode, keySize), func(t *testing.T) {
				key := strings.Repeat("k", keySize)
				keyPath := configFile(t, key+"\n")
				path := configFile(t, fmt.Sprintf(`{"server":%q,"key":"device-secret","encryption_key_file":%q,"encryption_mode":%q}`, server.URL, keyPath, mode))
				input := `{"body":"private-secret-body","title":"private-secret-title","markdown":"**private-secret**","image":"https://private-secret.example/image","group":"private-secret-group","badge":-1,"sound":"birdsong","id":"routing-id"}`
				var previousIV string
				for attempt := 0; attempt < 2; attempt++ {
					code, got, output := invoke(t, []string{"--config", path, "push", "--encrypt", "--json", input}, nil)
					if code != 0 || !got.OK || strings.Contains(output, "secret") {
						t.Fatalf("exit=%d %s", code, output)
					}
					wire := <-received
					for name := range wire {
						switch name {
						case "device_key", "id", "ciphertext", "iv":
						default:
							t.Errorf("plaintext field leaked: %s", name)
						}
					}
					if payloadText(wire, "device_key") != "device-secret" || payloadText(wire, "id") != "routing-id" {
						t.Fatal("routing fields missing")
					}
					iv := payloadText(wire, "iv")
					if mode != "ecb" && attempt > 0 && previousIV == iv {
						t.Fatal("IV reused")
					}
					previousIV = iv
					decoded := decryptWire(t, wire, []byte(key), mode)
					actual, _ := json.Marshal(decoded)
					var want map[string]json.RawMessage
					_ = json.Unmarshal([]byte(input), &want)
					expected, _ := json.Marshal(want)
					if !bytes.Equal(actual, expected) {
						t.Fatal("encrypted notification lost fields")
					}
				}
			})
		}
	}
	keyPath := configFile(t, "1234567890123456\r\n")
	path := configFile(t, fmt.Sprintf(`{"server":%q,"key":"device-secret","encryption_key_file":%q}`, server.URL, keyPath))
	code, _, output := invoke(t, []string{"--config", path, "push", "--encrypt", "--delete", "--id", "routing-id"}, nil)
	if code != 0 {
		t.Fatal(output)
	}
	wire := <-received
	inner := decryptWire(t, wire, []byte("1234567890123456"), "cbc")
	for _, name := range []string{"id", "delete"} {
		if len(wire[name]) == 0 || !bytes.Equal(wire[name], inner[name]) {
			t.Fatalf("encrypted deletion lost routing %s", name)
		}
	}
}

func TestEncryptionValidationAndOverrides(t *testing.T) {
	cleanEnv(t)
	requests := 0
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { requests++; fmt.Fprint(w, `{"code":200}`) }))
	defer server.Close()
	path := configFile(t, fmt.Sprintf(`{"server":%q,"key":"device-secret"}`, server.URL))
	validKey := configFile(t, "1234567890123456")
	for _, args := range [][]string{
		{"--encrypt", "hello"},
		{"--encrypt", "--encryption-key-file", configFile(t, "short-secret"), "hello"},
		{"--encrypt", "--encryption-key-file", configFile(t, strings.Repeat("é", 8)), "hello"},
		{"--encrypt", "--encryption-key-file", validKey, "--encryption-mode", "unknown-secret", "hello"},
		{"--encrypt", "--encryption-key-file", validKey, "--ciphertext", "secret-ciphertext"},
		{"--encrypt", "--encryption-key-file", validKey, "--iv", "secret-iv", "hello"},
	} {
		code, got, output := invoke(t, append([]string{"--config", path, "push"}, args...), nil)
		if code != 2 || got.OK || strings.Contains(output, "secret") {
			t.Errorf("exit=%d %s", code, output)
		}
	}
	if requests != 0 {
		t.Fatalf("invalid encryption sent %d requests", requests)
	}
	t.Setenv("BARK_ENCRYPTION_KEY_FILE", "/missing/secret")
	t.Setenv("BARK_ENCRYPTION_MODE", "unknown-secret")
	code, _, output := invoke(t, []string{"--config", path, "push", "--encrypt", "--encryption-key-file", validKey, "--encryption-mode", "GCM", "hi"}, nil)
	if code != 0 {
		t.Fatal(output)
	}
	code, _, output = invoke(t, []string{"--config", path, "push", "plain"}, nil)
	if code != 0 {
		t.Fatal("unused encryption settings prevented plaintext push:", output)
	}
}
