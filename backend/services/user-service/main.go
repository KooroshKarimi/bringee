package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
	"strconv"
	"sync"
)

type User struct {
	ID                string    `json:"id"`
	Email             string    `json:"email"`
	Name              string    `json:"name"`
	IsVerified        bool      `json:"isVerified"`
	UserType          string    `json:"userType"` // "sender" or "transporter"
	ProfileImage      *string   `json:"profileImage,omitempty"`
	Rating            *float64  `json:"rating,omitempty"`
	CompletedShipments *int     `json:"completedShipments,omitempty"`
	CreatedAt         time.Time `json:"createdAt"`
	UpdatedAt         time.Time `json:"updatedAt"`
}

type CreateUserRequest struct {
	Email    string `json:"email"`
	Name     string `json:"name"`
	Password string `json:"password"`
	UserType string `json:"userType"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginResponse struct {
	User  User   `json:"user"`
	Token string `json:"token"`
}

type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Service   string    `json:"service"`
}

type APIResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// In-memory storage for demo purposes
// In production, this would be a database
var (
	users = make(map[string]User)
	mu    sync.RWMutex
	nextID = 1
)

func main() {
	log.Println("🚀 Starting Bringee User Service...")

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// API routes
	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/v1/users", usersHandler)
	http.HandleFunc("/api/v1/auth/register", registerHandler)
	http.HandleFunc("/api/v1/auth/login", loginHandler)
	http.HandleFunc("/api/v1/users/", userHandler)
	
	log.Printf("📡 Listening on port %s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	response := map[string]interface{}{
		"service": "Bringee User Service",
		"version": "1.0.0",
		"status":  "running",
		"endpoints": []string{
			"GET /health",
			"POST /api/v1/auth/register",
			"POST /api/v1/auth/login",
			"GET /api/v1/users",
			"GET /api/v1/users/{id}",
			"PUT /api/v1/users/{id}",
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
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func usersHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	mu.RLock()
	defer mu.RUnlock()

	userList := make([]User, 0, len(users))
	for _, user := range users {
		userList = append(userList, user)
	}

	response := APIResponse{
		Success: true,
		Message: "Users retrieved successfully",
		Data:    userList,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
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

	// Validate request
	if req.Email == "" || req.Name == "" || req.Password == "" {
		response := APIResponse{
			Success: false,
			Message: "Email, name, and password are required",
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(response)
		return
	}

	if req.UserType != "sender" && req.UserType != "transporter" {
		response := APIResponse{
			Success: false,
			Message: "UserType must be 'sender' or 'transporter'",
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(response)
		return
	}

	mu.Lock()
	defer mu.Unlock()

	// Check if user already exists
	for _, user := range users {
		if user.Email == req.Email {
			response := APIResponse{
				Success: false,
				Message: "User with this email already exists",
			}
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusConflict)
			json.NewEncoder(w).Encode(response)
			return
		}
	}

	// Create new user
	userID := strconv.Itoa(nextID)
	nextID++

	now := time.Now()
	user := User{
		ID:         userID,
		Email:      req.Email,
		Name:       req.Name,
		IsVerified: false,
		UserType:   req.UserType,
		CreatedAt:  now,
		UpdatedAt:  now,
	}

	users[userID] = user

	// Generate a simple token (in production, use JWT)
	token := fmt.Sprintf("token_%s_%d", userID, now.Unix())

	response := LoginResponse{
		User:  user,
		Token: token,
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Validate request
	if req.Email == "" || req.Password == "" {
		response := APIResponse{
			Success: false,
			Message: "Email and password are required",
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(response)
		return
	}

	mu.RLock()
	defer mu.RUnlock()

	// Find user by email
	var foundUser User
	var found bool
	for _, user := range users {
		if user.Email == req.Email {
			foundUser = user
			found = true
			break
		}
	}

	if !found {
		response := APIResponse{
			Success: false,
			Message: "Invalid email or password",
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(response)
		return
	}

	// In a real application, you would hash and verify the password
	// For demo purposes, we'll accept any password

	// Generate a simple token (in production, use JWT)
	token := fmt.Sprintf("token_%s_%d", foundUser.ID, time.Now().Unix())

	response := LoginResponse{
		User:  foundUser,
		Token: token,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func userHandler(w http.ResponseWriter, r *http.Request) {
	// Extract user ID from URL path
	userID := r.URL.Path[len("/api/v1/users/"):]
	if userID == "" {
		http.Error(w, "User ID required", http.StatusBadRequest)
		return
	}

	switch r.Method {
	case "GET":
		mu.RLock()
		defer mu.RUnlock()

		user, exists := users[userID]
		if !exists {
			response := APIResponse{
				Success: false,
				Message: "User not found",
			}
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode(response)
			return
		}

		response := APIResponse{
			Success: true,
			Message: "User retrieved successfully",
			Data:    user,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)

	case "PUT":
		var updateData map[string]interface{}
		if err := json.NewDecoder(r.Body).Decode(&updateData); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}

		mu.Lock()
		defer mu.Unlock()

		user, exists := users[userID]
		if !exists {
			response := APIResponse{
				Success: false,
				Message: "User not found",
			}
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode(response)
			return
		}

		// Update allowed fields
		if name, ok := updateData["name"].(string); ok {
			user.Name = name
		}
		if userType, ok := updateData["userType"].(string); ok {
			if userType == "sender" || userType == "transporter" {
				user.UserType = userType
			}
		}
		if rating, ok := updateData["rating"].(float64); ok {
			user.Rating = &rating
		}
		if completedShipments, ok := updateData["completedShipments"].(int); ok {
			user.CompletedShipments = &completedShipments
		}

		user.UpdatedAt = time.Now()
		users[userID] = user

		response := APIResponse{
			Success: true,
			Message: "User updated successfully",
			Data:    user,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)

	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}