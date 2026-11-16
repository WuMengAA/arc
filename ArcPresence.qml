// arc:ArcPresence —— Core/Primitives/PresenceHost.cs：IsPresent / PresenceMode / EnterScale / Offset。
// Apply(p) 用真源码 Lerp：Fade=仅透明度，Scale=缩放，Slide=位移，Pop=缩放+位移。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property bool present: true
    property int mode: 0                // 0 Fade / 1 Scale / 2 Slide / 3 Pop
    property real enterScale: 0.92
    property real offset: 12
    property string springName: "Snappy"
    default property alias content: _host.data
    signal exited()

    property real reveal: root.present ? 1 : 0
    readonly property var pose: root.th !== null ? root.th.presencePose(root.mode, root.reveal, root.enterScale, root.offset) : null
    implicitWidth: _host.childrenRect.width
    implicitHeight: _host.childrenRect.height
    visible: root.reveal > 0.001

    Behavior on reveal {
        NumberAnimation {
            duration: root.th !== null ? root.th.springSettle(root.springName) : 466
            easing.type: Easing.Bezier
            easing.bezierCurve: root.th !== null ? root.th.ease(root.present ? "Enter" : "Standard") : [0.16,1,0.3,1,1,1]
        }
    }
    onRevealChanged: if (!root.present && root.reveal <= 0.001) root.exited()

    Item {
        id: _host
        width: root.width; height: root.height
        opacity: root.pose ? root.pose.opacity : 1
        scale: root.pose ? root.pose.scale : 1
        x: root.pose ? root.pose.x : 0
        y: root.pose ? root.pose.y : 0
        transformOrigin: Item.TopLeft
    }
}
