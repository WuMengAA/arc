// arc:ArcPulse —— Core/Motion/ArcBusyPulse.cs + SkeletonBlocks.cs：加载点/骨架条正弦呼吸，
// 每项按 Skeleton.PulseStagger=0.09s 错峰；Off 停在满不透明，Full 也允许（只是不需要）。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property int count: 3
    property real dotSize: 10
    property real gap: 8
    property color color: th ? th.c("Foreground") : "#FF1D1D1D"
    property bool running: true
    property bool bars: false           // true = 骨架条（宽度 3×dotSize）

    property real _t: 0
    readonly property real _w: root.count * (root.bars ? root.dotSize * 3 : root.dotSize)
    implicitWidth: root._w + (root.count - 1) * root.gap
    implicitHeight: root.bars ? root.dotSize : root.dotSize

    Timer {
        interval: 50
        repeat: true
        running: root.running && root.th !== null
        onTriggered: root._t += 0.05
    }

    Row {
        spacing: root.gap
        Repeater {
            model: root.count
            Rectangle {
                width: root.bars ? root.dotSize * 3 : root.dotSize
                height: root.bars ? root.dotSize : root.dotSize
                radius: root.bars ? root.th.t4(root.th.design("RadiusControl"), 0) * 0.4 : root.dotSize / 2
                color: root.color
                // 逐项相位 = SkeletonBlocks.PulseStagger (0.09s)，Opacity 用真源码闭式解
                opacity: root.running && root.th !== null && root.th.motionLevel > 0
                         ? root.th.busyOpacity(root._t + index * 0.09)
                         : 1
            }
        }
    }
}
