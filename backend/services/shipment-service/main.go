package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
<<<<<<< HEAD
	"github.com/gorilla/mux"
=======
	"strconv"
	"strings"
>>>>>>> 033c0c866550133c8a28156ddeb21326d2c77cab
)

type Shipment struct {
	ID                    string    `json:"id"`
	SenderID              string    `json:"sender_id"`
	TravelerID            *string   `json:"traveler_id,omitempty"`
	RecipientName         string    `json:"recipient_name"`
	RecipientAddress      string    `json:"recipient_address"`
	RecipientPhone        string    `json:"recipient_phone"`
	ItemDescription       string    `json:"item_description"`
	ItemValueUSD          float64   `json:"item_value_usd"`
	AgreedFeeUSD          float64   `json:"agreed_fee_usd"`
	BringeeCommissionUSD  float64   `json:"bringee_commission_usd"`
	DutiesAndTaxesUSD     float64   `json:"duties_and_taxes_usd"`
	Status                string    `json:"status"`
	CreatedAt             time.Time `json:"created_at"`
	AcceptedAt            *time.Time `json:"accepted_at,omitempty"`
	DeliveredAt           *time.Time `json:"delivered_at,omitempty"`
	DeliveryConfirmationCode string `json:"delivery_confirmation_code"`
	FromLocation          string    `json:"from_location"`
	ToLocation            string    `json:"to_location"`
	EstimatedDeliveryDate time.Time `json:"estimated_delivery_date"`
}

type CreateShipmentRequest struct {
	RecipientName    string  `json:"recipient_name"`
	RecipientAddress string  `json:"recipient_address"`
	RecipientPhone   string  `json:"recipient_phone"`
	ItemDescription  string  `json:"item_description"`
	ItemValueUSD     float64 `json:"item_value_usd"`
	FromLocation     string  `json:"from_location"`
	ToLocation       string  `json:"to_location"`
	EstimatedDeliveryDate time.Time `json:"estimated_delivery_date"`
}

type AcceptShipmentRequest struct {
	TravelerID string `json:"traveler_id"`
	AgreedFee  float64 `json:"agreed_fee"`
}

type UpdateShipmentStatusRequest struct {
	Status string `json:"status"`
}

type ShipmentStatusUpdate struct {
	ShipmentID string    `json:"shipment_id"`
	Status     string    `json:"status"`
	Timestamp  time.Time `json:"timestamp"`
	Notes      string    `json:"notes,omitempty"`
}

type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Service   string    `json:"service"`
	Version   string    `json:"version"`
}

<<<<<<< HEAD
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
=======
type ShipmentBid struct {
	ID         string    `json:"id"`
	ShipmentID string    `json:"shipment_id"`
	CarrierID  string    `json:"carrier_id"`
	Price      float64   `json:"price"`
	Message    string    `json:"message"`
	CreatedAt  time.Time `json:"created_at"`
}

type ShipmentStatus struct {
	ID          string    `json:"id"`
	ShipmentID  string    `json:"shipment_id"`
	Status      string    `json:"status"`
	Description string    `json:"description"`
	Location    string    `json:"location"`
	Timestamp   time.Time `json:"timestamp"`
}

// In-memory storage for demo purposes
// In production, this would be a database
var shipments = make(map[string]Shipment)
var shipmentStatusHistory = make(map[string][]ShipmentStatusUpdate)

