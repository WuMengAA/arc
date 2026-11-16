// arc:CopyButton —— Buttons/CopyButton 真值移植。
// enum CopyState Idle/Copied/Error；:copied 图标打勾，IconLabelGap / DisabledOpacity。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string label: "Copy"
    property string copyState: "idle"   // idle | copied | error
    property bool iconOnly: false
    signal copyRequested()

    readonly property real _h: th.design("ControlSizeSM")
    readonly property real _px: th.t4(th.ct("CopyButton", "InlinePadding"), 0)
    readonly property real _gap: th.ct("CopyButton", "IconLabelGap")
    readonly property real _op: th.ct("CopyButton", "DisabledOpacity")
    readonly property color _fg: root.copyState === "error" ? th.c("Danger") : th.c("Foreground")
    implicitWidth: iconOnly ? _h : _row.implicitWidth + 2 * _px
    implicitHeight: _h
    width: implicitWidth; height: implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: th.t4(th.ct("CopyButton", "FocusRingRadius"), 0)
        color: _ma.containsMouse ? th.c("SurfaceMuted") : th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Row {
            id: _row
            anchors.centerIn: parent; spacing: root._gap
            Arc.ArcIcon {
                anchors.verticalCenter: parent.verticalCenter
                th: root.th
                kind: root.copyState === "copied" ? "Check" : root.copyState === "error" ? "CircleX" : "Copy"
                width: 16; height: 16; color: root._fg
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                visible: !root.iconOnly
                anchors.verticalCenter: parent.verticalCenter
                text: root.copyState === "copied" ? "Copied" : root.copyState === "error" ? "Failed" : root.label
                color: root._fg; font.pixelSize: th.design("TypeSM")
            }
        }
        MouseArea {
            id: _ma; anchors.fill: parent; hoverEnabled: true
            enabled: root.copyState !== "copied"
            onClicked: { root.copyRequested(); root.copyState = "copied"; }
        }
    }
}
