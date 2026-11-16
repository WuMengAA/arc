// arc:WaterfallPanel/TilePanel/CyclicPanel —— Layout 真源码算法移植：
// WaterfallPanel.cs MeasureOverride 里 "each going to the end of the lane that is currently shortest"
// （ends[l] 最短列优先，平手取第一列，start = used[lane] ? ends[lane]+spacing : 0）；
// TilePanel.cs 首个可放位置、等格；CyclicPanel.cs Offset 以 item 为单位环绕、VisibleItemCount=5。
// 令牌：Waterfall MinLaneSize 200/Spacing 12、Tile MinCellSize 96/Spacing 8、Cyclic ScrollDuration "240ms"。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property string mode: "waterfall"    // waterfall | tile | cyclic
    property var items: []               // [{ h?, label, icon? }]
    property int columns: 0             // 真源码 ColumnsProperty：0 = 按 MinLaneSize 自适应，>0 显式指定泳道数
    readonly property real _wfMin: th.ct("WaterfallPanel", "MinLaneSize")
    readonly property real _wfGap: th.ct("WaterfallPanel", "Spacing")
    readonly property real _tileMin: th.ct("TilePanel", "MinCellSize")
    readonly property real _tileGap: th.ct("TilePanel", "Spacing")
    readonly property int _autoCols: Math.max(1, Math.min(root.items.length || 1,
        Math.floor((root.width - 2 * root._wfGap + root._wfGap) / (root._wfMin + root._wfGap))))
    readonly property int _cols: root.columns > 0 ? Math.max(1, Math.min(root.items.length || 1, root.columns)) : root._autoCols
    readonly property int _tileCols: Math.max(1, Math.floor((root.width - 2 * root._tileGap + root._tileGap) / (root._tileMin + root._tileGap)))
    readonly property real _cellW: Math.max(40, (root.width - 2 * root._wfGap - (_cols - 1) * root._wfGap) / _cols)
    readonly property real _tileW: Math.max(40, (root.width - 2 * root._tileGap - (_tileCols - 1) * root._tileGap) / _tileCols)
    // 真·瀑布流：按 items 顺序模拟 ends[] 数组，返回每项的 x/y/h
    function computeLayout() {
        var ends = [], used = [], r = [];
        for (var l = 0; l < root._cols; l++) { ends.push(0); used.push(false); }
        for (var i = 0; i < root.items.length; i++) {
            var lane = 0;
            for (var l2 = 1; l2 < root._cols; l2++) if (ends[l2] < ends[lane] - 1e-9) lane = l2;
            var h = root.items[i].h || 90;
            var y = used[lane] ? ends[lane] + root._wfGap : 0;
            r.push({ x: lane * (root._cellW + root._wfGap), y: y, h: h, lane: lane });
            ends[lane] = y + h; used[lane] = true;
        }
        return r;
    }
    readonly property var _layout: computeLayout()
    function computeFlow() {
        var m = 0;
        for (var i = 0; i < root._layout.length; i++) m = Math.max(m, root._layout[i].y + root._layout[i].h);
        return m;
    }
    readonly property real _wfH: computeFlow()
    readonly property int _tileRows: Math.ceil(root.items.length / root._tileCols)
    readonly property real _stageH: root.mode === "cyclic" ? 220
                                 : root.mode === "tile" ? _tileRows * (_tileW + _tileGap) - _tileGap
                                 : _wfH
    width: 360; height: _stageH + 2 * root._wfGap
    Rectangle {
        id: _panel
        width: parent.width; height: parent.height
        color: root.th.c("SurfaceMuted"); radius: root.th.t4(root.th.design("RadiusPanel"), 0)
        clip: true
        // Tile：等格 Flow
        Flow {
            visible: root.mode === "tile"
            x: root._tileGap; y: root._tileGap
            width: parent.width - 2 * root._tileGap; spacing: root._tileGap
            Repeater {
                model: root.items
                delegate: Rectangle {
                    required property var modelData
                    width: root._tileW; height: root._tileW
                    radius: root.th.t4(root.th.design("RadiusControl"), 0)
                    color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("Border")
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: modelData.label || ""; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS") }
                }
            }
        }
        // Waterfall：按 _layout[] 精确落位（最短列优先，不依赖 Canvas）
        Item {
            visible: root.mode === "waterfall"
            width: parent.width; height: root._stageH
            clip: true
        Repeater {
            model: root._layout
            delegate: Rectangle {
                required property var modelData; required property int index
                x: root._wfGap + modelData.x; y: root._wfGap + modelData.y
                width: root._cellW; height: modelData.h
                radius: root.th.t4(root.th.design("RadiusControl"), 0)
                color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("Border")
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: (root.items[index] && root.items[index].label) || ""; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS") }
            }
        }
        }
        // Cyclic：5 槽环绕，Offset 可点左右按钮轮换
        Item {
            visible: root.mode === "cyclic"
            width: parent.width; height: 220
            property real offset: 0
            Repeater {
                model: root.items
                delegate: Rectangle {
                    required property var modelData; required property int index
                    property real _a: (index - parent.offset) * 2 * Math.PI / Math.max(root.items.length, 1)
                    property real _r: Math.min(parent.width, parent.height) * 0.34
                    x: parent.width / 2 + Math.cos(_a) * _r - 24
                    y: parent.height / 2 + Math.sin(_a) * _r - 24
                    width: 48; height: 48; radius: 24
                    color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("Border")
                    ArcIcon { anchors.centerIn: parent; th: root.th; kind: modelData.icon || "CircleDot"; width: 20; height: 20; color: root.th.a("accent") }
                    Behavior on x { NumberAnimation { duration: root.th.dur("Fast"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
                    Behavior on y { NumberAnimation { duration: root.th.dur("Fast"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
                }
            }
        }
    }
}
