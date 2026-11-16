// QML 版 TKCode.Arc 模板 ArcAdminApp：Sidebar（240 展开 / 64 轨道）+ 顶栏 52 + 5 页面。
// 令牌全部来自 arc/Tokens.js（真实基线），主题由 ArcTheme 按 dark / accentIndex 解析。
import QtQuick 2.15

Rectangle {
    id: app

    property alias themeObj: theme
    property bool startDark: false
    property int startAccent: 0

    readonly property bool dark: startDark
    readonly property int accentIndex: startAccent

    function setDark(v) { startDark = v; }
    function setAccent(i) { startAccent = i; }

    color: theme.c("Background")

    ArcTheme { id: theme; dark: app.startDark; accentIndex: app.startAccent }

    // issue 8：四个数据源做成可空默认 —— 第三方包不再强制注入 Northwind 商业假数据。
    // 宿主可从数据桥传入真实读数；为空时 PageDashboard/PageCustomers/PageTeam/PageBilling 自动降级为空白态。
    property var customersData: null
    property var dashboardData: null
    property var workspaceData: null
    property var billingData: null
    // issue 9：文案桥 —— 所有商业字面量可由宿主覆盖；navSections 可被 filterSections() 裁剪。
    property var strings: ({})
    property var visibleSections: []
    function t(key, fallback) { return app.strings && app.strings[key] !== undefined ? app.strings[key] : fallback; }
    function filterSections(list) {
        if (!app.visibleSections || app.visibleSections.length === 0) return list;
        var out = [];
        for (var i = 0; i < list.length; i++) {
            var s = list[i], items = [];
            for (var j = 0; j < s.items.length; j++) if (app.visibleSections.indexOf(s.items[j].key) >= 0) items.push(s.items[j]);
            if (items.length) out.push({ header: s.header, items: items });
        }
        return out;
    }

    property string section: "dashboard"
    property bool collapsed: false

    // 侧栏分组逐字对齐官方真源码，不沿用早期推演的 Gallery 分类：
    //   templates/TKCode.Arc.Templates/content/ArcAdminApp/App/Views/MainView.axaml:66-69
    //     → 无 Header 的 SidebarSection：Dashboard / Customers
    //   :70-74 → <arc:SidebarSection Header="Workspace">：Team / Billing / Settings
    //   README.md:33 → "The 112 components in 22 groups, organized like Arc's sidebar"
    //   src/TKCode.Arc/ 实际 27 个组件目录（Buttons/Cards/Charts/.../Toggles）
    //   src/TKCode.Arc.Blocks/BlockCatalog.cs:18 → "The Blocks and Screens taxonomy, in sidebar order (as on uiarc.dev)"
    //   templates/README.md:197-200 → scenario templates: ArcAdminApp / ArcAiChatApp /
    //     ArcDevtoolApp / ArcWorkflowApp / ArcProjectsApp / ArcAnalyticsApp
    readonly property var navSections: filterSections([
        { header: "", items: [
            { key: "dashboard", label: "Dashboard", icon: "LayoutDashboard" },
            { key: "customers", label: "Customers", icon: "Users" }
        ] },
        { header: "Workspace", items: [
            { key: "team", label: "Team", icon: "UserCog" },
            { key: "billing", label: "Billing", icon: "CreditCard" },
            { key: "settings", label: "Settings", icon: "Settings" }
        ] },
        { header: "Components · 22 groups", items: [
            { key: "foundation", label: "Foundation", icon: "CircleDot" },
            { key: "buttons", label: "Buttons", icon: "Zap" },
            { key: "components", label: "TextFields & Forms", icon: "Command" },
            { key: "library", label: "Overlays & Tables", icon: "Sparkles" },
            { key: "more", label: "Messages & Expand", icon: "Palette" },
            { key: "charts", label: "Charts & Selects", icon: "TrendingUp" },
            { key: "menus", label: "Menus & Overlays", icon: "Menu" },
            { key: "interactions", label: "Gestures & Toggles", icon: "SlidersHorizontal" },
            { key: "motion", label: "Activity & TextEffects", icon: "Activity" },
            { key: "layout", label: "Layout", icon: "Grid2X2" }
        ] },
        { header: "Blocks & screens", items: [
            { key: "surfaces", label: "Surfaces", icon: "Layers" },
            { key: "analytics", label: "Analytics app", icon: "ChartNoAxesCombined" }
        ] }
    ])

    // 官方 AppPages.cs:26-33 的 Title 逐字：Dashboard / Customers / Team / Billing / Settings。
    // 其余标题按官方组件目录 / BlockCatalog 分组名命名，不再用早期推演的 Gallery 标题。
    function titleFor(key) {
        if (key === "dashboard") return t("dashboardTitle", "Dashboard");
        if (key === "customers") return t("customersTitle", "Customers");
        if (key === "team") return t("teamTitle", "Team");
        if (key === "billing") return t("billingTitle", "Billing");
        if (key === "settings") return t("settingsTitle", "Settings");
        if (key === "foundation") return "Foundation";
        if (key === "buttons") return "Buttons";
        if (key === "components") return "TextFields & Forms";
        if (key === "library") return "Overlays & Tables";
        if (key === "more") return "Messages & Expand";
        if (key === "charts") return "Charts & Selects";
        if (key === "menus") return "Menus & Overlays";
        if (key === "interactions") return "Gestures & Toggles";
        if (key === "motion") return "Activity & TextEffects";
        if (key === "layout") return "Layout";
        if (key === "surfaces") return "Surfaces";
        if (key === "analytics") return "Analytics app";
        return "";
    }

    Sidebar {
        id: _side
        height: parent.height
        th: theme
        collapsed: app.collapsed
        sections: app.navSections
        currentKey: app.section
        workspaceName: app.workspaceData ? app.workspaceData.name : ""
        accountName: app.workspaceData ? app.workspaceData.owner : ""
        accountRole: app.workspaceData ? app.workspaceData.ownerRole : ""
        onNavigate: function (k) { app.section = k; }
        onToggleCollapse: app.collapsed = !app.collapsed
    }

    Item {
        x: _side.width
        width: parent.width - _side.width
        height: parent.height

        ArcTopBar {
            id: _topbar
            width: parent.width
            th: theme
            title: app.titleFor(app.section)
            collapsed: app.collapsed
            onToggleSidebar: app.collapsed = !app.collapsed
            onCycleTheme: app.startDark = !app.startDark
        }

        Loader {
            id: _page
            anchors.top: _topbar.bottom
            width: parent.width
            height: parent.height - _topbar.height
            sourceComponent: app.section === "dashboard" ? _dash
                           : app.section === "customers" ? _cust
                           : app.section === "team" ? _team
                           : app.section === "billing" ? _bill
                           : app.section === "components" ? _ctl
                           : app.section === "library" ? _lib
                           : app.section === "more" ? _more
                           : app.section === "charts" ? _charts
                           : app.section === "foundation" ? _foundation
                           : app.section === "motion" ? _motion
                           : app.section === "menus" ? _menus
                           : app.section === "buttons" ? _buttons
                           : app.section === "interactions" ? _interactions
                           : app.section === "analytics" ? _analytics
                           : app.section === "surfaces" ? _surfaces
                           : app.section === "layout" ? _layout
                           : _set

            onLoaded: if (item) { item.th = theme; }
        }
    }

    Component { id: _dash; PageDashboard { th: theme; model: app.dashboardData; strings: app.strings } }
    Component { id: _cust; PageCustomers { th: theme; customers: app.customersData; strings: app.strings } }
    Component { id: _team; PageTeam { th: theme; ws: app.workspaceData; strings: app.strings } }
    Component { id: _bill; PageBilling { th: theme; info: app.billingData; strings: app.strings } }
    Component { id: _set; PageSettings { th: theme; hostApp: app; strings: app.strings } }
    Component { id: _ctl; PageControls { th: theme } }
    Component { id: _lib; PageControls2 { th: theme } }
    Component { id: _more; PageControls3 { th: theme } }
    Component { id: _charts; PageControls4 { th: theme } }
    Component { id: _foundation; PageFoundation { th: theme } }
    Component { id: _motion; PageMotion { th: theme } }
    Component { id: _menus; PageMenus { th: theme } }
    Component { id: _buttons; PageButtons { th: theme } }
    Component { id: _interactions; PageInteractions { th: theme } }
    Component { id: _analytics; PageAnalytics { th: theme } }
    Component { id: _surfaces; PageSurfaces { th: theme } }
    Component { id: _layout; PageLayout { th: theme } }

    // 主题或强调色变化时让页面重取令牌（Loader 重建，简单可靠）
    onStartDarkChanged: _page.active = false, _page.active = true
    onStartAccentChanged: _page.active = false, _page.active = true
}
