// ArcAnalyticsApp · Usage 页 —— 真源码 App/Pages/UsagePage.axaml 的 arc:UsageForecast。
// SampleUsage.cs：21 天读数、Budget 26M、UnitPrice 150、$0.15 / 1k events。
import QtQuick 2.15
import "." as Arc
import "AnalyticsData.js" as Data

Flickable {
    id: root
    property var th: null
    contentWidth: width
    contentHeight: _col.implicitHeight + 48
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    readonly property var _e: Data.usageEvents()
    readonly property real _used: root._e[20]
    readonly property real _budget: Data.USAGE.budget

    Column {
        id: _col
        x: 28; y: 20
        width: root.width - 56
        spacing: 16

        Arc.ArcPageHeader {
            th: root.th; width: parent.width
            title: "Usage outlook"
            subtitle: "Harborline Studio · Growth plan · Renews Jul 1"
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Events sent so far"
            description: "Weekdays ≈1.35M, weekends ≈0.52M; budget 26M."
            Arc.ArcLineChart {
                width: parent.width; th: root.th; plotHeight: 200; unit: ""
                days: ["Jun 1","Jun 5","Jun 10","Jun 15","Jun 21"]
                seriesList: [
                    { name: "Events (M)", values: root._e, dashed: false },
                    { name: "Budget 26M", values: [26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26], dashed: true }
                ]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Cycle usage"
            description: "Progress bars use Progress/TrackHeight 7 and Success at 100%."
            Column {
                width: parent.width; spacing: 14
                Arc.ArcProgress { width: parent.width; th: root.th; label: "Events"; percentage: Math.min(100, Math.round(root._used / root._budget * 100)) }
                Arc.ArcProgress { width: parent.width; th: root.th; label: "Database storage"; percentage: 62 }
                Arc.ArcProgress { width: parent.width; th: root.th; label: "Editor seats"; percentage: 40 }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Forecast"
            description: "At $0.15 per 1k events — $150 per million over budget."
            Arc.ArcTable {
                width: parent.width; height: 44 + 4 * 52 + 44; th: root.th
                caption: "Billing cycle Jun 1–30, 2027"
                columns: [
                    { key: "k", title: "Measure" },
                    { key: "v", title: "Value", align: "right" }
                ]
                rows: [
                    { k: "Events used (day 21)", v: root._used.toFixed(2) + "M" },
                    { k: "Budget", v: "26.00M" },
                    { k: "Projected at day 30", v: (root._used / 21 * 30).toFixed(2) + "M" },
                    { k: "Overage charge", v: "$" + Math.round(Math.max(0, root._used / 21 * 30 - 26) * 150) }
                ]
            }
        }
    }
}
