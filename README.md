# EGMCP Server - Envoy Gateway MCP Server

### **Alpha Software - Evaluation Only**

**Warning:** This MCP server is currently in an alpha stage and is **not ready for production use**. It is provided for evaluation purposes only. The authors and contributors bear no liability for any damages or issues that may arise from its use.

---

An MCP server that provides Claude Desktop with direct access to Envoy Gateway configuration and management capabilities.

## 🎯 Overview

The EGMCP Server bridges Claude Desktop and Envoy Gateway, enabling natural language queries and management of your service mesh infrastructure. It provides real-time access to listeners, routes, and clusters through Claude's interface.

## ✨ Key Features

- **🔌 Real-time Configuration Access**: Live connection to Envoy Gateway admin API
- **🛠️ Interactive Tools**: 4 specialized tools for Envoy Gateway management
- **📊 Resource Discovery**: Dynamic listing of listeners, routes, and clusters
- **🔒 Robust Error Handling**: Graceful degradation and timeout protection
- **⚡ High Performance**: Optimized for responsiveness with Claude Desktop
- **🎛️ Configurable**: Support for different Envoy Gateway deployments

## 🚀 Installation

### Option 1: One-Line Install (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/saptak/eg-mcp-server/main/install.sh | bash
```

This installer will:
- Detect your operating system and architecture
- Download the appropriate binary
- Configure Claude Desktop automatically
- Set up the MCP server for immediate use

### Option 2: Manual Installation

1. **Download the binary for your platform:**

   **macOS (Intel):**
   ```bash
   curl -L -o egmcp-server https://github.com/saptak/eg-mcp-server/releases/latest/download/egmcp-server-darwin-amd64
   ```

   **macOS (Apple Silicon):**
   ```bash
   curl -L -o egmcp-server https://github.com/saptak/eg-mcp-server/releases/latest/download/egmcp-server-darwin-arm64
   ```

   **Linux (x64):**
   ```bash
   curl -L -o egmcp-server https://github.com/saptak/eg-mcp-server/releases/latest/download/egmcp-server-linux-amd64
   ```

   **Windows (x64):**
   ```powershell
   Invoke-WebRequest -Uri "https://github.com/saptak/eg-mcp-server/releases/latest/download/egmcp-server-windows-amd64.exe" -OutFile "egmcp-server.exe"
   ```

2. **Make it executable and move to PATH:**

   **macOS/Linux:**
   ```bash
   chmod +x egmcp-server
   sudo mv egmcp-server /usr/local/bin/
   ```

   **Windows:**
   Move `egmcp-server.exe` to a directory in your PATH.

3. **Configure Claude Desktop:**

   Edit your Claude Desktop configuration file:

   **macOS:**
   ```bash
   nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

   **Windows:**
   ```cmd
   notepad %APPDATA%\Claude\claude_desktop_config.json
   ```

   **Linux:**
   ```bash
   nano ~/.config/Claude/claude_desktop_config.json
   ```

   Add the EGMCP server configuration:

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

   **Note:** For Windows, use the full path to `egmcp-server.exe` in the `command` field.

4. **Restart Claude Desktop**

## 🔧 Configuration

### Setting up Envoy Gateway Access

The EGMCP server needs access to your Envoy Gateway's admin API. Here are common setup scenarios:

#### For Kind Clusters (Local Development)
```bash
# Find your Envoy Gateway pod
kubectl get pods -n envoy-gateway-system

# Port forward to the admin API
kubectl port-forward -n envoy-gateway-system pod/YOUR_ENVOY_POD 9901:19000
```

#### For Remote Envoy Gateway
Update your Claude Desktop configuration with the remote URL:

```json
{
  "mcpServers": {
    "egmcp-server": {
      "command": "/usr/local/bin/egmcp-server",
      "args": ["stdio-tools", "--envoy-url", "http://your-envoy-gateway.example.com:9901"],
      "env": {}
    }
  }
}
```

#### For Kubernetes Service
```json
{
  "mcpServers": {
    "egmcp-server": {
      "command": "/usr/local/bin/egmcp-server", 
      "args": ["stdio-tools", "--envoy-url", "http://envoy-gateway.envoy-system.svc.cluster.local:9901"],
      "env": {}
    }
  }
}
```

