// arc:LineChart —— LineChartToken 真值：右侧数值槽 48、日期轴行 26、线宽 2、图例下方间距 16。
// 图例：圆点 + 名称胶囊；PREVIOUS 系列用虚线。绘图用 Canvas，Theme 变化时重绘。
import QtQuick 2.15

Column {
    id: root

    property var th: null
    property var days: []
    property var seriesList: []       // [{ name, values, dashed }]
    property real plotHeight: 260
    property string unit: "$"

    spacing: th.n("chart","LegendGap")

    // ── 图例 ──
    Row {
        spacing: 16
        Repeater {
            model: root.seriesList
            delegate: Item {
                required property var modelData
                required property int index
                width: _lg.implicitWidth
                height: 20
                Row {
                    id: _lg
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    Rectangle {
                        width: 14; height: modelData.dashed ? 2 : 3
                        radius: 1.5
                        color: root.th.series(index)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        text: modelData.name
                        color: root.th.c("TextSecondary")
                        font.pixelSize: root.th.design("TypeSM")
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    // ── 绘图区 ──
    Canvas {
        id: cv
        width: root.width
        height: root.plotHeight
        antialiasing: true

        readonly property real gutter: root.th.n("chart","GutterWidth")
        readonly property real axisRow: root.th.n("chart","AxisRowHeight")

        function fmt(v) {
            if (v >= 1000) return root.unit + (v / 1000).toFixed(1) + "k";
            return root.unit + Math.round(v);
        }

        function bounds() {
            var lo = Infinity, hi = -Infinity;
            for (var s = 0; s < root.seriesList.length; s++) {
                var vals = root.seriesList[s].values || [];
                for (var i = 0; i < vals.length; i++) {
                    if (vals[i] < lo) lo = vals[i];
                    if (vals[i] > hi) hi = vals[i];
                }
            }
            if (lo === Infinity) { lo = 0; hi = 1; }
            var pad = (hi - lo) * 0.12 || 1;
            return { lo: lo - pad, hi: hi + pad };
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            if (!root.th || !root.days || root.days.length < 2) return;

            var b = bounds();
            var left = 8, right = width - gutter, top = 10, bottom = height - axisRow;
            var w = right - left, h = bottom - top;
            if (w <= 0 || h <= 0) return;

            // 横向网格 4 条 + 右侧数值
            ctx.font = "11px sans-serif";
            ctx.textAlign = "left";
            ctx.textBaseline = "middle";
            for (var g = 0; g <= 4; g++) {
                var y = top + (h / 4) * g;
                ctx.beginPath();
                ctx.strokeStyle = root.th.c("BorderSubtle");
                ctx.lineWidth = 1;
                ctx.moveTo(left, y + 0.5);
                ctx.lineTo(right, y + 0.5);
                ctx.stroke();
                ctx.fillStyle = root.th.c("TextMuted");
                ctx.fillText(fmt(b.hi - (b.hi - b.lo) * (g / 4)), right + 6, y);
            }

            // 日期轴（首/中/尾）
            var n = root.days.length;
            var ticks = [0, Math.floor((n - 1) / 2), n - 1];
            ctx.textAlign = "center";
            for (var t = 0; t < ticks.length; t++) {
                var ti = ticks[t];
                var tx = left + (w * ti) / (n - 1);
                ctx.fillStyle = root.th.c("TextMuted");
                ctx.fillText(root.days[ti], tx, bottom + axisRow / 2);
            }

            // 各系列曲线
            for (var s = 0; s < root.seriesList.length; s++) {
                var ser = root.seriesList[s];
                var vals = ser.values || [];
                if (vals.length < 2) continue;
                ctx.beginPath();
                for (var i = 0; i < vals.length; i++) {
                    var px = left + (w * i) / (vals.length - 1);
                    var py = bottom - ((vals[i] - b.lo) / (b.hi - b.lo)) * h;
                    if (i === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py);
                }
                ctx.strokeStyle = root.th.series(s === 0 ? 0 : 3);
                ctx.lineWidth = root.th.n("chart","StrokeWidth") - (ser.dashed ? 0.5 : 0);
                ctx.lineJoin = "round";
                ctx.lineCap = "round";
                ctx.setLineDash(ser.dashed ? [5, 4] : []);
                ctx.stroke();
                ctx.setLineDash([]);
            }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        Connections {
            target: root.th
            function onDarkChanged() { cv.requestPaint() }
            function onAccentIndexChanged() { cv.requestPaint() }
        }
    }
}
