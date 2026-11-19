// arc:Gauge —— Charts/Gauge 真源码移植（Gauge.cs + GaugeToken.cs + GaugeTheme.axaml）。
// 半圆表盘：底环（SurfaceMuted）+ 数值弧（序列色/强调色）+ 中心读数（Type2XL）+ 下方 Caption。
// 令牌：RingThickness9 / DialMaxWidth176 / CaptionGap10。阈值（Threshold）的刻度短线段染 Success/Warning/Danger。
// 弧线用 SVG data URI（与 ArcDonutChart 同口径，避开 Qt 6.12 该环境 Canvas 首帧空绘）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property real value: 0
    property real minValue: 0
    property real maxValue: 100
    property string caption: ""
    property string valueText: ""
    property var thresholds: []        // [{at:number, tone:"success|warning|danger"}]
    property color arcColor: th ? th.a("accent") : "#FF2FB8C6"
    property real diameter: 176        // DialMaxWidth

    readonly property real _ring: root.th.ct("Gauge", "RingThickness")
    readonly property real _capGap: root.th.ct("Gauge", "CaptionGap")
    readonly property real _maxW: root.th.ct("Gauge", "DialMaxWidth")
    readonly property real _d: Math.min(root.diameter > 0 ? root.diameter : root._maxW, root._maxW)
    // 半圆：-90° 到 +90°，半径按直径减环厚
    readonly property real _r: (root._d - root._ring) / 2
    readonly property real _frac: Math.max(0, Math.min(1,
            (root.value - root.minValue) / Math.max(0.000001, root.maxValue - root.minValue)))
    readonly property string _shown: root.valueText !== "" ? root.valueText : String(Math.round(root.value))

    implicitWidth: root._d
    implicitHeight: root._d / 2 + root._ring / 2 + _readout.implicitHeight + root._capGap

    function _svg() {
        var cx = 60, cy = 58, r = 50, TAU = Math.PI;
        var s = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 66">';
        // 底环（半圆）
        s += '<path d="M ' + (cx - r) + ' ' + cy + ' A ' + r + ' ' + r + ' 0 0 1 ' + (cx + r) + ' ' + cy
           + '" fill="none" stroke="' + (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0")
           + '" stroke-width="' + root._ring + '" stroke-linecap="round"/>';
        // 数值弧
        if (root._frac > 0.001) {
            var ang = TAU * root._frac;
            var ex = cx - r * Math.cos(ang), ey = cy - r * Math.sin(ang);
            s += '<path d="M ' + (cx - r) + ' ' + cy + ' A ' + r + ' ' + r + ' 0 ' + (root._frac > 0.5 ? 1 : 0) + ' 1 '
               + ex.toFixed(2) + ' ' + ey.toFixed(2)
               + '" fill="none" stroke="' + root.arcColor + '" stroke-width="' + root._ring + '" stroke-linecap="round"/>';
        }
        // 阈值刻度：在各自位置画一小段径向短线
        for (var i = 0; i < root.thresholds.length; i++) {
            var t = root.thresholds[i];
            var f = Math.max(0, Math.min(1, (t.at - root.minValue) / Math.max(0.000001, root.maxValue - root.minValue)));
            var a = TAU * f;
            var x1 = cx - (r - root._ring / 2 - 1) * Math.cos(a), y1 = cy - (r - root._ring / 2 - 1) * Math.sin(a);
            var x2 = cx - (r + root._ring / 2 + 1) * Math.cos(a), y2 = cy - (r + root._ring / 2 + 1) * Math.sin(a);
            var tone = t.tone || "warning";
            var col = root.th ? root.th.c(tone === "success" ? "Success" : tone === "danger" ? "Danger" : "Warning") : "#FFB08000";
            s += '<line x1="' + x1.toFixed(2) + '" y1="' + y1.toFixed(2) + '" x2="' + x2.toFixed(2) + '" y2="' + y2.toFixed(2)
               + '" stroke="' + col + '" stroke-width="2"/>';
        }
        return s + '</svg>';
    }

    Image {
        width: root._d
        height: root._d / 2 + root._ring / 2
        sourceSize: Qt.size(root._d * 2, root._d + root._ring)
        smooth: true
        source: "data:image/svg+xml;utf8," + encodeURIComponent(root._svg())
    }
    Column {
        id: _readout
        anchors.top: parent.top
        anchors.topMargin: root._d / 2 - _big.implicitHeight * 0.62
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0
        Text {
            id: _big
            renderType: Text.NativeRendering
            anchors.horizontalCenter: parent.horizontalCenter
            text: root._shown
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            font.pixelSize: root.th ? root.th.design("Type2XL") : 26
            font.weight: root.th ? root.th.weightMedium : 500
        }
    }
    Text {
        anchors.top: parent.top
        anchors.topMargin: root._d / 2 + root._ring / 2 + root._capGap
        anchors.horizontalCenter: parent.horizontalCenter
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.caption
        visible: root.caption !== ""
        color: root.th ? root.th.c("TextMuted") : "#FF6D6D6D"
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
    }
}
