Milestone 1: Deploy Base Models (GPT-3.5-Turbo & GPT-4) and Databricks :

- Objective: Provision Azure OpenAI with GPT-3.5-Turbo and GPT-4 models, plus a Databricks workspace.

What We Did:

- Deployed azurerm_cognitive_account (my-openai-service) with S0 SKU.
Added deployments:
- gpt-35-turbo.
- gpt-4 .
- Created azurerm_databricks_workspace (mosaic-ai-workspace) with premium SKU.

Instructions:

Deploy:

```bash
cd terraform
terraform init
terraform apply -var "subscription_id=955faad9-ebe9-4a85-9974-acae429ae877" -auto-approve
```

Verify:

```bash
az cognitiveservices account deployment list --name my-openai-service --resource-group openai-rg
terraform output databricks_workspace_url
```

Test:

```bash
ENDPOINT=$(terraform output -raw openai_endpoint)
KEY=$(az cognitiveservices account keys list --name my-openai-service --resource-group openai-rg --query key1 -o tsv)
curl -X POST "${ENDPOINT}/openai/deployments/gpt-35-turbo-0125/chat/completions?api-version=2023-05-15" -H "Content-Type: application/json" -H "api-key: ${KEY}" -d '{"messages": [{"role": "user", "content": "Hello"}]}'
```


------

Milestone 2: Deploy Kong API Gateway and Azure Application Gateway :

- Objective: Set up Kong as a containerized API gateway and route traffic through an Application Gateway with WAF

What We Did:

- Created azurerm_container_registry (mykongacr) to host kong:3.6.
- Configured azurerm_container_group (kong-api-gateway) to run Kong (pending successful deployment).
- Deployed azurerm_application_gateway (openai-appgw) with WAF in Prevention mode (pending due to Kong failure).
- Added VNet and subnet for networking.

Instructions:

Push Kong Image (if not done):

```bash
az acr login --name mykongacr
docker pull kong:3.6
docker tag kong:3.6 mykongacr.azurecr.io/kong:3.6
docker push mykongacr.azurecr.io/kong:3.6
```

Deploy:
```bash
terraform apply -var "subscription_id=955faad9-ebe9-4a85-9974-acae429ae877" -auto-approve
```

Verify:

```bash
terraform state list | grep -E "kong|appgw"
terraform output kong_fqdn
terraform output appgw_public_ip
```
Test:

```bash
curl "http://$(terraform output -raw kong_fqdn):8000"
curl "http://$(terraform output -raw appgw_public_ip)"
```
Configure Kong Route:

```bash
OPENAI_KEY=$(az cognitiveservices account keys list --name my-openai-service --resource-group openai-rg --query key1 -o tsv)
curl -X POST "http://$(terraform output -raw kong_fqdn):8001/services" -H "Content-Type: application/json" -d "{\"name\": \"openai-service\", \"url\": \"$(terraform output -raw openai_endpoint)openai/deployments/gpt-35-turbo-0125/chat/completions?api-version=2023-05-15\", \"headers\": {\"api-key\": \"${OPENAI_KEY}\"}}"
curl -X POST "http://$(terraform output -raw kong_fqdn):8001/services/openai-service/routes" -H "Content-Type: application/json" -d '{"paths": ["/openai"]}'
curl -X POST "http://$(terraform output -raw appgw_public_ip)/openai" -H "Content-Type: application/json" -d '{"messages": [{"role": "user", "content": "Test"}]}'
```

------------

Milestone 3: Azure DevOps CI/CD :

Objective: Automate deployment via Azure DevOps pipelines.

What We Did :

- Create openai-pipeline.yml
- Create kong-pipeline.yml
- Create appgw-pipeline.yml

Setup Azure DevOps:
- Create a service connection with SPN credentials.
- Push code to a repo and link the pipeline.

Verify: Check pipeline run logs in Azure DevOps.

---------------

Milestone 4: Monitoring & Alerting Implementation:

Objective: Monitor Application Gateway latency and alert the team.

What We Did:

- Added azurerm_log_analytics_workspace (openai-log-analytics).
- Configured diagnostics for Application Gateway.
- Created action group notify-team and alert high-latency-alert.

---------------

Milestone 5: Automated Quota Management :
 
Objective: Monitor and alert on OpenAI request quotas.

-Rate Limiting and Quota Increase

---------------

Sixth Milestone: End-to-End Integration Test Environment :

- Create Test Environment
- Duplicate Terraform Config
- Create terraform/test-main.tf with a new resource group (test-openai-rg) and apply it separately:
- Create Test Script : terraform/test.sh

---------------


Testing:

Setup Jest Test Suite
1. Initialize:
   ```bash
   cd /azure-openai-platform/tests
   npm init -y
   npm install --save-dev jest axios dotenv
   ```
