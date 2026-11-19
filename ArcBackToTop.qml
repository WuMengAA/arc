// arc:BackToTop —— Layout/BackToTop 真源码移植（BackToTop.cs + BackToTopToken.cs）。
// 滚过阈值后浮出的「回到顶部」圆钮：HiddenOffset(8) 下移 + HiddenScale(0.86) 缩小作为隐藏位姿；
// 图标尺寸按 size 取 IconSizeSM16/MD18/LG20。真源码是 FAB 形态，这里保留同一套位姿与图标尺寸。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property bool visibleFlag: false     // 宿主给：滚过阈值
    property string size: "md"           // sm | md | lg
    property string icon: "ArrowUp"
    property real thresholdAt: 0         // 预留：宿主判定用
    signal clicked()

    readonly property real _d: root.size === "sm" ? 36 : (root.size === "lg" ? 52 : 44)
    readonly property real _iconSz: root.size === "sm" ? root.th.ct("BackToTop", "IconSizeSM")
                                    : root.size === "lg" ? root.th.ct("BackToTop", "IconSizeLG")
                                    : root.th.ct("BackToTop", "IconSizeMD")
    readonly property real _hideOff: root.th.ct("BackToTop", "HiddenOffset")
    readonly property real _hideScale: root.th.ct("BackToTop", "HiddenScale")
    width: _d; height: _d
    // 隐藏位姿：下移 HiddenOffset + 缩到 HiddenScale + 透明
    y: root.visibleFlag ? 0 : root._hideOff
    scale: root.visibleFlag ? 1 : root._hideScale
    opacity: root.visibleFlag ? 1 : 0
    Behavior on y { NumberAnimation { duration: root.th ? root.th.dur("Standard") : 240
        easing.type: Easing.Bezier; easing.bezierCurve: root.th ? root.th.ease("Standard") : [0.22, 1, 0.36, 1, 1, 1] } }
    Behavior on scale { NumberAnimation { duration: root.th ? root.th.dur("Standard") : 240
        easing.type: Easing.Bezier; easing.bezierCurve: root.th ? root.th.ease("Standard") : [0.22, 1, 0.36, 1, 1, 1] } }
    Behavior on opacity { NumberAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 0
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
    }
    Arc.ArcIcon {
        anchors.centerIn: parent
        width: root._iconSz; height: root._iconSz
        th: root.th
        kind: root.icon
        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
