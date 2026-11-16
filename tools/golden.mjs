// Text golden for the upstream ArcAdminApp dashboard, computed from this package's SampleData.js.
// Usage: node tools/golden.mjs            → regenerate GOLDEN.json
//        node tools/golden.mjs --check    → exit 1 on drift
import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";
import crypto from "node:crypto";
import { fileURLToPath } from "node:url";
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const sha = (v) => crypto.createHash("sha256").update(v).digest("hex");
const body = fs.readFileSync(path.join(root, "SampleData.js"), "utf8").replace(/^\s*\.pragma\s+library\s*$/m, "");
const ctx = { console, Math, Date, JSON };
vm.createContext(ctx);
vm.runInContext(body + "\nthis.__api = { customers, dashboard, workspace, billing };", ctx);
const customers = ctx.__api.customers();
const dashboard = ctx.__api.dashboard(customers);
const upstreamText = [
  "Dashboard",
  "How the business did over the last 30 days.",
  "Revenue",
  "This period against the one before.",
  "This period",
  "Previous period",
  "vs. previous 30 days"
];
const golden = {
  schema: "arc-port-text-golden/v1",
  upstream: { repo: "AIDotNet/TKCode.Arc", commit: "695a85d727772490c03ff6586455796d6f4af16f",
              source: "templates/TKCode.Arc.Templates/content/ArcAdminApp/App/Pages/DashboardPage.axaml" },
  upstreamText,
  upstreamTextSha256: sha(upstreamText.join("\n")),
  sample: {
    customerCount: customers.length,
    firstCustomer: customers[0],
    lastCustomer: customers[customers.length - 1],
    customersSha256: sha(JSON.stringify(customers)),
    dashboardKpis: dashboard.kpis,
    dashboardKpisSha256: sha(JSON.stringify(dashboard.kpis)),
    daysCount: dashboard.days.length,
    revenueSha256: sha(JSON.stringify(dashboard.revenue)),
    previousSha256: sha(JSON.stringify(dashboard.previous)),
    context: dashboard.context
  }
};
const out = path.join(root, "GOLDEN.json");
const text = JSON.stringify(golden, null, 1) + "\n";
if (process.argv.includes("--check")) {
  const cur = fs.readFileSync(out, "utf8");
  if (cur.trim() !== text.trim()) { console.error("GOLDEN_DRIFT expected sha=" + golden.upstreamTextSha256); process.exit(1); }
  console.log("GOLDEN_OK textSha256=" + golden.upstreamTextSha256 + " customers=" + customers.length + " days=" + dashboard.days.length);
} else { fs.writeFileSync(out, text); console.log("GOLDEN_WRITTEN " + out); }
