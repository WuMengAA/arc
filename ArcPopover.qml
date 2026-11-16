// arc:Popover —— Overlays/Popover + PopoverSurface 真值移植。
// PART_Frame/ContentPresenter/TriggerPresenter；placement top|bottom，SideOffset 偏移。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property bool open: true
    property string placement: "bottom"
    property string triggerText: "Open popover"
    default property alias content: _content.data

    readonly property real _minW: th.ct("PopoverSurface", "PanelMinWidth")
    readonly property real _maxW: th.ct("PopoverSurface", "PanelMaxWidth")
    readonly property real _pad: th.pad(th.ct("PopoverSurface", "PanelPadding"))
    readonly property real _off: th.ct("Popover", "SideOffset")
    readonly property real _gap: 8
    implicitWidth: 320; implicitHeight: 210
    width: implicitWidth; height: implicitHeight

    Rectangle {
        id: _trigger
        width: 150; height: th.design("ControlSizeSM")
        radius: th.t4(th.design("RadiusControl"), 0)
        color: _ma.containsMouse ? th.c("SurfaceMuted") : th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: root.triggerText; color: th.c("Foreground"); font.pixelSize: th.design("TypeSM") }
        MouseArea { id: _ma; anchors.fill: parent; hoverEnabled: true; onClicked: root.open = !root.open }
    }
    Rectangle {
        id: _frame
        visible: root.open
        x: root._off
        y: root.placement === "top" ? -(_content.implicitHeight + 2 * root._pad) - root._gap : _trigger.height + root._gap
        width: Math.min(root._maxW, Math.max(root._minW, root.width - root._off))
        height: _content.implicitHeight + 2 * root._pad
        radius: th.t4(th.design("RadiusPanel"), 0)
        color: th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Column { id: _content; x: root._pad; y: root._pad; width: parent.width - 2 * root._pad }
    }
}
