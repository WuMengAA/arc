// ArcAnalyticsApp · Overview 页 —— 真源码 App/Pages/OverviewPage.axaml 的 arc:KpiDrilldown "Studio pulse"。
// 6 指标（SampleKpis.cs 180 天种子序列）+ 30 天折线 + Tier 维度下钻表。
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

    readonly property var _k: Data.kpis()
    readonly property real _cw: (width - 56 - 32) / 3

    Column {
        id: _col
        x: 28; y: 20
        width: root.width - 56
        spacing: 16

        Arc.ArcPageHeader {
            th: root.th; width: parent.width
            title: "Studio pulse"
            subtitle: "KpiDrilldown — six seeded metrics, 180-day series, three drilldown dimensions."
        }

        Grid {
            width: parent.width; columns: 3; spacing: 16
            Repeater {
                model: root._k
                delegate: Arc.ArcMetricCard {
                    required property var modelData
                    required property int index
                    th: root.th
                    width: root._cw
                    label: modelData.label
                    value: modelData.value
                    prefix: modelData.prefix; suffix: modelData.suffix
                    decimals: modelData.decimals
                    change: modelData.change; up: modelData.up
                    context: modelData.context
                    sparkValues: modelData.spark
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Annual run rate · last 30 days"
            description: "Seeded 180-day series (mulberry32) — plateau, rise, dip."
            Arc.ArcLineChart {
                width: parent.width; th: root.th; plotHeight: 190; unit: "$"
                days: ["D1","D5","D10","D15","D20","D25","D30"]
                seriesList: [
                    { name: "Run rate", values: root._k[0].series, dashed: false },
                    { name: "Baseline", values: [2.30,2.32,2.33,2.35,2.36,2.38,2.40], dashed: true }
                ]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Breakdown by Tier"
            description: "SampleKpis.cs shares [0.44, 0.30, 0.18, 0.08] with seeded drift."
            Arc.ArcTable {
                width: parent.width; height: 44 + 4 * 52 + 44; th: root.th
                caption: "Tier"
                columns: [
                    { key: "name", title: "Segment" },
                    { key: "share", title: "Share" },
                    { key: "value", title: "Run rate", align: "right" },
                    { key: "trend", title: "30d", align: "right" }
                ]
                rows: (function () {
                    var out = [], b = Data.breakdown("tier", root._k[0].value * 1e6);
                    for (var i = 0; i < b.length; i++) out.push({
                        name: b[i].name, share: (b[i].share * 100).toFixed(0) + "%",
                        value: "$" + (b[i].value / 1e6).toFixed(2) + "M", trend: b[i].trend
                    });
                    return out;
                })()
            }
        }
    }
}
