// arc:ContextMenu —— Menus/ContextMenu 真值移植（AnchorGap/AnchorInset + 共用菜单面）。
// 右键/长按场景：open 时菜单浮于 anchorX/anchorY，点空白处关闭。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property bool open: true
    property real anchorX: 16
    property real anchorY: 12
    property var items: []
    signal activated(int index)

    readonly property real _gap: th.ct("ContextMenu", "AnchorGap")
    readonly property real _inset: th.ct("ContextMenu", "AnchorInset")
    implicitWidth: 420; implicitHeight: 300
    width: implicitWidth; height: implicitHeight

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        MouseArea { anchors.fill: parent; enabled: root.open; onClicked: root.open = false }
    }
    Arc.ArcMenuPanel {
        id: _panel
        visible: root.open
        x: Math.min(root.anchorX + root._gap, root.width - width - root._inset)
        y: Math.min(root.anchorY + root._gap, root.height - height - root._inset)
        th: root.th
        items: root.items
        rowWidth: Math.max(th.ct("MenuSurface", "ContextMinWidth") - 10, 210)
        onActivated: function (i) { root.activated(i); root.open = false; }
    }
}
