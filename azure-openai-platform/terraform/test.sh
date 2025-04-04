#!/bin/bash
APPGW_IP=$(terraform output -raw appgw_public_ip)
curl -X POST "https://${APPGW_IP}/api/test" \
-H "Content-Type: application/json" \
-d '{"prompt": "Test integration", "model": "gpt-4"}'
