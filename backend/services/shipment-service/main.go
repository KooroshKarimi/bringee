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

type Shipment struct {
	ID          string    `json:"id"`
	SenderID    string    `json:"sender_id"`
	CarrierID   *string   `json:"carrier_id,omitempty"`
	From        string    `json:"from"`
	To          string    `json:"to"`
	Status      string    `json:"status"`
	Price       float64   `json:"price"`
	Description string    `json:"description"`
	Weight      float64   `json:"weight"`
	Dimensions  string    `json:"dimensions"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

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

func main() {
	log.Println("starting bringee shipment-service...")

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", handler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/v1/shipments", shipmentsHandler)
	http.HandleFunc("/api/v1/shipments/", shipmentDetailHandler)
	http.HandleFunc("/api/v1/bids", bidsHandler)
	http.HandleFunc("/api/v1/status", statusHandler)
	
	log.Printf("listening on port %s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}

func handler(w http.ResponseWriter, r *http.Request) {
	log.Printf("received request from %s", r.RemoteAddr)
	
	response := map[string]interface{}{
		"message": "Bringee Shipment Service - Peer-to-Peer Logistik",
		"service": "shipment-service",
		"version": "1.0.0",
		"endpoints": []string{
			"/health",
			"/api/v1/shipments",
			"/api/v1/bids",
			"/api/v1/status",
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
		Version:   "1.0.0",
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func shipmentsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		// Mock shipment data
		carrierID1 := "carrier-001"
		carrierID2 := "carrier-002"
		
		shipments := []Shipment{
			{
				ID:          "ship-001",
				SenderID:    "user-001",
				CarrierID:   &carrierID1,
				From:        "Berlin",
				To:          "München",
				Status:      "in_progress",
				Price:       25.00,
				Description: "Kleine Pakete mit Dokumenten",
				Weight:      2.5,
				Dimensions:  "30x20x10 cm",
				CreatedAt:   time.Now().AddDate(0, 0, -1),
				UpdatedAt:   time.Now().Add(-2 * time.Hour),
			},
			{
				ID:          "ship-002",
				SenderID:    "user-002",
				CarrierID:   &carrierID2,
				From:        "Hamburg",
				To:          "Köln",
				Status:      "in_transit",
				Price:       30.00,
				Description: "Elektronik und Zubehör",
				Weight:      1.8,
				Dimensions:  "25x15x8 cm",
				CreatedAt:   time.Now().AddDate(0, 0, -2),
				UpdatedAt:   time.Now().Add(-1 * time.Hour),
			},
			{
				ID:          "ship-003",
				SenderID:    "user-003",
				From:        "Frankfurt",
				To:          "Düsseldorf",
				Status:      "available",
				Price:       20.00,
				Description: "Kleidung und Accessoires",
				Weight:      3.2,
				Dimensions:  "40x30x15 cm",
				CreatedAt:   time.Now().AddDate(0, 0, -3),
				UpdatedAt:   time.Now().Add(-30 * time.Minute),
			},
			{
				ID:          "ship-004",
				SenderID:    "user-001",
				CarrierID:   &carrierID1,
				From:        "München",
				To:          "Stuttgart",
				Status:      "delivered",
				Price:       18.00,
				Description: "Bücher und Zeitschriften",
				Weight:      1.5,
				Dimensions:  "20x15x5 cm",
				CreatedAt:   time.Now().AddDate(0, 0, -4),
				UpdatedAt:   time.Now().AddDate(0, 0, -1),
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
		shipment.UpdatedAt = time.Now()
		shipment.Status = "created"
		
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(shipment)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func shipmentDetailHandler(w http.ResponseWriter, r *http.Request) {
	// Extract shipment ID from URL path
	// This is a simplified implementation
	shipmentID := "ship-001" // Mock ID
	
	carrierID := "carrier-001"
	shipment := Shipment{
		ID:          shipmentID,
		SenderID:    "user-001",
		CarrierID:   &carrierID,
		From:        "Berlin",
		To:          "München",
		Status:      "in_progress",
		Price:       25.00,
		Description: "Kleine Pakete mit Dokumenten",
		Weight:      2.5,
		Dimensions:  "30x20x10 cm",
		CreatedAt:   time.Now().AddDate(0, 0, -1),
		UpdatedAt:   time.Now().Add(-2 * time.Hour),
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(shipment)
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
		
		bid.ID = "bid-" + fmt.Sprintf("%d", time.Now().Unix())
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
		
		status.ID = "status-" + fmt.Sprintf("%d", time.Now().Unix())
		status.Timestamp = time.Now()
		
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(status)
		
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}