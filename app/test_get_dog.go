package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestGetDogHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/api/dog", nil)
	if err != nil {
		t.Fatal(err)
	}

	res := httptest.NewRecorder()
	handler := http.HandlerFunc(getDogHandler)
	handler.ServeHTTP(res, req)

	// Check if the response status code is 200 OK.
	if status := res.Code; status != http.StatusOK {
		t.Errorf("Expected status 200 OK, but got %v", status)
	}

	// Check if response has a dog url
	if res.Body.String() == "" {
		t.Error("Expected non-empty response body")
	}
}
