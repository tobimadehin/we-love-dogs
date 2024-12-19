# bin/bash

echo "Adding Prometheus Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

echo "Updating Helm repositories..."
helm repo update

echo "Installing Prometheus stack..."
helm upgrade --install --values prometheus-stack-values.yaml prometheus-community prometheus-community/kube-prometheus-stack 

echo "Installing Loki stack..."
helm upgrade --install --values loki-stack-values.yaml loki grafana/loki-stack

echo "Waiting for all pods to be ready. This could take a bit..."

# List of pods and their expected container readiness counts
declare -A pod_requirements=(
  ["app"]="1/1"
  ["prometheus-community-prometheus-node-exporter"]="1/1"
  ["prometheus-community-kube-operator"]="1/1"
  ["prometheus-community-kube-state-metrics"]="1/1"
  ["alertmanager-prometheus-community-kube-alertmanager"]="2/2"
  ["prometheus-prometheus-community-kube-prometheus"]="2/2"
  ["loki"]="1/1"
  ["loki-promtail"]="1/1"
  ["prometheus-community-grafana"]="3/3"
)

# Function to check pod readiness
check_pod_ready() {
  local pod_prefix=$1
  local expected=$2
  kubectl get pods --no-headers | grep "^${pod_prefix}" | awk '{print $2}' | grep -q "${expected}"
}

# Loop through all pods and check readiness
for pod in "${!pod_requirements[@]}"; do
  expected="${pod_requirements[$pod]}"
  echo "Checking readiness for pods starting with: ${pod}, expecting: ${expected}"
  until check_pod_ready "${pod}" "${expected}"; do
    echo "Pod(s) with prefix ${pod} are not ready yet. Retrying in 5 seconds..."
    sleep 5
  done
  echo "Pod(s) with prefix ${pod} are ready!"
done

echo "All pods are ready!"
echo "Setting up port forwarding for Grafana and Prometheus..."
kubectl port-forward deployment/prometheus-community-grafana 3000 & 
kubectl port-forward prometheus-prometheus-community-kube-prometheus-0 9090:9090