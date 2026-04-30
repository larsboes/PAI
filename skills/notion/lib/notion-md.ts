/**
 * Notion Block to Markdown Converter
 * Converts Notion block trees to Markdown format.
 *
 * Blocks may carry pre-fetched `.children` arrays (set by the CLI's
 * recursive fetcher).  The converter walks those children inline so
 * that toggles, callouts, columns, tables, and nested lists render
 * their full content.
 */

import type { Block as BaseBlock, RichText, Color } from "../references/notion-types.js";

/** Block with optional pre-fetched children */
export type Block = BaseBlock & { children?: Block[] };

const HEADING_PREFIX: Record<string, string> = {
  heading_1: "# ",
  heading_2: "## ",
  heading_3: "### ",
};

export interface MarkdownOptions {
  includeCalloutEmoji?: boolean;
  preserveColors?: boolean;
}

// ============================================================================
// Public API
// ============================================================================

/**
 * Convert an array of Notion blocks to Markdown
 */
export function blocksToMarkdown(
  blocks: Block[],
  options: MarkdownOptions = {},
  indent = ""
): string {
  const lines: string[] = [];

  for (let i = 0; i < blocks.length; i++) {
    const block = blocks[i];
    const line = blockToMarkdown(block, options, indent, blocks, i);
    if (line !== null) {
      lines.push(line);
    }
  }

  return lines.join("\n");
}

// ============================================================================
// Single-block dispatch
// ============================================================================

function blockToMarkdown(
  block: Block,
  options: MarkdownOptions,
  indent: string,
  siblings: Block[],
  index: number
): string | null {
  switch (block.type) {
    // --- Text blocks ---
    case "paragraph":
      return block.paragraph
        ? `${indent}${richTextToMd(block.paragraph.rich_text)}${renderChildren(block, options, indent)}`
        : "";

    case "heading_1":
    case "heading_2":
    case "heading_3": {
      const data = block[block.type];
      if (!data) return "";
      const md = `${indent}${HEADING_PREFIX[block.type]}${richTextToMd(data.rich_text)}`;
      // Toggleable headings can have children
      return md + renderChildren(block, options, indent);
    }

    // --- Lists ---
    case "bulleted_list_item":
      return block.bulleted_list_item
        ? `${indent}- ${richTextToMd(block.bulleted_list_item.rich_text)}${renderChildren(block, options, indent + "  ")}`
        : "";

    case "numbered_list_item": {
      if (!block.numbered_list_item) return "";
      const num = calculateListNumber(siblings, index);
      return `${indent}${num}. ${richTextToMd(block.numbered_list_item.rich_text)}${renderChildren(block, options, indent + "   ")}`;
    }

    case "to_do":
      return block.to_do
        ? `${indent}- [${block.to_do.checked ? "x" : " "}] ${richTextToMd(block.to_do.rich_text)}${renderChildren(block, options, indent + "  ")}`
        : "";

    // --- Containers ---
    case "toggle":
      if (!block.toggle) return "";
      return `${indent}<details>\n${indent}<summary>${richTextToMd(block.toggle.rich_text)}</summary>\n\n${renderChildren(block, options, indent)}\n${indent}</details>`;

    case "column_list":
      return renderColumnList(block, options, indent);

    case "column":
      // Columns are rendered by column_list; standalone fallback:
      return renderChildren(block, options, indent).trim() || null;

    // --- Code / Quote / Callout ---
    case "code":
      if (!block.code) return "";
      return `${indent}\`\`\`${block.code.language || ""}\n${block.code.rich_text.map((t) => t.plain_text).join("")}\n${indent}\`\`\``;

    case "quote":
      if (!block.quote) return "";
      return `${indent}> ${richTextToMd(block.quote.rich_text).replace(/\n/g, `\n${indent}> `)}${renderChildren(block, options, indent + "> ")}`;

    case "callout": {
      if (!block.callout) return "";
      const emoji =
        options.includeCalloutEmoji !== false &&
        block.callout.icon?.type === "emoji"
          ? block.callout.icon.emoji + " "
          : "";
      const body = richTextToMd(block.callout.rich_text).replace(/\n/g, `\n${indent}> `);
      return `${indent}> ${emoji}${body}${renderChildren(block, options, indent + "> ")}`;
    }

    case "divider":
      return `${indent}---`;

    // --- Media / Embeds ---
    case "image":
      if (!block.image) return "";
      return `${indent}![${getCaption(block.image.caption)}](${block.image.external?.url || block.image.file?.url || ""})`;

    case "file": {
      if (!block.file) return "";
      const url = block.file.external?.url || block.file.file?.url || "";
      const caption = block.file.caption?.length
        ? getCaption(block.file.caption)
        : "File";
      return `${indent}[📎 ${caption}](${url})`;
    }

    case "pdf": {
      if (!block.pdf) return "";
      const url = block.pdf.external?.url || block.pdf.file?.url || "";
      const caption = block.pdf.caption?.length
        ? getCaption(block.pdf.caption)
        : "PDF";
      return `${indent}[📄 ${caption}](${url})`;
    }

    case "video": {
      if (!block.video) return "";
      const url = block.video.external?.url || block.video.file?.url || "";
      const caption = block.video.caption?.length
        ? getCaption(block.video.caption)
        : "Video";
      return `${indent}[🎬 ${caption}](${url})`;
    }

    case "bookmark":
      return block.bookmark
        ? `${indent}[${getCaption(block.bookmark.caption) || block.bookmark.url}](${block.bookmark.url})`
        : "";

    case "link_preview":
      return block.link_preview
        ? `${indent}[${block.link_preview.url}](${block.link_preview.url})`
        : "";

    case "embed":
      return block.embed
        ? `${indent}[Embedded: ${block.embed.url}](${block.embed.url})`
        : "";

    case "equation":
      return block.equation
        ? `${indent}$$${block.equation.expression}$$`
        : "";

    // --- Tables ---
    case "table":
      return renderTable(block, options, indent);

    case "table_row":
      // Rendered by renderTable; standalone fallback
      return null;

    // --- References ---
    case "child_page":
      return block.child_page
        ? `${indent}[📄 ${block.child_page.title}](https://notion.so/${block.id.replace(/-/g, "")})`
        : "";

    case "child_database":
      return block.child_database
        ? `${indent}[🗃️ ${block.child_database.title}](https://notion.so/${block.id.replace(/-/g, "")})`
        : "";

    case "link_to_page": {
      const linkedId = block.link_to_page?.page_id || block.link_to_page?.database_id || "";
      return `${indent}[🔗 Linked Page](https://notion.so/${linkedId.replace(/-/g, "")})`;
    }

    // --- Sync / Template ---
    case "synced_block":
      return renderChildren(block, options, indent).trim() || null;

    case "template":
      return block.template
        ? `${indent}<!-- Template: ${richTextToMd(block.template.rich_text)} -->${renderChildren(block, options, indent)}`
        : "";

    case "unsupported":
      return `${indent}<!-- Unsupported block type -->`;

    default:
      return `${indent}<!-- Unknown block type: ${block.type} -->`;
  }
}

