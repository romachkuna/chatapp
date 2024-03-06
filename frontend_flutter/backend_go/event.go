package main

import "encoding/json"

type Event struct {
	EventType string          `json:"event_type"`
	Payload   json.RawMessage `json:"payload"`
	Date      string          `json:"date"`
	From      string          `json:"from"`
}
