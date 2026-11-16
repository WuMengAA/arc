// Charts/DonutChart —— RingThicknessDefault 24 / CenterLineHeight 16.8；
// 真源码 PART_Plot 扇形 + PART_Center 中心读数 + PART_Rows 图例。
// 圆环用 SVG data URI（避开 Qt 6.12 该环境 Canvas 首帧空绘），stroke-dasharray 分段。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var segments: []      // [{label,value,color?}]
    property string totalLabel: "Total"
    property string centerValue: ""
    property real diameter: 180
    property real ringThickness: 24
    property bool showLegend: true

    implicitWidth: showLegend ? diameter + 150 : diameter
    implicitHeight: Math.max(diameter, _legend.implicitHeight)

    readonly property real _C: 2 * Math.PI * 50
    readonly property real _ring: ringThickness > 0 ? ringThickness : th.ct("DonutChart", "RingThicknessDefault")

    function _total() {
        var s = 0;
        for (var i = 0; i < segments.length; i++) s += Number(segments[i].value) || 0;
        return s || 1;
    }
    function _svg() {
        var tot = _total(), acc = 0, s = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 140 140">';
        s += '<circle cx="70" cy="70" r="50" fill="none" stroke="' + th.c("SurfaceMuted") + '" stroke-width="' + _ring + '"/>';
        for (var i = 0; i < segments.length; i++) {
            var seg = segments[i];
            var frac = (Number(seg.value) || 0) / tot;
            var col = seg.color || th.series(i);
            s += '<circle cx="70" cy="70" r="50" fill="none" stroke="' + col + '" stroke-width="' + _ring
               + '" stroke-dasharray="' + (_C * frac - 2 > 0 ? _C * frac - 2 : 0) + ' ' + _C
               + '" stroke-dashoffset="' + (-_C * acc) + '" transform="rotate(-90 70 70)"/>';
            acc += frac;
        }
        return s + '</svg>';
    }

    Item {
        width: root.diameter; height: root.diameter
        Image {
            anchors.fill: parent
            sourceSize: Qt.size(root.diameter * 2, root.diameter * 2)
            smooth: true
            source: "data:image/svg+xml;utf8," + encodeURIComponent(root._svg())
        }
        Column {
            anchors.centerIn: parent
            spacing: 2
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.totalLabel
                color: root.th.c("TextMuted")
                font.pixelSize: root.th.design("TypeXS")
                lineHeight: root.th.ct("DonutChart", "CenterLineHeight")
                lineHeightMode: Text.FixedHeight
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.centerValue !== "" ? root.centerValue : String(root._total())
                color: root.th.c("Foreground")
                font.pixelSize: root.th.design("TypeXL")
                font.weight: root.th.weightSemibold
            }
        }
    }

    Column {
        id: _legend
        visible: root.showLegend
        x: root.diameter + 20
        anchors.verticalCenter: parent.verticalCenter
        width: 130
        spacing: 8
        Repeater {
            model: root.segments
            delegate: Row {
                required property var modelData
                required property int index
                spacing: 8
                Rectangle {
                    width: 10; height: 10; radius: 3
                    color: modelData.color || root.th.series(index)
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    text: modelData.label
                    color: root.th.c("TextSecondary")
                    font.pixelSize: root.th.design("TypeXS")
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    text: String(modelData.value)
                    color: root.th.c("Foreground")
                    font.pixelSize: root.th.design("TypeXS")
                    font.weight: root.th.weightMedium
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
