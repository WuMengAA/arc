// ArcAnalyticsApp · Retention 页 —— 真源码 App/Pages/RetentionPage.axaml 的 arc:CohortRetention。
// 12 月度 cohort Jun 2026–May 2027、All/Starter/Business 三段。
import QtQuick 2.15
import "." as Arc
import "AnalyticsData.js" as Data

Flickable {
    id: root
    property var th: null
    property string segment: "All"
    contentWidth: width
    contentHeight: _col.implicitHeight + 48
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    readonly property var _g: Data.retentionGrid(root.segment)

    Column {
        id: _col
        x: 28; y: 20
        width: root.width - 56
        spacing: 16

        Arc.ArcPageHeader {
            th: root.th; width: parent.width
            title: "Space retention"
            subtitle: "Team spaces still editing each month after creation. Updated through Jun 30, 2027."
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Cohort heatmap"
            description: "12 monthly cohorts — cell = % still editing N months after creation."
            Column {
                width: parent.width; spacing: 12
                Arc.ArcSegmentedControl {
                    th: root.th; value: root.segment
                    options: [{value:"All",label:"All"},{value:"Starter",label:"Starter"},{value:"Business",label:"Business"}]
                    onActivated: function (v) { root.segment = v; }
                }
                Grid {
                    width: parent.width; columns: 12; spacing: 3
                    Repeater {
                        model: 144
                        delegate: Rectangle {
                            required property int index
                            readonly property int _r: Math.floor(index / 12)
                            readonly property int _c: index % 12
                            readonly property int _v: root._g[_r][_c]
                            width: (parent.width - 11 * 3) / 12; height: 28
                            radius: 4
                            color: _v < 0 ? root.th.c("SurfaceMuted")
                                 : root.th.fade(root.th.a("accent"), 0.08 + 0.72 * (_v / 100))
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                                anchors.centerIn: parent
                                visible: parent._v >= 0
                                text: String(parent._v)
                                color: parent._v > 60 ? "#FFFFFFFF" : root.th.c("Foreground")
                                font.pixelSize: root.th.design("TypeXS") - 2
                            }
                        }
                    }
                }
                Row {
                    spacing: 8
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Rows: Jun 26 → May 27"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "·"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Columns: month 0 → 11"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "·"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "grey = cohort not yet aged"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Segment baselines"
            description: "Curve() in SampleRetention.cs — Business 0.91→0.74 / Starter 0.70→0.29."
            Arc.ArcTable {
                width: parent.width; height: 44 + 3 * 52 + 44; th: root.th
                caption: "Segments"
                columns: [
                    { key: "name", title: "Segment" },
                    { key: "start", title: "Month 0", align: "right" },
                    { key: "floor", title: "Long-run", align: "right" },
                    { key: "cohorts", title: "Cohorts", align: "right" }
                ]
                rows: [
                    { name: "All", start: "80%", floor: "53%", cohorts: "12" },
                    { name: "Starter", start: "70%", floor: "29%", cohorts: "12" },
                    { name: "Business", start: "91%", floor: "74%", cohorts: "12" }
                ]
            }
        }
    }
}
