# Obsidian MCP Integration Reference

This document outlines the architecture, local tools, client configuration, and security controls for the private, self-hosted Obsidian Model Context Protocol (MCP) server.

---

## 1. Architecture Overview

To maintain performance and keep your data secure, the server uses a modular **Butler-Librarian** split:

```
┌─────────────────────────────────────── Obsidian ──────────────────────────────────────┐
│                                                                                       │
│  ┌─────────────────────────────── Native MCP Plugin ──────────────────────────────┐  │
│  │                                                                                │  │
│  │   ┌─────────────────────────── Semantic Router ────────────────────────────┐   │  │
│  │   │            (vault | edit | view | graph | bases | dataview)            │   │  │
│  │   └───────────────┬────────────────────────────────────────┬───────────────┘   │  │
│  │                   │                                        │                   │  │
│  │                   ▼ (CRUD Writes)                          ▼ (Semantic Reads)  │  │
│  │             ┌───────────┐                            ┌───────────┐             │  │
│  │             │  Butler   │                            │ Librarian │             │  │
│  │             │  (Local   │                            │ (Local    │             │  │
│  │             │   API)    │                            │  Client)  │             │  │
│  │             └───────────┘                            └─────┬─────┘             │  │
│  └────────────────────────────────────────────────────────────┼───────────────────┘  │
│                                                               │ Local HTTP            │
│                                                               ▼ (Port 7821)           │
│  ┌─────────────────────────────── python-rag Backend ─────────────────────────────┐  │
│  │                                                                                │  │
│  │   ┌───────────────┐        ┌───────────────┐        ┌──────────────────────┐   │  │
│  │   │  FastAPI App  ├───────►│ sqlite-vec DB ├───────►│ networkx DiGraph     │   │  │
│  │   │  (Port 7821)  │        │ (Chroma-less) │        │ (PageRank/backlinks) │   │  │
│  │   └───────────────┘        └───────────────┘        └──────────────────────┘   │  │
│  └────────────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

1. **The Butler (Local writes & CRUD)**: Implemented in-process in TypeScript within the native [obsidian-mcp-plugin](file:///Users/larsboes/Developer/obsidian-mono/obsidian-mcp/obsidian-mcp-plugin). It executes structural edits, daily note creations, and file updates using Obsidian's internal APIs.
2. **The Librarian (Semantic search & RAG)**: Implemented out-of-process in Python via [obsidian-rag](file:///Users/larsboes/Developer/obsidian-mono/obsidian-rag). It indexes note vectors using a lightweight `sqlite-vec` database and maps dependencies using a NetworkX directed graph.

---

## 2. Server Ports & Configuration

- **MCP Plugin Server**: Runs an SSE (Server-Sent Events) HTTP server listening on port `3001` (configurable in Obsidian plugin settings).
- **RAG Backend Daemon**: Runs on port `7821` (configured via `OBSIDIAN_RAG_PORT=7821` in your `.env`).
- **Index Sync Hooks**: The plugin registers file-change hooks (`vault.on('modify')`) to send immediate incremental updates (`POST /index/update`) to the RAG daemon.

---

## 3. Client Configuration

Configure your AI clients to interact with the local MCP server over HTTP SSE:

### Claude Desktop Configuration
Add the server under `mcpServers` in your Claude Desktop configuration file (typically `~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "obsidian-vault": {
      "transport": {
        "type": "http",
        "url": "http://localhost:3001/mcp",
        "headers": {
          "Authorization": "Bearer YOUR_API_KEY"
        }
      }
    }
  }
}
```

### Claude Code Configuration
Run the following CLI command to add the server:

```bash
claude mcp add --transport http obsidian http://localhost:3001/mcp --header "Authorization: Bearer YOUR_API_KEY"
```

---

## 4. Exposed Tool Schema

The plugin provides 8 core tool namespaces:

| Tool Namespace | Actions | Description |
|---|---|---|
| `vault` | `list`, `read`, `create`, `search`, `move`, `split`, `combine` | File operations, semantic search, keyword indexing. |
| `edit` | `append`, `patch`, `replace` | Heading, block, and line-level structural updates. |
| `view` | `active`, `open`, `view` | Interacts with active panels, opens specific tabs. |
| `graph` | `traverse`, `path`, `backlinks` | Explores node linkages, finds connection pathways. |
| `workflow`| `suggest` | Contextual hints, next-action suggestions. |
| `dataview`| `query` | Runs Dataview Query Language (DQL) queries. |
| `bases` | `query`, `export` | Queries database structures and filters schemas. |
| `system` | `status`, `fetch` | Inspects server health, pulls webpage snapshots. |

---

## 5. Secure Remote Exposure (Claude iOS)

Because your vault contains private data, **never port-forward port 3001 directly on your router.** Instead, deploy one of these zero-trust pathways:

### Pathway A: Tailscale Mesh Network (Recommended)
1. Install **Tailscale** on your Mac and iPhone.
2. Enable Tailscale VPN on your iPhone.
3. Configure the MCP client on your iPhone using the Mac's Tailscale private IP address (e.g., `100.x.y.z`):
   ```json
   "url": "http://100.x.y.z:3001/mcp"
   ```

### Pathway B: Cloudflare Tunnel + Mutual TLS (mTLS)
Allows exposing your vault over a public domain name (`mcp.myvault.com`) protected by certificate-based handshakes:
1. **Create Tunnel**: Map `mcp.myvault.com` to `http://localhost:3001` using `cloudflared`.
2. **Setup mTLS**: Generate a Client CA certificate in the Cloudflare Dashboard (SSL/TLS -> Client Certificates).
3. **Install Client Profile**: Package the certificate and private key into a `.p12` profile and install it on your iPhone.
4. **WAF Rules**: Enforce that all requests to `mcp.myvault.com` must present the client certificate.

---

## 6. Security Guardrails

The server enforces zero-trust controls to protect your filesystem:
- **Path Traversal Protection**: All incoming paths are strictly verified to ensure they resolve inside the vault's root directory.
- **Strict `.mcpignore` Checks**: The plugin blocks reading or writing to files or folders matching patterns defined in the `.mcpignore` file located in the vault root.
- **Sandboxed Expression Engine**: Bases filter rules are parsed into an Abstract Syntax Tree (AST) using a safe expression parser instead of unsafe Javascript `eval()`.
