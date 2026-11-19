// arc:TilePanel —— Layout/TilePanel 真源码移植（TilePanel.cs 735 行 + TilePanelToken.cs）。
// 磁贴面板：子项按 MinCellSize(96) 的最小边长自动铺成尽可能满的网格，间距 Spacing(8)。
// 布局是确定性切分（同 TilePanel 的 fill-line 算法：先按列数=floor(W/最小边长)，再按行均分）。
// 子项通过 default property content 传进来；每格用 content 数组的下标对位。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var tiles: []           // [Component, ...] 或 [{component, spanCol, spanRow}]
    property real minCellSize: 0
    property bool uniform: true

    readonly property real _min: root.minCellSize > 0 ? root.minCellSize : root.th.ct("TilePanel", "MinCellSize")
    readonly property real _sp: root.th.ct("TilePanel", "Spacing")
    readonly property int _cols: Math.max(1, Math.floor((root.width + root._sp) / (root._min + root._sp)))
    readonly property int _rows: root.tiles.length === 0 ? 0 : Math.ceil(root.tiles.length / root._cols)
    readonly property real _cellW: root._cols > 0 ? (root.width - (root._cols - 1) * root._sp) / root._cols : root._min
    readonly property real _cellH: root._rows > 0 ? (root.height - (root._rows - 1) * root._sp) / root._rows : root._min
    implicitWidth: 320
    implicitHeight: root._rows > 0 && root.height > 0 ? root.height : root._rows * root._min + (root._rows - 1) * root._sp

    Repeater {
        model: root.tiles.length
        delegate: Item {
            required property int index
            readonly property int col: index % root._cols
            readonly property int row: Math.floor(index / root._cols)
            x: col * (root._cellW + root._sp)
            y: row * (root._cellH + root._sp)
            width: root._cellW
            height: root._cellH
            Loader {
                anchors.fill: parent
                sourceComponent: root.tiles[index] && root.tiles[index].component !== undefined
                                ? root.tiles[index].component : root.tiles[index]
            }
        }
    }
}
