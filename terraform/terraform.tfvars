subscription_id = "955faad9-ebe9-4a85-9974-acae429ae877"
environment = "dev"
location = "eastus"
gpt35_capacity = 1
gpt4_capacity = 1
allowed_ip_ranges = ["128.203.125.112"] # Replace with actual IP ranges for development
alert_email = "dev-team@example.com"
tags = {
  Environment = "Development"
  Project = "OpenAI Platform"
  ManagedBy = "Terraform"
}

# New variable values for AKS and Kong
aks_node_count = 2
aks_vm_size = "Standard_D2s_v3"
kong_replica_count = 2