### Advanced Configuration

You can customize the server behavior with additional arguments:

```json
{
  "mcpServers": {
    "egmcp-server": {
      "command": "/usr/local/bin/egmcp-server",
      "args": [
        "stdio-tools", 
        "--envoy-url", "http://localhost:9901",
        "--connect-timeout", "5s",
        "--request-timeout", "10s",
        "--log-level", "info"
      ],
      "env": {}
    }
  }
}
```

## 🛠️ Available Tools

Once installed, the EGMCP server provides these tools to Claude Desktop:

| Tool | Description | Use Case |
|------|-------------|----------|
| **`list_envoy_listeners`** | List all listeners with configurations | Port and endpoint discovery |
| **`list_envoy_routes`** | List routes and virtual hosts | Traffic routing analysis |
| **`list_envoy_clusters`** | List backend clusters | Service discovery |
| **`get_envoy_config_summary`** | Overall configuration summary | Quick health checks |

## 💬 Example Usage

Once installed, you can ask Claude Desktop natural language questions about your Envoy Gateway:

### Configuration Analysis
- *"What's the current status of my Envoy Gateway?"*
- *"Show me all the listeners in Envoy Gateway"*
- *"Analyze my traffic routing configuration"*
- *"List all backend services available"*

### Troubleshooting
- *"Check if there are any listeners on port 8080"*
- *"Find routes that point to the product-service cluster"*
- *"What's the configuration for the https_listener?"*

### Monitoring
- *"Give me a summary of the gateway configuration"*
- *"How many routes are currently configured?"*
- *"What clusters are available for traffic routing?"*

## 🚨 Troubleshooting

### Common Issues

**"Could not attach to MCP Server"**
- Ensure the binary path in your configuration is correct and absolute
- Verify the binary is executable: `chmod +x /usr/local/bin/egmcp-server`
- Restart Claude Desktop after making configuration changes

**"Connection refused" to Envoy Gateway**
- Ensure port forwarding is active (if using Kind)
- Test Envoy Gateway admin API accessibility: `curl http://localhost:9901/ready`
- Verify the admin API is enabled in your Envoy Gateway configuration

**"No tools available" in Claude Desktop**
- Ensure you're using `stdio-tools` in the args, not `stdio-minimal`
- Check that your Claude Desktop configuration includes the server
- Restart Claude Desktop to reload the MCP server

### Debug Mode

To enable debug logging, add `--log-level debug` to your configuration:

```json
{
  "args": ["stdio-tools", "--envoy-url", "http://localhost:9901", "--log-level", "debug"]
}
```

Debug logs will appear in Claude Desktop's console output.

### Testing Connection

You can test the connection manually:

```bash
# Test server health
egmcp-server health --envoy-url http://localhost:9901

# Test MCP communication
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list", "params": {}}' | egmcp-server stdio-tools --envoy-url http://localhost:9901
```

## ⚙️ Uninstallation

To remove the EGMCP server:

1. **Remove from Claude Desktop configuration:**
   Edit your `claude_desktop_config.json` and remove the `egmcp-server` entry from `mcpServers`.

2. **Remove the binary:**
   ```bash
   sudo rm /usr/local/bin/egmcp-server
   ```

3. **Restart Claude Desktop**

## 📋 System Requirements

- **Operating System**: macOS, Linux, Windows
- **Claude Desktop**: Latest version with MCP support
- **Envoy Gateway**: Any version with admin API enabled
- **Network Access**: Port forwarding or direct access to Envoy Gateway admin API

## 🔒 Security Notice

The EGMCP server connects to your Envoy Gateway's admin API. Ensure:
- Admin API access is properly secured in production environments
- Network access to the admin API is restricted as appropriate
- Regular updates are applied to maintain security

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

- **GitHub Issues**: [Report bugs and request features](https://github.com/saptak/eg-mcp-server/issues)
- **Source Code**: [View the source](https://github.com/saptak/egmcp)

---

**Ready to supercharge your Envoy Gateway management with Claude Desktop?** Get started with the [one-line installer](#option-1-one-line-install-recommended)! 🚀