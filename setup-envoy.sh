#!/bin/bash

# EGMCP Server - Envoy Gateway Setup Helper
# This script sets up port forwarding from localhost:9901 to Envoy Gateway admin API

set -e

echo "🚀 EGMCP Server - Envoy Gateway Setup"
echo "====================================="
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl to use this script."
    echo "   Or manually set up port forwarding to your Envoy Gateway admin API."
    exit 1
fi

# Check if we can connect to Kubernetes
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster."
    echo "   Please ensure your kubectl is configured and cluster is accessible."
    exit 1
fi

echo "✅ Kubernetes cluster accessible"

# Look for Envoy Gateway pods
echo "🔍 Looking for Envoy Gateway pods..."

# Try to find Envoy Gateway pods (multiple strategies)
ENVOY_POD=""

# Strategy 1: Look for Envoy Gateway deployment pods
ENVOY_POD=$(kubectl get pods -n envoy-gateway-system -l app.kubernetes.io/name=envoy-gateway -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

# Strategy 2: Look for gateway pods with admin interface
if [ -z "$ENVOY_POD" ]; then
    ENVOY_POD=$(kubectl get pods -n envoy-gateway-system -l gateway.envoyproxy.io/owning-gateway-name -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
fi

# Strategy 3: Look for any pod with "envoy" in the name that has multiple containers (likely has admin interface)
if [ -z "$ENVOY_POD" ]; then
    ENVOY_POD=$(kubectl get pods -n envoy-gateway-system -o json | jq -r '.items[] | select(.spec.containers | length > 1) | select(.metadata.name | contains("gateway")) | .metadata.name' | head -1 2>/dev/null || echo "")
fi

if [ -z "$ENVOY_POD" ]; then
    echo "❌ No suitable Envoy Gateway pod found."
    echo ""
    echo "Available pods in envoy-gateway-system:"
    kubectl get pods -n envoy-gateway-system 2>/dev/null || echo "No pods found in envoy-gateway-system namespace"
    echo ""
    echo "💡 Manual setup:"
    echo "   1. Find your Envoy Gateway pod: kubectl get pods -n envoy-gateway-system"
    echo "   2. Port forward: kubectl port-forward -n envoy-gateway-system pod/YOUR_POD 9901:19000"
    exit 1
fi

echo "✅ Found Envoy Gateway pod: $ENVOY_POD"

# Check if port 9901 is already in use
if lsof -Pi :9901 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️  Port 9901 is already in use"
    echo "   Checking if it's already connected to Envoy Gateway..."
    
    if curl -s http://localhost:9901/ready >/dev/null 2>&1; then
        echo "✅ Port 9901 is already forwarded to Envoy Gateway!"
        echo "   No setup needed. You can now use EGMCP Server with Claude Desktop."
        exit 0
    else
        echo "❌ Port 9901 is in use but not connected to Envoy Gateway"
        echo "   Please stop the process using port 9901 and run this script again."
        echo "   Or use a different port by modifying your Claude Desktop config."
        exit 1
    fi
fi

echo "🔌 Setting up port forwarding..."
echo "   localhost:9901 → $ENVOY_POD:19000"
echo ""
echo "📝 This will make Envoy Gateway admin API accessible to EGMCP Server"
echo "   Keep this terminal open while using Claude Desktop"
echo "   Press Ctrl+C to stop"
echo ""
echo "🎯 After this starts, restart Claude Desktop and ask:"
echo "   'What listeners are configured in Envoy Gateway?'"
echo ""

# Start port forwarding
kubectl port-forward -n envoy-gateway-system pod/$ENVOY_POD 9901:19000