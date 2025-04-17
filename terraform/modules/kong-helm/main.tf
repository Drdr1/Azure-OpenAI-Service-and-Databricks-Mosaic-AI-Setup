resource "helm_release" "kong" {
  name             = var.name
  repository       = "https://charts.konghq.com"
  chart            = "kong"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  
  # Deployment settings for better reliability
  timeout       = var.helm_timeout
  wait          = true
  atomic        = true
  recreate_pods = true
  max_history   = 5

  values = [
    templatefile("${path.module}/values.yaml", {
      image_repository = var.use_acr_credentials ? "${var.acr_login_server}/kong" : "kong"
      image_tag        = var.image_tag
      replica_count    = var.replica_count
      service_type     = var.service_type
      internal_lb      = var.internal_lb ? "true" : "false"
      cpu_request      = var.cpu_request
      memory_request   = var.memory_request
      cpu_limit        = var.cpu_limit
      memory_limit     = var.memory_limit
    })
  ]
  
  # Ensure this depends on the AKS cluster being fully provisioned
  depends_on = [
    var.aks_dependency
  ]
}

# Use a local value for the service name and FQDN
locals {
  kong_proxy_service_name = "${var.name}-kong-proxy"
  kong_service_fqdn = "${local.kong_proxy_service_name}.${var.namespace}.svc.cluster.local"
}

# Output the Kong service details for use in other configurations
# Only fetch the service data if we're not in a plan phase
# data "kubernetes_service" "kong_proxy" {
#   #count = var.fetch_kubernetes_resources ? 1 : 0
  
#   metadata {
#     name      = local.kong_proxy_service_name
#     namespace = var.namespace
#   }
#   depends_on = [
#     helm_release.kong
#   ]
# }





