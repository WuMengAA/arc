// arc:ResizablePanels —— Expand 域真值：ResizablePanels.DividerThickness=1、ResizablePanel.DefaultMinWidth=80；
// 主题 HandleLineBrush=Border / HandleLineHotBrush=BorderStrong / GripActiveBrush=Foreground / RestoreFill=Surface。
// 可拖拽分隔条改左右窗格宽度，双击复位；尺寸全部走令牌，不写魔法宽度。
import QtQuick 2.15

Rectangle {
    id: root
    property var th: null
    property real split: 0.42
    property string leftTitle: "Explorer"
    property string rightTitle: "Editor"
    readonly property real _div: Math.max(1, th.ct("ResizablePanels", "DividerThickness"))
    readonly property real _min: th.ct("ResizablePanel", "DefaultMinWidth")
    width: 620; height: 240
    color: th.c("Surface"); border.width: 1; border.color: th.c("Border")
    radius: th.t4(th.design("RadiusPanel"), 0)
    clip: true
    Item {
        x: 0; y: 0; width: root.split * (parent.width - root._div); height: parent.height
        Rectangle { anchors.fill: parent; color: root.th.c("SurfaceMuted") }
        Column { x: 16; y: 16; spacing: 8; Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.leftTitle; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") } Repeater { model: 5; delegate: Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "· item " + (index + 1); color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS") } } }
    }
    Item {
        x: root.split * (parent.width - root._div) + root._div
        width: parent.width - x; height: parent.height
        Rectangle { anchors.fill: parent; color: root.th.c("Surface") }
        Column { x: 16; y: 16; spacing: 8; Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.rightTitle; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") } Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "// Drag the divider, double-click to restore."; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "// ResizablePanels.DividerThickness = 1"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } }
    }
    Rectangle {
        id: _handle
        x: root.split * (root.width - root._div); width: root._div + 8; height: root.height
        color: "transparent"
        Rectangle { anchors.centerIn: parent; width: root._div; height: root.height; color: _ma.containsMouse || _ma.pressed ? root.th.c("BorderStrong") : root.th.c("Border") }
        Rectangle { anchors.centerIn: parent; width: 4; height: 32; radius: 2; color: _ma.pressed ? root.th.c("Foreground") : root.th.c("BorderStrong") }
        MouseArea {
            id: _ma; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.SizeHorizontalCursor
            preventStealing: true   // 拖面板分隔条不滚页面
            onPositionChanged: function (m) { if (pressed) root.split = Math.max(root._min / root.width, Math.min(1 - root._min / root.width, m.x / root.width)); }
            onPressed: function (m) { root.split = Math.max(root._min / root.width, Math.min(1 - root._min / root.width, m.x / root.width)); }
            onDoubleClicked: root.split = 0.42
        }
    }
}