// ============================================================================
// Children rendering (uses pre-fetched .children)
// ============================================================================

function renderChildren(block: Block, options: MarkdownOptions, indent: string): string {
  if (!block.children || block.children.length === 0) return "";
  return "\n" + blocksToMarkdown(block.children, options, indent);
}

// ============================================================================
// Column layout → Markdown table (best-effort)
// ============================================================================

/**
 * Render a column_list as either:
 * - A markdown table (if columns have parallel row-like structure)
 * - Sequential sections separated by `|` dividers (fallback)
 */
function renderColumnList(block: Block, options: MarkdownOptions, indent: string): string | null {
  const columns = block.children || [];
  if (columns.length === 0) return null;

  // Simple fallback: render each column's content separated by blank lines
  // with a visual column indicator
  const parts: string[] = [];
  for (const col of columns) {
    const content = renderChildren(col, options, indent).trim();
    if (content) {
      parts.push(content);
    }
  }

  if (parts.length === 0) return null;
  if (parts.length === 1) return parts[0];

  // Join columns with a blank line separator
  return parts.join("\n\n");
}

// ============================================================================
// Table rendering (uses pre-fetched .children)
// ============================================================================

function renderTable(block: Block, options: MarkdownOptions, indent: string): string {
  const rows = block.children || [];
  if (rows.length === 0) return `${indent}<!-- Empty table -->`;

  const hasHeader = block.table?.has_column_header ?? false;
  const lines: string[] = [];

  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    const cells = row.table_row?.table_row?.cells || (row as any).table_row?.cells || [];
    const cellTexts = cells.map((cell: RichText[]) =>
      richTextToMd(cell).replace(/\|/g, "\\|").replace(/\n/g, " ")
    );
    lines.push(`${indent}| ${cellTexts.join(" | ")} |`);

    // Add separator after header row
    if (i === 0 && hasHeader) {
      lines.push(`${indent}| ${cellTexts.map(() => "---").join(" | ")} |`);
    }
  }

  // If no header flag but we still have rows, add separator after first row
  if (!hasHeader && lines.length > 0) {
    const firstCells = rows[0].table_row?.table_row?.cells || (rows[0] as any).table_row?.cells || [];
    lines.splice(1, 0, `${indent}| ${firstCells.map(() => "---").join(" | ")} |`);
  }

  return lines.join("\n");
}

