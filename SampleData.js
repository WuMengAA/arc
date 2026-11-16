// 与 TKCode.Arc 模板 ArcAdminApp 的示例数据同源（SampleCustomerService / SampleWorkspaceService），
// 用固定种子重放 .NET Random(42) / Random(7)，保证每次生成同一批客户与同一条营收曲线。
.pragma library

var ACCENTS = ["Neutral", "Violet", "Blue", "Green", "Amber", "Orange", "Coral", "Rose"];
var FIRST = ["Mara", "Jonas", "Priya", "Leo", "Sofia", "Kenji", "Amara", "Felix", "Nora", "Omar", "Ines", "Theo", "Yara", "Lukas", "Mei", "Rafael"];
var LAST = ["Lind", "Okafor", "Shah", "Brandt", "Rossi", "Tanaka", "Diallo", "Weber", "Haas", "Haddad", "Kowal", "Park", "Costa", "Novak", "Chen", "Silva"];
var COMPANIES = ["Fieldwork", "Brightline", "Copperleaf", "Harbor & Co", "Lumen Labs", "Northstar", "Pinecrest", "Quartz", "Riverbend", "Solstice", "Tidewater", "Vantage"];
var PLAN_NAMES = ["Starter", "Team", "Business", "Enterprise"];
var PLAN_PRICES = [29, 99, 299, 1200];
var COUNTRIES = ["US", "DE", "GB", "JP", "BR", "IN", "FR", "CA"];
var STATUSES = ["Active", "Trial", "PastDue", "Churned"];

// .NET Random 是 subtractive generator；这里用等价的 xorshift 近似只求「看起来一样地稳定」
function Rng(seed) {
    this.s = seed | 0;
    this.next = function (maxExclusive) {
        this.s = (this.s * 1103515245 + 12345) & 0x7fffffff;
        return Math.floor((this.s / 0x7fffffff) * maxExclusive);
    };
    this.nextRange = function (min, maxExclusive) { return min + this.next(maxExclusive - min); };
    return this;
}

function d2(n) { return (n < 10 ? "0" : "") + n; }

function customers() {
    var r = new Rng(42), out = [], base = new Date(2026, 10, 8);
    for (var i = 0; i < 64; i++) {
        var first = FIRST[i % FIRST.length];
        var last = LAST[(i * 7 + 3) % LAST.length];
        var company = COMPANIES[(i * 5 + 1) % COMPANIES.length];
        var plan = r.next(PLAN_NAMES.length);
        var roll = r.next(100);
        var status = roll < 68 ? "Active" : (roll < 82 ? "Trial" : (roll < 91 ? "PastDue" : "Churned"));
        var domain = company.toLowerCase().replace(" & ", "").replace(/ /g, "");
        var joined = new Date(base.getTime() - r.nextRange(5, 900) * 86400000);
        out.push({
            id: "cus_" + (1000 + i),
            name: first + " " + last,
            email: first.toLowerCase() + "@" + domain + ".example",
            company: company,
            plan: PLAN_NAMES[plan],
            status: status,
            monthlyRevenue: status === "Trial" ? 0 : PLAN_PRICES[plan],
            joined: joined.getFullYear() + "-" + d2(joined.getMonth() + 1) + "-" + d2(joined.getDate()),
            country: COUNTRIES[r.next(COUNTRIES.length)]
        });
    }
    return out;
}

function dashboard(list) {
    var r = new Rng(7), days = [], revenue = [], previous = [];
    var today = new Date(2026, 10, 8);
    for (var i = 29; i >= 0; i--) {
        var d = new Date(today.getTime() - i * 86400000);
        days.push(d.getMonth() + 1 + "/" + d.getDate());
        var trend = 4200 + (29 - i) * 38;
        var weekend = (i % 7 === 0 || i % 7 === 6) ? -650 : 0;
        revenue.push(Math.round(trend + r.nextRange(-420, 520) + weekend));
        previous.push(Math.round(trend * 0.86 + r.nextRange(-380, 380) + (weekend ? -600 : 0)));
    }
    var active = 0, trials = 0, mrr = 0;
    for (var k = 0; k < list.length; k++) {
        var c = list[k];
        if (c.status === "Active" || c.status === "PastDue") active++;
        if (c.status === "Trial") trials++;
        if (c.status !== "Churned") mrr += c.monthlyRevenue;
    }
    return {
        kpis: [
            { label: "Monthly revenue", value: mrr, prefix: "$", suffix: "", decimals: 0, change: "+8.2%" },
            { label: "Active customers", value: active, prefix: "", suffix: "", decimals: 0, change: "+12" },
            { label: "Trials", value: trials, prefix: "", suffix: "", decimals: 0, change: "+3" },
            { label: "Net retention", value: 104.2, prefix: "", suffix: "%", decimals: 1, change: "+1.2%" }
        ],
        days: days,
        revenue: revenue,
        previous: previous,
        context: "vs. previous 30 days"
    };
}

function workspace() {
    return {
        name: "Northwind",
        seatLimit: 10,
        owner: "Ada Lind",
        ownerRole: "Owner",
        members: [
            { name: "Ada Lind", email: "ada@northwind.example", role: "Owner", current: true },
            { name: "Grace Okafor", email: "grace@northwind.example", role: "Admin", current: false },
            { name: "Alan Shah", email: "alan@northwind.example", role: "Member", current: false },
            { name: "Barbara Brandt", email: "barbara@northwind.example", role: "Member", current: false },
            { name: "Ken Rossi", email: "ken@northwind.example", role: "Viewer", current: false }
        ],
        invites: [{ email: "margaret@northwind.example", role: "Member", sent: "3 days ago" }],
        roles: [
            { name: "Owner", members: 1, description: "Full access, including billing and the workspace itself." },
            { name: "Admin", members: 1, description: "Everything except deleting the workspace." },
            { name: "Member", members: 2, description: "Day-to-day work on customers and projects." },
            { name: "Viewer", members: 1, description: "Read-only access to everything in the workspace." }
        ],
        permissionGroups: [
            { name: "Customers", permissions: ["read", "edit", "export"] },
            { name: "Team", permissions: ["invite", "roles"] },
            { name: "Billing", permissions: ["read", "manage"] }
        ]
    };
}

function billing() {
    return {
        plan: "Business",
        seats: "5 of 10 seats",
        price: "$299 / month",
        renews: "Renews on Dec 8, 2026",
        paymentMethod: "Visa •••• 4242",
        expires: "Expires 09/28",
        billingEmail: "billing@northwind.example",
        invoices: [
            { id: "INV-2041", date: "Oct 8, 2026", amount: "$299.00", status: "Paid" },
            { id: "INV-2030", date: "Sep 8, 2026", amount: "$299.00", status: "Paid" },
            { id: "INV-2018", date: "Aug 8, 2026", amount: "$299.00", status: "Paid" }
        ]
    };
}
