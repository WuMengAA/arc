#!/usr/bin/env node
// Regenerate qmldir from the .qml files in this directory.
// Usage: node tools/gen_qmldir.mjs [packageRoot]   (default: parent of tools/)
// Keeps every QML type registered so "import arc 1.0" resolves all of them.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
const root = process.argv[2] || path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const head = [
  "module arc",
  "# TKCode.Arc → Qt/QML port · QML types registered (auto-generated from .qml files).",
  '# Qt module URI must equal the directory name: keep this directory named "arc".',
  "#   qml -I <parent-of-arc> main.qml   →   import arc 1.0",
  '# A plain directory import (import "arc" as Arc) also works; see README.md §0.2.',
  "# Demo.qml is the standalone window entry point; it is registered for completeness.",
  "# Regenerate with: node tools/gen_qmldir.mjs   (keep in sync when adding/removing a .qml)."
].join("\n");
const files = fs.readdirSync(root).filter(f => f.endsWith(".qml")).sort();
if (!files.every(f => /^[A-Z]/.test(f))) {
  console.error("qmldir type names must start with an upper case letter; offenders: " + files.filter(f => !/^[A-Z]/.test(f)).join(", "));
  process.exit(1);
}
const body = files.map(f => path.basename(f, ".qml") + " 1.0 " + f).join("\n");
fs.writeFileSync(path.join(root, "qmldir"), head + "\n" + body + "\n");
console.log("QMLEDIR_OK types=" + files.length + " -> " + path.join(root, "qmldir"));
