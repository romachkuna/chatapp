package main

import "fmt"

import (
	"encoding/json"
	"log"
	"time"

	"github.com/gorilla/websocket"
)

type Client struct {
	connection *websocket.Conn
	manager    *Manager
	egress     chan Event

	// egress is used to avoid concurrent writes on the websocket connection

}

type ClientList map[*Client]bool

func newClient(connection *websocket.Conn, manager *Manager) *Client {
	return &Client{
		connection: connection,
		manager:    manager,
		egress:     make(chan Event),
	}
}

func (c *Client) readMessages() {
	defer func() {
		// cleans up connection
		c.manager.removeClient(c)
	}()
	for {
		_, payload, err := c.connection.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				fmt.Println("closed with error", err)
			}
			break
		}

		log.Println("message received ", string(payload))

		var request Event
		err = json.Unmarshal(payload, &request)
		if err != nil {
			fmt.Println("error unmarshalling the payload")
			request = Event{
				EventType: "error",
				Payload:   json.RawMessage(""),
				Date:      time.Now().GoString(),
			}
		}

		for clientToReceive := range c.manager.clients {
			if c != clientToReceive {
				fmt.Println("evaluated here that c == clientToRecieve")
				clientToReceive.egress <- request
			}
		}
	}
}

func (c *Client) writeMessages() {
	defer func() {
		// cleans up connection
		c.manager.removeClient(c)
	}()

	for {
		select {
		case message, ok := <-c.egress:
			if !ok {
				if err := c.connection.WriteMessage(websocket.CloseMessage, nil); err != nil {
					fmt.Println("connection closed already ", err)
				}
				return
			}

			msg, err := json.Marshal(message)
			if err != nil {
				fmt.Println("error marshaling the message: ", err)
				continue // keep the connection alive if the message sent couldn't be marshaled
			}

			err = c.connection.WriteMessage(websocket.TextMessage, msg)
			if err != nil {
				fmt.Println("error sending the message: ", err)
				continue
			}

			fmt.Println("message - ", string(msg), "was sent")
		}
	}
}
