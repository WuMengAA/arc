// arc:PaymentFlow —— Illustrations/PaymentFlow 真源码移植（PaymentFlow.cs + PaymentFlowToken.cs）。
// 支付流程示意：下单 → 授权 → 扣款 → 回调，节点逐段推进。
// 骨架由 nodes / edges（或 steps）描述，位置为 0..1 相对坐标；跑包/光斑由 Timer 推进，只改位置不重建节点。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var nodes: []
    property var edges: []
    property var labels: ({})
    property bool running: true

    readonly property real _pad: root.th.pad(root.th.ct("PaymentFlow", "FramePadding"))
    readonly property real _nodeR: root.th.ct("PaymentFlow", "NodeRadius")
    readonly property real _packet: root.th.ct("PaymentFlow", "PacketSize")
    property real clock: 0
    implicitWidth: 380
    implicitHeight: 220

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
    Repeater {
        model: root.edges.length
        delegate: Canvas {
            required property int index
            anchors.fill: parent
            antialiasing: true
            property var from: root._byId(root.edges[index][0])
            property var to: root._byId(root.edges[index][1])
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
                var span = 0.9;
                var t = ((root.clock / 1000) % span) / span;
                var px = x1 + (x2 - x1) * t, py = y1 + (y2 - y1) * t;
                ctx.beginPath();
                ctx.arc(px, py, root._packet / 2, 0, 6.2832);
                ctx.fillStyle = root.th ? root.th.a("accent") : "#FF2FB8C6";
                ctx.fill();
            }
        }
    }
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
                border.color: n && n.tone === "danger" ? (root.th ? root.th.c("Danger") : "#FFCD1526")
                             : n && n.tone === "warning" ? (root.th ? root.th.c("Warning") : "#FFB08000")
                             : (root.th ? root.th.a("accent") : "#FF2FB8C6")
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
    function _byId(id) {
        for (var i = 0; i < root.nodes.length; i++) if (root.nodes[i].id === id) return root.nodes[i];
        return null;
    }
}
