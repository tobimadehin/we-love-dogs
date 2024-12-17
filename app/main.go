package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"log"
)

var (
	infoLog  = log.New(os.Stdout, "INFO: ", log.Ldate|log.Ltime|log.Lshortfile)
	errorLog = log.New(os.Stderr, "ERROR: ", log.Ldate|log.Ltime|log.Lshortfile)
	debugLog = log.New(os.Stdout, "DEBUG: ", log.Ldate|log.Ltime|log.Lshortfile)
)

func main() {
	infoLog.Println("Serving static files...")
	fs := http.FileServer(http.Dir("static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	// Serve the HTML from "templates"
	http.HandleFunc("/", func(res http.ResponseWriter, req *http.Request) {
		http.ServeFile(res, req, "templates/index.html")
	})
	http.HandleFunc("/api/dog", getDogHandler)
	port := os.Getenv("PORT")

	if port == "" {
		port = "8080"
		debugLog.Printf("No PORT environment variable found, using default: %s", port)
	}
	
	fmt.Printf("Server running on port %s\n", port)

	if err := http.ListenAndServe(":"+port, nil); err != nil {
		errorLog.Fatalf("Server failed to start: %v", err)
	}
}

func getDogHandler(res http.ResponseWriter, req *http.Request) {
	infoLog.Println("Fetching random dog image...")
	resp, err := http.Get("https://dog.ceo/api/breeds/image/random")
	
	if err != nil {
		errorLog.Printf("Error fetching dog image: %v\n", err)
		http.Error(res, "Failed to fetch dog image", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	var dogAPIResp map[string]string
	if err := json.NewDecoder(resp.Body).Decode(&dogAPIResp); err != nil {
		errorLog.Println("Failed to decode dog image response")
		http.Error(res, "Parse error", http.StatusInternalServerError)
		return
	}

	if dogAPIResp["message"] == "" {
		errorLog.Println("Dog API returned an empty response")
		http.Error(res, "Dog API error", http.StatusInternalServerError)
		return
	}

	infoLog.Printf("Dog image URL: %s\n", dogAPIResp["message"])

	dogRes := DogResponse{Image: dogAPIResp["message"]}	
	res.Header().Set("Content-Type", "application/json")
	json.NewEncoder(res).Encode(dogRes)
}
type DogResponse struct {
	Image string `json:"image"`
}