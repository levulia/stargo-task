#!/bin/bash

# Exit on any error
set -e

# Start Minikube if not running
if ! minikube status | grep -q "Running"; then
    echo "Starting Minikube..."
    minikube start --driver=docker
fi

# Check for data.rdb
if [ ! -f "/lib/var/redis/data.rdb" ]; then
  echo "Error: data.rdb not found at /lib/var/redis/data.rdb"
  exit 1
fi

# Copy data.rdb to Minikube and set permissions
echo "Copying data.rdb to Minikube..."
minikube ssh "sudo mkdir -p /lib/var/redis"
minikube cp /lib/var/redis/data.rdb /lib/var/redis/data.rdb
minikube ssh "sudo chmod 644 /lib/var/redis/data.rdb"
minikube ssh "sudo chown 1001:1001 /lib/var/redis/data.rdb"

# Build Go server
echo "Building Go server..."
tar -xf music_app.tar
go build -o server main.go
chmod +x server

# Create Docker image for server
echo "Building Docker image..."
cat << EOF > Dockerfile
FROM golang:1.24
WORKDIR /app
COPY server .
EXPOSE 9090
CMD ["./server", "redis-service:6379"]
EOF

docker build -t music-app:latest .
minikube image load music-app:latest

# Apply Kubernetes configurations
echo "Deploying Kubernetes resources..."
kubectl apply -f redis-secret.yaml
kubectl apply -f redis-deployment.yaml
kubectl apply -f music-app-deployment.yaml

# Wait for deployments to be ready
kubectl wait --for=condition=available deployment/redis --timeout=120s || { echo "Redis deployment failed"; kubectl describe pod -l app=redis; exit 1; }
kubectl wait --for=condition=available deployment/music-app --timeout=120s || { echo "Music app deployment failed"; kubectl logs -l app=music-app; exit 1; }

# Port forward to access the application
echo "Setting up port forwarding..."
kubectl port-forward svc/music-app-service 9090:9090 &
echo "Application available at http://localhost:9090"

echo "Deployment completed successfully!"
