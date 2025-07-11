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
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Service:   "user-service",
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func usersHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	switch r.Method {
	case "GET":
		// Return list of users (in production, this would be paginated)
		userList := make([]User, 0, len(users))
		for _, user := range users {
			userList = append(userList, user)
		}
		json.NewEncoder(w).Encode(map[string]interface{}{
			"users": userList,
			"total": len(userList),
		})
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func userHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	// Extract user ID from URL
	userID := r.URL.Path[len("/api/v1/users/"):]
	
	switch r.Method {
	case "GET":
		user, exists := users[userID]
		if !exists {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}
		json.NewEncoder(w).Encode(user)
		
	case "PUT":
		var req UpdateUserRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}
		
		user, exists := users[userID]
		if !exists {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}
		
		// Update user fields
		if req.FirstName != "" {
			user.FirstName = req.FirstName
		}
		if req.LastName != "" {
			user.LastName = req.LastName
		}
		if req.Phone != "" {
			user.Phone = req.Phone
		}
		user.UpdatedAt = time.Now()
		
		users[userID] = user
		json.NewEncoder(w).Encode(user)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	
	var req AuthRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	
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
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}
	
	// In production, you would verify the password hash here
	// For demo purposes, we'll accept any password
	
	// Generate a simple token
	token := generateToken()
	userTokens[token] = foundUser.ID
	
	response := AuthResponse{
		Token: token,
		User:  foundUser,
	}
	
	json.NewEncoder(w).Encode(response)
}

func registerHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
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
		if user.Username == req.Username {
			http.Error(w, "Username already taken", http.StatusConflict)
			return
		}
	}
	
	// Create new user
	userID := strconv.Itoa(len(users) + 1)
	now := time.Now()
	
	newUser := User{
		ID:          userID,
		Email:       req.Email,
		Username:    req.Username,
		FirstName:   req.FirstName,
		LastName:    req.LastName,
		Phone:       req.Phone,
		Verified:    false,
		Rating:      0.0,
		CompletedShipments: 0,
		CreatedAt:   now,
		UpdatedAt:   now,
	}
	
	users[userID] = newUser
	
	// Generate token
	token := generateToken()
	userTokens[token] = userID
	
	response := AuthResponse{
		Token: token,
		User:  newUser,
	}
	
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

func verifyHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	
	// Get token from Authorization header
	token := r.Header.Get("Authorization")
	if token == "" {
		http.Error(w, "Missing authorization token", http.StatusUnauthorized)
		return
	}
	
	// Remove "Bearer " prefix if present
	if len(token) > 7 && token[:7] == "Bearer " {
		token = token[7:]
	}
	
	userID, exists := userTokens[token]
	if !exists {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
		return
	}
	
	user, exists := users[userID]
	if !exists {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}
	
	json.NewEncoder(w).Encode(user)
}

func generateToken() string {
	bytes := make([]byte, 16)
	rand.Read(bytes)
	return hex.EncodeToString(bytes)
}