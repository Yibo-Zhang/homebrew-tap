package main

import (
	"encoding/json"
	"errors"
)

func payloadText(payload map[string]json.RawMessage, name string) string {
	var value string
	_ = json.Unmarshal(payload[name], &value)
	return value
}

func hasContent(payload map[string]json.RawMessage) bool {
	for _, name := range []string{"title", "subtitle", "body", "markdown", "image", "ciphertext"} {
		if payloadText(payload, name) != "" {
			return true
		}
	}
	return payloadText(payload, "delete") == "1"
}

func hasAlternativeContent(payload map[string]json.RawMessage) bool {
	for _, name := range []string{"markdown", "image", "ciphertext"} {
		if payloadText(payload, name) != "" {
			return true
		}
	}
	return payloadText(payload, "delete") == "1"
}

func validateNotification(payload map[string]json.RawMessage) error {
	if !hasContent(payload) {
		return errors.New("Provide notification content (body, title, subtitle, markdown, image or ciphertext), or delete with an id.")
	}
	if payloadText(payload, "delete") == "1" && payloadText(payload, "id") == "" {
		return errors.New("Deleting a notification requires a nonempty id.")
	}
	if payloadText(payload, "iv") != "" && payloadText(payload, "ciphertext") == "" {
		return errors.New("iv is only valid with pre-encrypted ciphertext; --encrypt generates its own IV.")
	}
	if payloadText(payload, "ciphertext") != "" {
		// Mixing a secret message with plaintext fields defeats encrypted pushes.
		for name := range payload {
			switch name {
			case "device_key", "device_keys", "ciphertext", "iv", "id", "delete":
			default:
				return errors.New("ciphertext can only be combined with recipients, iv, id and delete routing fields.")
			}
		}
	}
	return nil
}
