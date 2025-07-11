package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
	"strconv"
	"strings"
)

type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Service   string    `json:"service"`
}

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

// In-memory storage for demo purposes
// In production, this would be a database
var shipments = make(map[string]Shipment)
var shipmentStatusHistory = make(map[string][]ShipmentStatusUpdate)

func main() {
	log.Println("starting shipment-service...")

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Initialize some demo shipments
	initializeDemoShipments()

	http.HandleFunc("/", handler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/v1/shipments", shipmentsHandler)
	http.HandleFunc("/api/v1/shipments/", shipmentHandler)
	http.HandleFunc("/api/v1/shipments/", func(w http.ResponseWriter, r *http.Request) {
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
		shipmentHandler(w, r)
	})
	
	log.Printf("listening on port %s", port)
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
		SenderID:              "1",
		TravelerID:            stringPtr("2"),
		RecipientName:         "Lisa Müller",
		RecipientAddress:      "Teststraße 789, 20095 Hamburg",
		RecipientPhone:        "+49401234567",
		ItemDescription:       "Kleines Paket, zerbrechlich",
		ItemValueUSD:          150.0,
		AgreedFeeUSD:          35.0,
		BringeeCommissionUSD:  3.5,
		DutiesAndTaxesUSD:     0.0,
		Status:                "IN_TRANSIT",
		CreatedAt:             now.AddDate(0, 0, -2),
		AcceptedAt:            &now,
		DeliveredAt:           nil,
		DeliveryConfirmationCode: "DEF54321",
		FromLocation:          "Düsseldorf",
		ToLocation:            "Hamburg",
		EstimatedDeliveryDate: now.AddDate(0, 0, 1),
	}
	shipments["3"] = shipment3
}

func stringPtr(s string) *string {
	return &s
}

