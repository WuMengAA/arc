// arc:ScrollArea + BackToTop —— Navigation 域真值：ScrollArea TrackThickness=11 / FocusRingMargin[0..]；
// BackToTop HiddenOffset=8 / HiddenScale=0.86 / IconSizeSM 16 / MD 18 / LG 20 / Threshold 200 / Inset 16。
// 滚动超过 200 才浮出「回到顶部」圆钮，点击平滑回顶；滚动条宽度走 TrackThickness。
import QtQuick 2.15

Rectangle {
    id: root
    property var th: null
    property var rows: []
    property bool previewShown: false
    readonly property real _track: th.ct("ScrollArea", "TrackThickness")
    readonly property real _threshold: 200
    readonly property real _inset: 16
    width: 420; height: 320
    color: th.c("Surface"); border.width: 1; border.color: th.c("Border")
    radius: th.t4(th.design("RadiusPanel"), 0)
    clip: true
    Flickable {
        id: _flick
        anchors.fill: parent
        contentWidth: width; contentHeight: _col.implicitHeight + 40
        clip: true; boundsBehavior: Flickable.StopAtBounds
        Column {
            id: _col
            x: 20; y: 20; width: parent.width - 40 - root._track - 8; spacing: 10
            Repeater {
                model: root.rows
                delegate: Rectangle {
                    required property var modelData; required property int index
                    width: _col.width; height: 44
                    color: index % 2 ? root.th.c("SurfaceMuted") : root.th.c("Surface")
                    border.width: 1; border.color: root.th.c("BorderSubtle")
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.verticalCenter: parent.verticalCenter; x: 12; text: modelData; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
                }
            }
        }
        Rectangle {
            visible: _flick.contentHeight > _flick.height
            anchors.right: parent.right; anchors.rightMargin: 2
            width: root._track; height: Math.max(30, _flick.height * _flick.height / _flick.contentHeight)
            color: root.th.c("BorderStrong"); radius: root._track / 2; opacity: 0.7
            y: 4 + (_flick.height - height) * Math.max(0, Math.min(1, _flick.contentY / Math.max(1, _flick.contentHeight - _flick.height)))
        }
    }
    Rectangle {
        id: _top
        visible: root.previewShown || _flick.contentY > root._threshold
        anchors.right: parent.right; anchors.bottom: parent.bottom
        anchors.rightMargin: root._inset; anchors.bottomMargin: root._inset
        width: root.th.design("ControlSizeMD"); height: root.th.design("ControlSizeMD")
        radius: root.th.t4(root.th.design("RadiusPill"), 0)
        color: root.th.c("SurfaceRaised"); border.width: 1; border.color: root.th.c("Border")
        scale: visible ? 1 : root.th.ct("BackToTop", "HiddenScale")
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: root.th.dur("Fast") } }
        Behavior on scale { NumberAnimation { duration: root.th.dur("Fast"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
        ArcIcon { anchors.centerIn: parent; th: root.th; kind: "ArrowUp"; width: root.th.ct("BackToTop", "IconSizeMD"); height: root.th.ct("BackToTop", "IconSizeMD"); color: root.th.c("Foreground") }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: _flick.contentY = 0 }
    }
}
