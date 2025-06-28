# EGMCP Server - Envoy Gateway MCP Server

### **Alpha Software - Evaluation Only**

**Warning:** This MCP server is currently in an alpha stage and is **not ready for production use**. It is provided for evaluation purposes only. The authors and contributors bear no liability for any damages or issues that may arise from its use.

---

A Model Context Protocol (MCP) server that connects Claude Desktop to Envoy Gateway, enabling natural language queries about your service mesh configuration.

## 📖 Documentation

**[📚 Complete User Guide](USER_GUIDE.md)** - Comprehensive installation, configuration, and usage documentation

## 🚀 Quick Start

### 1. Install EGMCP Server

#### Option A: NPX Installation (Recommended - No Install Required)

```bash
# Test the server directly
npx @saptak/egmcp-server stdio-tools --envoy-url http://localhost:9901

# Use specific version
npx @saptak/egmcp-server@0.2.11 stdio-tools --envoy-url http://localhost:9901
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
        "http://localhost:9901"
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

### 2. Set Up Envoy Gateway Connection

**For Kubernetes/Kind clusters:**
```bash
# Find your Envoy Gateway pod
kubectl get pods -n envoy-gateway-system

# Port forward the admin API (keep this running)
kubectl port-forward -n envoy-gateway-system pod/YOUR_ENVOY_POD 9901:19000
```

**Quick helper script:**
```bash
curl -sSL https://raw.githubusercontent.com/saptak/eg-mcp-server/main/setup-envoy.sh | bash
```

### 3. Restart Claude Desktop

Restart Claude Desktop to load the EGMCP server.

### 4. Test the Connection

Ask Claude: *"What listeners are configured in Envoy Gateway?"*

## 🔧 Troubleshooting

### "Server disconnected" Error

**Most common cause:** Envoy Gateway admin API not accessible on localhost:9901

**Quick fix:**
1. Ensure port forwarding is running: `curl http://localhost:9901/ready`
2. Test EGMCP health: `egmcp-server health --envoy-url http://localhost:9901`
3. Restart Claude Desktop

**For detailed troubleshooting:** See the [User Guide](USER_GUIDE.md#troubleshooting)

### Manual Installation

**Download binary for your platform:**

```bash
# macOS Intel
curl -L -o egmcp-server https://github.com/saptak/eg-mcp-server/releases/latest/download/egmcp-server-darwin-amd64

# macOS Apple Silicon  
curl -L -o egmcp-server https://github.com/saptak/eg-mcp-server/releases/latest/download/egmcp-server-darwin-arm64

# Linux x64
curl -L -o egmcp-server https://github.com/saptak/eg-mcp-server/releases/latest/download/egmcp-server-linux-amd64

# Windows x64
curl -L -o egmcp-server.exe https://github.com/saptak/eg-mcp-server/releases/latest/download/egmcp-server-windows-amd64.exe
```

**Install:**
```bash
chmod +x egmcp-server
sudo mv egmcp-server /usr/local/bin/
```

## 💬 Example Usage

Once connected, you can ask Claude:

- *"Show me all Envoy Gateway listeners"*
- *"What routes are configured?"*
- *"List the backend clusters"*
- *"Give me a summary of the gateway configuration"*
- *"Are there any listeners on port 8080?"*

## 🛠 Available Tools

| Tool | Description |
|------|-------------|
| **`list_envoy_listeners`** | List all listeners with configurations |
| **`list_envoy_routes`** | List routes and virtual hosts |
| **`list_envoy_clusters`** | List backend clusters |
| **`get_envoy_config_summary`** | Overall configuration summary |

**For detailed tool documentation:** See the [User Guide](USER_GUIDE.md#available-tools)

## 📋 System Requirements

- **Claude Desktop**: Latest version with MCP support
- **Envoy Gateway**: Any version with admin API enabled
- **Network Access**: Port forwarding or direct access to admin API (port 9901)
- **OS**: macOS, Linux, or Windows

## 🆘 Support

- **Issues**: [Report problems](https://github.com/saptak/eg-mcp-server/issues)
- **Documentation**: [Complete User Guide](USER_GUIDE.md)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Need help?** The most common issue is Envoy Gateway connectivity. Ensure port forwarding is active: `kubectl port-forward -n envoy-gateway-system pod/YOUR_ENVOY_POD 9901:19000`
EOF < /dev/null