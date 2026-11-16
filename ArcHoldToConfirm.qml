// arc:HoldToConfirm —— Gestures/HoldToConfirm 真值移植。
// 长按 Fill 从左扫到右，到头触发 confirmed()；tone danger 用 DangerBorder + Danger 填充。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string label: "Hold to confirm"
    property string tone: "danger"       // danger | neutral
    property real holdMs: 900
    signal confirmed()

    readonly property real _h: th.design("ControlSizeMD")
    readonly property real _px: th.t4(th.ct("HoldToConfirm", "InlinePadding"), 0)
    readonly property real _rad: th.pad(th.ct("HoldToConfirm", "FocusRingRadius"))
    readonly property color _fill: tone === "danger" ? th.fade(th.c("Danger"), 0.85)
                                  : th.fade(th.c("Accent"), th.ct("HoldToConfirm", "HoverTintOpacity"))
    property real progress: 0
    implicitWidth: 260; implicitHeight: _h
    width: implicitWidth; height: implicitHeight

    Rectangle {
        id: _surface
        anchors.fill: parent; radius: root._rad
        color: th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        clip: true
        Rectangle {
            id: _fill
            x: 0; y: 0; width: root.width * root.progress; height: root.height
            color: root._fill
            Behavior on width { NumberAnimation { duration: 60 } }
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            anchors.centerIn: parent
            text: root.progress >= 1 ? "Confirmed" : root.label
            color: root.progress > 0.55 ? "#FFFFFFFF" : th.c("Foreground")
            font.pixelSize: th.design("TypeSM")
        }
        MouseArea {
            id: _ma; anchors.fill: parent
            onPressed: { _hold.start(); }
            onReleased: { _hold.stop(); if (root.progress < 1) _back.start(); }
            onCanceled: { _hold.stop(); _back.start(); }
        }
    }
    Timer {
        id: _hold; interval: 30; repeat: true
        onTriggered: {
            root.progress = Math.min(1, root.progress + 30 / root.holdMs);
            if (root.progress >= 1) { stop(); root.confirmed(); }
        }
    }
    Timer {
        id: _back; interval: 16; repeat: true
        onTriggered: { root.progress = Math.max(0, root.progress - 0.05); if (root.progress <= 0) stop(); }
    }
}
