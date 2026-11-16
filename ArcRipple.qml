// arc:ArcRipple —— 操作反馈：指针按下点扩散的波纹（MD3 state layer 的动效化）。
// 时长走 ArcMotion.Considered(480) / 缓动走 ArcEasings.Standard，不写死数字。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property color waveColor: th ? th.fade(th.c("Foreground"), 0.18) : "#22000000"
    property real maxRadius: 96
    property bool demo: false
    property bool clipWave: true
    property real previewRadius: 0      // >0 画一个静态波纹圈，供单帧截图展示
    signal triggered(real x, real y)
    clip: root.clipWave
    implicitWidth: 200
    implicitHeight: 80

    readonly property int _dur: root.th !== null ? root.th.dur("Considered") : 480
    readonly property var _ease: root.th !== null ? root.th.ease("Standard") : [0.22,1,0.36,1,1,1]

    Component {
        id: _wave
        Rectangle {
            id: _rect
            property real cx: 0
            property real cy: 0
            x: cx - width / 2
            y: cy - height / 2
            width: 8; height: 8
            radius: width / 2
            color: root.waveColor
            opacity: 0.55
            ParallelAnimation {
                id: _grow
                running: true
                NumberAnimation { target: _rect; property: "width"; to: root.maxRadius * 2; duration: root._dur; easing.type: Easing.Bezier; easing.bezierCurve: root._ease }
                NumberAnimation { target: _rect; property: "height"; to: root.maxRadius * 2; duration: root._dur; easing.type: Easing.Bezier; easing.bezierCurve: root._ease }
                NumberAnimation { target: _rect; property: "opacity"; to: 0; duration: root._dur; easing.type: Easing.Bezier; easing.bezierCurve: root._ease }
                onStopped: _rect.destroy()
            }
        }
    }

    function spawn(x, y) {
        if (root.th !== null && root.th.motionLevel === 0) { root.triggered(x, y); return; }
        _wave.createObject(root, { cx: x, cy: y });
        root.triggered(x, y);
    }

    // 静态预览圈：截图是单帧，真实波纹动画未必恰好在画面里
    Rectangle {
        visible: root.previewRadius > 0
        x: root.width * 0.35 - root.previewRadius
        y: root.height * 0.5 - root.previewRadius
        width: root.previewRadius * 2; height: root.previewRadius * 2
        radius: root.previewRadius
        color: root.th !== null ? root.th.fade(root.th.c("Accent"), 0.10) : "#1A3B5DC9"
        border.width: 2
        border.color: root.th !== null ? root.th.fade(root.th.c("Accent"), 0.55) : "#8C3B5DC9"
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.5; height: parent.height * 0.5
            radius: width / 2
            color: "transparent"
            border.width: 1
            border.color: root.th !== null ? root.th.fade(root.th.c("Accent"), 0.35) : "#593B5DC9"
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: root.th !== null ? root.th.c("Border") : "#FFE9E9E9"
        radius: root.th !== null ? root.th.t4(root.th.design("RadiusControl"), 0) : 18
    }

    MouseArea { anchors.fill: parent; onClicked: root.spawn(mouseX, mouseY) }
    Timer { interval: 1600; repeat: true; running: root.demo; onTriggered: root.spawn(root.width * 0.35, root.height * 0.5) }
}
