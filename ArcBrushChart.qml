// arc:BrushChart —— Charts/BrushChart 真源码移植（BrushChart.cs 1138 行 + BrushChartToken.cs + BrushChartOverview/
// ChartTimeTypes）。
// 带刷选的折线图：主图（GutterWidth44 的数值栏 + AxisRowHeight28 的轴行）+ 下方 Overview 缩略图
// （OverviewMargin[0,8,44,0]）；刷选区间用 Range（0..1 两端）表示，拖两端手柄改区间。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var values: []           // [number]
    property var range: [0, 1]        // 刷选区间（0..1）
    property real minSpan: 0.05
    property real overviewHeight: 56
    property string unit: ""

    readonly property real _gutter: root.th.ct("BrushChart", "GutterWidth")
    readonly property real _axisH: root.th.ct("BrushChart", "AxisRowHeight")
    readonly property real _ovMargin: root.th.t4(root.th.ct("BrushChart", "OverviewMargin"), 3)
    readonly property real _plotH: root.height > 0 ? Math.max(80, root.height - root.overviewHeight - root._axisH - root._ovMargin) : 160
    readonly property real _lo: Math.min(root.range[0], root.range[1])
    readonly property real _hi: Math.max(root.range[0], root.range[1])
    implicitWidth: 440
    implicitHeight: root._plotH + root._axisH + root.overviewHeight + root._ovMargin

    // 主图折线
    Canvas {
        id: _main
        x: root._gutter
        width: parent.width - root._gutter
        height: root._plotH
        antialiasing: true
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            if (!root.values || root.values.length < 2) return;
            var lo = Math.min.apply(null, root.values), hi = Math.max.apply(null, root.values);
            var span = (hi - lo) || 1, n = root.values.length;
            // 刷选区外的部分压暗
            ctx.fillStyle = root.th ? root.th.fade(root.th.c("Surface"), 0.72) : "#B8FFFFFF";
            ctx.fillRect(0, 0, width * root._lo, height);
            ctx.fillRect(width * root._hi, 0, width * (1 - root._hi), height);
            ctx.beginPath();
            for (var i = 0; i < n; i++) {
                var x = (width * i) / (n - 1);
                var y = height - ((root.values[i] - lo) / span) * (height - 8) - 4;
                if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
            }
            ctx.lineWidth = 1.8;
            ctx.lineJoin = "round";
            ctx.strokeStyle = root.th ? root.th.series(0) : "#FF2FB8C6";
            ctx.stroke();
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        property real tick: root._lo + root._hi
        onTickChanged: requestPaint()
    }
    // 数值栏
    Column {
        width: root._gutter
        height: root._plotH
        Repeater {
            model: 4
            delegate: Text {
                required property int index
                width: root._gutter - 6
                height: (root._plotH - 8) / 4
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: {
                    if (!root.values || root.values.length === 0) return "";
                    var lo = Math.min.apply(null, root.values), hi = Math.max.apply(null, root.values);
                    var v = hi - (hi - lo) * (index / 3);
                    return (Math.round(v * 10) / 10) + root.unit;
                }
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
        }
    }
    // Overview（缩略 + 刷选窗）
    Rectangle {
        id: _ov
        y: root._plotH + root._axisH
        x: root._gutter
        width: parent.width - root._gutter
        height: root.overviewHeight - root._ovMargin
        radius: 10
        color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
        clip: true
        Canvas {
            anchors.fill: parent
            antialiasing: true
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                if (!root.values || root.values.length < 2) return;
                var lo = Math.min.apply(null, root.values), hi = Math.max.apply(null, root.values);
                var span = (hi - lo) || 1, n = root.values.length;
                ctx.beginPath();
                for (var i = 0; i < n; i++) {
                    var x = (width * i) / (n - 1);
                    var y = height - ((root.values[i] - lo) / span) * (height - 6) - 3;
                    if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                }
                ctx.lineWidth = 1.2;
                ctx.strokeStyle = root.th ? root.th.fade(root.th.series(0), 0.7) : "#B32FB8C6";
                ctx.stroke();
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            property real tick2: root._lo + root._hi
            onTick2Changed: requestPaint()
        }
        // 刷选窗
        Rectangle {
            x: parent.width * root._lo
            width: Math.max(8, parent.width * (root._hi - root._lo))
            height: parent.height
            radius: 8
            color: root.th ? root.th.fade(root.th.a("accent"), 0.14) : "#242FB8C6"
            border.width: 1.5
            border.color: root.th ? root.th.a("accent") : "#FF2FB8C6"
            // 左手柄
            Rectangle {
                x: -2
                width: 6; height: parent.height
                radius: 3
                color: root.th ? root.th.a("accent") : "#FF2FB8C6"
            }
            // 右手柄
            Rectangle {
                anchors.right: parent.right
                x: -4
                width: 6; height: parent.height
                radius: 3
                color: root.th ? root.th.a("accent") : "#FF2FB8C6"
            }
            MouseArea {
                anchors.fill: parent
                onPositionChanged: {
                    if (!pressed) return;
                    var f = Math.max(0, Math.min(1, mouse.x / parent.parent.width));
                    var span = root._hi - root._lo;
                    var lo2 = Math.max(0, Math.min(1 - span, f - span / 2));
                    root.range = [lo2, lo2 + span];
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            onPositionChanged: {
                if (!pressed) return;
                var f = Math.max(0, Math.min(1, mouse.x / width));
                var span = Math.max(root.minSpan, root._hi - root._lo);
                var lo2 = Math.max(0, Math.min(1 - span, f - span / 2));
                root.range = [lo2, lo2 + span];
            }
        }
    }
}
