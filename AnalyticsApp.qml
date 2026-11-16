// ArcAnalyticsApp —— TKCode.Arc 官方预设应用整页移植（templates/.../ArcAnalyticsApp）。
// 真源码 MainView.axaml：DockPanel 顶栏 56（28x28 logo + ArcDisplayName + SegmentedControl
// Overview/Revenue/Retention/Usage/Status + ThemeSwitcher IsIconOnly）+ PageHost 五页。
// 五页内容各承载一个 showpiece：KpiDrilldown / RevenueExplorer / CohortRetention /
// UsageForecast / UptimeStatus；数据全部来自 AnalyticsData.js（SampleData/*.cs 真值）。
import QtQuick 2.15
import "." as Arc

Rectangle {
    id: root
    property bool dark: false
    property int accentIndex: 0
    property string section: "overview"

    color: theme.c("Background")

    ArcTheme { id: theme; dark: root.dark; accentIndex: root.accentIndex }

    readonly property var _options: [
        { value: "overview",   label: "Overview" },
        { value: "revenue",    label: "Revenue" },
        { value: "retention",  label: "Retention" },
        { value: "usage",      label: "Usage" },
        { value: "status",     label: "Status" }
    ]

    // ── PART_TopBar（MainView.axaml DockPanel.Dock=Top, Height=56, Padding 16,0）──
    Rectangle {
        id: _top
        width: parent.width; height: 56
        color: theme.c("Surface")
        Rectangle {
            anchors.bottom: parent.bottom; width: parent.width; height: 1
            color: theme.c("BorderSubtle")
        }
        Row {
            x: 16; anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            Rectangle {
                width: 28; height: 28; radius: 8
                color: theme.c("Foreground")
                anchors.verticalCenter: parent.verticalCenter
                Arc.ArcIcon {
                    anchors.centerIn: parent; th: theme
                    kind: "Activity"; width: 14; height: 14
                    color: theme.c("Background")
                }
            }
            Text { renderType: Text.NativeRendering; font.family: theme.fontFamily; 
                text: "ArcDisplayName"
                color: theme.c("Foreground")
                font.pixelSize: theme.design("TypeBase")
                font.weight: theme.design("WeightMedium")
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Arc.ArcSegmentedControl {
            anchors.centerIn: parent
            th: theme
            value: root.section
            options: root._options
            onActivated: function (v) { root.section = v; }
        }
        Arc.ArcThemeSwitcher {
            anchors.right: parent.right; anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            th: theme; dark: root.dark; iconOnly: true
            onChangeRequested: function (next) { root.dark = next; }
        }
    }

    // ── PageHost ──
    Loader {
        id: _page
        anchors.top: _top.bottom
        width: parent.width
        height: parent.height - _top.height
        sourceComponent: root.section === "overview" ? _overview
                       : root.section === "revenue" ? _revenue
                       : root.section === "retention" ? _retention
                       : root.section === "usage" ? _usage
                       : _status
        onLoaded: if (item) item.th = theme
    }

    Component { id: _overview;  AnOverview  { th: theme } }
    Component { id: _revenue;   AnRevenue   { th: theme } }
    Component { id: _retention; AnRetention { th: theme } }
    Component { id: _usage;     AnUsage     { th: theme } }
    Component { id: _status;    AnStatus    { th: theme } }

    onDarkChanged: _page.active = false, _page.active = true
    onAccentIndexChanged: _page.active = false, _page.active = true
}