func main() {
	log.Println("🚀 Starting Bringee Shipment Service...")
>>>>>>> 033c0c866550133c8a28156ddeb21326d2c77cab

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

<<<<<<< HEAD
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
	
=======
	// Initialize some demo shipments
	initializeDemoShipments()

	http.HandleFunc("/", handler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/v1/shipments", shipmentsHandler)
	http.HandleFunc("/api/v1/shipments/", shipmentHandler)
	http.HandleFunc("/api/v1/bids", bidsHandler)
	http.HandleFunc("/api/v1/status", statusHandler)
	
	log.Printf("📡 Listening on port %s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}

func initializeDemoShipments() {
	now := time.Now()
	
	// Demo shipment 1
	shipment1 := Shipment{
		ID:                    "1",
		SenderID:              "1",
		TravelerID:            nil,
		RecipientName:         "Anna Schmidt",
		RecipientAddress:      "Musterstraße 123, 10115 Berlin",
		RecipientPhone:        "+49301234567",
		ItemDescription:       "Laptop, gut verpackt",
		ItemValueUSD:          1200.0,
		AgreedFeeUSD:          45.0,
		BringeeCommissionUSD:  4.5,
		DutiesAndTaxesUSD:     0.0,
		Status:                "POSTED",
		CreatedAt:             now.AddDate(0, 0, -5),
		AcceptedAt:            nil,
		DeliveredAt:           nil,
		DeliveryConfirmationCode: "ABC12345",
		FromLocation:          "München",
		ToLocation:            "Berlin",
		EstimatedDeliveryDate: now.AddDate(0, 0, 2),
	}
	shipments["1"] = shipment1
	
	// Demo shipment 2
	acceptedAt := now.AddDate(0, 0, -3)
	shipment2 := Shipment{
		ID:                    "2",
		SenderID:              "2",
		TravelerID:            stringPtr("1"),
		RecipientName:         "Max Mustermann",
		RecipientAddress:      "Beispielweg 456, 80331 München",
		RecipientPhone:        "+49891234567",
		ItemDescription:       "Wichtige Dokumente",
		ItemValueUSD:          50.0,
		AgreedFeeUSD:          25.0,
		BringeeCommissionUSD:  2.5,
		DutiesAndTaxesUSD:     0.0,
		Status:                "DELIVERED",
		CreatedAt:             now.AddDate(0, 0, -10),
		AcceptedAt:            &acceptedAt,
		DeliveredAt:           &now,
		DeliveryConfirmationCode: "XYZ98765",
		FromLocation:          "Frankfurt",
		ToLocation:            "München",
		EstimatedDeliveryDate: now.AddDate(0, 0, -2),
	}
	shipments["2"] = shipment2
	
	// Demo shipment 3
	shipment3 := Shipment{
		ID:                    "3",
		SenderID:              "3",
		TravelerID:            stringPtr("2"),
		RecipientName:         "Lisa Müller",
		RecipientAddress:      "Teststraße 789, 20095 Hamburg",
		RecipientPhone:        "+49401234567",
		ItemDescription:       "Elektronik und Zubehör",
		ItemValueUSD:          300.0,
		AgreedFeeUSD:          35.0,
		BringeeCommissionUSD:  3.5,
		DutiesAndTaxesUSD:     0.0,
		Status:                "IN_TRANSIT",
		CreatedAt:             now.AddDate(0, 0, -2),
		AcceptedAt:            &now,
		DeliveredAt:           nil,
		DeliveryConfirmationCode: "DEF67890",
		FromLocation:          "Düsseldorf",
		ToLocation:            "Hamburg",
		EstimatedDeliveryDate: now.AddDate(0, 0, 1),
	}
	shipments["3"] = shipment3
}

func handler(w http.ResponseWriter, r *http.Request) {
	log.Printf("received request from %s", r.RemoteAddr)
	
	response := map[string]interface{}{
		"message": "Bringee Shipment Service - Peer-to-Peer Logistik",
		"service": "shipment-service",
		"version": "1.0.0",
		"status": "running",
		"endpoints": []string{
			"GET /health",
			"GET /api/v1/shipments",
			"POST /api/v1/shipments",
			"GET /api/v1/shipments/{id}",
			"PUT /api/v1/shipments/{id}/accept",
			"PUT /api/v1/shipments/{id}/status",
			"GET /api/v1/bids",
			"POST /api/v1/bids",
			"GET /api/v1/status",
			"POST /api/v1/status",
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
>>>>>>> 033c0c866550133c8a28156ddeb21326d2c77cab
	json.NewEncoder(w).Encode(response)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Service:   "bringee-shipment-service",
<<<<<<< HEAD
=======
		Version:   "1.0.0",
>>>>>>> 033c0c866550133c8a28156ddeb21326d2c77cab
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func shipmentsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		// Return all shipments
		shipmentList := make([]Shipment, 0, len(shipments))
		for _, shipment := range shipments {
			shipmentList = append(shipmentList, shipment)
		}
		
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"shipments": shipmentList,
			"total":     len(shipmentList),
		})
		
	case "POST":
		// Create new shipment
		var req CreateShipmentRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}
		
		// Generate shipment ID
		shipmentID := strconv.FormatInt(time.Now().Unix(), 10)
		
		shipment := Shipment{
			ID:                    shipmentID,
			SenderID:              "1", // Mock sender ID
			TravelerID:            nil,
			RecipientName:         req.RecipientName,
			RecipientAddress:      req.RecipientAddress,
			RecipientPhone:        req.RecipientPhone,
			ItemDescription:       req.ItemDescription,
			ItemValueUSD:          req.ItemValueUSD,
			AgreedFeeUSD:          0.0,
			BringeeCommissionUSD:  0.0,
			DutiesAndTaxesUSD:     0.0,
			Status:                "POSTED",
			CreatedAt:             time.Now(),
			AcceptedAt:            nil,
			DeliveredAt:           nil,
			DeliveryConfirmationCode: generateConfirmationCode(),
			FromLocation:          req.FromLocation,
			ToLocation:            req.ToLocation,
			EstimatedDeliveryDate: req.EstimatedDeliveryDate,
		}
		
		shipments[shipmentID] = shipment
		
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(shipment)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func shipmentHandler(w http.ResponseWriter, r *http.Request) {
	// Extract shipment ID from URL path
	// This is a simplified implementation
	shipmentID := "1" // Mock ID for demo
	
	switch r.Method {
	case "GET":
		if shipment, exists := shipments[shipmentID]; exists {
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(shipment)
		} else {
			http.Error(w, "Shipment not found", http.StatusNotFound)
		}
		
	case "PUT":
		// Handle sub-routes like /api/v1/shipments/{id}/accept
		path := r.URL.Path
		if strings.HasSuffix(path, "/accept") {
			shipmentAcceptHandler(w, r)
			return
		}
		if strings.HasSuffix(path, "/status") {
			shipmentStatusHandler(w, r)
			return
		}
		
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func shipmentAcceptHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "PUT" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	
	var req AcceptShipmentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	
	shipmentID := "1" // Mock ID for demo
	if shipment, exists := shipments[shipmentID]; exists {
		now := time.Now()
		shipment.TravelerID = &req.TravelerID
		shipment.AgreedFeeUSD = req.AgreedFee
		shipment.Status = "ACCEPTED"
		shipment.AcceptedAt = &now
		shipment.BringeeCommissionUSD = req.AgreedFee * 0.1 // 10% commission
		
		shipments[shipmentID] = shipment
		
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(shipment)
	} else {
		http.Error(w, "Shipment not found", http.StatusNotFound)
	}
}

func shipmentStatusHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "PUT" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	
	var req UpdateShipmentStatusRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	
	shipmentID := "1" // Mock ID for demo
	if shipment, exists := shipments[shipmentID]; exists {
		shipment.Status = req.Status
		
		if req.Status == "DELIVERED" {
			now := time.Now()
			shipment.DeliveredAt = &now
		}
		
		shipments[shipmentID] = shipment
		
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(shipment)
	} else {
		http.Error(w, "Shipment not found", http.StatusNotFound)
	}
}

func bidsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		// Mock bid data
		bids := []ShipmentBid{
			{
				ID:         "bid-001",
				ShipmentID: "ship-003",
				CarrierID:  "carrier-001",
				Price:      22.00,
				Message:    "Kann morgen transportieren",
				CreatedAt:  time.Now().Add(-2 * time.Hour),
			},
			{
				ID:         "bid-002",
				ShipmentID: "ship-003",
				CarrierID:  "carrier-002",
				Price:      20.00,
				Message:    "Sofort verfügbar",
				CreatedAt:  time.Now().Add(-1 * time.Hour),
			},
		}
		
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"bids": bids,
			"total": len(bids),
		})
		
	case "POST":
		// Mock bid creation
		var bid ShipmentBid
		if err := json.NewDecoder(r.Body).Decode(&bid); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}
		
		bid.ID = "bid-" + strconv.FormatInt(time.Now().Unix(), 10)
		bid.CreatedAt = time.Now()
		
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(bid)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func statusHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		// Mock status history
		statuses := []ShipmentStatus{
			{
				ID:          "status-001",
				ShipmentID:  "ship-001",
				Status:      "created",
				Description: "Sendung erstellt",
				Location:    "Berlin",
				Timestamp:   time.Now().AddDate(0, 0, -1),
			},
			{
				ID:          "status-002",
				ShipmentID:  "ship-001",
				Status:      "accepted",
				Description: "Von Transporteur angenommen",
				Location:    "Berlin",
				Timestamp:   time.Now().Add(-12 * time.Hour),
			},
			{
				ID:          "status-003",
				ShipmentID:  "ship-001",
				Status:      "in_transit",
				Description: "Unterwegs nach München",
				Location:    "Nürnberg",
				Timestamp:   time.Now().Add(-6 * time.Hour),
			},
		}
		
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"statuses": statuses,
			"total":    len(statuses),
		})
		
	case "POST":
		// Mock status update
		var status ShipmentStatus
		if err := json.NewDecoder(r.Body).Decode(&status); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}
		
		status.ID = "status-" + strconv.FormatInt(time.Now().Unix(), 10)
		status.Timestamp = time.Now()
		
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(status)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func stringPtr(s string) *string {
	return &s
}

func generateConfirmationCode() string {
	bytes := make([]byte, 8)
	for i := range bytes {
		bytes[i] = byte('A' + i%26)
	}
	return string(bytes)
}