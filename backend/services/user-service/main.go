package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
	"github.com/gorilla/mux"
)

type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Service   string    `json:"service"`
}

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

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

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