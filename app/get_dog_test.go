package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func GetDogHandlerTest(t *testing.T) {
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

	// Check if the response body contains the expected JSON structure.
	expected := `{"image":"https://dog.ceo/dog.jpg"}`
	if res.Body.String() != expected {
		t.Errorf("Expected response body %v, but got %v", expected, res.Body.String())
	}
}
