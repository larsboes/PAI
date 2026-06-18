#!/usr/bin/env bun
/**
 * KnowledgeMcp - thin CLI adapter from the PAI Knowledge skill to semantic-vault-mcp.
 *
 * This keeps the skill router small while moving read-heavy graph/RAG work into the
 * Obsidian plugin. Legacy KnowledgeGraph.ts remains as a recoverable fallback.
 */

import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

type ToolName = "vault" | "graph";

interface CliOptions {
  command: string;
  args: string[];
  top: number;
  hops: number;
  raw: boolean;
  force: boolean;
  port: number;
}

interface McpConfig {
  url: string;
  apiKey: string;
}

interface KnowledgeScope {
  mode: "scoped" | "whole-vault" | "fallback-whole-vault";
  folderFilter?: string;
  includeFolders: string[];
  configuredFolder?: string;
  configuredIncludeFolders: string[];
  missingFolders: string[];
  vaultPath?: string;
}

function loadEnvFile(filePath: string): Record<string, string> {
  if (!fs.existsSync(filePath)) return {};
  const env: Record<string, string> = {};
  for (const rawLine of fs.readFileSync(filePath, "utf8").split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith("#") || !line.includes("=")) continue;
    const idx = line.indexOf("=");
    const key = line.slice(0, idx).trim().replace(/^export\s+/, "");
    let value = line.slice(idx + 1).trim();
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    if (process.env[key] === undefined) {
      process.env[key] = value;
    }
    env[key] = value;
  }
  return env;
}

function loadEnvironment(): void {
  loadEnvFile(path.join(os.homedir(), ".env"));

  const monoRoot = process.env.OBSIDIAN_MONO_PATH ?? path.join(os.homedir(), "Developer", "tmp", "obsidian-mono");
  loadEnvFile(path.join(monoRoot, ".env"));
}

function resolveConfig(port: number): McpConfig {
  const url = process.env.OBSIDIAN_MCP_URL ?? `http://127.0.0.1:${port}/mcp`;
  const explicitApiKey = process.env.OBSIDIAN_MCP_API_KEY ?? process.env.SEMANTIC_VAULT_MCP_API_KEY;
  if (explicitApiKey) {
    return { url, apiKey: explicitApiKey };
  }

  const settingsCandidates = [
    process.env.OBSIDIAN_PLUGINS_PATH
      ? path.join(process.env.OBSIDIAN_PLUGINS_PATH, "semantic-vault-mcp", "data.json")
      : undefined,
    process.env.OBSIDIAN_VAULT_PATH
      ? path.join(process.env.OBSIDIAN_VAULT_PATH, ".obsidian", "plugins", "semantic-vault-mcp", "data.json")
      : undefined
  ].filter((candidate): candidate is string => Boolean(candidate));

  for (const settingsPath of settingsCandidates) {
    if (!fs.existsSync(settingsPath)) continue;
    const settings = JSON.parse(fs.readFileSync(settingsPath, "utf8")) as { apiKey?: string };
    if (settings.apiKey) {
      return { url, apiKey: settings.apiKey };
    }
  }

  throw new Error(
    "Could not resolve MCP API key. Set OBSIDIAN_MCP_API_KEY, SEMANTIC_VAULT_MCP_API_KEY, " +
    "OBSIDIAN_PLUGINS_PATH, or OBSIDIAN_VAULT_PATH."
  );
}

async function requestJson(url: string, apiKey: string, body: unknown, sessionId?: string): Promise<{ ok: boolean; status: number; sessionId?: string; body: unknown }> {
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      "Accept": "application/json, text/event-stream",
      ...(sessionId ? { "mcp-session-id": sessionId } : {})
    },
    body: JSON.stringify(body)
  });

  return {
    ok: response.ok,
    status: response.status,
    sessionId: response.headers.get("mcp-session-id") ?? undefined,
    body: parseSseOrJson(await response.text())
  };
}

function parseSseOrJson(text: string): unknown {
  const dataLine = text.split(/\r?\n/).find(line => line.startsWith("data: "));
  const jsonText = dataLine ? dataLine.slice("data: ".length) : text;
  return jsonText.trim() ? JSON.parse(jsonText) : null;
}

function parseToolText(responseBody: unknown): unknown {
  const body = responseBody as { result?: { content?: Array<{ type?: string; text?: string }> } };
  const text = body.result?.content?.find(item => item.type === "text")?.text;
  if (!text) return responseBody;
  try {
    return JSON.parse(text);
  } catch {
    return { text };
  }
}

async function initialize(config: McpConfig): Promise<string> {
  const response = await requestJson(config.url, config.apiKey, {
    jsonrpc: "2.0",
    id: 1,
    method: "initialize",
    params: {
      protocolVersion: "2025-06-18",
      capabilities: {},
      clientInfo: {
        name: "pai-knowledge-mcp",
        version: "0.1.0"
      }
    }
  });

  if (!response.ok || !response.sessionId) {
    throw new Error(`MCP initialize failed with HTTP ${response.status}`);
  }
  return response.sessionId;
}

