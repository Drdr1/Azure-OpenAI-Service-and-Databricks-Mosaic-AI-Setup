output "kong_service_name" {
  description = "Name of the Kong service"
  value       = "${var.name}-kong-proxy"
}

output "kong_service_fqdn" {
  description = "FQDN of the Kong service for use with Application Gateway"
  value       = "${var.name}-kong-proxy.${helm_release.kong.namespace}.svc.cluster.local"
}

output "kong_namespace" {
  description = "Kubernetes namespace where Kong is deployed"
  value       = helm_release.kong.namespace
}

output "kong_status" {
  description = "Status of the Kong Helm release"
  value       = helm_release.kong.status
}

output "kong_service_ip" {
  value       = null
  description = "The IP address of the Kong proxy service (if available)"
}

output "kong_service_hostname" {
  value       = null
  description = "The hostname of the Kong proxy service (if available)"
}
