package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
<<<<<<< HEAD
	"strconv"
	"crypto/rand"
	"encoding/hex"
=======
	"github.com/gorilla/mux"
>>>>>>> cursor/l-sen-des-merge-konflikts-dd99
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

<<<<<<< HEAD
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
=======
type User struct {
	ID       string `json:"id"`
	Username string `json:"username"`
	Email    string `json:"email"`
	Role     string `json:"role"`
	Created  string `json:"created"`
}

type UserResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	User    *User  `json:"user,omitempty"`
	Users   []User `json:"users,omitempty"`
}

// In-memory storage for demo purposes
var users = map[string]User{
	"1": {
		ID:       "1",
		Username: "john_doe",
		Email:    "john@example.com",
		Role:     "user",
		Created:  time.Now().Format(time.RFC3339),
	},
	"2": {
		ID:       "2",
		Username: "jane_smith",
		Email:    "jane@example.com",
		Role:     "admin",
		Created:  time.Now().Format(time.RFC3339),
	},
}

func main() {
	log.Println("starting Bringee user-service...")
>>>>>>> cursor/l-sen-des-merge-konflikts-dd99

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

<<<<<<< HEAD
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
=======
	r := mux.NewRouter()
	
	// API routes
	r.HandleFunc("/api/users", getUsersHandler).Methods("GET")
	r.HandleFunc("/api/users/{id}", getUserHandler).Methods("GET")
	r.HandleFunc("/api/users", createUserHandler).Methods("POST")
	r.HandleFunc("/api/users/{id}", updateUserHandler).Methods("PUT")
	r.HandleFunc("/api/users/{id}", deleteUserHandler).Methods("DELETE")
	
	// Health check
	r.HandleFunc("/health", healthHandler)
	
	// Root endpoint
	r.HandleFunc("/", rootHandler)
	
	log.Printf("listening on port %s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), r))
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	response := map[string]interface{}{
		"service": "Bringee User Service",
		"version": "1.0.0",
		"status":  "running",
		"endpoints": []string{
			"GET /api/users - Get all users",
			"GET /api/users/{id} - Get user by ID",
			"POST /api/users - Create new user",
			"PUT /api/users/{id} - Update user",
			"DELETE /api/users/{id} - Delete user",
			"GET /health - Health check",
		},
	}
	json.NewEncoder(w).Encode(response)
}

func getUsersHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	var userList []User
	for _, user := range users {
		userList = append(userList, user)
	}
	
	response := UserResponse{
		Success: true,
		Message: "Users retrieved successfully",
		Users:   userList,
	}
	
	json.NewEncoder(w).Encode(response)
}

func getUserHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	vars := mux.Vars(r)
	userID := vars["id"]
	
	user, exists := users[userID]
	if !exists {
		w.WriteHeader(http.StatusNotFound)
		response := UserResponse{
			Success: false,
			Message: "User not found",
		}
		json.NewEncoder(w).Encode(response)
		return
	}
	
	response := UserResponse{
		Success: true,
		Message: "User retrieved successfully",
		User:    &user,
	}
	
	json.NewEncoder(w).Encode(response)
}

func createUserHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	var newUser User
	if err := json.NewDecoder(r.Body).Decode(&newUser); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		response := UserResponse{
			Success: false,
			Message: "Invalid request body",
		}
		json.NewEncoder(w).Encode(response)
		return
	}
	
	// Generate ID (in real app, use UUID)
	newUser.ID = fmt.Sprintf("%d", len(users)+1)
	newUser.Created = time.Now().Format(time.RFC3339)
	
	users[newUser.ID] = newUser
	
	response := UserResponse{
		Success: true,
		Message: "User created successfully",
		User:    &newUser,
	}
	
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

func updateUserHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	vars := mux.Vars(r)
	userID := vars["id"]
	
	if _, exists := users[userID]; !exists {
		w.WriteHeader(http.StatusNotFound)
		response := UserResponse{
			Success: false,
			Message: "User not found",
		}
		json.NewEncoder(w).Encode(response)
		return
	}
	
	var updatedUser User
	if err := json.NewDecoder(r.Body).Decode(&updatedUser); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		response := UserResponse{
			Success: false,
			Message: "Invalid request body",
		}
		json.NewEncoder(w).Encode(response)
		return
	}
	
	updatedUser.ID = userID
	users[userID] = updatedUser
	
	response := UserResponse{
		Success: true,
		Message: "User updated successfully",
		User:    &updatedUser,
	}
	
	json.NewEncoder(w).Encode(response)
}

func deleteUserHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	vars := mux.Vars(r)
	userID := vars["id"]
	
	if _, exists := users[userID]; !exists {
		w.WriteHeader(http.StatusNotFound)
		response := UserResponse{
			Success: false,
			Message: "User not found",
		}
		json.NewEncoder(w).Encode(response)
		return
	}
	
	delete(users, userID)
	
	response := UserResponse{
		Success: true,
		Message: "User deleted successfully",
	}
	
>>>>>>> cursor/l-sen-des-merge-konflikts-dd99
	json.NewEncoder(w).Encode(response)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Service:   "bringee-user-service",
<<<<<<< HEAD
		Version:   "1.0.0",
=======
>>>>>>> cursor/l-sen-des-merge-konflikts-dd99
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