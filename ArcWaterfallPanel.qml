// arc:WaterfallPanel —— Layout/WaterfallPanel 真源码移植（WaterfallPanel.cs 372 行 + WaterfallPanelToken.cs +
// WaterfallItemSizing）。
// 瀑布流：按最矮列优先（shortest-lane）把子项塞进 N 条泳道，泳道宽 ≥ MinLaneSize(200)，间距 Spacing(12)。
// 子项高度取它自己的 implicitHeight（真源码用 WaterfallItemSizing 估算），所以这里要求 tile 自带高度。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var tiles: []            // [{component, height}]
    property real minLaneSize: 0
    property real itemSpacing: -1

    readonly property real _min: root.minLaneSize > 0 ? root.minLaneSize : root.th.ct("WaterfallPanel", "MinLaneSize")
    readonly property real _sp: root.itemSpacing >= 0 ? root.itemSpacing : root.th.ct("WaterfallPanel", "Spacing")
    readonly property int _lanes: Math.max(1, Math.floor((root.width + root._sp) / (root._min + root._sp)))
    readonly property real _laneW: root._lanes > 0 ? (root.width - (root._lanes - 1) * root._sp) / root._lanes : root._min
    // 最矮列优先分配：返回 [{x,y,index}] 与总高
    readonly property var _layout: {
        var heights = [], out = [], i;
        for (i = 0; i < root._lanes; i++) heights.push(0);
        for (i = 0; i < root.tiles.length; i++) {
            var t = root.tiles[i];
            var h = (t && t.height > 0) ? t.height : 120;
            var lane = 0;
            for (var j = 1; j < root._lanes; j++) if (heights[j] < heights[lane]) lane = j;
            out.push({ x: lane * (root._laneW + root._sp), y: heights[lane], index: i, h: h });
            heights[lane] += h + root._sp;
        }
        var maxH = 0;
        for (i = 0; i < heights.length; i++) maxH = Math.max(maxH, heights[i]);
        return { items: out, height: Math.max(0, maxH - root._sp) };
    }
    implicitWidth: 320
    implicitHeight: root._layout.height

    Repeater {
        model: root.tiles.length
        delegate: Item {
            required property int index
            readonly property var slot: root._layout.items[index]
            x: slot ? slot.x : 0
            y: slot ? slot.y : 0
            width: root._laneW
            height: slot ? slot.h : 0
            Loader {
                anchors.fill: parent
                sourceComponent: root.tiles[index] && root.tiles[index].component !== undefined
                                ? root.tiles[index].component : root.tiles[index]
            }
        }
    }
}
