// 由 TKCode.Arc 官方令牌基线生成 ControlTokens.js（逐值照抄，产物已入库）。
// 用法：node tools/gen_tokens.mjs <TKCode.Arc 仓库根> [输出目录]
// 例：node tools/gen_tokens.mjs ../TKCode.Arc ..
// 不依赖本机绝对路径；仅在「升级上游版本」时需要重跑，运行移植包本身不需要它。
import fs from "node:fs";
import path from "node:path";

const root = process.argv[2];
const outDir = process.argv[3] || path.dirname(new URL(import.meta.url).pathname).replace(/^\/([A-Za-z]:)/, "$1");
if (!root) {
  console.error("usage: node tools/gen_tokens.mjs <TKCode.Arc repo root> [out dir]");
  process.exit(1);
}
const SRC = path.join(root, "tests", "Baselines", "tokens");
const OUT = path.join(outDir, "ControlTokens.js");
const L = JSON.parse(fs.readFileSync(path.join(SRC, "light-default.json"), "utf8")).tokens;
const D = JSON.parse(fs.readFileSync(path.join(SRC, "dark-default.json"), "utf8")).tokens;

function norm(v) {
  if (typeof v !== "string") return v;
  const s = v.trim();
  if (/^#[0-9A-Fa-f]{6,8}$/.test(s)) return s;
  if (/^-?\d+(\.\d+)?([eE][+-]?\d+)?$/.test(s)) return Number(s);
  if (/^-?[\d.]+(,-?[\d.]+)+$/.test(s)) return s.split(",").map(Number);
  return s;
}
function build(t) {
  const o = {};
  for (const [d, obj] of Object.entries(t)) {
    if (d === "ArcDesign") continue;
    const x = {};
    for (const [k, v] of Object.entries(obj)) x[k] = norm(v);
    o[d] = x;
  }
  return o;
}
const light = build(L), dark = build(D);
const ov = {}; let ovKeys = 0;
for (const [d, obj] of Object.entries(dark)) {
  const x = {};
  for (const [k, v] of Object.entries(obj))
    if (JSON.stringify(v) !== JSON.stringify(light[d]?.[k])) { x[k] = v; ovKeys++; }
  if (Object.keys(x).length) ov[d] = x;
}
const header = [
  "// TKCode.Arc 控件规格令牌（真值，勿手改）。",
  "// 数据源：tests/Baselines/tokens/{light,dark}-default.json（494 identity，逐值照抄）。",
  "// 生成：node tools/gen_tokens.mjs <TKCode.Arc 仓库根> ..   （产物已入库，重生成非运行依赖）",
  "// LIGHT = 493 个控件域全量（排除 ArcDesign；全局设计令牌在 Tokens.js）；",
  "// DARK  = 仅存与 LIGHT 不同的键（" + ovKeys + " 键 / " + Object.keys(ov).length + " 域）。",
  "// 用法：th.ct(域名, 键名) —— 域名与真源码 <Control>Token.cs 一致，经 ArcTheme 解析。",
  "// 分工：Tokens.js 管全局设计/强调色/序列/预设页派生值；本文件管控件规格。新控件一律读 ct()。",
  ".pragma library",
  "",
].join("\n");
fs.writeFileSync(OUT, header + "var LIGHT = " + JSON.stringify(light) + ";\nvar DARK = " + JSON.stringify(ov) + ";\n");
console.log("WROTE " + OUT);
console.log("LIGHT domains=" + Object.keys(light).length + " DARK override domains=" + Object.keys(ov).length + " keys=" + ovKeys);
