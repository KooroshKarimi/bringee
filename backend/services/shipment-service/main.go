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

type Shipment struct {
	ID          string  `json:"id"`
	Title       string  `json:"title"`
	Description string  `json:"description"`
	FromAddress string  `json:"from_address"`
	ToAddress   string  `json:"to_address"`
	Status      string  `json:"status"`
	Price       float64 `json:"price"`
	Weight      float64 `json:"weight"`
	UserID      string  `json:"user_id"`
	Created     string  `json:"created"`
	Updated     string  `json:"updated"`
}

type ShipmentResponse struct {
	Success   bool       `json:"success"`
	Message   string     `json:"message"`
	Shipment  *Shipment  `json:"shipment,omitempty"`
	Shipments []Shipment `json:"shipments,omitempty"`
}

// In-memory storage for demo purposes
var shipments = map[string]Shipment{
	"1": {
		ID:          "1",
		Title:       "Paket von Berlin nach München",
		Description: "Kleine Box mit Büchern",
		FromAddress: "Berlin, Deutschland",
		ToAddress:   "München, Deutschland",
		Status:      "available",
		Price:       25.50,
		Weight:      2.5,
		UserID:      "1",
		Created:     time.Now().Format(time.RFC3339),
		Updated:     time.Now().Format(time.RFC3339),
	},
	"2": {
		ID:          "2",
		Title:       "Express Lieferung Hamburg - Frankfurt",
		Description: "Dokumente für wichtige Präsentation",
		FromAddress: "Hamburg, Deutschland",
		ToAddress:   "Frankfurt, Deutschland",
		Status:      "in_transit",
		Price:       45.00,
		Weight:      0.5,
		UserID:      "2",
		Created:     time.Now().Format(time.RFC3339),
		Updated:     time.Now().Format(time.RFC3339),
	},
}

func main() {
	log.Println("starting Bringee shipment-service...")

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	r := mux.NewRouter()
	
	// API routes
	r.HandleFunc("/api/shipments", getShipmentsHandler).Methods("GET")
	r.HandleFunc("/api/shipments/{id}", getShipmentHandler).Methods("GET")
	r.HandleFunc("/api/shipments", createShipmentHandler).Methods("POST")
	r.HandleFunc("/api/shipments/{id}", updateShipmentHandler).Methods("PUT")
	r.HandleFunc("/api/shipments/{id}", deleteShipmentHandler).Methods("DELETE")
	r.HandleFunc("/api/shipments/user/{userID}", getUserShipmentsHandler).Methods("GET")
	
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
		"service": "Bringee Shipment Service",
		"version": "1.0.0",
		"status":  "running",
		"endpoints": []string{
			"GET /api/shipments - Get all shipments",
			"GET /api/shipments/{id} - Get shipment by ID",
			"POST /api/shipments - Create new shipment",
			"PUT /api/shipments/{id} - Update shipment",
			"DELETE /api/shipments/{id} - Delete shipment",
			"GET /api/shipments/user/{userID} - Get user's shipments",
			"GET /health - Health check",
		},
	}
	json.NewEncoder(w).Encode(response)
}

func getShipmentsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	var shipmentList []Shipment
	for _, shipment := range shipments {
		shipmentList = append(shipmentList, shipment)
	}
	
	response := ShipmentResponse{
		Success:   true,
		Message:   "Shipments retrieved successfully",
		Shipments: shipmentList,
	}
	
	json.NewEncoder(w).Encode(response)
}

func getShipmentHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	vars := mux.Vars(r)
	shipmentID := vars["id"]
	
	shipment, exists := shipments[shipmentID]
	if !exists {
		w.WriteHeader(http.StatusNotFound)
		response := ShipmentResponse{
			Success: false,
			Message: "Shipment not found",
		}
		json.NewEncoder(w).Encode(response)
		return
	}
	
	response := ShipmentResponse{
		Success:  true,
		Message:  "Shipment retrieved successfully",
		Shipment: &shipment,
	}
	
	json.NewEncoder(w).Encode(response)
}

func createShipmentHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	var newShipment Shipment
	if err := json.NewDecoder(r.Body).Decode(&newShipment); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		response := ShipmentResponse{
			Success: false,
			Message: "Invalid request body",
		}
		json.NewEncoder(w).Encode(response)
		return
	}
	
	// Generate ID (in real app, use UUID)
	newShipment.ID = fmt.Sprintf("%d", len(shipments)+1)
	newShipment.Created = time.Now().Format(time.RFC3339)
	newShipment.Updated = time.Now().Format(time.RFC3339)
	
	shipments[newShipment.ID] = newShipment
	
	response := ShipmentResponse{
		Success:  true,
		Message:  "Shipment created successfully",
		Shipment: &newShipment,
	}
	
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

func updateShipmentHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	vars := mux.Vars(r)
	shipmentID := vars["id"]
	
	if _, exists := shipments[shipmentID]; !exists {
		w.WriteHeader(http.StatusNotFound)
		response := ShipmentResponse{
			Success: false,
			Message: "Shipment not found",
		}
		json.NewEncoder(w).Encode(response)
		return
	}
	
	var updatedShipment Shipment
	if err := json.NewDecoder(r.Body).Decode(&updatedShipment); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		response := ShipmentResponse{
			Success: false,
			Message: "Invalid request body",
		}
		json.NewEncoder(w).Encode(response)
		return
	}
	
	updatedShipment.ID = shipmentID
	updatedShipment.Updated = time.Now().Format(time.RFC3339)
	shipments[shipmentID] = updatedShipment
	
	response := ShipmentResponse{
		Success:  true,
		Message:  "Shipment updated successfully",
		Shipment: &updatedShipment,
	}
	
	json.NewEncoder(w).Encode(response)
}

func deleteShipmentHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	vars := mux.Vars(r)
	shipmentID := vars["id"]
	
	if _, exists := shipments[shipmentID]; !exists {
		w.WriteHeader(http.StatusNotFound)
		response := ShipmentResponse{
			Success: false,
			Message: "Shipment not found",
		}
		json.NewEncoder(w).Encode(response)
		return
	}
	
	delete(shipments, shipmentID)
	
	response := ShipmentResponse{
		Success: true,
		Message: "Shipment deleted successfully",
	}
	
	json.NewEncoder(w).Encode(response)
}

func getUserShipmentsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	vars := mux.Vars(r)
	userID := vars["userID"]
	
	var userShipments []Shipment
	for _, shipment := range shipments {
		if shipment.UserID == userID {
			userShipments = append(userShipments, shipment)
		}
	}
	
	response := ShipmentResponse{
		Success:   true,
		Message:   "User shipments retrieved successfully",
		Shipments: userShipments,
	}
	
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