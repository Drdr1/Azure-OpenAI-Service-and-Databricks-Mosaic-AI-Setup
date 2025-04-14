subscription_id = "955faad9-ebe9-4a85-9974-acae429ae877"
environment = "dev"
location = "eastus"
gpt35_capacity = 1
gpt4_capacity = 1
allowed_ip_ranges = ["0.0.0.0/0"] # Replace with actual IP ranges for development
alert_email = "dev-team@example.com"
tags = {
  Environment = "Development"
  Project = "OpenAI Platform"
  ManagedBy = "Terraform"
}