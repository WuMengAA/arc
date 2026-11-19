// arc:TreeSelectRow —— Selects/TreeSelect/TreeSelectRow.cs 真源码移植。
// 树行：RowHeight36 / IndentWidth18 / RowRadius12；折角 12；复选框 CheckboxSize16 / CheckboxRadius4.5 / CheckStrokeThickness1.75。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var node: null
    property string path: ""
    property int depth: 0
    property bool hasChildren: false
    property bool expanded: false
    property bool checked: false
    signal toggleOpen()
    signal toggleCheck()

    readonly property real _rowH: root.th.ct("TreeSelect", "RowHeight")
    readonly property real _indent: root.th.ct("TreeSelect", "IndentWidth")
    readonly property real _rowRad: root.th.ct("TreeSelect", "RowRadius")
    readonly property real _chk: root.th.ct("TreeSelect", "CheckboxSize")
    readonly property real _chkRad: root.th.ct("TreeSelect", "CheckboxRadius")
    readonly property real _chkStroke: root.th.ct("TreeSelect", "CheckStrokeThickness")
    width: parent ? parent.width : 280
    height: root._rowH

    Rectangle {
        anchors.fill: parent
        radius: root._rowRad
        color: _ma.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
    }
    Arc.ArcIcon {
        visible: root.hasChildren
        x: 4 + root.depth * root._indent
        anchors.verticalCenter: parent.verticalCenter
        width: 12; height: 12
        th: root.th; kind: "ChevronRight"
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        rotation: root.expanded ? 90 : 0
        MouseArea {
            anchors.fill: parent
            onClicked: root.toggleOpen()
        }
    }
    Rectangle {
        x: 20 + root.depth * root._indent
        anchors.verticalCenter: parent.verticalCenter
        width: root._chk; height: root._chk
        radius: root._chkRad
        color: root.checked ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : "transparent"
        border.width: root._chkStroke
        border.color: root.checked ? (root.th ? root.th.a("accent") : "#FF2FB8C6")
                                   : (root.th ? root.th.c("BorderStrong") : "#FFC0C0C0")
        Arc.ArcIcon {
            anchors.centerIn: parent
            visible: root.checked
            width: 10; height: 10
            th: root.th; kind: "Check"
            color: root.th ? root.th.a("foreground") : "#FFFFFFFF"
        }
        MouseArea { anchors.fill: parent; onClicked: root.toggleCheck() }
    }
    Text {
        x: 20 + root.depth * root._indent + root._chk + 8
        width: parent.width - x - 8
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.node ? (root.node.label || "") : ""
        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
    }
    MouseArea {
        id: _ma
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.hasChildren ? root.toggleOpen() : root.toggleCheck()
    }
}
