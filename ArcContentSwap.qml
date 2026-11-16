// arc:ArcContentSwap —— Core/Primitives/ArcContentSwap.cs：ContentSwapMode (Fade/Slide/Scale/Flip)、
// Direction(±1)、EnterOffset。两层叠放：旧层退出、新层进入，_t:0→1 驱动 Mo.contentSwapOffset 的位姿。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property var pages: []              // Component 数组
    property int currentIndex: 0
    property int mode: 1                // 0 Fade / 1 Slide / 2 Scale / 4 Flip
    property int direction: 1
    property real enterOffset: 24
    property bool autoPlay: false
    property int autoInterval: 3000
    signal swapped(int index)

    property int _shown: 0
    property int _prev: 0
    property real _t: 1
    readonly property var _off: root.th !== null ? root.th.contentSwapOffset(root.mode, root.direction, root.enterOffset) : { x: 24, y: 0, scale: 1 }
    implicitWidth: 260
    implicitHeight: 96
    clip: true

    Component.onCompleted: { root._shown = root.currentIndex; _enter.sourceComponent = root.pages[root._shown] || null; }

    function swapTo(i) {
        if (root.pages.length === 0 || i === root._shown) return;
        root._prev = root._shown;
        root._shown = Math.max(0, Math.min(root.pages.length - 1, i));
        _exit.sourceComponent = root.pages[root._prev] || null;
        _enter.sourceComponent = root.pages[root._shown] || null;
        root._t = 0;
        _anim.restart();
    }

    NumberAnimation {
        id: _anim
        target: root
        property: "_t"
        from: 0; to: 1
        duration: root.th !== null ? root.th.dur("Standard") : 240
        easing.type: Easing.Bezier
        easing.bezierCurve: root.th !== null ? root.th.ease("Standard") : [0.22,1,0.36,1,1,1]
        onStopped: root.swapped(root._shown)
    }

    Timer {
        interval: root.autoInterval
        repeat: true
        running: root.autoPlay && root.pages.length > 1
        onTriggered: root.swapTo((root._shown + 1) % root.pages.length)
    }

    // 退出层：opacity 1→0，位移 0→-off.x，scale 1→off.scale
    Loader {
        id: _exit
        width: root.width; height: root.height
        opacity: 1 - root._t
        x: -root._off.x * root._t
        scale: 1 - (1 - root._off.scale) * root._t
        transformOrigin: Item.Center
        visible: root._t < 0.999
    }
    // 进入层：opacity 0→1，位移 off.x→0，scale off.scale→1
    Loader {
        id: _enter
        width: root.width; height: root.height
        opacity: root._t
        x: root._off.x * (1 - root._t)
        scale: root._off.scale + (1 - root._off.scale) * root._t
        transformOrigin: Item.Center
    }
}
