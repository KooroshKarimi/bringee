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

type Shipment struct {
	ID            string    `json:"id"`
	Origin        string    `json:"origin"`
	Destination   string    `json:"destination"`
	Price         float64   `json:"price"`
	Description   string    `json:"description"`
	Status        string    `json:"status"` // "available", "inProgress", "delivered", "cancelled"
	SenderID      string    `json:"senderId"`
	TransporterID *string   `json:"transporterId,omitempty"`
	CreatedAt     time.Time `json:"createdAt"`
	AcceptedAt    *time.Time `json:"acceptedAt,omitempty"`
	DeliveredAt   *time.Time `json:"deliveredAt,omitempty"`
}

type CreateShipmentRequest struct {
	Origin      string  `json:"origin"`
	Destination string  `json:"destination"`
	Price       float64 `json:"price"`
	Description string  `json:"description"`
	SenderID    string  `json:"senderId"`
}

type AcceptShipmentRequest struct {
	TransporterID string `json:"transporterId"`
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
	shipments = make(map[string]Shipment)
	mu        sync.RWMutex
	nextID    = 1
)

func main() {
	log.Println("🚀 Starting Bringee Shipment Service...")

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// API routes
	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/v1/shipments", shipmentsHandler)
	http.HandleFunc("/api/v1/shipments/", shipmentHandler)
	http.HandleFunc("/api/v1/shipments/", acceptShipmentHandler)
	
	log.Printf("📡 Listening on port %s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	response := map[string]interface{}{
		"service": "Bringee Shipment Service",
		"version": "1.0.0",
		"status":  "running",
		"endpoints": []string{
			"GET /health",
			"GET /api/v1/shipments",
			"POST /api/v1/shipments",
			"GET /api/v1/shipments/{id}",
			"PUT /api/v1/shipments/{id}",
			"POST /api/v1/shipments/{id}/accept",
		},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Service:   "bringee-shipment-service",
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func shipmentsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		// Get query parameters for filtering
		status := r.URL.Query().Get("status")
		senderID := r.URL.Query().Get("senderId")
		transporterID := r.URL.Query().Get("transporterId")

		mu.RLock()
		defer mu.RUnlock()

		shipmentList := make([]Shipment, 0, len(shipments))
		for _, shipment := range shipments {
			// Apply filters
			if status != "" && shipment.Status != status {
				continue
			}
			if senderID != "" && shipment.SenderID != senderID {
				continue
			}
			if transporterID != "" && (shipment.TransporterID == nil || *shipment.TransporterID != transporterID) {
				continue
			}
			shipmentList = append(shipmentList, shipment)
		}

		response := APIResponse{
			Success: true,
			Message: "Shipments retrieved successfully",
			Data:    shipmentList,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)

	case "POST":
		var req CreateShipmentRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}

		// Validate request
		if req.Origin == "" || req.Destination == "" || req.Price <= 0 || req.SenderID == "" {
			response := APIResponse{
				Success: false,
				Message: "Origin, destination, price, and senderId are required",
			}
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(response)
			return
		}

		mu.Lock()
		defer mu.Unlock()

		// Create new shipment
		shipmentID := strconv.Itoa(nextID)
		nextID++

		now := time.Now()
		shipment := Shipment{
			ID:          shipmentID,
			Origin:      req.Origin,
			Destination: req.Destination,
			Price:       req.Price,
			Description: req.Description,
			Status:      "available",
			SenderID:    req.SenderID,
			CreatedAt:   now,
		}

		shipments[shipmentID] = shipment

		response := APIResponse{
			Success: true,
			Message: "Shipment created successfully",
			Data:    shipment,
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(response)

	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func shipmentHandler(w http.ResponseWriter, r *http.Request) {
	// Extract shipment ID from URL path
	shipmentID := r.URL.Path[len("/api/v1/shipments/"):]
	if shipmentID == "" {
		http.Error(w, "Shipment ID required", http.StatusBadRequest)
		return
	}

	switch r.Method {
	case "GET":
		mu.RLock()
		defer mu.RUnlock()

		shipment, exists := shipments[shipmentID]
		if !exists {
			response := APIResponse{
				Success: false,
				Message: "Shipment not found",
			}
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode(response)
			return
		}

		response := APIResponse{
			Success: true,
			Message: "Shipment retrieved successfully",
			Data:    shipment,
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

		shipment, exists := shipments[shipmentID]
		if !exists {
			response := APIResponse{
				Success: false,
				Message: "Shipment not found",
			}
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode(response)
			return
		}

		// Update allowed fields
		if status, ok := updateData["status"].(string); ok {
			validStatuses := []string{"available", "inProgress", "delivered", "cancelled"}
			for _, validStatus := range validStatuses {
				if status == validStatus {
					shipment.Status = status
					break
				}
			}
		}
		if price, ok := updateData["price"].(float64); ok && price > 0 {
			shipment.Price = price
		}
		if description, ok := updateData["description"].(string); ok {
			shipment.Description = description
		}

		shipments[shipmentID] = shipment

		response := APIResponse{
			Success: true,
			Message: "Shipment updated successfully",
			Data:    shipment,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)

	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

// Handle shipment acceptance
func acceptShipmentHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Extract shipment ID from URL path
	shipmentID := r.URL.Path[len("/api/v1/shipments/"):]
	shipmentID = shipmentID[:len(shipmentID)-len("/accept")]
	if shipmentID == "" {
		http.Error(w, "Shipment ID required", http.StatusBadRequest)
		return
	}

	var req AcceptShipmentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if req.TransporterID == "" {
		response := APIResponse{
			Success: false,
			Message: "Transporter ID is required",
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(response)
		return
	}

	mu.Lock()
	defer mu.Unlock()

	shipment, exists := shipments[shipmentID]
	if !exists {
		response := APIResponse{
			Success: false,
			Message: "Shipment not found",
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(response)
		return
	}

	if shipment.Status != "available" {
		response := APIResponse{
			Success: false,
			Message: "Shipment is not available for acceptance",
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(response)
		return
	}

	// Accept the shipment
	now := time.Now()
	shipment.Status = "inProgress"
	shipment.TransporterID = &req.TransporterID
	shipment.AcceptedAt = &now

	shipments[shipmentID] = shipment

	response := APIResponse{
		Success: true,
		Message: "Shipment accepted successfully",
		Data:    shipment,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}