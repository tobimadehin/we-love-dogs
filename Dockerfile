FROM golang:1.23-alpine

WORKDIR /app

COPY go.mod ./

RUN go mod download

COPY app/ .

RUN CGO_ENABLED=0 GOOS=linux go build -o /docker-gs-ping

# Provide the port if defined in .env file
ENV PORT=8080

CMD ["/docker-gs-ping"]
