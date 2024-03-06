package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	setupAPI()
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("defaulting to port %s", port)
	}

	// Start HTTP server.
	log.Printf("listening on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

func setupAPI() {
	http.HandleFunc("/ws", serveWS)
}

func serveWS(w http.ResponseWriter, r *http.Request) {
	// Parse room ID from URL query parameter or path
	roomID := r.URL.Query().Get("roomID")
	if roomID == "" {
		http.Error(w, "roomID query parameter is required", http.StatusBadRequest)
		return
	}

	manager := getOrCreateManager(roomID)

	// upgrade regular http connection to websocket
	conn, err := webSocketUpgrader.Upgrade(w, r, nil)
	if err != nil {
		fmt.Println("error upgrading the connection")
		fmt.Println(err)
		return
	}

	client := newClient(conn, manager)
	manager.addClient(client)
	fmt.Println("there is a new connection")
	go client.readMessages()
	go client.writeMessages()
}
