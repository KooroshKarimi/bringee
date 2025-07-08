# Use a smaller, secure base image
FROM golang:1.22-alpine as builder

# Set the working directory
WORKDIR /app

# Copy Go modules and source code
COPY go.mod go.sum ./
COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -v -o server

# Use a minimal image for the final container
FROM alpine:latest

# Set the working directory
WORKDIR /

# Copy the binary from the builder stage
COPY --from=builder /app/server .

# Expose the port the app runs on
EXPOSE 8080

# Run the binary
CMD ["/server"]