# EGMCP Server - Envoy Gateway MCP Server

[![NPM Version](https://img.shields.io/npm/v/@saptak/egmcp-server)](https://www.npmjs.com/package/@saptak/egmcp-server)
[![GitHub Release](https://img.shields.io/github/release/saptak/eg-mcp-server.svg)](https://github.com/saptak/eg-mcp-server/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A production-ready Model Context Protocol (MCP) server that provides MCP Client with comprehensive access to Envoy Gateway configuration, monitoring, and **route management capabilities** with full write operations support.

## ✨ Key Features

### 🔍 **Monitoring & Discovery**
- **Real-time Configuration Access**: Live connection to Envoy Gateway admin API
- **Resource Discovery**: Dynamic listing of listeners, routes, and clusters
- **Interactive Tools**: 7 specialized tools for complete Envoy Gateway management
- **Robust Error Handling**: Graceful degradation and timeout protection

### 🚀 **Route Management** (NEW!)
- **HTTPRoute Creation**: Create routes via natural language
- **Route Deletion**: Remove routes with safety validation
- **Gateway Listener Management**: Add/remove ports and protocols
- **Generate-Apply-Verify Pattern**: Reliable write operations

### 🛡️ **Production Safety**
- **Read-Only Mode**: Safe monitoring without modification risk
- **Comprehensive Validation**: Resource name, hostname, port validation
- **Conflict Prevention**: Duplicate resource detection
- **RBAC Error Handling**: Clear permission error messages
- **Resource Labeling**: Track EGMCP-managed resources

## 🎬 Watch the Demo

Check out this YouTube short for a quick demo of the EGMCP server in action:

[![EGMCP Server Demo](https://img.youtube.com/vi/C-Fakrx3fUQ/0.jpg)](https://www.youtube.com/shorts/C-Fakrx3fUQ)

*Note: Demo shows basic features. Latest version includes comprehensive route management capabilities!*

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

For MCP Client, configure with:
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

### 3. Restart MCP Client

MCP Client will automatically load the EGMCP server and make all tools available.

## 🛠️ Available Tools

### Read-Only Monitoring Tools

| Tool | Description | Use Case |
|------|-------------|----------|
| **`list_envoy_listeners`** | List all listeners with configurations | Port and endpoint discovery |
| **`list_envoy_routes`** | List routes and virtual hosts | Traffic routing analysis |
| **`list_envoy_clusters`** | List backend clusters | Service discovery |
| **`get_envoy_config_summary`** | Overall configuration summary | Quick health checks |

### Write Operation Tools (NEW!)

| Tool | Description | Parameters | Safety Features |
|------|-------------|------------|-----------------|
| **`create_http_route`** | Create new HTTPRoute resources | name, namespace, gateway_name, hostname, path, service_name, service_port | Validates inputs, prevents conflicts, Generate-Apply-Verify |
| **`delete_http_route`** | Remove existing HTTPRoute resources | name, namespace | Existence verification, detailed feedback |
| **`modify_listener`** | Add/remove Gateway listeners | gateway_name, namespace, port, protocol, action | Port conflict prevention, protocol validation |
| **`create_grpc_route`** | Create new GRPCRoute resources | name, namespace, gateway_name, hostname, service_name, service_port | Validates inputs, prevents conflicts, Generate-Apply-Verify |
| **`delete_grpc_route`** | Remove existing GRPCRoute resources | name, namespace | Existence verification, detailed feedback |

## 💬 Example Queries

Once installed, you can ask MCP Client:

### Configuration Analysis & Monitoring
- *"What's the current status of my Envoy Gateway?"*
- *"Show me all the listeners in Envoy Gateway"*
- *"Analyze my traffic routing configuration"*
- *"List all backend services available"*

### Route Management (NEW!)
- *"Create a route for my API service on api.example.com that sends traffic to api-service port 8080"*
- *"Add a new route named user-api for users.example.com pointing to user-service:3000"*
- *"Delete the route named test-route"*
- *"Add HTTPS support to my gateway"*
- *"Remove the listener on port 8080 from my gateway"*

### Advanced Route Configuration
- *"Create a route in the production namespace for payments.app.com pointing to payment-svc:8080 with path /api/v1"*
- *"Add an HTTPS listener on port 443 to demo-gateway"*
- *"Show me all routes and then create a new one for my service"*

### Troubleshooting
- *"Check if there are any listeners on port 8080"*
- *"Find routes that point to the product-service cluster"*
- *"What's the configuration for the https_listener?"*
- *"Why isn't traffic reaching my service?"*

## 📋 System Requirements

### Basic Requirements
- **Operating System**: macOS, Linux, Windows
- **MCP Client**: Latest version with MCP support
- **Envoy Gateway**: Any version with admin API enabled
- **Network Access**: Port forwarding or direct access to Envoy Gateway admin API

### For Write Operations (NEW!)
- **Kubernetes Access**: kubectl configuration and permissions
- **Gateway API**: Kubernetes cluster with Gateway API CRDs installed
- **RBAC Permissions**: Access to create/modify HTTPRoute and Gateway resources


## 🔧 Configuration

### Basic Configuration

```bash
# Read-only monitoring
npx @saptak/egmcp-server stdio-tools --envoy-url http://localhost:19001

# Full management capabilities
npx @saptak/egmcp-server stdio-tools \
  --envoy-url http://localhost:19001 \
  --kubernetes.kubeconfig ~/.kube/config \
  --kubernetes.default_namespace demo

# Production-safe read-only mode
npx @saptak/egmcp-server stdio-tools \
  --envoy-url http://localhost:19001 \
  --kubernetes.kubeconfig ~/.kube/config \
  --kubernetes.read_only
```

### Environment Variables

```bash
export EGMCP_ENVOY_ADMIN_URL="http://localhost:19001"
export EGMCP_LOG_LEVEL="info"
export KUBECONFIG="/path/to/kubeconfig"
```

## 🚨 Troubleshooting

### Common Issues

#### "Could not attach to MCP Server"
- Check that the binary path is correct and absolute
- Verify binary is executable: `chmod +x /path/to/egmcp-server`
- Ensure kubeconfig path exists and is accessible
- Restart MCP Client after configuration changes

#### "Connection refused" to Envoy Gateway
- Ensure port forwarding is active: `kubectl port-forward ...`
- Check Envoy Gateway admin API: `curl http://localhost:19001/ready`
- Verify correct port (19000 for Gateway, not 9901)
- Run automated setup: `curl -sSL .../setup-envoy.sh | bash`

#### "Permission denied" for write operations
- Verify kubectl access: `kubectl get httproutes`
- Check RBAC permissions for Gateway API resources
- Use read-only mode for monitoring: `--kubernetes.read_only`
- Ensure service account has proper cluster role bindings

#### "Route creation fails with validation errors"
- Use lowercase names with hyphens only (no underscores/uppercase)
- Ensure valid DNS hostnames (no special characters)
- Use valid port numbers (1-65535)
- Ensure target namespace exists

## 🤝 Contributing

We welcome contributions!

- **Issues & Feature Requests**: https://github.com/saptak/eg-mcp-server/issues

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **GitHub Issues**: [Report bugs and request features](https://github.com/saptak/eg-mcp-server/issues)
- **Complete Documentation**: [User Guide](USER_GUIDE.md)

---

**Ready to supercharge your Envoy Gateway management with MCP Client? Get started with NPX and experience the power of route management!** 🚀

**New to EGMCP Server?** Check out the comprehensive [User Guide](USER_GUIDE.md) for detailed examples and use cases.