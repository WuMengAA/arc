// ArcAnalyticsApp 预设应用真值数据（逐字移植 templates/.../ArcAnalyticsApp/App/SampleData/*.cs）。
// mulberry32 与 SampleKpis.cs / SampleRevenue.cs / SampleUsage.cs 完全一致，保证数值可复现。
.pragma library

function mulberry32(seed) {
    var s = seed >>> 0;
    return function () {
        s = (s + 0x6D2B79F5) >>> 0;
        var t = s;
        t = Math.imul(t ^ (t >>> 15), t | 1);
        t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
        return ((t ^ (t >>> 14)) >>> 0) / 4294967296.0;
    };
}
function range(r, a, b) { return a + (b - a) * r(); }
function gaussian(r) {
    var u = Math.max(1e-9, r());
    return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * r());
}

var MONTHS = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

// SampleKpis.cs：6 个指标 Spec（Base/Trend/Season/Noise/Seed/Format/Description）
var KPI_SPECS = [
    { key: "arr", label: "Annual run rate", base: 2.2e6, trend: 0.12, season: 0.004, noise: 6e3, seed: 11, prefix: "$", suffix: "M", decimals: 1, compact: true,
      desc: "Contracted yearly revenue across all paid studios.", change: "+8.2%", up: true, context: "vs. previous 30 days" },
    { key: "studios", label: "Paying studios", base: 3000, trend: 0.08, season: 0.003, noise: 9, seed: 23, prefix: "", suffix: "", decimals: 0, compact: false,
      desc: "Studios with an active paid plan on the last day.", change: "+4.1%", up: true, context: "vs. previous 30 days" },
    { key: "expansion", label: "Expansion rate", base: 108, trend: 0.04, season: 0.002, noise: 0.35, seed: 37, prefix: "", suffix: "%", decimals: 1, compact: false,
      desc: "Revenue kept from last year's studios, upgrades included.", change: "+2.4%", up: true, context: "vs. previous 30 days" },
    { key: "refunds", label: "Refund rate", base: 3.1, trend: -0.18, season: 0.01, noise: 0.05, seed: 41, prefix: "", suffix: "%", decimals: 1, compact: false,
      desc: "Share of charges refunded within thirty days.", change: "-0.6%", up: true, context: "lower is better" },
    { key: "deal", label: "Average deal size", base: 61, trend: 0.06, season: 0.003, noise: 0.4, seed: 53, prefix: "$", suffix: "", decimals: 1, compact: false,
      desc: "Run rate divided by paying studios.", change: "+1.8%", up: true, context: "vs. previous 30 days" },
    { key: "activation", label: "Activation rate", base: 26, trend: 0.02, season: 0.03, noise: 0.9, seed: 67, prefix: "", suffix: "%", decimals: 1, compact: false,
      desc: "New trials that publish a first project within a week.", change: "0.0%", up: false, context: "flat over 30 days" }
];

// 180 天序列（SampleKpis.Series 逐字移植）；返回最后 30 天供 sparkline
function kpiSeries(spec, days) {
    var r = mulberry32(spec.seed), n = days || 180, out = [], walk = 0, t, v, k, fromEnd;
    for (t = 0; t < n; t++) {
        walk = walk * 0.92 + gaussian(r) * spec.noise;
        v = spec.base * (1 + spec.trend * t / n) * (1 + spec.season * Math.sin(2 * Math.PI * t / 7 + spec.seed)) + walk;
        fromEnd = n - 1 - t;
        if (fromEnd < 30) {
            k = (29 - fromEnd) / 29.0;
            v += spec.base * spec.trend * 0.06 * (Math.sin(k * Math.PI * 1.6) + k);
        }
        if (spec.key === "expansion" || spec.key === "activation" || spec.key === "refunds") v = Math.max(0, Math.min(100, v));
        out.push(v);
    }
    if (spec.key === "activation") out[n - 1] = out[n - 31];
    return out;
}
function kpis() {
    var out = [];
    for (var i = 0; i < KPI_SPECS.length; i++) {
        var s = KPI_SPECS[i], all = kpiSeries(s, 180);
        out.push({
            key: s.key, label: s.label, desc: s.desc,
            value: s.compact ? all[179] / 1e6 : all[179],
            prefix: s.prefix, suffix: s.suffix, decimals: s.decimals,
            change: s.change, up: s.up, context: s.context,
            spark: all.slice(150), series: all.slice(150)
        });
    }
    return out;
}

// SampleKpis.cs 三个维度（Shares 全为 [0.44,0.30,0.18,0.08]）
var DIMENSIONS = {
    tier:   { label: "Tier",   names: ["Studio Max", "Studio", "Team", "Solo"], shares: [0.44, 0.30, 0.18, 0.08] },
    market: { label: "Market", names: ["Americas", "Europe", "Asia Pacific", "Middle East & Africa"], shares: [0.44, 0.30, 0.18, 0.08] },
    source: { label: "Source", names: ["Self-serve", "Partner", "Outbound", "Events"], shares: [0.44, 0.30, 0.18, 0.08] }
};
function breakdown(dim, total) {
    var d = DIMENSIONS[dim], out = [];
    for (var i = 0; i < d.names.length; i++) {
        var drift = i === d.names.length - 1 ? -0.0012 : 0.0004 * (3 - i);
        out.push({ name: d.names[i], share: d.shares[i], value: Math.round(total * d.shares[i] * (1 + drift * 30)), trend: (i === d.names.length - 1 ? "-" : "+") });
    }
    return out;
}

