// arc:RadialMenu —— Menus/RadialMenu 真值移植（InnerRadius/OuterRadius/SectorGap）。
// 扇区用 SVG data URI 画（避 Canvas 首帧空绘）；中心 PART_CenterLabel + 环绕图标。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var items: []          // [{label, icon}]
    property string centerLabel: "Arc"
    property bool open: true
    signal activated(int index)

    readonly property real _ri: th.ct("RadialMenu", "InnerRadius")
    readonly property real _ro: th.ct("RadialMenu", "OuterRadius")
    readonly property real _gapDeg: th.ct("RadialMenu", "SectorGap")
    readonly property real _icon: th.ct("RadialMenuItem", "IconSize")
    readonly property real _pad: th.pad(th.ct("RadialMenuItem", "ContentPadding"))
    readonly property color _fill: th.ct("RadialMenuItem", "SectorFill")
    readonly property real _size: 2 * (_ro + 12)
    implicitWidth: _size; implicitHeight: _size
    width: implicitWidth; height: implicitHeight
    opacity: root.open ? 1 : 0
    scale: root.open ? 1 : 0.78
    Behavior on opacity { NumberAnimation { duration: th.dur("Fast") } }
    Behavior on scale { NumberAnimation { duration: th.dur("Fast") } }

    function _hex(c) {
        var s = String(c);
        if (s.charAt(0) !== "#") return "#808080";
        return s.length === 9 ? "#" + s.substring(3) : s;
    }
    function _alpha(c) {
        var s = String(c);
        if (s.charAt(0) !== "#" || s.length !== 9) return 1;
        return parseInt(s.substring(1, 3), 16) / 255;
    }
    function _svg() {
        var n = Math.max(root.items.length, 1);
        var cx = root._ro + 12, cy = root._ro + 12;
        var a, a0, a1, x0, y0, x1, y1, x2, y2, x3, y3, p = "";
        var g = root._gapDeg * Math.PI / 180;
        for (var i = 0; i < n; i++) {
            a0 = -Math.PI / 2 + i * 2 * Math.PI / n + g / 2;
            a1 = -Math.PI / 2 + (i + 1) * 2 * Math.PI / n - g / 2;
            x0 = cx + root._ro * Math.cos(a0); y0 = cy + root._ro * Math.sin(a0);
            x1 = cx + root._ro * Math.cos(a1); y1 = cy + root._ro * Math.sin(a1);
            x2 = cx + root._ri * Math.cos(a1); y2 = cy + root._ri * Math.sin(a1);
            x3 = cx + root._ri * Math.cos(a0); y3 = cy + root._ri * Math.sin(a0);
            p += '<path d="M' + x0.toFixed(2) + ' ' + y0.toFixed(2) +
                 ' A' + root._ro + ' ' + root._ro + ' 0 0 1 ' + x1.toFixed(2) + ' ' + y1.toFixed(2) +
                 ' L' + x2.toFixed(2) + ' ' + y2.toFixed(2) +
                 ' A' + root._ri + ' ' + root._ri + ' 0 0 0 ' + x3.toFixed(2) + ' ' + y3.toFixed(2) +
                 ' Z" fill="' + root._hex(root._fill) + '" fill-opacity="' + root._alpha(root._fill).toFixed(3)
                 + '" stroke="' + root._hex(th.c("Border")) + '" stroke-width="1"/>';
        }
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + root._size + ' ' + root._size + '">' + p + '</svg>';
    }
    Image {
        anchors.fill: parent
        source: "data:image/svg+xml;utf8," + encodeURIComponent(root._svg())
        sourceSize.width: root._size * 2; sourceSize.height: root._size * 2
    }
    Repeater {
        model: root.items
        delegate: Item {
            required property int index
            required property var modelData
            x: root.width / 2 + (root._ri + root._ro) / 2 * Math.cos(-Math.PI / 2 + (index + 0.5) * 2 * Math.PI / root.items.length) - root._icon / 2
            y: root.height / 2 + (root._ri + root._ro) / 2 * Math.sin(-Math.PI / 2 + (index + 0.5) * 2 * Math.PI / root.items.length) - root._icon / 2
            width: root._icon; height: root._icon
            Arc.ArcIcon {
                anchors.centerIn: parent
                th: root.th; kind: modelData.icon || "Circle"
                width: root._icon; height: root._icon
                color: th.c("Foreground")
            }
            MouseArea { anchors.fill: parent; onClicked: root.activated(index) }
        }
    }
    Rectangle {
        anchors.centerIn: parent
        width: root._ri * 1.55; height: root._ri * 1.55
        radius: width / 2
        color: th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            anchors.centerIn: parent
            text: root.centerLabel
            color: th.c("Foreground")
            font.pixelSize: th.design("TypeXS")
            font.weight: th.design("WeightMedium")
        }
    }
}
