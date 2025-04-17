# Manual Testing Guide for OpenAI Platform

This guide provides step-by-step instructions for manually testing the OpenAI Platform components, helping you understand the flow from Application Gateway to Kong to the OpenAI service.

## Prerequisites

- A web browser or curl
- Access to Azure Portal (optional)
- Access to Kubernetes cluster (optional)

## Testing Flow Overview

The request flow through the platform is:

```
User → Application Gateway (4.236.134.0) → Kong API Gateway (128.203.125.112) → OpenAI Service
```

## 1. Testing the Application Gateway

The Application Gateway serves as the entry point to our platform.

### 1.1 Testing the Root Path

**Using curl:**
```bash
curl -v http://4.236.134.0/
```

**Expected result:**
- HTTP 200 OK response
- HTML page with "Kong is healthy!" message

### 1.2 Testing the Health Check Endpoint

**Using curl:**
```bash
curl -v http://4.236.134.0/health
```

**Expected result:**
- HTTP 200 OK response
- HTML page with "Kong is healthy!" message

### 1.3 Testing the OpenAI Endpoint

**Using curl:**
```bash
curl -v http://4.236.134.0/openai/
```

**Expected result:**
- HTTP 200 OK response
- HTML page with "OpenAI Mock Service" message

## 2. Testing the Kong API Gateway Directly

Testing Kong directly helps verify that the API Gateway is functioning correctly.

### 2.1 Testing the Root Path

**Using curl:**
```bash
curl -v http://128.203.125.112/
```

**Expected result:**
- HTTP 200 OK response
- HTML page with "Kong is healthy!" message

### 2.2 Testing the Health Check Endpoint

**Using curl:**
```bash
curl -v http://128.203.125.112/health
```

**Expected result:**
- HTTP 200 OK response
- HTML page with "Kong is healthy!" message

### 2.3 Testing the OpenAI Endpoint

**Using curl:**
```bash
curl -v http://128.203.125.112/openai/
```

**Expected result:**
- HTTP 200 OK response
- HTML page with "OpenAI Mock Service" message

## 3. Understanding the Flow

When you make a request to the Application Gateway:

1. The request first hits the Application Gateway (4.236.134.0)
2. The Application Gateway routes the request to Kong API Gateway (128.203.125.112)
3. Kong API Gateway processes the request and routes it to the appropriate backend service:
   - Root path ("/") → Health Check Service
   - Health path ("/health") → Health Check Service
   - OpenAI path ("/openai/") → OpenAI Mock Service
4. The backend service processes the request and returns a response
5. The response flows back through Kong and the Application Gateway to the user

## 4. Testing with Different HTTP Methods

### 4.1 Testing with Headers

**Using curl:**
```bash
curl -v http://4.236.134.0/openai/ \
  -H "Accept: application/json"
```

**Expected result:**
- Response may vary depending on implementation

## 5. Troubleshooting Common Issues

### 5.1 Application Gateway Returns 502 Bad Gateway

This indicates that the Application Gateway cannot connect to Kong.

**Possible solutions:**
- Verify Kong service is running: `kubectl get pods -n kong`
- Check if Kong service IP is correct in Application Gateway backend pool
- Ensure health probe is configured correctly

### 5.2 Kong Returns 404 Not Found

This indicates that the route is not configured in Kong.

**Possible solutions:**
- Verify Kong routes: `kubectl get ingress -A`
- Check if the path is correct in your request
- Ensure the Ingress resources are properly configured

### 5.3 OpenAI Service Not Responding

**Possible solutions:**
- Verify OpenAI service is running: `kubectl get pods -n default -l app=openai-mock`
- Check OpenAI service logs: `kubectl logs -n default deployment/openai-mock`
- Ensure the service is properly configured in Kong routes

### 6. Backend Health Verification

#### 6.1 Application Gateway Backend Health
```bash
# Check Application Gateway backend health via Azure CLI
az network application-gateway show-backend-health \
  --resource-group dev-openai-rg \
  --name dev-openai-appgw
```
Expected result: Output showing "Healthy" status for backend pools

#### 6.2 Kong Pods Status
```bash
# Check Kong pods status
kubectl get pods -n kong
```
Expected result: All pods should be in "Running" state with status "Ready"

#### 6.3 OpenAI Service Pods
```bash
# Check OpenAI service pods
kubectl get pods -n default -l app=openai-mock
```
Expected result: All pods should be in "Running" state with status "Ready"


## 7. Advanced Testing

### 7.1 Testing Latency

**Using curl with time measurement:**
```bash
time curl -s http://4.236.134.0/openai/ > /dev/null
```

**Expected result:**
- Response time should be under 500ms for optimal performance

### 7.2 Testing with Query Parameters

**Using curl:**
```bash
curl -v "http://4.236.134.0/openai/?param=value"
```

**Expected result:**
- The request should be properly routed to the OpenAI service with the query parameters

## 8. Understanding Response Headers

When examining responses with curl's verbose mode (-v), pay attention to these headers:

- `Server: kong/3.5.0` - Indicates the request was processed by Kong
- `X-Kong-Upstream-Latency` - Time taken by the upstream service to respond
- `X-Kong-Proxy-Latency` - Time taken by Kong to process the request
- `Via: kong/3.5.0` - Another indicator that the request went through Kong

These headers confirm that your request is flowing through the Kong API Gateway as expected.

## Conclusion

By following this manual testing guide, you should have a clear understanding of how requests flow through the OpenAI Platform from the Application Gateway to Kong to the backend services. This knowledge will help you troubleshoot issues and develop applications that integrate with the platform.

If you encounter any issues during testing, refer to the troubleshooting section or run the automated end-to-end testing script for more detailed diagnostics.