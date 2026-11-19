#!/usr/bin/env node
// Regenerate public-api.json from the .qml files in this directory (schema arc-port-public-api/v1).
// Usage: node tools/gen_public_api.mjs [packageRoot]
// Keeps the same shape as the original contract file: per type = file / upstream / stability /
// public properties / internal properties / signals / functions / internal functions / ct() domains.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = process.argv[2] || path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const read = (f) => fs.readFileSync(path.join(root, f), "utf8").replace(/\r/g, "");
const qmls = fs.readdirSync(root).filter((f) => f.endsWith(".qml")).sort();

// Types that are demo/showcase/theme glue rather than contract-bearing components.
const PREVIEW = /^(Demo|AnalyticsApp|ArcAdminApp|ArcTheme|Page[A-Z])/;

const strip = (s) => s.replace(/\/\*[\s\S]*?\*\//g, "").replace(/\/\/.*$/gm, "");
const propRe = /^\s*(readonly\s+)?property\s+([A-Za-z_][\w.<>]*)\s+([A-Za-z_]\w*)\s*:/gm;
const sigRe = /^\s*signal\s+([A-Za-z_]\w*)\s*(?:\(([^)]*)\))?/gm;
const fnRe = /^\s{4}function\s+([A-Za-z_]\w*)\s*\(([^)]*)\)/gm;
const ctRe = /\.ct\(\s*"([A-Za-z0-9_]+)"\s*,\s*"([A-Za-z0-9_]+)"/g;
const ctDomRe = /\.ct\(\s*"([A-Za-z0-9_]+)"/g;

const out = {};
const stable = [];
const preview = [];
for (const f of qmls) {
  const name = path.basename(f, ".qml");
  const body = strip(read(f));
  const props = [];
  let m;
  propRe.lastIndex = 0;
  while ((m = propRe.exec(body))) {
    props.push({
      name: m[3],
      type: m[2],
      default: null,
      readonly: !!m[1],
      access: m[3].startsWith("_") ? "internal" : "public"
    });
  }
  const signals = [];
  sigRe.lastIndex = 0;
  while ((m = sigRe.exec(body))) signals.push({ name: m[1], params: m[2] ? m[2].trim() : "" });
  const fns = [];
  fnRe.lastIndex = 0;
  while ((m = fnRe.exec(body))) {
    if (m[1].startsWith("_")) continue;
    fns.push({ name: m[1], params: m[2] ? m[2].trim() : "" });
  }
  const doms = new Set();
  ctDomRe.lastIndex = 0;
  while ((m = ctDomRe.exec(body))) doms.add(m[1]);
  const isPreview = PREVIEW.test(name);
  (isPreview ? preview : stable).push(name);
  out[name] = {
    file: f,
    upstream: null,
    stability: isPreview ? "preview" : "stable",
    properties: props.filter((p) => p.access === "public"),
    internalProperties: props.filter((p) => p.access === "internal").map((p) => p.name),
    signals: signals,
    functions: fns,
    internalFunctions: [],
    ctDomains: [...doms].sort()
  };
}

const api = {
  schema: "arc-port-public-api/v1",
  portTag: read("PIN").match(/port_tag:\s*(\S+)/)?.[1] || "port/v0.1.0",
  upstream: { repo: "AIDotNet/TKCode.Arc", commit: "695a85d727772490c03ff6586455796d6f4af16f", license: "MIT" },
  module: { uri: "arc", version: "1.0", qmlTypes: qmls.length },
  stability: {
    stable: "non-underscored properties / signals / functions of the non-preview types; changing one requires a new port tag + BREAKING.md entry",
    preview: "Demo.qml, showcase Page*.qml, Analytics*App glue and ArcTheme are preview: they may change in a minor tag"
  },
  previewTypes: preview.sort(),
  stableTypes: stable.sort(),
  types: out
};
fs.writeFileSync(path.join(root, "public-api.json"), JSON.stringify(api, null, 2) + "\n");
console.log("PUBLIC_API_OK types=" + qmls.length + " stable=" + stable.length + " preview=" + preview.length);
