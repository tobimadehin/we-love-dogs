package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	infoLog    = log.New(os.Stdout, "INFO: ", log.Ldate|log.Ltime|log.Lshortfile)
	errorLog   = log.New(os.Stderr, "ERROR: ", log.Ldate|log.Ltime|log.Lshortfile)
	debugLog   = log.New(os.Stdout, "DEBUG: ", log.Ldate|log.Ltime|log.Lshortfile)

	// Prometheus metrics
	buttonPressCounter = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "button_press_total",
			Help: "Total number of button presses.",
		},
	)
	apiResponseTime = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name: "http_response_time_seconds",
			Help: "Duration of HTTP requests.",
		}, []string{"path"},
	)
	apiErrorCounter = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "api_error_total",
			Help: "Total number of API errors.",
		},
	)
)

func init() {
	// Register Prometheus metrics
	prometheus.Register(buttonPressCounter)
	prometheus.Register(apiResponseTime)
	prometheus.Register(apiErrorCounter)
}

func main() {
    infoLog.Println("Serving static files...")
    router := mux.NewRouter()

    fs := http.FileServer(http.Dir("static"))
    router.PathPrefix("/static/").Handler(http.StripPrefix("/static/", fs))

    // Serve the HTML from "templates"
    router.HandleFunc("/", func(res http.ResponseWriter, req *http.Request) {
        http.ServeFile(res, req, "templates/index.html")
    })

    router.HandleFunc("/api/dog", getDogHandler)

	router.Path("/metrics").Handler(promhttp.Handler())

    // Start the main HTTP server
    infoLog.Println("Starting app server on port 9900...")
    if err := http.ListenAndServe(":9900", router); err != nil {
        errorLog.Fatalf("App server failed: %v", err)
    }}

func getDogHandler(res http.ResponseWriter, req *http.Request) {
	infoLog.Println("Fetching random dog image...")
	timer := prometheus.NewTimer(apiResponseTime.WithLabelValues("/api/dog"))

	resp, err := http.Get("https://dog.ceo/api/breeds/image/random")
	if err != nil {
		errorLog.Printf("Error fetching dog image: %v\n", err)
		apiErrorCounter.Inc()
		http.Error(res, "Failed to fetch dog image", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	timer.ObserveDuration()

	var dogAPIResp map[string]string
	if err := json.NewDecoder(resp.Body).Decode(&dogAPIResp); err != nil {
		errorLog.Println("Failed to decode dog image response")
		apiErrorCounter.Inc()
		http.Error(res, "Parse error", http.StatusInternalServerError)
		return
	}

	if dogAPIResp["message"] == "" {
		errorLog.Println("Dog API returned an empty response")
		apiErrorCounter.Inc()
		http.Error(res, "Dog API error", http.StatusInternalServerError)
		return
	}

	infoLog.Printf("Dog image URL: %s\n", dogAPIResp["message"])
	buttonPressCounter.Inc()

	dogRes := DogResponse{Image: dogAPIResp["message"]}
	res.Header().Set("Content-Type", "application/json")
	json.NewEncoder(res).Encode(dogRes)
}
type DogResponse struct {
	Image string `json:"image"`
}
