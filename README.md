# Dog API Monitoring with Prometheus and Grafana

This repository provides a simple Go-based server that serves random dog images through an API endpoint and demonstrates how to monitor key metrics (API response times, button presses, error rates) using Prometheus and Grafana.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
  - [Install Rancher](#install-rancher)
  - [Install K3d](#install-k3d)
  - [Install Helm](#install-helm)
- [Running the Application](#running-the-application)
- [Configuring Prometheus and Grafana](#configuring-prometheus-and-grafana)
- [Testing the Monitoring Setup](#testing-the-monitoring-setup)

---

## Prerequisites

- Docker installed on your system
- Basic understanding of Kubernetes and Helm
- Access to Rancher and K3d (Local kubernetes environment)

---

## Installation Steps

### Install Rancher

1. **Pull Rancher Docker Image**:
   ```bash
   docker run -d --restart=unless-stopped \
       -p 80:80 -p 443:443 \
       --name rancher \
       rancher/rancher
   ```

2. **Access Rancher**:
   Open `https://localhost` in your browser and configure Rancher.

3. **Create a Cluster**:
   - Use Rancher to create and manage a K3d Kubernetes cluster.

### Install K3d

1. **Install K3d**:
   ```bash
   curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
   ```

2. **Create a Cluster**:
   ```bash
   k3d cluster create mycluster
   ```

3. **Check Cluster Status**:
   ```bash
   kubectl get nodes
   ```

### Install Helm

1. **Install Helm**:
   ```bash
   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   ```

2. **Verify Installation**:
   ```bash
   helm version
   ```

---

## Running the Application

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Build and Run the Application**:
   ```bash
   go run main.go
   ```

3. **Access the Application**:
   Open `http://localhost:8080` to use the application.

---

## Configuring Prometheus and Grafana

### Install Prometheus and Grafana using Helm

1. **Add Prometheus Community Helm Repo**:
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   ```

2. **Install the Kube Prometheus Stack**:
   ```bash
   helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
       --namespace monitoring --create-namespace
   ```

3. **Verify Pods**:
   ```bash
   kubectl get pods -n monitoring
   ```

### Access Prometheus and Grafana

1. **Port Forward Prometheus**:
   ```bash
   kubectl port-forward -n monitoring svc/prometheus-stack-kube-prometheus-prometheus 9090:9090
   ```
   Access Prometheus at `http://localhost:9090`.

2. **Port Forward Grafana**:
   ```bash
   kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80
   ```
   Access Grafana at `http://localhost:3000`. Use the default credentials:
   - Username: `admin`
   - Password: `prom-operator`

3. **Add Prometheus as a Data Source**:
   - Open Grafana.
   - Navigate to Configuration > Data Sources.
   - Add a new Prometheus data source using `http://prometheus-stack-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090`.

### Import Grafana Dashboards

1. Go to Grafana and click **Dashboards** > **Import**.
2. Use a predefined dashboard ID (e.g., `1860` for Kubernetes cluster metrics).

---

## Testing the Monitoring Setup

1. **Simulate API Requests**:
   Use a tool like `curl` or Postman to make requests to the `/api/dog` endpoint:
   ```bash
   curl http://localhost:8080/api/dog
   ```

2. **Check Metrics in Prometheus**:
   Query for metrics like `http_server_requests_total` to see request counts.

3. **Visualize in Grafana**:
   Create custom dashboards to visualize metrics like:
   - Total API requests
   - Response times
   - Error rates

---

Enjoy monitoring your application!
