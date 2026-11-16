// arc:IconMorph —— Buttons/IconMorph 真值移植。
// 两个 ArcIcon 按 progress 交叉淡入（GlyphExtent / GlyphStrokeWidth），避 Canvas 首帧空绘。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string kindFrom: "Menu"
    property string kindTo: "X"
    property real progress: 0        // 0..1
    property color tint: "#FF000000"
    property real extent: 24
    signal toggled()

    readonly property real _e: th.ct("IconMorph", "GlyphExtent")
    implicitWidth: root.extent > 0 ? root.extent : root._e
    implicitHeight: implicitWidth
    width: implicitWidth; height: implicitHeight

    Arc.ArcIcon {
        anchors.centerIn: parent
        th: root.th; kind: root.kindFrom
        width: root.width; height: root.height
        strokeWidth: th.ct("IconMorph", "GlyphStrokeWidth")
        color: root.tint
        opacity: 1 - root.progress
        rotation: -90 * root.progress
    }
    Arc.ArcIcon {
        anchors.centerIn: parent
        th: root.th; kind: root.kindTo
        width: root.width; height: root.height
        strokeWidth: th.ct("IconMorph", "GlyphStrokeWidth")
        color: root.tint
        opacity: root.progress
        rotation: 90 * (1 - root.progress)
    }
    Behavior on progress { NumberAnimation { duration: th.dur("Fast") } }
    MouseArea { anchors.fill: parent; onClicked: root.toggled() }
}
