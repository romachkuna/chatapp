package main

import (
	"net/http"
	"sync"
)

import (
	"github.com/gorilla/websocket"
)

var (
	webSocketUpgrader = websocket.Upgrader{
		CheckOrigin: func(r *http.Request) bool {
			// Allow all connections
			return true
		},
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
	}
	managerMap = make(map[string]*Manager)
)

type Manager struct {
	clients ClientList
	sync.RWMutex
}

func newManager() *Manager {
	return &Manager{
		clients: make(ClientList),
	}
}

func getOrCreateManager(roomID string) *Manager {
	if manager, ok := managerMap[roomID]; ok {
		return manager
	}

	manager := newManager()
	managerMap[roomID] = manager
	return manager
}

func (m *Manager) addClient(client *Client) {
	m.Lock()
	defer m.Unlock()

	m.clients[client] = true

}

func (m *Manager) removeClient(client *Client) {
	m.Lock()
	defer m.Unlock()

	if _, ok := m.clients[client]; ok {
		err := client.connection.Close()
		if err != nil {
			return
		}
		delete(m.clients, client)

	}
}
