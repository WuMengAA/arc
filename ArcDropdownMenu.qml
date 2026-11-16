// arc:DropdownMenu —— Menus/DropdownMenu 真值移植。
// PART_Trigger(PART_TriggerIcon/PART_Label/PART_Chevron) + :open 旋转 180 + MenuGap 浮出。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property bool open: false
    property string label: "Options"
    property string triggerIcon: "SlidersHorizontal"
    property var items: []
    signal activated(int index)

    readonly property real _h: th.design("ControlSizeMD")
    readonly property real _gap: th.ct("DropdownMenu", "MenuGap")
    readonly property real _trigGap: th.ct("DropdownMenu", "TriggerGap")
    readonly property real _icon: th.ct("DropdownMenu", "TriggerIconSize")
    readonly property real _chev: th.ct("DropdownMenu", "ChevronSize")
    readonly property real _stroke: th.ct("DropdownMenu", "ChevronStroke")
    readonly property real _rad: th.t4(th.design("RadiusControl"), 0)
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property color _pressed: th.ct("DropdownMenu", "TriggerPressedBackground")
    implicitWidth: 230
    implicitHeight: _panel && root.open ? _h + _gap + _panel.height : _h
    width: implicitWidth; height: implicitHeight

    Rectangle {
        id: _trigger
        width: root.width; height: root._h
        radius: root._rad
        color: root.open ? th.c("SurfaceMuted") : (_ma.pressed ? root._pressed : th.c("Surface"))
        border.width: root._edge
        border.color: root.open ? th.c("BorderStrong") : th.c("Border")
        Behavior on color { ColorAnimation { duration: th.dur("Instant") } }
        Row {
            anchors.left: parent.left; anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: root._trigGap
            Arc.ArcIcon {
                anchors.verticalCenter: parent.verticalCenter
                th: root.th; kind: root.triggerIcon
                width: root._icon; height: root._icon
                color: th.c("TextSecondary")
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                anchors.verticalCenter: parent.verticalCenter
                text: root.label
                color: th.c("Foreground")
                font.pixelSize: th.design("TypeSM")
            }
        }
        Arc.ArcIcon {
            anchors.right: parent.right; anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            th: root.th; kind: "ChevronDown"
            width: root._chev; height: root._chev
            strokeWidth: root._stroke
            color: th.c("TextSecondary")
            rotation: root.open ? 180 : 0
            Behavior on rotation { NumberAnimation { duration: th.dur("Fast") } }
        }
        MouseArea {
            id: _ma; anchors.fill: parent; hoverEnabled: true
            onClicked: root.open = !root.open
        }
    }
    Arc.ArcMenuPanel {
        id: _panel
        visible: root.open
        y: root._h + root._gap
        th: root.th; items: root.items; rowWidth: root.width - 12
        onActivated: function (i) { root.activated(i); root.open = false; }
    }
}
