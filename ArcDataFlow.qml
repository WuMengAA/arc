// arc:DataFlow —— Illustrations/DataFlow 真源码移植（DataFlow.cs 356 行 + DataFlowToken.cs）。
// 数据流示意：节点（NodeRadius12）+ 连线上跑的小包（PacketSize7）；FramePadding[20,20,20,14] 是画框内边距。
// 骨架由 nodes / edges 描述，跑包用 Timer 推进（每帧只改包的位置，不重建节点）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var nodes: []             // [{id, label, x, y}]（x/y 为 0..1 相对坐标）
    property var edges: []             // [[fromId, toId], ...]
    property real eventsPerSecond: 1.2
    property real filterRatio: 1
    property var labels: ({})
    property bool running: true

    readonly property real _pad: root.th.pad(root.th.ct("DataFlow", "FramePadding"))
    readonly property real _nodeR: root.th.ct("DataFlow", "NodeRadius")
    readonly property real _packet: root.th.ct("DataFlow", "PacketSize")
    property real clock: 0
    implicitWidth: 380
    implicitHeight: 200

    Timer {
        interval: 33
        repeat: true
        running: root.running
        onTriggered: root.clock += 33
    }
    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
    }
    // 连线
    Repeater {
        model: root.edges.length
        delegate: Canvas {
            required property int index
            anchors.fill: parent
            antialiasing: true
            property var from: root._nodeById(root.edges[index][0])
            property var to: root._nodeById(root.edges[index][1])
            property int tick: Math.floor(root.clock / 33)
            onTickChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                if (!from || !to) return;
                var x1 = root._pad + from.x * (width - 2 * root._pad);
                var y1 = root._pad + from.y * (height - 2 * root._pad);
                var x2 = root._pad + to.x * (width - 2 * root._pad);
                var y2 = root._pad + to.y * (height - 2 * root._pad);
                ctx.beginPath();
                ctx.moveTo(x1, y1);
                ctx.lineTo(x2, y2);
                ctx.lineWidth = 1.4;
                ctx.strokeStyle = root.th ? root.th.fade(root.th.c("Border"), 0.9) : "#33E0E0E0";
                ctx.stroke();
                // 小包：沿线的位置由 eventsPerSecond 推
                var span = Math.max(0.6, 1 / Math.max(0.05, root.eventsPerSecond));
                var t = ((root.clock / 1000) % span) / span;
                var px = x1 + (x2 - x1) * t, py = y1 + (y2 - y1) * t;
                ctx.beginPath();
                ctx.arc(px, py, root._packet / 2, 0, 6.2832);
                ctx.fillStyle = root.th ? root.th.a("accent") : "#FF2FB8C6";
                ctx.fill();
            }
        }
    }
    // 节点
    Repeater {
        model: root.nodes.length
        delegate: Item {
            required property int index
            readonly property var n: root.nodes[index]
            x: root._pad + (n ? n.x : 0) * (root.width - 2 * root._pad) - root._nodeR
            y: root._pad + (n ? n.y : 0) * (root.height - 2 * root._pad) - root._nodeR
            width: 2 * root._nodeR; height: 2 * root._nodeR
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
                border.width: 1.5
                border.color: root.th ? root.th.a("accent") : "#FF2FB8C6"
            }
            Text {
                anchors.centerIn: parent
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: n ? (n.label || "") : ""
                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
        }
    }
    function _nodeById(id) {
        for (var i = 0; i < root.nodes.length; i++) if (root.nodes[i].id === id) return root.nodes[i];
        return null;
    }
}
