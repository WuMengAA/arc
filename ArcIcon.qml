// lucide 图标（路径数据见 Icons.js，24x24 viewBox），用 SVG data URI 自绘，不依赖 C++ image provider。
import QtQuick 2.15
import "Icons.js" as Icons

Item {
    id: root

    property var th: null               // 统一组件契约（图标本身不需要令牌，占位以保持调用点一致）
    property string kind: "Circle"
    property color color: "#FF000000"
    property real strokeWidth: 1.75
    property bool filled: false
    property bool spin: false           // 加载/刷新类图标自转（ArcSpinner.cs TurnSeconds=0.7）

    RotationAnimation on rotation {
        from: 0; to: 360
        duration: 700
        loops: Animation.Infinite
        running: root.spin
    }

    implicitWidth: 16
    implicitHeight: 16

    readonly property string pathData: Icons.PATHS[kind] !== undefined ? Icons.PATHS[kind] : Icons.PATHS["Circle"]

    Image {
        anchors.fill: parent
        sourceSize.width: Math.max(8, Math.round(root.width * 2))
        sourceSize.height: Math.max(8, Math.round(root.height * 2))
        smooth: true
        fillMode: Image.PreserveAspectFit
        // 颜色随父级自动重算；SVG 里直接烧进颜色，所以用 data URI 拼装
        source: "data:image/svg+xml;utf8," + encodeURIComponent(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="' +
            (root.filled ? "currentColor" : "none") + '" stroke="currentColor" stroke-width="' +
            root.strokeWidth + '" stroke-linecap="round" stroke-linejoin="round" color="' +
            root.color + '"><path d="' + root.pathData + '"/></svg>')
    }
}
