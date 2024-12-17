# Use official Golang image to build the Go server
FROM golang:1.19 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the Go files into the container
COPY . .

# Download the Go dependencies
RUN go mod tidy

# Build the Go application
RUN go build -o dog-api .

# Use a minimal base image to run the Go application
FROM debian:bullseye-slim

# Set the working directory inside the container
WORKDIR /root/

# Copy the built binary from the builder image
COPY --from=builder /app/dog-api .

# Expose the port the app will run on
EXPOSE 8080

# Command to run the Go application
CMD ["./dog-api"]
