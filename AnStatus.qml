// ArcAnalyticsApp · Status 页 —— 真源码 App/Pages/StatusPage.axaml 的 arc:UptimeStatus。
// SampleUptime.cs：4 服务、5 incidents、Now 2027-03-14 14:30 UTC。
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

    readonly property var _s: Data.UPTIME.services
    readonly property real _cw: (width - 56 - 16) / 2

    Column {
        id: _col
        x: 28; y: 20
        width: root.width - 56
        spacing: 16

        Arc.ArcPageHeader {
            th: root.th; width: parent.width
            title: "Larkspur status"
            subtitle: "All systems monitored · Updated 2027-03-14 14:32 UTC"
        }

        Grid {
            width: parent.width; columns: 2; spacing: 16
            Repeater {
                model: root._s
                delegate: Arc.ArcCard {
                    required property var modelData
                    required property int index
                    th: root.th; width: root._cw
                    title: modelData.name
                    description: modelData.desc
                    Row {
                        width: parent.width; spacing: 10
                        Rectangle {
                            width: 10; height: 10; radius: 5
                            color: modelData.status === "Operational" ? root.th.c("Success") : root.th.c("Warning")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                            text: modelData.status
                            color: modelData.status === "Operational" ? root.th.c("Success") : root.th.c("Warning")
                            font.pixelSize: root.th.design("TypeSM")
                        }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                            text: modelData.latency + " ms p95"
                            color: root.th.c("TextMuted")
                            font.pixelSize: root.th.design("TypeXS")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Arc.ArcSparkline {
                            th: root.th; up: modelData.status === "Operational"
                            values: [12,15,13,18,16,20,17,22,19,21,18,20]
                        }
                    }
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Incidents · last 90 days"
            description: "Five seeded incidents; the first one is still being monitored."
            Arc.ArcTable {
                width: parent.width; height: 44 + 5 * 52 + 44; th: root.th
                caption: "Incidents"
                columns: [
                    { key: "date", title: "Date" },
                    { key: "title", title: "Title" },
                    { key: "service", title: "Service" },
                    { key: "status", title: "Status", align: "right" }
                ]
                rows: (function () {
                    var o = [];
                    for (var i = 0; i < Data.UPTIME.incidents.length; i++) o.push(Data.UPTIME.incidents[i]);
                    return o;
                })()
            }
        }
    }
}
