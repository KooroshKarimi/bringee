package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
	"strconv"
	"crypto/rand"
	"encoding/hex"
)

type User struct {
	ID          string    `json:"id"`
	Email       string    `json:"email"`
	Username    string    `json:"username"`
	FirstName   string    `json:"first_name"`
	LastName    string    `json:"last_name"`
	Phone       string    `json:"phone"`
	Verified    bool      `json:"verified"`
	Rating      float64   `json:"rating"`
	CompletedShipments int `json:"completed_shipments"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type CreateUserRequest struct {
	Email     string `json:"email"`
	Username  string `json:"username"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Phone     string `json:"phone"`
	Password  string `json:"password"`
}

type UpdateUserRequest struct {
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Phone     string `json:"phone"`
}

type AuthRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Service   string    `json:"service"`
	Version   string    `json:"version"`
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

// In-memory storage for demo purposes
// In production, this would be a database
var users = make(map[string]User)
var userTokens = make(map[string]string)

func main() {
	log.Println("🚀 Starting Bringee User Service...")

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Initialize some demo users
	initializeDemoUsers()

	http.HandleFunc("/", handler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/v1/users", usersHandler)
	http.HandleFunc("/api/v1/users/", userHandler)
	http.HandleFunc("/api/v1/auth/login", loginHandler)
	http.HandleFunc("/api/v1/auth/register", registerHandler)
	http.HandleFunc("/api/v1/auth/verify", verifyHandler)
	http.HandleFunc("/api/v1/shipments", shipmentsHandler)
	http.HandleFunc("/api/v1/chat", chatHandler)
	
	log.Printf("📡 Listening on port %s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}

func initializeDemoUsers() {
	users["1"] = User{
		ID:          "1",
		Email:       "max.mustermann@email.com",
		Username:    "max_mustermann",
		FirstName:   "Max",
		LastName:    "Mustermann",
		Phone:       "+49123456789",
		Verified:    true,
		Rating:      4.8,
		CompletedShipments: 8,
		CreatedAt:   time.Now().AddDate(0, -2, 0),
		UpdatedAt:   time.Now(),
	}
	
	users["2"] = User{
		ID:          "2",
		Email:       "anna.schmidt@email.com",
		Username:    "anna_schmidt",
		FirstName:   "Anna",
		LastName:    "Schmidt",
		Phone:       "+49987654321",
		Verified:    true,
		Rating:      4.9,
		CompletedShipments: 12,
		CreatedAt:   time.Now().AddDate(0, -3, 0),
		UpdatedAt:   time.Now(),
	}
}

func handler(w http.ResponseWriter, r *http.Request) {
	log.Printf("received request from %s", r.RemoteAddr)
	
	// CORS headers
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
	
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}
	
	response := map[string]interface{}{
		"message": "Willkommen bei Bringee - Peer-to-Peer Logistik",
		"service": "user-service",
		"version": "1.0.0",
		"status": "running",
		"endpoints": []string{
			"GET /health",
			"GET /api/v1/users",
			"GET /api/v1/users/{id}",
			"POST /api/v1/auth/login",
			"POST /api/v1/auth/register",
			"POST /api/v1/auth/verify",
			"GET /api/v1/shipments",
			"POST /api/v1/shipments",
			"GET /api/v1/chat",
			"POST /api/v1/chat",
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	// CORS headers
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
	
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}
	
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
		// Return all users
		userList := make([]User, 0, len(users))
		for _, user := range users {
			userList = append(userList, user)
		}
		
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"users": userList,
			"total": len(userList),
		})
		
	case "POST":
		// Create new user
		var req CreateUserRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}
		
		// Generate user ID
		userID := strconv.FormatInt(time.Now().Unix(), 10)
		
		user := User{
			ID:          userID,
			Email:       req.Email,
			Username:    req.Username,
			FirstName:   req.FirstName,
			LastName:    req.LastName,
			Phone:       req.Phone,
			Verified:    false,
			Rating:      0.0,
			CompletedShipments: 0,
			CreatedAt:   time.Now(),
			UpdatedAt:   time.Now(),
		}
		
		users[userID] = user
		
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(user)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func userHandler(w http.ResponseWriter, r *http.Request) {
	// Extract user ID from URL path
	// This is a simplified implementation
	userID := "1" // Mock ID for demo
	
	switch r.Method {
	case "GET":
		if user, exists := users[userID]; exists {
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(user)
		} else {
			http.Error(w, "User not found", http.StatusNotFound)
		}
		
	case "PUT":
		var req UpdateUserRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}
		
		if user, exists := users[userID]; exists {
			user.FirstName = req.FirstName
			user.LastName = req.LastName
			user.Phone = req.Phone
			user.UpdatedAt = time.Now()
			
			users[userID] = user
			
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(user)
		} else {
			http.Error(w, "User not found", http.StatusNotFound)
		}
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	
	var req AuthRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	
	// Mock authentication - in production, verify password
	for _, user := range users {
		if user.Email == req.Email {
			// Generate mock token
			token := generateToken()
			userTokens[token] = user.ID
			
			response := AuthResponse{
				Token: token,
				User:  user,
			}
			
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(response)
			return
		}
	}
	
	http.Error(w, "Invalid credentials", http.StatusUnauthorized)
}

func registerHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	
	var req CreateUserRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	
	// Check if user already exists
	for _, user := range users {
		if user.Email == req.Email {
			http.Error(w, "User already exists", http.StatusConflict)
			return
		}
	}
	
	// Create new user
	userID := strconv.FormatInt(time.Now().Unix(), 10)
	user := User{
		ID:          userID,
		Email:       req.Email,
		Username:    req.Username,
		FirstName:   req.FirstName,
		LastName:    req.LastName,
		Phone:       req.Phone,
		Verified:    false,
		Rating:      0.0,
		CompletedShipments: 0,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	
	users[userID] = user
	
	// Generate token
	token := generateToken()
	userTokens[token] = userID
	
	response := AuthResponse{
		Token: token,
		User:  user,
	}
	
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

func verifyHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	
	var req struct {
		Token string `json:"token"`
	}
	
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	
	if userID, exists := userTokens[req.Token]; exists {
		if user, userExists := users[userID]; userExists {
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(map[string]interface{}{
				"valid": true,
				"user":  user,
			})
			return
		}
	}
	
	http.Error(w, "Invalid token", http.StatusUnauthorized)
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
				Description: "Kleine Pakete mit Dokumenten",
			},
			{
				ID:          "ship-002",
				From:        "Hamburg",
				To:          "Köln",
				Status:      "in_transit",
				Price:       30.00,
				CreatedAt:   time.Now().AddDate(0, 0, -2),
				Description: "Elektronik und Zubehör",
			},
			{
				ID:          "ship-003",
				From:        "Frankfurt",
				To:          "Düsseldorf",
				Status:      "delivered",
				Price:       20.00,
				CreatedAt:   time.Now().AddDate(0, 0, -3),
				Description: "Kleidung und Accessoires",
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
		
		shipment.ID = "ship-" + strconv.FormatInt(time.Now().Unix(), 10)
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
		
		message.ID = "msg-" + strconv.FormatInt(time.Now().Unix(), 10)
		message.Timestamp = time.Now()
		
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(message)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func generateToken() string {
	bytes := make([]byte, 32)
	rand.Read(bytes)
	return hex.EncodeToString(bytes)
}