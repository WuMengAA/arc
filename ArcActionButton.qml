// arc:ActionButton —— Buttons/ActionButton 真值移植。
// enum ActionButtonState Idle/Pending/Success/Failed；PART_Frame/Label/Icon/Status/FocusRing。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string text: "Run action"
    property string icon: "Play"
    property string stateName: "idle"     // idle | pending | success | failed
    signal clicked()

    readonly property real _h: th.design("ControlSizeMD")
    readonly property real _px: th.t4(th.ct("ActionButton", "InlinePadding"), 0)
    readonly property real _gap: th.ct("ActionButton", "LabelIconGap")
    readonly property real _slot: th.ct("ActionButton", "IconSlotExtent")
    readonly property real _op: th.ct("ActionButton", "DisabledOpacity")
    readonly property string _glyph: root.stateName === "pending" ? "LoaderCircle"
                                    : root.stateName === "success" ? "Check"
                                    : root.stateName === "failed" ? "CircleX" : root.icon
    readonly property color _glyphColor: root.stateName === "success" ? th.c("Success")
                                        : root.stateName === "failed" ? th.c("Danger")
                                        : th.c("Foreground")
    implicitWidth: _row.implicitWidth + 2 * _px
    implicitHeight: _h
    width: implicitWidth; height: implicitHeight
    opacity: root.stateName === "pending" ? root._op + (1 - root._op) * 0.4 : 1

    Rectangle {
        anchors.fill: parent
        radius: th.t4(th.design("RadiusControl"), 0)
        color: th.c("Foreground")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Row {
            id: _row
            anchors.centerIn: parent
            spacing: root._gap
            Item {
                width: root._slot; height: root._h
                anchors.verticalCenter: parent.verticalCenter
                Arc.ArcIcon {
                    anchors.centerIn: parent
                    th: root.th; kind: root._glyph
                    spin: root.stateName === "pending"
                    width: 17; height: 17
                    color: th.c("Background")
                }
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                anchors.verticalCenter: parent.verticalCenter
                text: root.stateName === "success" ? "Done" : root.stateName === "failed" ? "Failed" : root.text
                color: th.c("Background")
                font.pixelSize: th.design("TypeSM")
                font.weight: th.design("WeightMedium")
            }
        }
        MouseArea { anchors.fill: parent; onClicked: root.clicked() }
    }
}
