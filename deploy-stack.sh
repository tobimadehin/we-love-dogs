# bin/bash

echo "Building Docker image..."
docker build . -t we-love-dogs:latest

echo "Creating registry..."
k3d registry create my-app-registry --port 5050

echo "Creating cluster..."
k3d cluster create my-cluster -p "9900:80@loadbalancer" --registry-use k3d-my-app-registry:5050 --registry-config k8s/registries.yaml

echo "Importing image to cluster..."
k3d image import we-love-dogs:v0.1 -c my-cluster

echo "Tagging image..."
docker tag we-love-dogs:latest localhost:5050/we-love-dogs:v0.1

echo "Pushing image to registry..."
docker push localhost:5050/we-love-dogs:v0.1

echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/deployment.yaml

echo "Creating Kubernetes service..."
kubectl apply -f k8s/service.yaml

echo "Creating Kubernetes ingress..."
kubectl apply -f k8s/ingress.yaml

echo "Starting Deployment..."
sh ./deploy-mlt-stack.sh