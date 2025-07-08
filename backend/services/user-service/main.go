package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	log.Println("starting user-service...")

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", handler)
	log.Printf("listening on port %s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}

func handler(w http.ResponseWriter, r *http.Request) {
	log.Printf("received request from %s", r.RemoteAddr)
	fmt.Fprintf(w, "Hello from user-service!")
}