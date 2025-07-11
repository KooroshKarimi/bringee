#!/bin/bash

echo "🧪 Testing Bringee Services"
echo "=========================="

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed"
    echo "Please install Go first: https://golang.org/doc/install"
    exit 1
fi

# Function to start a service
start_service() {
    local service_name=$1
    local service_path=$2
    local port=$3
    
    echo "🚀 Starting $service_name on port $port..."
    cd "$service_path"
    go run main.go &
    local pid=$!
    echo "✅ $service_name started with PID $pid"
    sleep 2
    
    # Test the service
    echo "🧪 Testing $service_name..."
    curl -s "http://localhost:$port/" | jq . 2>/dev/null || echo "Service not responding"
    echo ""
    
    return $pid
}

# Start services
echo "Starting services..."

# Start User Service
user_pid=$(start_service "User Service" "backend/services/user-service" 8081)

# Start Shipment Service  
shipment_pid=$(start_service "Shipment Service" "backend/services/shipment-service" 8082)

echo "📋 Service URLs:"
echo "• User Service: http://localhost:8081"
echo "• Shipment Service: http://localhost:8082"
echo ""

echo "🧪 Testing API endpoints..."
echo ""

# Test User Service
echo "Testing User Service:"
echo "1. Creating a user..."
curl -s -X POST http://localhost:8081/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@bringee.com",
    "name": "Test User",
    "password": "password123",
    "userType": "sender"
  }' | jq .

echo ""
echo "2. Logging in..."
curl -s -X POST http://localhost:8081/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@bringee.com",
    "password": "password123"
  }' | jq .

echo ""
echo "3. Getting all users..."
curl -s http://localhost:8081/api/v1/users | jq .

echo ""

# Test Shipment Service
echo "Testing Shipment Service:"
echo "1. Creating a shipment..."
curl -s -X POST http://localhost:8082/api/v1/shipments \
  -H "Content-Type: application/json" \
  -d '{
    "origin": "New York, NY",
    "destination": "London, UK",
    "price": 50.00,
    "description": "Small package, electronics",
    "senderId": "1"
  }' | jq .

echo ""
echo "2. Getting all shipments..."
curl -s http://localhost:8082/api/v1/shipments | jq .

echo ""
echo "3. Getting available shipments..."
curl -s "http://localhost:8082/api/v1/shipments?status=available" | jq .

echo ""
echo "✅ Testing complete!"
echo ""
echo "To stop services, run:"
echo "kill $user_pid $shipment_pid"
echo ""
echo "Or press Ctrl+C to stop all services"

# Wait for user to stop
trap "echo 'Stopping services...'; kill $user_pid $shipment_pid 2>/dev/null; exit" INT
wait