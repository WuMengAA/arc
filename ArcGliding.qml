// arc:ArcGliding —— Core/Primitives/GlidingIndicator.cs：MoveTo(Rect) 的滑动选中块。
// 真源码 Spring=Snappy；本组件用其真 settle 时长 + ArcEasings.Enter 贝塞尔（QML 参数空间不同，不混用物理刚度）。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property var rects: []              // [{x,y,w,h}]
    property int activeIndex: 0
    property string springName: "Snappy"
    property color color: th ? th.c("Surface") : "#FFFFFFFF"
    property color borderColor: th ? th.c("Border") : "#FFE9E9E9"
    property bool showIndicator: true

    readonly property var r: root.rects.length > 0
        ? root.rects[Math.max(0, Math.min(root.rects.length - 1, root.activeIndex))]
        : null
    readonly property int _dur: root.th !== null ? root.th.springSettle(root.springName) : 466
    readonly property var _ease: root.th !== null ? root.th.ease("Enter") : [0.16,1,0.3,1,1,1]
    implicitWidth: 200
    implicitHeight: 40

    Rectangle {
        id: _pill
        visible: root.showIndicator && root.r !== null
        x: root.r ? root.r.x : 0
        y: root.r ? root.r.y : 0
        width: root.r ? root.r.w : 0
        height: root.r ? root.r.h : 0
        radius: root.th !== null ? root.th.t4(root.th.design("RadiusControl"), 0) : 18
        color: root.color
        border.width: 1
        border.color: root.borderColor
        opacity: root.r ? 1 : 0
        Behavior on x { NumberAnimation { duration: root._dur; easing.type: Easing.Bezier; easing.bezierCurve: root._ease } }
        Behavior on width { NumberAnimation { duration: root._dur; easing.type: Easing.Bezier; easing.bezierCurve: root._ease } }
        Behavior on opacity { NumberAnimation { duration: root.th !== null ? root.th.dur("Instant") : 120 } }
    }
}
