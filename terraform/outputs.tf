# outputs.tf
output "cluster_endpoint" {
  value     = digitalocean_kubernetes_cluster.we_love_dogs_cluster.endpoint
  sensitive = true
}

output "registry_endpoint" {
  value = digitalocean_container_registry.we_love_dogs_registry.server_url
}

output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.we_love_dogs_cluster.kube_config[0].raw_config
  sensitive = true
}
