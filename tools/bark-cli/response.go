package main

import "encoding/json"

// Index refers to the input device_keys position. Never expose credentials or
// server messages: both the response order and its free text are untrusted.
type recipientResult struct {
	Index int  `json:"index"`
	OK    bool `json:"ok"`
	Code  int  `json:"code"`
}

func parseResponse(data []byte, payload map[string]json.RawMessage, httpStatus int) (result, int) {
	r := result{HTTPStatus: httpStatus}
	invalid := func() (result, int) {
		r.Error, r.Message = "server", "Server returned an invalid or incomplete response."
		r.Results = nil
		return r, 1
	}
	var reply map[string]json.RawMessage
	var code int
	if decodeObject(data, &reply) != nil || json.Unmarshal(reply["code"], &code) != nil || code == 0 {
		return invalid()
	}
	r.Code = &code
	if code != 200 {
		r.Error, r.Message = "server", "Bark rejected the notification."
		return r, 1
	}
	if rawKeys, batch := payload["device_keys"]; batch {
		var keys []string
		_ = json.Unmarshal(rawKeys, &keys)
		var replies []json.RawMessage
		if json.Unmarshal(reply["data"], &replies) != nil || len(replies) != len(keys) {
			return invalid()
		}
		positions := make(map[string][]int)
		for index, key := range keys {
			positions[key] = append(positions[key], index)
		}
		r.Results = make([]recipientResult, len(keys))
		failed := false
		for _, raw := range replies {
			var item map[string]json.RawMessage
			var key string
			var itemCode int
			if decodeObject(raw, &item) != nil || json.Unmarshal(item["device_key"], &key) != nil || json.Unmarshal(item["code"], &itemCode) != nil || itemCode == 0 {
				return invalid()
			}
			indices := positions[key]
			if len(indices) == 0 {
				return invalid()
			}
			index := indices[0]
			positions[key] = indices[1:]
			r.Results[index] = recipientResult{Index: index, OK: itemCode == 200, Code: itemCode}
			failed = failed || itemCode != 200
		}
		if failed {
			r.Error, r.Message = "server", "At least one notification failed; inspect results by input index."
			return r, 1
		}
	}
	r.OK = true
	return r, 0
}
