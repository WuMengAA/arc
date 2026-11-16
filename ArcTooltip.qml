// arc:Tooltip —— Overlays/Tooltip 真源码移植：Foreground 深底 / Background 白字，
// BubbleBorderColor 边（Oklch 14% 混色）、RadiusControl(18)、BubbleMaxWidth 240、内距 16/12。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property string text: ""
    property string placement: "top"   // top | bottom | left | right

    readonly property real _maxW: th.ct("Tooltip", "BubbleMaxWidth")
    readonly property real _px: th.t4(th.ct("Tooltip", "BubblePadding"), 0)
    readonly property real _py: th.t4(th.ct("Tooltip", "BubblePadding"), 1)
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _r: th.t4(th.design("RadiusControl"), 0)

    implicitWidth: Math.min(_maxW, _lbl.implicitWidth + 2 * _px)
    implicitHeight: _lbl.implicitHeight + 2 * _py + 8
    width: implicitWidth; height: implicitHeight

    // 小尖角：45° 旋转方块，颜色与气泡一致
    Rectangle {
        width: 12; height: 12
        rotation: 45
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.placement === "top" ? root.height - 12 : 0
        color: root.th.c("Foreground")
        border.width: root._edge
        border.color: root.th.ct("Tooltip", "BubbleBorderColor")
        visible: root.placement === "top" || root.placement === "bottom"
    }

    Rectangle {
        id: _bubble
        anchors.fill: parent
        anchors.bottomMargin: root.placement === "top" ? 8 : 0
        anchors.topMargin: root.placement === "bottom" ? 8 : 0
        radius: root._r
        color: root.th.c("Foreground")
        border.width: root._edge
        border.color: root.th.ct("Tooltip", "BubbleBorderColor")

        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            id: _lbl
            anchors.centerIn: parent
            width: Math.min(root._maxW - 2 * root._px, implicitWidth)
            text: root.text
            color: root.th.c("Background")
            font.pixelSize: root.th.design("TypeSM")
            font.weight: root.th.design("WeightRegular")
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

