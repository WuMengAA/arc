// arc:ActivityHeatmap —— Charts/ActivityHeatmap 真源码移植（ActivityHeatmap.cs + ActivityHeatmapToken.cs +
// ActivityDay / ActivityHeatmapGrid / ActivityHeatmapLegend）。
// 贡献热力图：列是周、行是星期（WeekdayColumn30 宽标签列），格边长在 CellMin9 .. CellMax15 之间自适应，CellGap3。
// 每格颜色 = 序列色按该日强度（0..1）叠到 SurfaceMuted 上；底部是图例（Less → More）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var days: []            // [{date:"2026-01-02", value:number}] 或纯 number 数组
    property int cellMax: 0          // 0 → 走令牌 CellMax
    property bool showWeekdayLabels: true
    property bool showLegend: true
    property string weekdayLabel: "Mon"
    property var weekdayNames: ["", "Mon", "", "Wed", "", "Fri", ""]

    readonly property real _gap: root.th.ct("ActivityHeatmap", "CellGap")
    readonly property real _cMin: root.th.ct("ActivityHeatmap", "CellMin")
    readonly property real _cMax: root.cellMax > 0 ? root.cellMax : root.th.ct("ActivityHeatmap", "CellMax")
    readonly property real _labelW: root.th.ct("ActivityHeatmap", "WeekdayColumn")
    readonly property int _weeks: Math.ceil(root.days.length / 7)
    readonly property real _cell: Math.max(root._cMin, Math.min(root._cMax, root._cMax))
    readonly property real _maxVal: {
        var m = 0;
        for (var i = 0; i < root.days.length; i++) {
            var v = root._valueOf(i);
            if (v > m) m = v;
        }
        return m || 1;
    }
    function _valueOf(i) {
        var d = root.days[i];
        if (d === undefined || d === null) return 0;
        return typeof d === "number" ? d : (Number(d.value) || 0);
    }
    implicitWidth: (root.showWeekdayLabels ? root._labelW : 0) + root._weeks * (root._cell + root._gap)
    implicitHeight: 7 * (root._cell + root._gap) + (root.showLegend ? 10 + 16 : 0)

    // 星期标签列
    Column {
        visible: root.showWeekdayLabels
        spacing: root._gap
        Repeater {
            model: 7
            delegate: Text {
                required property int index
                width: root._labelW - 4
                height: root._cell
                verticalAlignment: Text.AlignVCenter
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root.weekdayNames[index] || ""
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
        }
    }
    Grid {
        x: root.showWeekdayLabels ? root._labelW : 0
        columns: root._weeks
        columnSpacing: root._gap
        rowSpacing: root._gap
        Repeater {
            model: root._weeks * 7
            delegate: Rectangle {
                required property int index
                readonly property real v: index < root.days.length ? root._valueOf(index) : 0
                readonly property real intensity: v <= 0 ? 0 : Math.max(0.18, Math.min(1, v / root._maxVal))
                width: root._cell; height: root._cell
                radius: Math.max(1, root._cell * 0.18)
                color: intensity <= 0
                        ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0")
                        : (root.th ? root.th.fade(root.th.series(0), intensity) : "#FF2FB8C6")
                visible: index < root.days.length
            }
        }
    }
    // 图例：Less — 五档 — More
    Row {
        visible: root.showLegend
        x: root.showWeekdayLabels ? root._labelW : 0
        y: root.implicitHeight - 16
        spacing: 4
        Text {
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: "Less"
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            anchors.verticalCenter: parent.verticalCenter
        }
        Repeater {
            model: [0.18, 0.38, 0.6, 0.8, 1]
            delegate: Rectangle {
                required property real modelData
                width: root._cell; height: root._cell
                radius: Math.max(1, root._cell * 0.18)
                anchors.verticalCenter: parent.verticalCenter
                color: root.th ? root.th.fade(root.th.series(0), modelData) : "#FF2FB8C6"
            }
        }
        Text {
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: "More"
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
