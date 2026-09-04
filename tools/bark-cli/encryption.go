package main

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"errors"
	"strings"
)

// Bark uses UTF-8 strings and validates both character and AES byte lengths.
// Printable ASCII keys/IVs satisfy both. Its GCM combined format is ciphertext
// followed by the authentication tag, with the IV sent separately (no AAD).
// See Finb/Bark Model/Algorithm.swift and Controller/CryptoSettingViewModel.swift.
func encryptPayload(payload map[string]json.RawMessage, cfg config) (map[string]json.RawMessage, error) {
	key, err := readFile(cfg.EncryptionKeyFile, 64<<10)
	if err != nil {
		return nil, errors.New("Cannot read encryption key file; use --encryption-key-file or configure encryption_key_file.")
	}
	if bytes.HasSuffix(key, []byte("\r\n")) {
		key = bytes.TrimSuffix(key, []byte("\r\n"))
	} else {
		key = bytes.TrimSuffix(key, []byte("\n"))
	}
	if len(key) != 16 && len(key) != 24 && len(key) != 32 {
		return nil, errors.New("Encryption key must contain 16, 24 or 32 ASCII bytes, matching the Bark app.")
	}
	for _, b := range key {
		if b < 32 || b > 126 {
			return nil, errors.New("Encryption key must contain printable ASCII characters matching the Bark app.")
		}
	}
	mode := strings.ToLower(cfg.EncryptionMode)
	ivSize := 0
	switch mode {
	case "cbc":
		ivSize = aes.BlockSize
	case "gcm":
		ivSize = 12
	case "ecb":
	default:
		return nil, errors.New("Encryption mode must be cbc, ecb or gcm.")
	}
	iv, err := randomIV(ivSize)
	if err != nil {
		return nil, errors.New("Cannot generate encryption IV.")
	}
	inner := make(map[string]json.RawMessage)
	outer := make(map[string]json.RawMessage)
	for name, value := range payload {
		switch name {
		case "device_key", "device_keys":
			outer[name] = value
		case "id", "delete":
			// APNs needs routing outside; the app replaces userInfo after decryption,
			// so preserve these fields inside too for history/deletion processing.
			outer[name], inner[name] = value, value
		default:
			inner[name] = value
		}
	}
	plain, _ := json.Marshal(inner)
	encrypted, err := encryptBytes(plain, key, mode, iv)
	if err != nil {
		return nil, errors.New("Cannot encrypt notification.")
	}
	outer["ciphertext"], _ = json.Marshal(base64.StdEncoding.EncodeToString(encrypted))
	if len(iv) != 0 {
		outer["iv"], _ = json.Marshal(string(iv))
	}
	return outer, nil
}

func randomIV(size int) ([]byte, error) {
	iv := make([]byte, 0, size)
	for len(iv) < size {
		var sample [32]byte
		if _, err := rand.Read(sample[:]); err != nil {
			return nil, err
		}
		for _, b := range sample {
			// 94 printable non-space ASCII characters, with rejection sampling
			// to avoid modulo bias and preserve Bark's exact string lengths.
			if b < 188 && len(iv) < size {
				iv = append(iv, 33+b%94)
			}
		}
	}
	return iv, nil
}

func encryptBytes(plain, key []byte, mode string, iv []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	if mode == "gcm" {
		gcm, err := cipher.NewGCM(block)
		if err != nil {
			return nil, err
		}
		return gcm.Seal(nil, iv, plain, nil), nil
	}
	padding := aes.BlockSize - len(plain)%aes.BlockSize
	padded := make([]byte, len(plain)+padding)
	copy(padded, plain)
	copy(padded[len(plain):], bytes.Repeat([]byte{byte(padding)}, padding))
	output := make([]byte, len(padded))
	if mode == "cbc" {
		cipher.NewCBCEncrypter(block, iv).CryptBlocks(output, padded)
	} else {
		for offset := 0; offset < len(padded); offset += aes.BlockSize {
			block.Encrypt(output[offset:offset+aes.BlockSize], padded[offset:offset+aes.BlockSize])
		}
	}
	return output, nil
}
