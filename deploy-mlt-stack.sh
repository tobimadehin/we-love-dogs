echo "Adding Prometheus Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

echo "Updating Helm repositories..."
helm repo update

echo "Installing Prometheus stack..."
helm upgrade --install prometheus-community prometheus-community/kube-prometheus-stack

echo "Fetching Loki stack values..."
helm show values grafana/loki-stack > loki-values.yaml

echo "Installing Loki stack..."
# helm upgrade --install --values loki-values.yaml loki grafana/loki-stack
# helm upgrade --install loki grafana/loki-stack

echo "Waiting for Grafana pod to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana --timeout=3600s

echo "Setting up port forwarding for Grafana..."
kubectl port-forward deployment/prometheus-community-grafana 3000
