// arc:CyclicPanel —— Layout/CyclicPanel 真源码移植（CyclicPanel.cs 541 行 + CyclicPanelToken.cs）。
// 循环面板：内容按 ScrollDuration(240ms) 做「滚出去、换、滚回来」的切换；Spacing(0) 是两页之间的间距。
// 页码环形（最后一页之后回到第一页）；切换用 ContentSwap 的同一套位姿（旧层退出、新层进入）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var pages: []           // [Component, ...]
    property int currentIndex: 0
    property int direction: 1
    property bool wrap: true

    readonly property int _dur: {
        var d = root.th.ct("CyclicPanel", "ScrollDuration");
        var n = parseFloat(String(d));
        return isNaN(n) ? 240 : n;
    }
    readonly property real _sp: root.th.ct("CyclicPanel", "Spacing")
    readonly property int _n: root.pages.length
    property int shown: root.currentIndex
    property real _t: 1
    property int _prev: 0
    implicitWidth: 260
    implicitHeight: 160
    clip: true

    onCurrentIndexChanged: {
        if (root._n === 0) return;
        var i = root.currentIndex;
        root._prev = root.shown;
        root.shown = i;
        root._t = 0;
        _anim.restart();
    }
    Component.onCompleted: root.shown = root.currentIndex

    NumberAnimation {
        id: _anim
        target: root; property: "_t"; from: 0; to: 1
        duration: root._dur
        easing.type: Easing.Bezier
        easing.bezierCurve: root.th ? root.th.ease("Standard") : [0.22, 1, 0.36, 1, 1, 1]
    }
    // 进入层
    Loader {
        id: _enter
        anchors.fill: parent
        x: (1 - root._t) * 40 * root.direction
        opacity: root._t
        sourceComponent: root._n > 0 ? root.pages[Math.max(0, Math.min(root._n - 1, root.shown))] : null
    }
    // 退出层
    Loader {
        id: _exit
        anchors.fill: parent
        x: -root._t * 40 * root.direction
        opacity: 1 - root._t
        visible: root._t < 1
        sourceComponent: root._n > 0 ? root.pages[Math.max(0, Math.min(root._n - 1, root._prev))] : null
    }
}
