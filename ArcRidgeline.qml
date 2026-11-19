// arc:Ridgeline —— Charts/Ridgeline 真源码移植（Ridgeline.cs + RidgelineToken.cs + RidgelineSeries）。
// 山脊图：每条序列是其观测值的密度脊线，脊线上移 Overlap 个行高（默认 2.4）压到上一行，形成层叠山峦。
// 序列按 DomainMinimum..DomainMaximum 归一；ActiveId 高亮一条（其余压暗）；底部 AxisHeight(28) 轴 + TickSpacing(72) 刻度。
// Lift(6) 是脊线在行内的抬升量。曲线用 SVG path（与 ArcDonutChart 同口径）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var items: []           // [{key,label,values:[number,...]}]
    property string label: ""
    property string unit: ""
    property real domainMinimum: NaN
    property real domainMaximum: NaN
    property real overlap: 2.4
    property real rowHeight: 48
    property real bandwidth: 0.9
    property bool isTinted: true
    property string activeId: ""
    property string emptyLabel: "No data"
    property real lift: 0
    property real axisHeight: 0
    property real tickSpacing: 0

    readonly property real _lift: root.lift > 0 ? root.lift : root.th.ct("Ridgeline", "Lift")
    readonly property real _axisH: root.axisHeight > 0 ? root.axisHeight : root.th.ct("Ridgeline", "AxisHeight")
    readonly property real _tick: root.tickSpacing > 0 ? root.tickSpacing : root.th.ct("Ridgeline", "TickSpacing")
    readonly property var _dom: {
        var lo = root.domainMinimum, hi = root.domainMaximum, i, j;
        if (isNaN(lo) || isNaN(hi)) {
            lo = Infinity; hi = -Infinity;
            for (i = 0; i < root.items.length; i++) {
                var vs = root.items[i].values || [];
                for (j = 0; j < vs.length; j++) { if (vs[j] < lo) lo = vs[j]; if (vs[j] > hi) hi = vs[j]; }
            }
            if (!isFinite(lo) || !isFinite(hi)) { lo = 0; hi = 1; }
            var pad = (hi - lo) * 0.06 || 1;
            if (isNaN(root.domainMinimum)) lo -= pad;
            if (isNaN(root.domainMaximum)) hi += pad;
        }
        return { lo: lo, hi: hi, span: (hi - lo) || 1 };
    }
    readonly property int _n: root.items.length
    readonly property real _plotH: Math.max(40, root._n * root.rowHeight)
    implicitWidth: 480
    implicitHeight: (root._n === 0 ? 24 : root._plotH + root._axisH)

    function _path(vals, rowIndex) {
        // 密度：把观测值分布切成 48 个桶，平滑后画贝塞尔面积
        var B = 48, counts = [], i, j;
        for (i = 0; i < B; i++) counts.push(0);
        for (i = 0; i < vals.length; i++) {
            var t = (vals[i] - root._dom.lo) / root._dom.span;
            var b = Math.max(0, Math.min(B - 1, Math.floor(t * B)));
            counts[b] += 1;
        }
        // 三点平滑
        var sm = [];
        for (i = 0; i < B; i++) {
            var a = counts[Math.max(0, i - 1)], c = counts[i], d = counts[Math.min(B - 1, i + 1)];
            sm.push((a + 2 * c + d) / 4);
        }
        var peak = 0;
        for (i = 0; i < B; i++) if (sm[i] > peak) peak = sm[i];
        if (peak <= 0) peak = 1;
        var W = 100, baseY = 40
        var y0 = baseY
        var d2 = "M 0 " + baseY
        for (i = 0; i < B; i++) {
            var x = (i / (B - 1)) * W;
            var amp = (sm[i] / peak) * 30 * root.bandwidth;
            d2 += " L " + x.toFixed(1) + " " + (baseY - amp).toFixed(1);
        }
        // 回程封底
        d2 += " L " + W + " " + (baseY + 6) + " L 0 " + (baseY + 6) + " Z";
        return d2;
    }
    function _svg() {
        if (root._n === 0) return "";
        var s = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 ' + (root._n * 40 + 8) + '" preserveAspectRatio="none">';
        for (var i = root._n - 1; i >= 0; i--) {
            var it = root.items[i];
            var vals = it.values || [];
            if (vals.length < 2) continue;
            var col = root.th ? root.th.series(i) : "#FF2FB8C6";
            var dim = root.activeId !== "" && (it.key || "") !== root.activeId;
            var op = dim ? 0.28 : (root.isTinted ? 0.34 : 0.16);
            var stroke = dim ? 0.45 : 1;
            var yOff = (root._n - 1 - i) * 40;
            s += '<g transform="translate(0,' + yOff + ')">'
               + '<path d="' + root._path(vals, i) + '" fill="' + col + '" fill-opacity="' + op + '"'
               + ' stroke="' + col + '" stroke-opacity="' + stroke + '" stroke-width="0.6" vector-effect="non-scaling-stroke"/>'
               + '</g>';
        }
        return s + '</svg>';
    }

    Text {
        visible: root._n === 0
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.emptyLabel
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
    }
    Image {
        visible: root._n > 0
        width: parent.width
        height: root._plotH
        sourceSize: Qt.size(root.width * 2, root._plotH * 2)
        smooth: true
        fillMode: Image.Stretch
        source: root._n > 0 ? ("data:image/svg+xml;utf8," + encodeURIComponent(root._svg())) : ""
    }
    // 每行标签（浮在脊线上）
    Column {
        visible: root._n > 0
        spacing: 0
        Repeater {
            model: root._n
            delegate: Item {
                required property int index
                width: 1; height: root.rowHeight
                Text {
                    x: 4
                    y: -9
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: (root.items[index] && root.items[index].label) ? root.items[index].label : ""
                    color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
            }
        }
    }
    // 底部轴：TickSpacing 一段一个刻度
    Item {
        visible: root._n > 0
        y: root._plotH
        width: parent.width
        height: root._axisH
        Rectangle {
            width: parent.width; height: 1
            color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        }
        Repeater {
            model: Math.max(2, Math.floor(root.width / root._tick) + 1)
            delegate: Item {
                required property int index
                readonly property real frac: index / Math.max(1, Math.floor(parent.width / root._tick))
                x: frac * parent.width
                width: 1; height: root._axisH
                Rectangle { width: 1; height: 4; color: root.th ? root.th.c("Border") : "#FFE0E0E0" }
                Text {
                    y: 8
                    x: -implicitWidth / 2 + 1
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: {
                        var v = root._dom.lo + (root._dom.hi - root._dom.lo) * parent.frac;
                        return (Math.round(v * 10) / 10) + root.unit;
                    }
                    color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
            }
        }
    }
}
