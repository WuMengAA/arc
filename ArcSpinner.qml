// arc:ArcSpinner —— Core/Primitives/ArcSpinner.cs：TurnSeconds=0.7 整圈旋转；
// Reduced/Off 不位移，改用 Core/Motion/ArcBusyPulse.cs 的 1→0.45→1 正弦呼吸。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property real spinnerSize: 24
    property color color: th ? th.c("Foreground") : "#FF1D1D1D"
    property color trackColor: th ? th.c("Border") : "#FFE9E9E9"
    property bool running: true
    property int level: th ? th.motionLevel : 2      // 0 Off / 1 Reduced / 2 Full

    readonly property bool _full: root.level === 2
    readonly property bool _pulse: root.level === 1  // MotionLevel.Reduced
    property real _t: 0
    implicitWidth: root.spinnerSize
    implicitHeight: root.spinnerSize

    // 环走 SVG data URI：Qt 6.12 该环境 Canvas 首帧空绘（历史 Checkbox/Grip 两次事故）。
    readonly property string _svg: "data:image/svg+xml;utf8," + encodeURIComponent(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 40 40" fill="none">' +
        '<circle cx="20" cy="20" r="16" stroke="' + root.trackColor + '" stroke-width="4" opacity="0.32"/>' +
        '<circle cx="20" cy="20" r="16" stroke="' + root.color + '" stroke-width="4" stroke-linecap="round" ' +
        'stroke-dasharray="72 30" transform="rotate(-90 20 20)"/></svg>')

    Image {
        id: _ring
        anchors.fill: parent
        sourceSize.width: Math.max(8, Math.round(root.spinnerSize * 2))
        sourceSize.height: Math.max(8, Math.round(root.spinnerSize * 2))
        smooth: true
        source: root._svg
        RotationAnimation on rotation {
            from: 0
            to: 360
            duration: 700                 // ArcSpinner.cs: TurnSeconds = 0.7
            loops: Animation.Infinite
            running: root.running && root._full
        }
    }

    // Reduced：只呼吸不动（真源码 ArcBusyPulse.Opacity 的闭式正弦，本组件逐帧采样）。
    Timer {
        interval: 50
        repeat: true
        running: root.running && root._pulse && root.th !== null
        onTriggered: {
            root._t += 0.05;
            _ring.opacity = root.th.busyOpacity(root._t);
        }
    }
    onRunningChanged: if (!root.running) { _ring.opacity = 1; }
    onLevelChanged: { _ring.opacity = root._pulse ? 1 : 1; root._t = 0; }
}