async function callTool(config: McpConfig, sessionId: string, tool: ToolName, args: Record<string, unknown>): Promise<unknown> {
  const response = await requestJson(config.url, config.apiKey, {
    jsonrpc: "2.0",
    id: Date.now(),
    method: "tools/call",
    params: {
      name: tool,
      arguments: {
        ...args,
        raw: true
      }
    }
  }, sessionId);

  const parsed = parseToolText(response.body) as { result?: unknown; error?: unknown };
  if (!response.ok || parsed?.error) {
    throw new Error(JSON.stringify(parsed?.error ?? response.body));
  }
  return parsed?.result ?? parsed;
}

function envValue(name: string): string | undefined {
  const value = process.env[name]?.trim();
  return value ? value : undefined;
}

function splitFolders(raw?: string): string[] {
  const seen = new Set<string>();
  const folders: string[] = [];
  for (const item of (raw ?? "").split(",")) {
    const folder = normalizeVaultFolder(item);
    if (!folder || seen.has(folder)) continue;
    seen.add(folder);
    folders.push(folder);
  }
  return folders;
}

function isWholeVaultScope(raw?: string): boolean {
  if (!raw) return true;
  const normalized = raw.trim().replace(/\\/g, "/").replace(/^\/+|\/+$/g, "").toLowerCase();
  return ["", ".", "*", "all", "vault", "whole-vault"].includes(normalized);
}

function normalizeVaultFolder(raw?: string): string | undefined {
  if (!raw || isWholeVaultScope(raw)) return undefined;
  const normalized = raw.trim().replace(/\\/g, "/").replace(/^\/+|\/+$/g, "");
  if (!normalized || path.isAbsolute(normalized) || /^[a-zA-Z]:/.test(normalized)) return undefined;
  return normalized;
}

function vaultFolderExists(vaultPath: string | undefined, folder: string): boolean {
  if (!vaultPath) return true;
  const candidate = path.join(vaultPath, ...folder.split("/"));
  try {
    return fs.statSync(candidate).isDirectory();
  } catch {
    return false;
  }
}

function resolveKnowledgeScope(): KnowledgeScope {
  const vaultPath = envValue("OBSIDIAN_VAULT_PATH");
  const configuredFolderRaw = envValue("VAULT_KNOWLEDGE") ?? envValue("OBSIDIAN_INDEX_FOLDER_FILTER");
  const configuredFolder = normalizeVaultFolder(configuredFolderRaw);
  const configuredIncludeFolders = splitFolders(envValue("VAULT_KNOWLEDGE_FOLDERS") ?? envValue("OBSIDIAN_INDEX_INCLUDE_FOLDERS"));
  const missingFolders: string[] = [];

  let folderFilter: string | undefined;
  if (configuredFolder && vaultFolderExists(vaultPath, configuredFolder)) {
    folderFilter = configuredFolder;
  } else if (configuredFolder) {
    missingFolders.push(configuredFolder);
  }

  const includeFolders = configuredIncludeFolders.filter(folder => {
    const exists = vaultFolderExists(vaultPath, folder);
    if (!exists) missingFolders.push(folder);
    return exists;
  });

  return {
    mode: folderFilter || includeFolders.length > 0
      ? "scoped"
      : configuredFolder && missingFolders.includes(configuredFolder)
        ? "fallback-whole-vault"
        : "whole-vault",
    folderFilter,
    includeFolders,
    configuredFolder,
    configuredIncludeFolders,
    missingFolders,
    vaultPath
  };
}

function scopedArgs(extra: Record<string, unknown> = {}, options: { ignoreDefaultFilters?: boolean } = {}): Record<string, unknown> {
  const scope = resolveKnowledgeScope();
  return {
    ...(options.ignoreDefaultFilters ? { ignoreDefaultFilters: true } : {}),
    ...(scope.folderFilter ? { folderFilter: scope.folderFilter } : {}),
    ...(scope.includeFolders.length > 0 ? { includeFolders: scope.includeFolders } : {}),
    ...extra
  };
}

