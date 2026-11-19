// arc:ReorderableList —— Tables/ReorderableList 真源码移植（ReorderableList.cs + ReorderableListToken.cs +
// ReorderableListItem/ReorderableListDrag）。
// 可拖动排序的列表：行最小高 RowMinHeight56，行内边距 RowInset[7,7,16,7]，行距 RowGap8；
// 左侧拖动柄 HandleExtent40（手柄字形 HandleGlyphExtent16，圆角 HandleRadius11）。
// 拖动用按下位移判定；松手后按目标下标重排并触发 moved(from,to)。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var items: []            // [string | {label}]
    property string label: ""
    property bool movesItems: true
    signal moved(int from, int to)

    readonly property real _rowMin: root.th.ct("ReorderableList", "RowMinHeight")
    readonly property real _rowGap: root.th.ct("ReorderableList", "RowGap")
    readonly property real _handle: root.th.ct("ReorderableList", "HandleExtent")
    readonly property real _glyph: root.th.ct("ReorderableList", "HandleGlyphExtent")
    readonly property real _handleRad: root.th.pad(root.th.ct("ReorderableList", "HandleRadius"))
    property int dragIndex: -1
    property real dragOffset: 0
    property int hoverIndex: -1
    readonly property real _slotH: root._rowMin + root._rowGap

    implicitWidth: 360
    implicitHeight: Math.max(root._rowMin, root.items.length * root._slotH - root._rowGap)

    function _labelOf(i) {
        var it = root.items[i];
        if (it === undefined || it === null) return "";
        return typeof it === "string" ? it : (it.label || "");
    }
    Column {
        spacing: root._rowGap
        Repeater {
            model: root.items.length
            delegate: Item {
                required property int index
                readonly property bool isDragging: root.dragIndex === index
                width: root.width
                height: root._rowMin
                y: isDragging ? root.dragOffset : 0
                z: isDragging ? 10 : 1
                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
                    border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
                    border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
                    opacity: 1
                }
                // PART_Handle：拖动柄
                Rectangle {
                    id: _handleBox
                    x: root.th.t4(root.th.ct("ReorderableList", "RowInset"), 0) + 4
                    anchors.verticalCenter: parent.verticalCenter
                    width: root._handle
                    height: root._handle
                    radius: root._handleRad
                    color: _hm.containsMouse || isDragging ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                    Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                    Column {
                        anchors.centerIn: parent
                        spacing: 3
                        Repeater {
                            model: 3
                            delegate: Rectangle {
                                required property int index
                                width: root._glyph; height: 1.5; radius: 1
                                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                            }
                        }
                    }
                    MouseArea {
                        id: _hm
                        anchors.fill: parent
                        hoverEnabled: true
                        onPressed: { root.dragIndex = index; root.dragOffset = 0; }
                        onPositionChanged: {
                            if (root.dragIndex !== index) return;
                            root.dragOffset = mouse.y - _handleBox.height / 2;
                        }
                        onReleased: {
                            if (root.dragIndex !== index) { root.dragIndex = -1; return; }
                            var to = Math.max(0, Math.min(root.items.length - 1,
                                       index + Math.round(root.dragOffset / root._slotH)));
                            if (to !== index && root.movesItems) root.moved(index, to);
                            root.dragIndex = -1;
                            root.dragOffset = 0;
                        }
                        onCanceled: { root.dragIndex = -1; root.dragOffset = 0; }
                    }
                }
                Text {
                    x: root.th.t4(root.th.ct("ReorderableList", "RowInset"), 0) + root._handle + 10
                    width: parent.width - x - root.th.t4(root.th.ct("ReorderableList", "RowInset"), 2)
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root._labelOf(index)
                    color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                    font.pixelSize: root.th ? root.th.design("TypeSM") : 13
                }
            }
        }
    }
}
