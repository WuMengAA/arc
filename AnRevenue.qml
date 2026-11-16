// ArcAnalyticsApp · Revenue 页 —— 真源码 App/Pages/RevenuePage.axaml 的 arc:RevenueExplorer。
// SampleRevenue.cs：Opening 1,050,000；24 个月 from Mar 2024，seed 7。
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

    readonly property var _r: Data.revenue()
    readonly property var _arr: Data.revenueArr()

    Column {
        id: _col
        x: 28; y: 20
        width: root.width - 56
        spacing: 16

        Arc.ArcPageHeader {
            th: root.th; width: parent.width
            title: "Subscription revenue"
            subtitle: "RevenueExplorer — new, expansion and churned MRR, 24 months from Mar 2024."
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Recurring revenue"
            description: "Opening $1.05M → $2.26M after 24 months; dip in new revenue at month 8."
            Arc.ArcLineChart {
                width: parent.width; th: root.th; plotHeight: 200; unit: "$"
                days: ["Mar 24","Jul 24","Nov 24","Mar 25","Jul 25","Nov 25","Feb 26"]
                seriesList: [{ name: "ARR", values: root._arr, dashed: false }]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Net new MRR by month"
            description: "BarChart token: GutterWidth 52 / MaxBarWidth 28 / SectionGap 20."
            Arc.ArcBarChart {
                width: parent.width; th: root.th; kind: "Net new"; unit: "$"; plotHeight: 150
                values: (function () { var o = []; for (var i = 0; i < root._r.length; i++) o.push(root._r[i].net); return o; })()
                labels: ["M1","M4","M8","M12","M16","M20","M24"]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Monthly detail"
            description: "First eight months — churn spike in month 6 (×1.35)."
            Arc.ArcTable {
                width: parent.width; height: 44 + 8 * 52 + 44; th: root.th
                caption: "Revenue months"
                columns: [
                    { key: "month", title: "Month" },
                    { key: "new", title: "New", align: "right" },
                    { key: "expansion", title: "Expansion", align: "right" },
                    { key: "churn", title: "Churn", align: "right" },
                    { key: "net", title: "Net", align: "right" }
                ]
                rows: (function () {
                    var o = [];
                    for (var i = 0; i < 8; i++) o.push({
                        month: root._r[i].month,
                        new: "$" + root._r[i].new, expansion: "$" + root._r[i].expansion,
                        churn: "$" + root._r[i].churn, net: "$" + root._r[i].net
                    });
                    return o;
                })()
            }
        }
    }
}
