// Dependency-free static self-check for the arc Qt/QML port.
// Usage: node tools/check.mjs [packageRoot]
// Exits 1 on any new structural / purity / contract violation.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
const root = process.argv[2] || path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const fail = [], warn = [];
const clean = (s) => s.replace(/\r/g, "");
const read = (f) => clean(fs.readFileSync(path.join(root, f), "utf8"));
const files = fs.readdirSync(root);
const qmls = files.filter(f => f.endsWith(".qml")).sort();
const jss = files.filter(f => f.endsWith(".js")).sort();

// 1. size + brace balance + hard constraints
for (const f of qmls) {
  const s = read(f), L = s.split("\n").length;
  if (L > 200) fail.push(f + ": " + L + " lines > 200");
  let d = 0, min = 0, quote = null, line = 0, inLine = false, inBlock = false;
  for (let i = 0; i < s.length; i++) {
    const c = s[i], n = s[i + 1];
    if (c === "\n") { line++; inLine = false; if (quote && quote !== "`") quote = null; continue; }
    if (inLine) continue;
    if (inBlock) { if (c === "*" && n === "/") { inBlock = false; i++; } continue; }
    if (quote) { if (c === "\\") { i++; continue; } if (c === quote) quote = null; continue; }
    if (c === "/" && n === "/") { inLine = true; i++; continue; }
    if (c === "/" && n === "*") { inBlock = true; i++; continue; }
    if (c === "\"" || c === "'" || c === "`") { quote = c; continue; }
    if (c === "{") d++;
    if (c === "}") { d--; if (d < min) min = d; }
  }
  if (d !== 0 || min !== 0) fail.push(f + ": braces depth=" + d + " min=" + min);
  if (/\b(XMLHttpRequest|WebSocket|fetch)\b|JSON\.parse|JSON\.stringify/.test(s)) fail.push(f + ": impure QML network/JSON");
  if (/^\s*import\s+QtQuick\.Controls|^\s*import\s+QtQuick\.Layouts/m.test(s)) fail.push(f + ": forbidden QtQuick import");
  if (/^\s*property\s+(?:bool|int|string|var)\s+(?:enabled|state|data)\s*:/m.test(s)) fail.push(f + ": shadows built-in property");
  if (/font\.family\s*:\s*"[^"]+"/.test(s)) fail.push(f + ": hard-coded font.family literal");
  const ctCalls = [...s.matchAll(/\.ct\(/g)];
  const badCt = ctCalls.filter(m => { const t = s.slice(m.index + 4).trimStart(); return t.charAt(0) !== "\"" && t.charAt(0) !== ")"; });
  if (badCt.length) fail.push(f + ": dynamic ct() domain/key (use literals)");
}
for (const f of jss) { if (read(f).split("\n").length > 600) fail.push(f + ": JS > 600 lines"); }

// 2. qmldir registration
const qmldir = read("qmldir");
const reg = qmldir.split("\n").map(x => x.match(/^(\w+)\s+1\.0\s+(\w+\.qml)$/)).filter(Boolean);
if (!/^module arc$/m.test(qmldir)) fail.push("qmldir: module URI must be arc");
if (reg.length !== qmls.length) fail.push("qmldir: registered " + reg.length + " / qml " + qmls.length);
const regNames = new Set(reg.map(m => m[1]));
for (const f of qmls) if (!regNames.has(path.basename(f, ".qml"))) fail.push("qmldir missing " + f);

// 3. contracts / docs exist
for (const f of ["LICENSE","THIRD-PARTY-NOTICES.md","README.md","CHANGELOG.md","INTEGRATION.md","PORTING-MAP.md","BREAKING.md","public-api.json","GOLDEN.json","PIN","SHA256SUMS","Demo.qml","ArcAdminApp.qml","ArcTheme.qml","Tokens.js","ControlTokens.js","ArcDisplay.js","tools/gen_qmldir.mjs","tools/gen_tokens.mjs","tools/golden.mjs","tools/pin.mjs"])
  if (!fs.existsSync(path.join(root, f))) fail.push("missing " + f);

// 4. no uppercase PascalCase method calls on root (QML syntax forbids)
for (const f of qmls) {
  const s = read(f);
  if (/\broot\.[A-Z]\w*\s*\(/.test(s)) fail.push(f + ": PascalCase method call");
}

// 5. summary
console.log("CHECK qml=" + qmls.length + " js=" + jss.length + " qmldir=" + reg.length + " fail=" + fail.length + " warn=" + warn.length);
for (const m of fail) console.log("FAIL " + m);
for (const m of warn) console.log("WARN " + m);
if (fail.length) process.exit(1);
console.log("CHECK_OK");