// ============================================================================
// Rich Text → Markdown
// ============================================================================

function richTextToMd(richText: RichText[]): string {
  return richText
    .map((text) => {
      let content = text.plain_text;

      // Apply annotations
      if (text.annotations.code) {
        content = `\`${content}\``;
      } else {
        // Only apply formatting to non-code spans
        if (text.annotations.bold) {
          content = `**${content}**`;
        }
        if (text.annotations.italic) {
          content = `*${content}*`;
        }
        if (text.annotations.strikethrough) {
          content = `~~${content}~~`;
        }
        if (text.annotations.underline) {
          content = `<u>${content}</u>`;
        }
      }

      // Handle links
      if (text.href) {
        content = `[${content}](${text.href})`;
      }

      return content;
    })
    .join("");
}

function getCaption(caption: RichText[]): string {
  return caption.map((t) => t.plain_text).join("");
}

// ============================================================================
// Helpers
// ============================================================================

function calculateListNumber(blocks: Block[], index: number): number {
  let number = 1;
  for (let i = index - 1; i >= 0; i--) {
    if (blocks[i].type === "numbered_list_item") {
      number++;
    } else if (
      blocks[i].type !== "bulleted_list_item" &&
      blocks[i].type !== "to_do"
    ) {
      break;
    }
  }
  return number;
}

/**
 * Extract title from page properties
 */
export function extractTitle(properties: Record<string, unknown>): string {
  const titleProp = Object.values(properties).find(
    (p): p is { title: Array<{ plain_text: string }> } =>
      typeof p === "object" &&
      p !== null &&
      "type" in p &&
      (p as any).type === "title"
  );

  if (titleProp?.title) {
    return titleProp.title.map((t) => t.plain_text).join("");
  }

  return "Untitled";
}

/**
 * Format a database query result as a Markdown table
 */
export function formatDatabaseAsTable(
  rows: Array<{
    id: string;
    properties: Record<string, unknown>;
    url: string;
  }>,
  propertyNames: string[]
): string {
  if (rows.length === 0) return "_No results_";

  const headers = propertyNames.length > 0 ? propertyNames : ["Name"];
  const headerLine = `| ${headers.join(" | ")} |`;
  const separatorLine = `| ${headers.map(() => "---").join(" | ")} |`;

  const dataLines = rows.map((row) => {
    const cells = headers.map((header) => {
      const prop = row.properties[header];
      const value = extractPropertyValue(prop);
      return value.replace(/\|/g, "\\|").replace(/\n/g, " ");
    });
    return `| ${cells.join(" | ")} |`;
  });

  return [headerLine, separatorLine, ...dataLines].join("\n");
}

function extractPropertyValue(prop: unknown): string {
  if (!prop || typeof prop !== "object") return "";

  const p = prop as Record<string, unknown>;

  switch (p.type) {
    case "title":
      return ((p.title as RichText[]) || []).map((t) => t.plain_text).join("");
    case "rich_text":
      return ((p.rich_text as RichText[]) || []).map((t) => t.plain_text).join("");
    case "number":
      return p.number !== null ? String(p.number) : "";
    case "select":
      return (p.select as { name?: string })?.name || "";
    case "multi_select":
      return ((p.multi_select as Array<{ name: string }>) || []).map((s) => s.name).join(", ");
    case "status":
      return (p.status as { name?: string })?.name || "";
    case "date":
      return (p.date as { start?: string; end?: string })?.start || "";
    case "checkbox":
      return p.checkbox ? "☑" : "☐";
    case "url":
      return (p.url as string) || "";
    case "email":
      return (p.email as string) || "";
    case "phone_number":
      return (p.phone_number as string) || "";
    case "formula":
      return String(
        (p.formula as { string?: string; number?: number })?.string ??
          (p.formula as { number?: number })?.number ?? ""
      );
    case "created_time":
      return (p.created_time as string) || "";
    case "last_edited_time":
      return (p.last_edited_time as string) || "";
    case "people":
      return ((p.people as Array<{ name?: string }>) || [])
        .map((u) => u.name)
        .filter(Boolean)
        .join(", ");
    case "relation":
      return `${(p.relation as Array<unknown>)?.length || 0} linked`;
    case "rollup":
      return "rollup";
    case "files":
      return `${(p.files as Array<unknown>)?.length || 0} files`;
    default:
      return "";
  }
}