function parseArgs(argv: string[]): CliOptions {
  const args = [...argv];
  const command = args.shift() ?? "status";
  let top = 10;
  let hops = 2;
  let raw = false;
  let force = false;
  let port = Number(process.env.OBSIDIAN_MCP_PORT ?? "3001");
  const positionals: string[] = [];

  for (let i = 0; i < args.length; i += 1) {
    const arg = args[i]!;
    if (arg === "--raw") {
      raw = true;
    } else if (arg === "--force" || arg === "--refresh") {
      force = true;
    } else if (arg === "--top" || arg === "--limit") {
      top = Number(args[++i] ?? top);
    } else if (arg === "--hops" || arg === "--depth") {
      hops = Number(args[++i] ?? hops);
    } else if (arg === "--port") {
      port = Number(args[++i] ?? port);
    } else {
      positionals.push(arg);
    }
  }

  return {
    command,
    args: positionals,
    top: Number.isFinite(top) && top > 0 ? top : 10,
    hops: Number.isFinite(hops) && hops > 0 ? hops : 2,
    raw,
    force,
    port: Number.isFinite(port) && port > 0 ? port : 3001
  };
}

async function run(options: CliOptions): Promise<unknown> {
  const config = resolveConfig(options.port);
  const session = await initialize(config);
  const query = options.args.join(" ").trim();

  switch (options.command) {
    case "status": {
      const scope = resolveKnowledgeScope();
      const indexStatus = await callTool(config, session, "vault", {
        action: "index_status",
        lightweight: true,
        ...scopedArgs({}, { ignoreDefaultFilters: true })
      });
      const queueStatus = await callTool(config, session, "vault", {
        action: "index_queue_status"
      });
      return {
        kind: "knowledge_status",
        scope,
        indexStatus,
        queueStatus
      };
    }

    case "stats":
    case "graph":
      if (query) {
        return await callTool(config, session, "graph", {
          action: "traverse",
          sourceTitle: query,
          maxDepth: options.hops,
          maxNodes: 50,
          ...scopedArgs()
        });
      }
      return await callTool(config, session, "graph", {
        action: "vault_stats",
        limit: options.top,
        ...scopedArgs()
      });

    case "hubs":
      return await callTool(config, session, "graph", {
        action: "central_notes",
        limit: options.top,
        force: options.force,
        refresh: options.force,
        ...scopedArgs()
      });

    case "related":
      requireQuery(query, "related <title>");
      return await callTool(config, session, "graph", {
        action: "neighbors",
        sourceTitle: query,
        ...scopedArgs()
      });

    case "traverse":
      requireQuery(query, "traverse <title>");
      return await callTool(config, session, "graph", {
        action: "traverse",
        sourceTitle: query,
        maxDepth: options.hops,
        maxNodes: 75,
        ...scopedArgs()
      });

    case "find":
      requireQuery(query, "find <category>");
      return await callTool(config, session, "graph", {
        action: "find_category",
        category: query,
        limit: options.top,
        ...scopedArgs()
      });

    case "contradictions":
      return await callTool(config, session, "graph", {
        action: "contradictions",
        limit: options.top,
        ...scopedArgs()
      });

    case "retrieve":
      requireQuery(query, "retrieve <query>");
      return await callTool(config, session, "vault", {
        action: "fragments",
        query,
        strategy: "hybrid",
        maxFragments: options.top,
        ...scopedArgs({}, { ignoreDefaultFilters: true })
      });

    case "search":
      requireQuery(query, "search <query>");
      return await callTool(config, session, "vault", {
        action: "search",
        query,
        ranked: true,
        includeSnippets: true,
        pageSize: options.top,
        ...scopedArgs({}, { ignoreDefaultFilters: true })
      });

    case "index-status":
      return await callTool(config, session, "vault", {
        action: "index_status",
        ...scopedArgs({}, { ignoreDefaultFilters: true })
      });

    case "queue-status":
      return await callTool(config, session, "vault", {
        action: "index_queue_status"
      });

    default:
      throw new Error("Commands: status | stats | graph [title] | hubs [--force] | related <title> | traverse <title> [--hops N] | find <category> | retrieve <query> [--top N] | search <query> [--top N] | contradictions [--top N] | index-status | queue-status");
  }
}

function requireQuery(query: string, usage: string): void {
  if (!query) {
    throw new Error(`Usage: ${usage}`);
  }
}

function printIndexStatus(value: Record<string, unknown>): void {
  if (typeof value.message === "string") {
    console.log(value.message);
  }
  console.log(`Indexed: ${value.indexedMarkdownCount ?? value.documentCount ?? 0}/${value.markdownFileCount ?? "?"}`);
  console.log(`Health: ${value.health ?? "unknown"}`);
  console.log(`Ready: ${value.ready === true ? "yes" : "no"}`);
  if (typeof value.vectorCoverageRatio === "number") {
    console.log(`Vector coverage: ${Math.round(value.vectorCoverageRatio * 100)}%`);
  }
  if (typeof value.unindexedMarkdownCount === "number") {
    console.log(`Unindexed: ${value.unindexedMarkdownCount}`);
  }
}