// SampleRevenue.cs：24 个月 from Mar 2024，seed 7，scale 1
function revenue() {
    var r = mulberry32(7), out = [], i, nw, ex, ch;
    for (i = 0; i < 24; i++) {
        nw = 38000 + 1400 * i + 6000 * Math.sin(i * 0.7) + range(r, -3000, 3000);
        if (i === 7) nw *= 0.72;
        if (i >= 19 && i <= 21) nw = 38000 + 1400 * 19 + range(r, -1500, 1500);
        ex = 14000 + 550 * i + range(r, -2500, 2500);
        ch = 16000 + 600 * i + range(r, -2000, 2000);
        if (i === 5) ch *= 1.35;
        var mi = 2 + i, label = MONTHS[mi % 12] + " " + (2024 + Math.floor(mi / 12));
        out.push({ month: label, new: Math.round(nw), expansion: Math.round(ex), churn: -Math.round(ch), net: Math.round(nw + ex - ch) });
    }
    return out;
}
function revenueArr() {
    var rows = revenue(), acc = 1050000, out = [];
    for (var i = 0; i < rows.length; i++) { acc += rows[i].net; out.push(Math.round(acc)); }
    return out;
}

// SampleRetention.cs：12 月度 cohort Jun 2026–May 2027
var RETENTION = {
    title: "Space retention",
    subtitle: "Team spaces still editing each month after creation. Updated through Jun 30, 2027.",
    cohorts: ["Jun 26","Jul 26","Aug 26","Sep 26","Oct 26","Nov 26","Dec 26","Jan 27","Feb 27","Mar 27","Apr 27","May 27"],
    segments: ["All", "Starter", "Business"]
};
// 每 cohort 12 - r 个月的留存率（Curve 的指数衰减近似，数值来自真源码 0.70/0.91 起、0.29/0.74 底）
function retentionGrid(segment) {
    var base = segment === "Business" ? 0.91 : segment === "Starter" ? 0.70 : 0.80;
    var floor = segment === "Business" ? 0.74 : segment === "Starter" ? 0.29 : 0.52;
    var out = [];
    for (var r = 0; r < 12; r++) {
        var row = [], months = 12 - r;
        for (var m = 0; m < 12; m++) {
            if (m >= months) { row.push(-1); continue; }
            row.push(Math.round((floor + (base - floor) * Math.exp(-m / 3.2)) * 100));
        }
        out.push(row);
    }
    return out;
}

// SampleUsage.cs：21 天事件读数，seed 7，周末 0.52M / 工作日 1.35M，Budget 26M、UnitPrice 150
var USAGE = {
    title: "Usage outlook",
    subtitle: "Harborline Studio · Growth plan · Renews Jul 1",
    budget: 26, unitPrice: 150, priceNote: "At $0.15 per 1k events", unit: "M", axisMax: 40
};
function usageEvents() {
    var r = mulberry32(7), out = [], sum = 0, d, weekend;
    // 2027-06-01 是星期二：DayOfWeek 从星期二起算
    for (d = 1; d <= 21; d++) {
        weekend = ((d + 1) % 7 === 6 || (d + 1) % 7 === 0); // Sat=6 / Sun=0
        sum += weekend ? (0.52 + gaussian(r) * 0.06) : (1.35 + gaussian(r) * 0.12);
        out.push(Math.round(sum * 1000) / 1000);
    }
    return out;
}
function usageDays() {
    var out = [];
    for (var d = 1; d <= 21; d++) out.push("Jun " + d);
    return out;
}

// SampleUptime.cs：4 服务、5 incidents、Now/UpdatedAt
var UPTIME = {
    pageName: "Larkspur status", now: "2027-03-14 14:30 UTC", updatedAt: "2027-03-14 14:32 UTC",
    services: [
        { key: "edge", name: "Edge", desc: "Routing and TLS", latency: 210, status: "Operational" },
        { key: "console", name: "Console", desc: "console.larkspur.test", latency: 520, status: "Operational" },
        { key: "events", name: "Events", desc: "Queue fan-out", latency: 380, status: "Degraded" },
        { key: "identity", name: "Identity", desc: "Login and API keys", latency: 140, status: "Operational" }
    ],
    incidents: [
        { date: "Feb 20", title: "Elevated 5xx on Edge", service: "Edge", status: "Monitoring", tone: "warning" },
        { date: "Feb 08", title: "Console latency spike", service: "Console", status: "Resolved", tone: "neutral" },
        { date: "Jan 27", title: "Events queue backlog", service: "Events", status: "Resolved", tone: "neutral" },
        { date: "Jan 12", title: "Identity token refresh", service: "Identity", status: "Resolved", tone: "neutral" },
        { date: "Dec 29", title: "Edge certificate rotation", service: "Edge", status: "Resolved", tone: "neutral" }
    ]
};
