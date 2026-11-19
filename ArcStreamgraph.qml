// arc:Streamgraph —— Charts/Streamgraph 真源码移植（Streamgraph.cs + StreamgraphToken.cs）。
// 流图：多条序列堆叠成一条居中对称的带状区（stacked area, centered）。Offset 决定基线（0 = 居中 / 1 = zero）；
// ShowDirectLabels 在带内直接标名字；顶部图例 LegendGap(16)、LegendMargin[-8,0,-8,0]；轴行高 AxisRowHeight(26)。
// 用 SVG 堆叠路径（与 ArcDonutChart 同口径）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var series: []          // [{key,label,values:[number,...]}]
    property int offset: 0           // 0 居中（streamgraph）/ 1 零基线（stacked）
    property bool showDirectLabels: true
    property bool showLegend: true
    property real plotHeight: 180

    readonly property real _legendGap: root.th.ct("Streamgraph", "LegendGap")
    readonly property real _axisH: root.th.ct("Streamgraph", "AxisRowHeight")
    readonly property int _n: root.series.length
    readonly property int _len: {
        var m = 0;
        for (var i = 0; i < root._n; i++) m = Math.max(m, (root.series[i].values || []).length);
        return m;
    }
    // 每个 x 位置的累计堆叠边界
    readonly property var _bounds: {
        var out = [], i, j;
        if (root._len === 0) return out;
        for (i = 0; i < root._len; i++) {
            var acc = 0, col = [];
            for (j = 0; j < root._n; j++) {
                var vs = root.series[j].values || [];
                var v = vs.length > 0 ? (Number(vs[Math.min(i, vs.length - 1)]) || 0) : 0;
                col.push({ from: acc, to: acc + v, v: v });
                acc += v;
            }
            out.push({ total: acc || 1, col: col });
        }
        return out;
    }
    implicitWidth: 520
    implicitHeight: (root.showLegend ? 20 + root._legendGap : 0) + root.plotHeight + root._axisH

    function _svg() {
        var W = 100, H = 100, i, j;
        var maxTotal = 1;
        for (i = 0; i < root._bounds.length; i++) maxTotal = Math.max(maxTotal, root._bounds[i].total);
        var s = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + W + ' ' + H + '" preserveAspectRatio="none">';
        for (j = 0; j < root._n; j++) {
            var col = root.th ? root.th.series(j) : "#FF2FB8C6";
            var upper = [], lower = [];
            for (i = 0; i < root._bounds.length; i++) {
                var b = root._bounds[i];
                var t = b.total / maxTotal;
                var mid = root.offset === 0 ? (H - H * t) / 2 : H - H * t;
                var u = root.offset === 0
                        ? mid + (H * t) / 2 - (H * (b.total - b.col[j].to)) / (2 * maxTotal)
                        : H - (H * b.col[j].to) / maxTotal;
                var l = root.offset === 0
                        ? u + (H * b.col[j].v) / maxTotal
                        : H - (H * b.col[j].from) / maxTotal;
                upper.push([ (i / Math.max(1, root._bounds.length - 1)) * W, u ]);
                lower.push([ (i / Math.max(1, root._bounds.length - 1)) * W, l ]);
            }
            var d = "";
            for (i = 0; i < upper.length; i++) d += (i === 0 ? "M " : " L ") + upper[i][0].toFixed(2) + " " + upper[i][1].toFixed(2);
            for (i = lower.length - 1; i >= 0; i--) d += " L " + lower[i][0].toFixed(2) + " " + lower[i][1].toFixed(2);
            d += " Z";
            s += '<path d="' + d + '" fill="' + col + '" fill-opacity="0.55" stroke="' + col + '" stroke-opacity="0.9" stroke-width="0.5"/>';
        }
        return s + '</svg>';
    }

    Row {
        id: _legend
        visible: root.showLegend
        height: 20
        spacing: root._legendGap
        Repeater {
            model: root.showLegend ? root._n : 0
            delegate: Row {
                required property int index
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    width: 10; height: 10; radius: 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.th ? root.th.series(index) : "#FF2FB8C6"
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root.series[index].label || root.series[index].key || ""
                    color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
            }
        }
    }
    Image {
        y: root.showLegend ? 20 + root._legendGap : 0
        width: parent.width
        height: root.plotHeight
        sourceSize: Qt.size(root.width * 2, root.plotHeight * 2)
        smooth: true
        fillMode: Image.Stretch
        source: root._n > 0 ? ("data:image/svg+xml;utf8," + encodeURIComponent(root._svg())) : ""
    }
    Item {
        y: (root.showLegend ? 20 + root._legendGap : 0) + root.plotHeight
        width: parent.width
        height: root._axisH
        Rectangle { width: parent.width; height: 1; color: root.th ? root.th.c("Border") : "#FFE0E0E0" }
        Row {
            y: 6
            spacing: Math.max(24, root.width / 6)
            Repeater {
                model: 6
                delegate: Text {
                    required property int index
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: "W" + (index + 1)
                    color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
            }
        }
    }
}
