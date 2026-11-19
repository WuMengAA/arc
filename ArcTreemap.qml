// arc:Treemap —— Charts/Treemap 真源码移植（Treemap.cs + TreemapToken.cs + TreemapNode/TreemapCrumbs/TreemapStage）。
// 矩形树图：squarified treemap 把根节点按权重切成矩形块；FigureGap(12) 是块间距，StageRadius(12) 是舞台圆角。
// 颜色按 ColorDomainMinimum..ColorDomainMaximum 映射到序列色；FocusedNodeId 聚焦某块（显示面包屑）。
// 布局是确定性递归切分（squarify 的简化等价：宽度 > 高度时竖切），不依赖随机。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var root_: null          // {label, value?, children:[...]}；用 items 也可以
    property var items: []            // [{label, value, key?}]
    property string label: ""
    property string colorLabel: ""
    property real colorDomainMinimum: NaN
    property real colorDomainMaximum: NaN
    property string focusedNodeId: ""
    property real plotHeight: 260
    property string emptyLabel: "No data"
    property real figureGap: 0
    property real stageRadius: 0

    readonly property real _gap: root.figureGap > 0 ? root.figureGap : root.th.ct("Treemap", "FigureGap")
    readonly property real _rad: root.stageRadius > 0 ? root.stageRadius : root.th.ct("Treemap", "StageRadius")
    readonly property real _h: root.plotHeight > 0 ? root.plotHeight : 260
    readonly property var _leaves: {
        if (root.items && root.items.length > 0) return root.items;
        if (root.root_ && root.root_.children) return root.root_.children;
        return [];
    }
    readonly property real _total: {
        var s = 0;
        for (var i = 0; i < root._leaves.length; i++) s += Math.max(0, Number(root._leaves[i].value) || 0);
        return s || 1;
    }
    // squarify：按值降序，逐行切；返回 [{x,y,w,h,item,index}]
    readonly property var _rects: {
        var out = [], n = root._leaves.length;
        if (n === 0) return out;
        var W = root.width > 0 ? root.width : 520, H = root._h;
        var order = [], i;
        for (i = 0; i < n; i++) order.push({ i: i, v: Math.max(0, Number(root._leaves[i].value) || 0) });
        order.sort(function (a, b) { return b.v - a.v; });
        // 递归切分：一块区域里取前 k 项，选择让长宽比最好的 k
        function layout(x, y, w, h, list) {
            if (list.length === 0) return;
            if (list.length === 1) {
                out.push({ x: x, y: y, w: w, h: h, item: list[0].item, i: list[0].i });
                return;
            }
            var sum = 0, j;
            for (j = 0; j < list.length; j++) sum += list[j].v;
            // 横向切（沿短边继续切）
            var acc = 0, k = 0;
            var best = -1, bestScore = 1e9;
            for (k = 1; k < list.length; k++) {
                acc = 0;
                for (j = 0; j < k; j++) acc += list[j].v;
                var frac = acc / sum;
                var rw = w * frac, rh = h;
                var score = Math.abs(1 - Math.max(rw, rh) / Math.max(1, Math.min(rw, rh)));
                if (score < bestScore) { bestScore = score; best = k; }
            }
            var kk = Math.max(1, best);
            var a = 0;
            for (j = 0; j < kk; j++) a += list[j].v;
            var f = a / sum;
            if (w >= h) {
                layout(x, y, w * f, h, list.slice(0, kk));
                layout(x + w * f, y, w * (1 - f), h, list.slice(kk));
            } else {
                layout(x, y, w, h * f, list.slice(0, kk));
                layout(x, y + h * f, w, h * (1 - f), list.slice(kk));
            }
        }
        var sorted = [];
        for (i = 0; i < n; i++) sorted.push({ i: order[i].i, v: order[i].v, item: root._leaves[order[i].i] });
        layout(0, 0, W, H, sorted);
        return out;
    }
    implicitWidth: 520
    implicitHeight: root._h

    Text {
        visible: root._rects.length === 0
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.emptyLabel
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
    }
    Repeater {
        model: root._rects
        delegate: Rectangle {
            required property var modelData
            required property int index
            x: modelData.x + root._gap / 2
            y: modelData.y + root._gap / 2
            width: Math.max(2, modelData.w - root._gap)
            height: Math.max(2, modelData.h - root._gap)
            radius: Math.min(root._rad, Math.min(width, height) / 2)
            // 颜色：按值在 colorDomain 上的位置取序列色；聚焦项更强
            color: {
                var v = Number(modelData.item.value) || 0;
                var lo = isNaN(root.colorDomainMinimum) ? 0 : root.colorDomainMinimum;
                var hi = isNaN(root.colorDomainMaximum) ? Math.max(1, root._total) : root.colorDomainMaximum;
                var t = Math.max(0, Math.min(1, (v - lo) / Math.max(0.0001, hi - lo)));
                var base = root.th.series(Math.min(3, Math.floor(t * 4)));
                var focused = root.focusedNodeId !== "" && (modelData.item.key || "") === root.focusedNodeId;
                return root.th ? root.th.fade(base, focused ? 0.95 : 0.62) : base;
            }
            clip: true
            Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Standard") : 240 } }

            Text {
                visible: parent.width > 54 && parent.height > 26
                x: 6; y: 5
                width: parent.width - 12
                elide: Text.ElideRight
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: (modelData.item.label || modelData.item.key || "")
                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                font.weight: root.th ? root.th.weightMedium : 500
            }
            Text {
                visible: parent.width > 54 && parent.height > 42
                x: 6
                y: 21
                width: parent.width - 12
                elide: Text.ElideRight
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: (root.th && root.colorLabel !== "") ? (Math.round(Number(modelData.item.value) || 0) + "") : ""
                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
        }
    }
    // 面包屑（聚焦时）
    Row {
        visible: root.focusedNodeId !== ""
        y: -22
        spacing: 6
        Text {
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: (root.root_ && root.root_.label ? root.root_.label : root.label) + " / " + root.focusedNodeId
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
    }
}
