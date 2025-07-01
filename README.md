# EGMCP Server - Envoy Gateway MCP Server

[![NPM Version](https://img.shields.io/npm/v/@saptak/egmcp-server)](https://www.npmjs.com/package/@saptak/egmcp-server)
[![GitHub Release](https://img.shields.io/github/release/saptak/eg-mcp-server.svg)](https://github.com/saptak/eg-mcp-server/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A production-ready Model Context Protocol (MCP) server that provides Claude Desktop with comprehensive access to Envoy Gateway configuration, monitoring, and **complete traffic management capabilities** with advanced traffic control features.

## 🎯 Overview

The EGMCP Server bridges Claude Desktop and Envoy Gateway, enabling natural language queries and **complete management** of your service mesh infrastructure. Built through **Sprint 4: Advanced Traffic Control**, it provides real-time access to listeners, routes, clusters, full route lifecycle management, and sophisticated traffic engineering capabilities.

## ✨ Key Features

### 🔍 **Monitoring & Discovery** (Sprint 1 & 2)
- **🔌 Real-time Configuration Access**: Live connection to Envoy Gateway admin API
- **📊 Resource Discovery**: Dynamic listing of listeners, routes, and clusters
- **🛠️ Interactive Tools**: 11 specialized tools for complete Envoy Gateway management
- **🔒 Robust Error Handling**: Graceful degradation and timeout protection

### 🚀 **Route Management** (Sprint 3)
- **🛣️ HTTPRoute Creation**: Create routes via natural language
- **🗑️ Route Deletion**: Remove routes with safety validation
- **🔧 Gateway Listener Management**: Add/remove ports and protocols
- **⚡ Generate-Apply-Verify Pattern**: Reliable write operations

### 🎯 **Advanced Traffic Control** (Sprint 4 - NEW!)
- **📊 Traffic Splitting**: Canary deployments with percentage-based traffic distribution
- **⚖️ Load Balancing**: Configure policies (Round Robin, Least Request, Random, Ring Hash, Maglev)
- **🏥 Health Checks**: Backend service health monitoring configuration
- **🛡️ Traffic Policies**: Rate limiting, authentication, CORS, and timeout policies

### 🛡️ **Production Safety**
- **🔒 Read-Only Mode**: Safe monitoring without modification risk
- **🧪 Dry-Run Mode**: Generate YAML manifests without applying
- **✅ Comprehensive Validation**: RFC 1123 compliant resource names, hostnames, ports
- **🚫 Conflict Prevention**: Duplicate resource detection with intelligent checking
- **🔐 RBAC Error Handling**: Clear permission error messages with troubleshooting guidance
- **🏷️ Resource Labeling**: Track EGMCP-managed resources for audit trails
- **⚡ Input Sanitization**: Real-time validation in both dry-run and live modes

### ⚡ **Enhanced Capabilities**
- **🎛️ Multi-Environment Support**: Production, staging, development configs
- **🧪 Edge Case Handling**: Robust error handling for production use
- **📈 Performance Optimized**: Tested for responsiveness with Claude Desktop
- **🔄 Kubernetes Integration**: Full Gateway API resource CRUD operations

## 🎬 Watch the Demo

Check out this YouTube short for a quick demo of the EGMCP server in action:

[![EGMCP Server Demo](https://img.youtube.com/vi/C-Fakrx3fUQ/0.jpg)](https://www.youtube.com/shorts/C-Fakrx3fUQ)

*Note: Demo shows Sprint 2 features. Current version includes comprehensive route management and advanced traffic control!*

## 📖 Documentation

**[📚 Complete User Guide](USER_GUIDE.md)** - Comprehensive installation, configuration, and usage documentation

## 🚀 Quick Start

### 1. Install EGMCP Server

#### Option A: NPX Installation (Recommended - No Install Required)

```bash
# Test the server directly
npx @saptak/egmcp-server stdio-tools --envoy-url http://localhost:19001

# With Kubernetes support for write operations
npx @saptak/egmcp-server stdio-tools --envoy-url http://localhost:19001 --kubernetes.kubeconfig ~/.kube/config
```

For Claude Desktop, configure with:
```json
{
  "mcpServers": {
    "egmcp-server": {
      "command": "npx",
      "args": [
        "@saptak/egmcp-server",
        "stdio-tools",
        "--envoy-url",
        "http://localhost:19001",
        "--kubernetes.kubeconfig",
        "/Users/yourname/.kube/config"
      ],
      "env": {}
    }
  }
}
```

#### For Read-Only Monitoring:
```json
{
  "mcpServers": {
    "egmcp-server": {
      "command": "npx",
      "args": [
        "@saptak/egmcp-server",
        "stdio-tools",
        "--envoy-url",
        "http://localhost:19001",
        "--kubernetes.kubeconfig",
        "/Users/yourname/.kube/config",
        "--kubernetes.read_only"
      ],
      "env": {}
    }
  }
}
```

#### For GitOps Development (Dry-Run Mode):
```json
{
  "mcpServers": {
    "egmcp-server": {
      "command": "npx",
      "args": [
        "@saptak/egmcp-server",
        "stdio-tools",
        "--envoy-url",
        "http://localhost:19001",
        "--kubernetes.dry_run"
      ],
      "env": {}
    }
  }
}
```

#### Option B: Binary Installation

```bash
curl -sSL https://raw.githubusercontent.com/saptak/eg-mcp-server/main/install.sh | bash
```

### 2. Set Up Envoy Gateway Access

```bash
# Automated setup
curl -sSL https://raw.githubusercontent.com/saptak/eg-mcp-server/main/setup-envoy.sh | bash

# Manual setup
kubectl get pods -n envoy-gateway-system
kubectl port-forward -n envoy-gateway-system pod/YOUR_ENVOY_POD 19001:19000
```

### 3. Restart Claude Desktop

Claude Desktop will automatically load the EGMCP server and make all tools available.

## 🛠️ Available Tools

### Available Tools Overview

The EGMCP Server provides **11 specialized tools** for comprehensive Envoy Gateway management:

#### **Read-Only Monitoring Tools** (4 tools)
- **Listeners**: Discover all listeners with their configurations
- **Routes**: Analyze traffic routing and virtual hosts  
- **Clusters**: List backend services and clusters
- **Summary**: Quick configuration overview and health status

#### **Write Operation Tools** (3 tools - Sprint 3)
- **Route Creation**: Create HTTPRoute resources via natural language
- **Route Deletion**: Remove existing routes with safety validation
- **Listener Management**: Add/remove Gateway listeners (ports/protocols)

#### **Advanced Traffic Control** (4 tools - Sprint 4)
- **Traffic Splitting**: Canary deployments with percentage-based distribution
- **Load Balancing**: Configure policies (Round Robin, Least Request, etc.)
- **Health Checks**: Backend service monitoring configuration
- **Traffic Policies**: Rate limiting, authentication, CORS, timeouts

**📖 For detailed tool documentation, parameters, examples, and safety features, see the [Complete User Guide](USER_GUIDE.md#available-tools).**

## 💬 Example Queries

Once installed, you can ask Claude Desktop:

### Configuration Analysis & Monitoring
- *"What's the current status of my Envoy Gateway?"*
- *"Show me all the listeners in Envoy Gateway"*
- *"Analyze my traffic routing configuration"*
- *"List all backend services available"*
- *"Give me a summary of the gateway configuration"*

### Route Management (Sprint 3)
- *"Create a route for my API service on api.example.com that sends traffic to api-service port 8080"*
- *"Add a new route named user-api for users.example.com pointing to user-service:3000"*
- *"Delete the route named test-route"*
- *"Add HTTPS support to my gateway"*
- *"Remove the listener on port 8080 from my gateway"*

### Advanced Traffic Control (Sprint 4 - NEW!)
- *"Shift 20% of traffic from api-v1 to api-v2 for canary testing"*
- *"Configure round robin load balancing for the main gateway listener"*
- *"Set up health checks for the user-api route with 30 second intervals"*
- *"Apply rate limiting of 100 requests per second to the api route"*
- *"Enable CORS for the frontend route allowing example.com origin"*
- *"Add JWT authentication to the admin route"*

### Dry-Run Mode & GitOps (Sprint 4 - NEW!)
- *"Generate YAML manifest for a new route without applying it"*
- *"Show me what changes would be made for traffic splitting without applying them"*
- *"Preview the YAML for adding health checks to my route"*
- *"Run in dry-run mode to validate configurations before deployment"*

### Advanced Route Configuration
- *"Create a route in the production namespace for payments.app.com pointing to payment-svc:8080 with path /api/v1"*
- *"Add an HTTPS listener on port 443 to demo-gateway"*
- *"Show me all routes and then create a new one for my service"*
- *"Gradually shift 10% of user traffic to the new recommendation service"*

### Troubleshooting
- *"Check if there are any listeners on port 8080"*
- *"Find routes that point to the product-service cluster"*
- *"What's the configuration for the https_listener?"*
- *"Why isn't traffic reaching my service?"*

## 📋 System Requirements

### Basic Requirements
- **Operating System**: macOS, Linux, Windows
- **Claude Desktop**: Latest version with MCP support
- **Envoy Gateway**: Any version with admin API enabled
- **Network Access**: Port forwarding or direct access to Envoy Gateway admin API

### For Write Operations (Sprint 3)
- **Kubernetes Access**: kubectl configuration and permissions
- **Gateway API**: Kubernetes cluster with Gateway API CRDs installed
- **RBAC Permissions**: Access to create/modify HTTPRoute and Gateway resources

### Optional
- **Go**: 1.21+ (for building from source)

## 🔧 Configuration

### Key Configuration Options

- `--envoy-url`: Envoy Gateway admin API URL
- `--kubernetes.kubeconfig`: Path to kubeconfig file  
- `--kubernetes.read_only`: Enable read-only mode (safe for production)
- `--kubernetes.dry_run`: Enable dry-run mode (generate manifests without applying)
- `--kubernetes.default_namespace`: Default namespace for operations
- `--log-level`: Logging verbosity (debug, info, warn, error)

### Quick Configuration Examples

#### Production Monitoring (Read-Only)
```json
{
  "args": [
    "stdio-tools", 
    "--envoy-url", "http://prod-envoy:19001",
    "--kubernetes.kubeconfig", "/etc/kubernetes/prod-config",
    "--kubernetes.read_only"
  ]
}
```

#### GitOps Development (Dry-Run Mode)
```json
{
  "args": [
    "stdio-tools", 
    "--envoy-url", "http://localhost:19001",
    "--kubernetes.dry_run"
  ]
}
```

**📖 For complete configuration options, environment variables, multi-environment setup, and detailed examples, see the [Configuration Guide](USER_GUIDE.md#configuration).**

## 🚨 Troubleshooting

### Quick Fixes

#### "Could not attach to MCP Server"
- ✅ Check binary path is absolute: `/usr/local/bin/egmcp-server`
- ✅ Restart Claude Desktop after configuration changes
- ✅ Verify kubeconfig path exists and is accessible

#### "Connection refused" to Envoy Gateway  
- ✅ Run automated setup: `curl -sSL https://raw.githubusercontent.com/saptak/eg-mcp-server/main/setup-envoy.sh | bash`
- ✅ Test connectivity: `curl http://localhost:19001/ready`

#### "Permission denied" for write operations
- ✅ Use read-only mode for monitoring: `--kubernetes.read_only`  
- ✅ Check kubectl access: `kubectl get httproutes`

#### "Route creation fails with validation errors"
- ✅ **Resource Names**: Use lowercase, numbers, hyphens only (`api-service` ✅, `Api_Service` ❌)
- ✅ **Hostnames**: Valid DNS format (`api.example.com` ✅, `invalid hostname` ❌)
- ✅ **Ports**: Must be 1-65535 (8080 ✅, 70000 ❌)

### Testing & Debug

```bash
# Health check
egmcp-server health --envoy-url http://localhost:19001

# Debug mode
egmcp-server stdio-tools --log-level debug --envoy-url http://localhost:19001

# Test read-only mode
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/call", "params": {"name": "create_http_route", "arguments": {"name": "test", "gateway_name": "demo", "hostname": "test.local", "service_name": "svc", "service_port": 8080}}}' | \
  egmcp-server stdio-tools --kubernetes.read_only
```

**📖 For comprehensive troubleshooting, detailed error solutions, validation examples, and testing procedures, see the [Complete Troubleshooting Guide](USER_GUIDE.md#troubleshooting).**

## 🤝 Contributing

We welcome contributions!

- **Issues & Feature Requests**: https://github.com/saptak/eg-mcp-server/issues

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **GitHub Issues**: [Report bugs and request features](https://github.com/saptak/eg-mcp-server/issues)
- **Complete Documentation**: [User Guide](USER_GUIDE.md)

---

**Ready to supercharge your Envoy Gateway management with Claude Desktop? Get started with NPX and experience the power of advanced traffic control!** 🚀

**New to EGMCP Server?** Check out the comprehensive [User Guide](USER_GUIDE.md) for detailed examples and use cases.