// arc:Switch —— SwitchTheme：轨道 42x24、拇指 18、按下拉长到 26、内缩 3、圆角全圆。
import QtQuick 2.15

Item {
    id: root

    property var th: null
    property bool checked: false
    signal toggled(bool value)
    Accessible.role: Accessible.CheckBox
    Accessible.name: qsTr("Switch")
    Accessible.checked: root.checked
    Accessible.onPressAction: { root.checked = !root.checked; root.toggled(root.checked); }

    readonly property real _tw: th.n("switchT","TrackWidth")
    readonly property real _th2: th.n("switchT","TrackHeight")
    readonly property real _thumb: th.n("switchT","ThumbSize")
    readonly property real _inset: th.pad(th.n("switchT","TrackInset"))

    implicitWidth: _tw
    implicitHeight: _th2

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? root.th.a("accent") : root.th.c("ControlTrack")
        Behavior on color { ColorAnimation { duration: th.dur("Fast") } }
    }

    Rectangle {
        width: ma.pressed ? root.th.n("switchT","ThumbStretchedWidth") : root._thumb
        height: root._thumb
        radius: height / 2
        y: (root.height - height) / 2
        x: root.checked ? (root.width - width - root._inset) : root._inset
        color: root.checked ? root.th.a("thumbOn") : root.th.c("ControlThumb")
        Behavior on x { NumberAnimation { duration: th.dur("Fast"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }
        Behavior on width { NumberAnimation { duration: th.dur("Instant") } }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { root.checked = !root.checked; root.toggled(root.checked); }
    }
}