function printQueueStatus(value: Record<string, unknown>): void {
  console.log(`Queue: ${value.queueLength}`);
  console.log(`Enabled: ${value.enabled === true ? "yes" : "no"}`);
  console.log(`Paused: ${value.paused === true ? "yes" : "no"}`);
  console.log(`Running: ${value.running === true ? "yes" : "no"}`);
  if (typeof value.safeStartupMode === "boolean") {
    console.log(`Safe startup: ${value.safeStartupMode ? "yes" : "no"}`);
  }
  if (typeof value.ready === "boolean") {
    console.log(`Ready: ${value.ready ? "yes" : "no"}`);
  }
  if (typeof value.readyQueueLength === "number") {
    console.log(`Ready queue: ${value.readyQueueLength}`);
  }
  if (typeof value.startupDelayMs === "number") {
    console.log(`Startup delay: ${value.startupDelayMs}ms`);
  }
  if (typeof value.retryBackoffMs === "number") {
    console.log(`Retry backoff: ${value.retryBackoffMs}ms`);
  }
  if (typeof value.nextProcessAt === "string") {
    console.log(`Next process: ${value.nextProcessAt}`);
  }
}

function printScope(scope: KnowledgeScope): void {
  const parts = [
    scope.folderFilter,
    ...scope.includeFolders
  ].filter((item): item is string => Boolean(item));

  console.log(`Scope: ${parts.length > 0 ? parts.join(", ") : "whole vault"}`);
  if (scope.missingFolders.length > 0) {
    console.log(`Missing configured folders: ${scope.missingFolders.join(", ")}`);
  }
}

function printResult(result: unknown, raw: boolean): void {
  if (raw) {
    console.log(JSON.stringify(result, null, 2));
    return;
  }

  const value = result as Record<string, unknown>;
  if (value.kind === "knowledge_status") {
    const scope = value.scope as KnowledgeScope | undefined;
    const indexStatus = value.indexStatus as Record<string, unknown> | undefined;
    const queueStatus = value.queueStatus as Record<string, unknown> | undefined;
    if (scope) {
      printScope(scope);
      console.log("");
    }
    if (indexStatus) {
      printIndexStatus(indexStatus);
    }
    if (queueStatus?.available === true && typeof queueStatus.queueLength === "number") {
      console.log("");
      printQueueStatus(queueStatus);
    }
    return;
  }

  if (typeof value.message === "string") {
    console.log(value.message);
  }

  if (typeof value.documentCount === "number" || typeof value.markdownFileCount === "number") {
    printIndexStatus(value);
    return;
  }

  if (value.available === true && typeof value.queueLength === "number") {
    printQueueStatus(value);
    return;
  }

  if (value.vaultStats && typeof value.vaultStats === "object") {
    const stats = value.vaultStats as Record<string, unknown>;
    console.log(`Nodes: ${stats.totalNodes ?? 0}`);
    console.log(`Edges: ${stats.totalEdges ?? 0}`);
    console.log(`Orphans: ${stats.orphanCount ?? 0}`);
    console.log(`Edge types: ${JSON.stringify(stats.edgeTypes ?? {})}`);
    const categories = Array.isArray(stats.topCategories) ? stats.topCategories.slice(0, 10) : [];
    if (categories.length > 0) {
      console.log("Top categories:");
      for (const category of categories as Array<{ category: string; count: number }>) {
        console.log(`- ${category.category}: ${category.count}`);
      }
    }
    return;
  }

  if (Array.isArray(value.result)) {
    for (const item of value.result.slice(0, 20) as Array<Record<string, unknown>>) {
      console.log(`- ${item.docPath ?? item.path ?? item.title ?? JSON.stringify(item)}`);
      if (typeof item.score === "number") {
        console.log(`  score: ${item.score.toFixed(4)}`);
      }
      if (typeof item.text === "string") {
        console.log(`  ${item.text.replace(/\s+/g, " ").slice(0, 240)}`);
      }
    }
    return;
  }

  if (Array.isArray(value.nodes)) {
    for (const node of value.nodes.slice(0, 30) as Array<Record<string, unknown>>) {
      console.log(`- ${node.title ?? node.path}`);
      if (node.path) console.log(`  ${node.path}`);
    }
    return;
  }

  if (Array.isArray(value.contradictions)) {
    for (const candidate of value.contradictions.slice(0, 20) as Array<Record<string, unknown>>) {
      const left = candidate.left as Record<string, unknown>;
      const right = candidate.right as Record<string, unknown>;
      console.log(`- ${left.title} <-> ${right.title}`);
      console.log(`  shared: ${(candidate.sharedCategories as string[] ?? []).join(", ")}`);
      console.log(`  score: ${candidate.score}`);
    }
    return;
  }

  console.log(JSON.stringify(result, null, 2));
}

loadEnvironment();
const options = parseArgs(Bun.argv.slice(2));
run(options)
  .then(result => printResult(result, options.raw))
  .catch(error => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exit(1);
  });
