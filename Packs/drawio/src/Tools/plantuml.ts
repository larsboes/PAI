#!/usr/bin/env bun
/**
 * plantuml — encode/decode PlantUML source for server render URLs.
 *
 * Implements PlantUML's standard text transport (the form a PlantUML server
 * accepts after the `~1` codec marker): the source is URL-encoded, raw-DEFLATE
 * compressed, then base64'd; decoding reverses it. See plantuml.com/text-encoding.
 *
 *   bun plantuml.ts encode <file.puml | ->                 # print the token
 *   bun plantuml.ts decode <token>                         # recover the source
 *   bun plantuml.ts url    <file.puml | -> [fmt] [server]  # fmt: svg|png|txt
 */
import { deflateRawSync, inflateRawSync } from "node:zlib";
import { readFileSync } from "node:fs";

const readSource = (a?: string) => readFileSync(a && a !== "-" ? a : 0, "utf8");

const encode = (src: string): string =>
  deflateRawSync(Buffer.from(encodeURIComponent(src), "utf8"), { level: 9 }).toString("base64");

const decode = (token: string): string =>
  decodeURIComponent(inflateRawSync(Buffer.from(token, "base64")).toString("utf8"));

const [, , cmd, a, fmt, server] = Bun.argv;
try {
  if (cmd === "encode") {
    process.stdout.write(encode(readSource(a)) + "\n");
  } else if (cmd === "decode") {
    if (!a) throw new Error("decode needs a <token>");
    process.stdout.write(decode(a) + "\n");
  } else if (cmd === "url") {
    const host = (server ?? "https://www.plantuml.com/plantuml").replace(/\/+$/, "");
    process.stdout.write(`${host}/${fmt ?? "svg"}/~1${encode(readSource(a))}\n`);
  } else {
    process.stderr.write("usage: bun plantuml.ts encode|decode|url <file|token> [fmt] [server]\n");
    process.exit(1);
  }
} catch (e) {
  process.stderr.write(`error: ${(e as Error).message}\n`);
  process.exit(1);
}