func handler(w http.ResponseWriter, r *http.Request) {
	log.Printf("received request from %s", r.RemoteAddr)
	
	response := map[string]interface{}{
		"service": "shipment-service",
		"version": "1.0.0",
		"status": "running",
		"endpoints": []string{
			"GET /health",
			"GET /api/v1/shipments",
			"GET /api/v1/shipments/{id}",
			"POST /api/v1/shipments",
			"PUT /api/v1/shipments/{id}/accept",
			"PUT /api/v1/shipments/{id}/status",
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Service:   "shipment-service",
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func shipmentsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	switch r.Method {
	case "GET":
		// Return list of shipments (in production, this would be paginated)
		shipmentList := make([]Shipment, 0, len(shipments))
		for _, shipment := range shipments {
			shipmentList = append(shipmentList, shipment)
		}
		json.NewEncoder(w).Encode(map[string]interface{}{
			"shipments": shipmentList,
			"total": len(shipmentList),
		})
	case "POST":
		var req CreateShipmentRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}
		
		// Create new shipment
		shipmentID := strconv.Itoa(len(shipments) + 1)
		now := time.Now()
		
		// Calculate commission (5% of agreed fee)
		commission := req.ItemValueUSD * 0.05
		
		newShipment := Shipment{
			ID:                    shipmentID,
			SenderID:              "1", // In production, get from auth token
			TravelerID:            nil,
			RecipientName:         req.RecipientName,
			RecipientAddress:      req.RecipientAddress,
			RecipientPhone:        req.RecipientPhone,
			ItemDescription:       req.ItemDescription,
			ItemValueUSD:          req.ItemValueUSD,
			AgreedFeeUSD:          0.0, // Will be set when accepted
			BringeeCommissionUSD:  commission,
			DutiesAndTaxesUSD:     0.0,
			Status:                "POSTED",
			CreatedAt:             now,
			AcceptedAt:            nil,
			DeliveredAt:           nil,
			DeliveryConfirmationCode: generateConfirmationCode(),
			FromLocation:          req.FromLocation,
			ToLocation:            req.ToLocation,
			EstimatedDeliveryDate: req.EstimatedDeliveryDate,
		}
		
		shipments[shipmentID] = newShipment
		
		// Add status update
		addStatusUpdate(shipmentID, "POSTED", "Shipment created")
		
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(newShipment)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func shipmentHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	// Extract shipment ID from URL
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) < 4 {
		http.Error(w, "Invalid shipment ID", http.StatusBadRequest)
		return
	}
	shipmentID := pathParts[len(pathParts)-1]
	
	switch r.Method {
	case "GET":
		shipment, exists := shipments[shipmentID]
		if !exists {
			http.Error(w, "Shipment not found", http.StatusNotFound)
			return
		}
		
		// Include status history
		statusHistory := shipmentStatusHistory[shipmentID]
		response := map[string]interface{}{
			"shipment": shipment,
			"status_history": statusHistory,
		}
		
		json.NewEncoder(w).Encode(response)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func shipmentAcceptHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	if r.Method != "PUT" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	
	// Extract shipment ID from URL
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) < 4 {
		http.Error(w, "Invalid shipment ID", http.StatusBadRequest)
		return
	}
	shipmentID := pathParts[len(pathParts)-2] // -2 because /accept is the last part
	
	var req AcceptShipmentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	
	shipment, exists := shipments[shipmentID]
	if !exists {
		http.Error(w, "Shipment not found", http.StatusNotFound)
		return
	}
	
	if shipment.Status != "POSTED" {
		http.Error(w, "Shipment is not available for acceptance", http.StatusBadRequest)
		return
	}
	
	// Update shipment
	now := time.Now()
	shipment.TravelerID = &req.TravelerID
	shipment.AgreedFeeUSD = req.AgreedFee
	shipment.Status = "ACCEPTED"
	shipment.AcceptedAt = &now
	
	shipments[shipmentID] = shipment
	
	// Add status update
	addStatusUpdate(shipmentID, "ACCEPTED", "Shipment accepted by traveler")
	
	json.NewEncoder(w).Encode(shipment)
}

func shipmentStatusHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	if r.Method != "PUT" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	
	// Extract shipment ID from URL
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) < 4 {
		http.Error(w, "Invalid shipment ID", http.StatusBadRequest)
		return
	}
	shipmentID := pathParts[len(pathParts)-2] // -2 because /status is the last part
	
	var req UpdateShipmentStatusRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	
	shipment, exists := shipments[shipmentID]
	if !exists {
		http.Error(w, "Shipment not found", http.StatusNotFound)
		return
	}
	
	// Validate status transition
	if !isValidStatusTransition(shipment.Status, req.Status) {
		http.Error(w, "Invalid status transition", http.StatusBadRequest)
		return
	}
	
	// Update shipment status
	now := time.Now()
	shipment.Status = req.Status
	
	// Set delivered_at if status is DELIVERED
	if req.Status == "DELIVERED" {
		shipment.DeliveredAt = &now
	}
	
	shipments[shipmentID] = shipment
	
	// Add status update
	addStatusUpdate(shipmentID, req.Status, "Status updated")
	
	json.NewEncoder(w).Encode(shipment)
}

func isValidStatusTransition(currentStatus, newStatus string) bool {
	validTransitions := map[string][]string{
		"POSTED": {"ACCEPTED", "CANCELED"},
		"ACCEPTED": {"IN_TRANSIT", "CANCELED"},
		"IN_TRANSIT": {"DELIVERED", "DISPUTED"},
		"DELIVERED": {}, // Final state
		"DISPUTED": {"DELIVERED", "CANCELED"},
		"CANCELED": {}, // Final state
	}
	
	allowedTransitions, exists := validTransitions[currentStatus]
	if !exists {
		return false
	}
	
	for _, allowed := range allowedTransitions {
		if allowed == newStatus {
			return true
		}
	}
	return false
}

func addStatusUpdate(shipmentID, status, notes string) {
	update := ShipmentStatusUpdate{
		ShipmentID: shipmentID,
		Status:     status,
		Timestamp:  time.Now(),
		Notes:      notes,
	}
	
	shipmentStatusHistory[shipmentID] = append(shipmentStatusHistory[shipmentID], update)
}

func generateConfirmationCode() string {
	// Simple 8-character alphanumeric code
	const charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	result := make([]byte, 8)
	for i := range result {
		result[i] = charset[time.Now().UnixNano()%int64(len(charset))]
	}
	return string(result)
}