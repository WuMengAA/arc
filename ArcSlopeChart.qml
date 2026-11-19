// arc:SlopeChart —— Charts/SlopeChart 真源码移植（SlopeChart.cs + SlopeChartToken.cs）。
// 斜率图：左右两列（StartLabel / EndLabel），每条记录从左值连到右值，线斜率表示升降；
// 行距 RowPitch(44)，两侧标签距离 LabelGap(20)；宽度 < NarrowBreakpoint(440) 时收成窄排版（标签压到线上）。
// HighlightKey / ActiveKey 指定高亮与选中项；IsRankVisible 在两端显示名次。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var items: []          // [{key,label,start,end}]
    property string label: ""
    property string startLabel: "Start"
    property string endLabel: "End"
    property real plotHeight: 0
    property string highlightKey: ""
    property string activeKey: ""
    property bool isRankVisible: false
    property string emptyLabel: "No data"

    readonly property real _pitch: root.th.ct("SlopeChart", "RowPitch")
    readonly property real _gap: root.th.ct("SlopeChart", "LabelGap")
    readonly property real _narrow: root.th.ct("SlopeChart", "NarrowBreakpoint")
    readonly property bool _isNarrow: root.width > 0 && root.width < root._narrow
    readonly property real _h: root.plotHeight > 0 ? root.plotHeight : Math.max(root._pitch, root.items.length * root._pitch)
    readonly property real _colW: Math.min(96, root.width * 0.22)
    // 值域：所有 start/end 的并集（留 8% 余量）
    readonly property var _dom: {
        var lo = Infinity, hi = -Infinity;
        for (var i = 0; i < root.items.length; i++) {
            var s = Number(root.items[i].start), e = Number(root.items[i].end);
            if (isFinite(s)) { lo = Math.min(lo, s); hi = Math.max(hi, s); }
            if (isFinite(e)) { lo = Math.min(lo, e); hi = Math.max(hi, e); }
        }
        if (!isFinite(lo) || !isFinite(hi)) { lo = 0; hi = 1; }
        var pad = (hi - lo) * 0.08 || 1;
        return { lo: lo - pad, hi: hi + pad, span: (hi - lo + 2 * pad) || 1 };
    }
    function _y(v) { return root._h - ((v - root._dom.lo) / root._dom.span) * root._h; }
    implicitWidth: 460
    implicitHeight: root._isNarrow ? root._h + 20 : root._h

    Text {
        visible: root.items.length === 0
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.emptyLabel
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
    }
    // 两端标题
    Row {
        visible: !root._isNarrow && root.items.length > 0
        width: parent.width
        spacing: 0
        Text {
            width: root._colW
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.startLabel
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightMedium : 500
        }
        Item { width: parent.width - 2 * root._colW; height: 1 }
        Text {
            width: root._colW
            horizontalAlignment: Text.AlignRight
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.endLabel
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightMedium : 500
        }
    }
    // 斜率线
    Canvas {
        id: _lines
        y: root._isNarrow ? 0 : 18
        width: parent.width
        height: root._h
        antialiasing: true
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            if (root.items.length === 0) return;
            var lx = root._isNarrow ? 8 : root._colW + 8;
            var rx = root.width - (root._isNarrow ? 8 : root._colW + 8);
            for (var i = 0; i < root.items.length; i++) {
                var it = root.items[i];
                var y1 = root._y(Number(it.start)), y2 = root._y(Number(it.end));
                var hi = (root.highlightKey !== "" && (it.key || "") === root.highlightKey)
                      || (root.activeKey !== "" && (it.key || "") === root.activeKey);
                ctx.beginPath();
                ctx.moveTo(lx, y1);
                ctx.lineTo(rx, y2);
                ctx.lineWidth = hi ? 2.2 : 1.4;
                ctx.strokeStyle = hi ? root.th.c("Foreground") : (root.th ? root.th.fade(root.th.c("TextMuted"), 0.55) : "#889A9A9A");
                ctx.stroke();
                // 两端点
                ctx.beginPath(); ctx.arc(lx, y1, hi ? 3.4 : 2.4, 0, 6.2832);
                ctx.fillStyle = hi ? root.th.c("Foreground") : (root.th ? root.th.c("TextMuted") : "#FF9A9A9A"); ctx.fill();
                ctx.beginPath(); ctx.arc(rx, y2, hi ? 3.4 : 2.4, 0, 6.2832);
                ctx.fillStyle = hi ? root.th.c("Foreground") : (root.th ? root.th.c("TextMuted") : "#FF9A9A9A"); ctx.fill();
            }
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onVisibleChanged: requestPaint()
    }
    // 两端标签（按行）
    Column {
        visible: !root._isNarrow && root.items.length > 0
        y: 18
        spacing: 0
        Repeater {
            model: root.items.length
            delegate: Item {
                required property int index
                readonly property var it: root.items[index]
                width: _box.width
                height: root._h / Math.max(1, root.items.length)
                Row {
                    id: _box
                    width: parent.width
                    height: parent.height
                    Text {
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        width: root._colW
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        text: {
                            var s = (it && it.label) ? it.label : "";
                            if (root.isRankVisible) s = (index + 1) + ". " + s;
                            return s + (it ? "  " + Math.round(it.start) : "");
                        }
                        color: (root.highlightKey !== "" && it && it.key === root.highlightKey)
                               ? (root.th ? root.th.c("Foreground") : "#FF1D1D1D")
                               : (root.th ? root.th.c("TextSecondary") : "#FF6D6D6D")
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    }
                    Item { width: parent.width - 2 * root._colW; height: 1 }
                    Text {
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        width: root._colW
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        text: it ? (Math.round(it.end) + "") : ""
                        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    }
                }
            }
        }
    }
}
