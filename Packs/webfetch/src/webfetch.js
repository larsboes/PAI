#!/usr/bin/env node
// webfetch.js — extract any URL to clean markdown via Jina AI Reader (free, no API key)
// Usage: webfetch.js fetch <url>

const [cmd, url] = process.argv.slice(2);

if (cmd !== "fetch" || !url) {
	console.log("Usage: webfetch.js fetch <url>");
	process.exit(1);
}

let target = url;
if (!url.startsWith("http://") && !url.startsWith("https://")) {
	target = `https://${url}`;
}

try {
	const res = await fetch(`https://r.jina.ai/${target}`, {
		headers: { "Accept": "text/plain", "X-Return-Format": "markdown" },
		signal: AbortSignal.timeout(30000),
	});
	if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);
	const text = await res.text();
	if (!text?.trim()) throw new Error("No content extracted from this page.");
	console.log(text);
} catch (e) {
	console.error(`Error: ${e.message}`);
	process.exit(1);
}
