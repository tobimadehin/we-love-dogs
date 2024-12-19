# main.tf
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create a new Kubernetes cluster
resource "digitalocean_kubernetes_cluster" "we_love_dogs_cluster" {
  name    = "we-love-dogs-cluster"
  region  = var.region
  version = "1.28.2-do.0"  # Latest stable version

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-4gb"  # Basic node size, adjust as needed
    auto_scale = true
    min_nodes  = 2
    max_nodes  = 4
  }
}

# Configure kubernetes provider
provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.we_love_dogs_cluster.endpoint
  token = digitalocean_kubernetes_cluster.we_love_dogs_cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.we_love_dogs_cluster.kube_config[0].cluster_ca_certificate
  )
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host  = digitalocean_kubernetes_cluster.we_love_dogs_cluster.endpoint
    token = digitalocean_kubernetes_cluster.we_love_dogs_cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.we_love_dogs_cluster.kube_config[0].cluster_ca_certificate
    )
  }
}

# Create Container Registry
resource "digitalocean_container_registry" "we_love_dogs_registry" {
  name                   = "we-love-dogs"
  subscription_tier_slug = "basic"
}

# Create container registry docker credentials
resource "digitalocean_container_registry_docker_credentials" "we_love_dogs_credentials" {
  registry_name = digitalocean_container_registry.we_love_dogs_registry.name
}

# Deploy Kubernetes resources
resource "kubernetes_deployment" "app" {
  metadata {
    name = "app"
    labels = {
      app = "app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "app"
      }
    }

    template {
      metadata {
        labels = {
          app = "app"
        }
      }

      spec {
        container {
          image = "${digitalocean_container_registry.we_love_dogs_registry.server_url}/we-love-dogs:v0.1"
          name  = "app"

          port {
            container_port = 8080
          }
          port {
            container_port = 8081
          }
        }
      }
    }
  }
}

# Create services
resource "kubernetes_service" "app_service" {
  metadata {
    name = "app-service"
  }

  spec {
    selector = {
      app = kubernetes_deployment.app.metadata[0].labels.app
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "metrics_service" {
  metadata {
    name = "metrics-service"
  }

  spec {
    selector = {
      app = kubernetes_deployment.app.metadata[0].labels.app
    }

    port {
      name        = "metrics"
      port        = 8081
      target_port = 8081
    }

    type = "ClusterIP"
  }
}

# Install Prometheus Stack using Helm
resource "helm_release" "prometheus_stack" {
  name       = "prometheus-community"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  set {
    name  = "nodeExporter.port"
    value = "9201"
  }
}

# Install Loki Stack using Helm
resource "helm_release" "loki_stack" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [helm_release.prometheus_stack]
}
