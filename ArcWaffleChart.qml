// arc:WaffleChart —— Charts/WaffleChart 真源码移植（WaffleChart.cs + WaffleChartToken.cs + WaffleCategory/WaffleGrid/WaffleLegendItem）。
// 华夫图：把总量切成 GridCells 格（默认 10x10=100），按分类占比逐格上色；CellGap3。
// GridMaxSize300 是网格边长上限；SideLegendBreakpoint420 —— 宽度 ≥ 该值时图例切到右侧，否则在下。
// 图例每项 = 色块 + 名称 + 占比%。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var items: []           // [{label, value, color?}]
    property int columns: 10
    property int rows: 10
    property bool showLegend: true
    property real valueSuffix: 0     // 预留：百分比后缀小数位

    readonly property real _gap: root.th.ct("WaffleChart", "CellGap")
    readonly property real _maxSize: root.th.ct("WaffleChart", "GridMaxSize")
    readonly property real _bp: root.th.ct("WaffleChart", "SideLegendBreakpoint")
    readonly property int _cells: root.columns * root.rows
    readonly property real _cell: {
        var avail = Math.min(root._maxSize, root.width > 0 ? root.width : root._maxSize);
        var w = (avail - (root.columns - 1) * root._gap) / root.columns;
        return Math.max(2, w);
    }
    readonly property real _gridW: root.columns * root._cell + (root.columns - 1) * root._gap
    readonly property real _gridH: root.rows * root._cell + (root.rows - 1) * root._gap
    readonly property bool _sideLegend: root.width >= root._bp
    readonly property real _total: {
        var s = 0;
        for (var i = 0; i < root.items.length; i++) s += Number(root.items[i].value) || 0;
        return s || 1;
    }
    // 每格归属哪个分类（按占比累计）
    readonly property var _ownership: {
        var out = [], acc = 0, idx = 0, cum = [];
        for (var i = 0; i < root.items.length; i++) {
            acc += (Number(root.items[i].value) || 0) / root._total;
            cum.push({ upto: acc, i: i });
        }
        for (var c = 0; c < root._cells; c++) {
            var t = (c + 0.5) / root._cells;
            var pick = -1;
            for (var k = 0; k < cum.length; k++) { if (t <= cum[k].upto) { pick = cum[k].i; break; } }
            if (pick < 0 && cum.length > 0) pick = cum.length - 1;
            out.push(pick);
        }
        return out;
    }

    implicitWidth: root._sideLegend ? root._gridW + 24 + _legend.implicitWidth : root._gridW
    implicitHeight: root._sideLegend ? Math.max(root._gridH, _legend.implicitHeight)
                                     : root._gridH + (root.showLegend ? 12 + _legend.implicitHeight : 0)

    Grid {
        id: _grid
        columns: root.columns
        columnSpacing: root._gap
        rowSpacing: root._gap
        Repeater {
            model: root._cells
            delegate: Rectangle {
                required property int index
                readonly property int owner: root._ownership[index]
                readonly property color fill: (owner >= 0 && root.items[owner])
                        ? (root.items[owner].color || root.th.series(owner)) : "transparent"
                width: root._cell; height: root._cell
                radius: Math.max(1, root._cell * 0.14)
                color: fill
                opacity: owner >= 0 ? 1 : 0
            }
        }
    }
    Column {
        id: _legend
        anchors.left: root._sideLegend ? _grid.right : _grid.left
        anchors.leftMargin: root._sideLegend ? 24 : 0
        anchors.top: root._sideLegend ? _grid.top : _grid.bottom
        anchors.topMargin: root._sideLegend ? 0 : 12
        spacing: 8
        Repeater {
            model: root.showLegend ? root.items.length : 0
            delegate: Row {
                required property int index
                spacing: 8
                Rectangle {
                    width: 10; height: 10; radius: 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.items[index].color || root.th.series(index)
                }
                Text {
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    anchors.verticalCenter: parent.verticalCenter
                    text: (root.items[index].label || "") + "  " + Math.round(100 * (Number(root.items[index].value) || 0) / root._total) + "%"
                    color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
            }
        }
    }
}
