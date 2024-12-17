package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

func main() {
	// Serve static files
	fs := http.FileServer(http.Dir("static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	// Serve the HTML from "templates"
	http.HandleFunc("/", func(res http.ResponseWriter, req *http.Request) {
		http.ServeFile(res, req, "templates/index.html")
	})

	http.HandleFunc("/api/dog", getDogHandler)
	port := "8080"
	fmt.Printf("Server running on port %s\n", port)
	http.ListenAndServe(":"+port, nil)
}

func getDogHandler(res http.ResponseWriter, req *http.Request) {
	resp, err := http.Get("https://dog.ceo/api/breeds/image/random")
	if err != nil {
		http.Error(res, "Failed to fetch dog image", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	var dogAPIResp map[string]string
	if err := json.NewDecoder(resp.Body).Decode(&dogAPIResp); err != nil {
		http.Error(res, "Failed to decode dog image response", http.StatusInternalServerError)
		return
	}

	dogRes := DogResponse{Image: dogAPIResp["message"]}

	res.Header().Set("Content-Type", "application/json")
	json.NewEncoder(res).Encode(dogRes)
}

type DogResponse struct {
	Image string `json:"image"`
}