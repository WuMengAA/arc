// arc:ConfirmMorph —— Buttons/ConfirmMorph 真值移植。
// 三态脸 IdleFace/ConfirmFace/CountFace 横移切换；ConfirmRestColor/TriggerHoverColor 等 22 键。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string label: "Delete project"
    property string face: "idle"      // idle | confirm | counting
    signal confirmed()
    signal cancelled()

    readonly property real _h: th.design("ControlSizeMD")
    readonly property real _px: th.t4(th.ct("ConfirmMorph", "TriggerInset"), 0)
    readonly property real _gap: th.ct("ConfirmMorph", "FaceGap")
    readonly property real _inner: th.ct("ConfirmMorph", "InnerButtonExtent")
    readonly property color _trigger: th.ct("ConfirmMorph", "TriggerHoverColor")
    readonly property color _confirm: th.ct("ConfirmMorph", "ConfirmRestColor")
    readonly property color _answer: th.ct("ConfirmMorph", "AnswerHoverColor")
    implicitWidth: 300; implicitHeight: _h
    width: implicitWidth; height: implicitHeight

    Rectangle {
        id: _pill
        anchors.fill: parent
        radius: parent.height / 2
        color: th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        clip: true
        Item {
            id: _idle
            width: parent.width; height: parent.height
            x: root.face === "idle" ? 0 : -parent.width
            opacity: root.face === "idle" ? 1 : 0
            Behavior on x { NumberAnimation { duration: th.dur("Fast") } }
            Row {
                anchors.centerIn: parent; spacing: 8
                Arc.ArcIcon { anchors.verticalCenter: parent.verticalCenter; th: root.th; kind: "Trash2"; width: 16; height: 16; color: th.c("Danger") }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.verticalCenter: parent.verticalCenter; text: root.label; color: th.c("Foreground"); font.pixelSize: th.design("TypeSM") }
            }
            MouseArea { anchors.fill: parent; onClicked: root.face = "confirm" }
        }
        Item {
            id: _confirmFace
            width: parent.width; height: parent.height
            x: root.face === "confirm" ? 0 : parent.width
            opacity: root.face === "confirm" ? 1 : 0
            Behavior on x { NumberAnimation { duration: th.dur("Fast") } }
            Rectangle {
                anchors.fill: parent; color: root._confirm
                Row {
                    anchors.centerIn: parent; spacing: root._gap
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Are you sure?"; color: th.c("Danger"); font.pixelSize: th.design("TypeSM") }
                    Rectangle {
                        width: 62; height: root._inner; radius: root._inner / 2
                        color: th.c("Danger")
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: "Confirm"; color: "#FFFFFFFF"; font.pixelSize: th.design("TypeXS") }
                        MouseArea { anchors.fill: parent; onClicked: { root.confirmed(); root.face = "counting"; } }
                    }
                    Rectangle {
                        width: 56; height: root._inner; radius: root._inner / 2
                        color: root._answer
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: "Cancel"; color: th.c("Foreground"); font.pixelSize: th.design("TypeXS") }
                        MouseArea { anchors.fill: parent; onClicked: { root.cancelled(); root.face = "idle"; } }
                    }
                }
            }
        }
        Rectangle {
            id: _countFace
            width: parent.width; height: parent.height
            x: root.face === "counting" ? 0 : parent.width
            color: th.c("Success")
            opacity: root.face === "counting" ? 1 : 0
            Behavior on x { NumberAnimation { duration: th.dur("Fast") } }
            Row {
                anchors.centerIn: parent; spacing: 8
                Arc.ArcIcon { anchors.verticalCenter: parent.verticalCenter; th: root.th; kind: "Check"; width: 16; height: 16; color: "#FFFFFFFF" }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Deleted"; color: "#FFFFFFFF"; font.pixelSize: th.design("TypeSM") }
            }
            MouseArea { anchors.fill: parent; onClicked: root.face = "idle" }
        }
    }
}
