package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Service   string    `json:"service"`
	Version   string    `json:"version"`
}

type User struct {
	ID        string    `json:"id"`
	Email     string    `json:"email"`
	Name      string    `json:"name"`
	Verified  bool      `json:"verified"`
	Rating    float64   `json:"rating"`
	CreatedAt time.Time `json:"created_at"`
}

type Shipment struct {
	ID          string    `json:"id"`
	From        string    `json:"from"`
	To          string    `json:"to"`
	Status      string    `json:"status"`
	Price       float64   `json:"price"`
	CreatedAt   time.Time `json:"created_at"`
	Description string    `json:"description"`
}

type ChatMessage struct {
	ID        string    `json:"id"`
	SenderID  string    `json:"sender_id"`
	ReceiverID string   `json:"receiver_id"`
	Message   string    `json:"message"`
	Timestamp time.Time `json:"timestamp"`
}

func main() {
	log.Println("starting bringee user-service...")

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", handler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/v1/users", usersHandler)
	http.HandleFunc("/api/v1/shipments", shipmentsHandler)
	http.HandleFunc("/api/v1/chat", chatHandler)
	
	log.Printf("listening on port %s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}

func handler(w http.ResponseWriter, r *http.Request) {
	log.Printf("received request from %s", r.RemoteAddr)
	
	response := map[string]interface{}{
		"message": "Willkommen bei Bringee - Peer-to-Peer Logistik",
		"service": "user-service",
		"version": "1.0.0",
		"endpoints": []string{
			"/health",
			"/api/v1/users",
			"/api/v1/shipments", 
			"/api/v1/chat",
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Service:   "bringee-user-service",
		Version:   "1.0.0",
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func usersHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		// Mock user data
		users := []User{
			{
				ID:        "user-001",
				Email:     "john.doe@example.com",
				Name:      "John Doe",
				Verified:  true,
				Rating:    4.8,
				CreatedAt: time.Now().AddDate(0, -2, 0),
			},
			{
				ID:        "user-002", 
				Email:     "anna.schmidt@example.com",
				Name:      "Anna Schmidt",
				Verified:  true,
				Rating:    4.9,
				CreatedAt: time.Now().AddDate(0, -1, 0),
			},
		}
		
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"users": users,
			"total": len(users),
		})
		
	case "POST":
		// Mock user creation
		var user User
		if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}
		
		user.ID = "user-" + fmt.Sprintf("%d", time.Now().Unix())
		user.CreatedAt = time.Now()
		user.Verified = false
		user.Rating = 0.0
		
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(user)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func shipmentsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		// Mock shipment data
		shipments := []Shipment{
			{
				ID:          "ship-001",
				From:        "Berlin",
				To:          "München", 
				Status:      "in_progress",
				Price:       25.00,
				CreatedAt:   time.Now().AddDate(0, 0, -1),
				Description: "Kleine Pakete",
			},
			{
				ID:          "ship-002",
				From:        "Hamburg",
				To:          "Köln",
				Status:      "in_transit", 
				Price:       30.00,
				CreatedAt:   time.Now().AddDate(0, 0, -2),
				Description: "Dokumente",
			},
			{
				ID:          "ship-003",
				From:        "Frankfurt",
				To:          "Düsseldorf",
				Status:      "delivered",
				Price:       20.00,
				CreatedAt:   time.Now().AddDate(0, 0, -3),
				Description: "Elektronik",
			},
		}
		
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"shipments": shipments,
			"total":     len(shipments),
		})
		
	case "POST":
		// Mock shipment creation
		var shipment Shipment
		if err := json.NewDecoder(r.Body).Decode(&shipment); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}
		
		shipment.ID = "ship-" + fmt.Sprintf("%d", time.Now().Unix())
		shipment.CreatedAt = time.Now()
		shipment.Status = "created"
		
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(shipment)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func chatHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		// Mock chat messages
		messages := []ChatMessage{
			{
				ID:         "msg-001",
				SenderID:   "user-001",
				ReceiverID: "user-002",
				Message:    "Wann können Sie die Sendung abholen?",
				Timestamp:  time.Now().Add(-time.Hour),
			},
			{
				ID:         "msg-002", 
				SenderID:   "user-002",
				ReceiverID: "user-001",
				Message:    "Morgen um 14:00 Uhr wäre perfekt",
				Timestamp:  time.Now().Add(-30 * time.Minute),
			},
			{
				ID:         "msg-003",
				SenderID:   "user-001", 
				ReceiverID: "user-002",
				Message:    "Perfekt, bis morgen!",
				Timestamp:  time.Now().Add(-15 * time.Minute),
			},
		}
		
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"messages": messages,
			"total":    len(messages),
		})
		
	case "POST":
		// Mock message creation
		var message ChatMessage
		if err := json.NewDecoder(r.Body).Decode(&message); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}
		
		message.ID = "msg-" + fmt.Sprintf("%d", time.Now().Unix())
		message.Timestamp = time.Now()
		
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(message)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}