// Regenerate SHA256SUMS + PIN. Excludes itself, SHA256SUMS and .git, so reruns are stable.
import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { fileURLToPath } from "node:url";
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
// Tag is passed in so a re-pin never rewrites history: node tools/pin.mjs [packageRoot] [portTag]
const argvTag = process.argv.slice(2).find((a) => /^port\//.test(a));
const portTag = argvTag || process.env.PORT_TAG || "port/v0.1.0";
const sha = (v) => crypto.createHash("sha256").update(v).digest("hex");
const skip = new Set([".git", "SHA256SUMS", "PIN"]);
const files = [];
for (const e of fs.readdirSync(root, { withFileTypes: true })) {
  if (skip.has(e.name)) continue;
  if (e.isDirectory()) {
    for (const f of fs.readdirSync(path.join(root, e.name))) files.push(e.name + "/" + f);
  } else files.push(e.name);
}
files.sort();
const sums = files.map((f) => sha(fs.readFileSync(path.join(root, f))) + "  " + f).join("\n") + "\n";
fs.writeFileSync(path.join(root, "SHA256SUMS"), sums);
const aggregate = sha(sums);
const pin = [
  "# arc port pin — machine-readable; do not hand-edit",
  "schema: arc-port-pin/v1",
  "port_repo: https://github.com/WuMengAA/arc",
  "port_tag: " + portTag,
  "port_commit: git rev-parse " + portTag + "^{commit}   # tag is the immutable commit alias",
  "module_uri: arc",
  "module_version: 1.0",
  "upstream_repo: AIDotNet/TKCode.Arc",
  "upstream_commit: 695a85d727772490c03ff6586455796d6f4af16f",
  "upstream_describe: v1.1.0-6-g695a85d7",
  "upstream_license: MIT",
  "files: " + files.length,
  "sha256sums: SHA256SUMS",
  "aggregate_sha256: " + aggregate,
  "cmp_manifest: qmldir public-api.json Tokens.js ControlTokens.js PORTING-MAP.md BREAKING.md GOLDEN.json LICENSE THIRD-PARTY-NOTICES.md README.md CHANGELOG.md INTEGRATION.md",
  "# Two-consumer acceptance: copy this directory to both endpoints, then compare SHA256SUMS byte-for-byte.",
  "# Rollback: point the consumer PIN at the previous port tag; see INTEGRATION.md §Canary rollback."
].join("\n") + "\n";
fs.writeFileSync(path.join(root, "PIN"), pin);
console.log("PIN_OK files=" + files.length + " aggregate=" + aggregate);
