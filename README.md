# EGMCP Server - Envoy Gateway MCP Server

### **Alpha Software - Evaluation Only**

**Warning:** This MCP server is currently in an alpha stage and is **not ready for production use**. It is provided for evaluation purposes only. The authors and contributors bear no liability for any damages or issues that may arise from its use.

---

A Model Context Protocol (MCP) server that connects Claude Desktop to Envoy Gateway, enabling natural language queries about your service mesh configuration.

## 🚀 Quick Start

### 1. Install EGMCP Server

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

### 3. Configure Claude Desktop

The installer automatically configures Claude Desktop, but you can verify at:

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`  
**Linux:** `~/.config/Claude/claude_desktop_config.json`

Should contain:
```json
{
  "mcpServers": {
    "egmcp-server": {
      "command": "/usr/local/bin/egmcp-server",
      "args": ["stdio-tools", "--envoy-url", "http://localhost:9901"],
      "env": {}
    }
  }
}
```

### 4. Restart Claude Desktop

Restart Claude Desktop to load the EGMCP server.

### 5. Test the Connection

Ask Claude: *"What listeners are configured in Envoy Gateway?"*

## 🔧 Troubleshooting

### "Server disconnected" Error

**Most common cause:** Envoy Gateway admin API not accessible on localhost:9901

**Quick fix:**
1. Ensure port forwarding is running: `curl http://localhost:9901/ready`
2. Test EGMCP health: `egmcp-server health --envoy-url http://localhost:9901`
3. Restart Claude Desktop

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

## 📋 System Requirements

- **Claude Desktop**: Latest version with MCP support
- **Envoy Gateway**: Any version with admin API enabled
- **Network Access**: Port forwarding or direct access to admin API (port 9901)
- **OS**: macOS, Linux, or Windows

## 🆘 Support

- **Issues**: [Report problems](https://github.com/saptak/eg-mcp-server/issues)
- **Source Code**: [Development repository](https://github.com/saptak/egmcp)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Need help?** The most common issue is Envoy Gateway connectivity. Ensure port forwarding is active: `kubectl port-forward -n envoy-gateway-system pod/YOUR_ENVOY_POD 9901:19000`