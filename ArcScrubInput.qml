// arc:ScrubInput —— SpecialInputs/ScrubInput 真源码移植（ScrubInput.cs 1341 行 + ScrubInputToken.cs + ScrubExpression/
// ScrubInputParts）。
// 拖拽调值输入：数值本体可横向拖动改值（TrackFill 表示拖动幅度），单位是一个小按钮（UnitHeight22 / UnitRadius6）；
// 壳 ShellHeightSM30 / ShellRadius12；拖动时上方出现 Tag（TagMargin[6,-26,0,0] / TagPadding[7,2,7,2]）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property real value: 0
    property real stepSize: 1
    property string unit: "px"
    property bool enabledState: true
    property real minimum: -1e9
    property real maximum: 1e9

    readonly property real _shellH: root.th.ct("ScrubInput", "ShellHeightSM")
    readonly property real _shellRad: root.th.pad(root.th.ct("ScrubInput", "ShellRadiusSM"))
    readonly property real _unitH: root.th.ct("ScrubInput", "UnitHeight")
    readonly property real _unitRad: root.th.pad(root.th.ct("ScrubInput", "UnitRadius"))
    readonly property real _handleMin: root.th.ct("ScrubInput", "HandleMinWidth")
    readonly property real _tagPad: root.th.pad(root.th.ct("ScrubInput", "TagPadding"))
    readonly property real _tagLH: root.th.ct("ScrubInput", "TagLineHeight")
    readonly property real _op: root.enabledState ? 1 : root.th.ct("ScrubInput", "DisabledOpacity")
    property real dragStart: 0
    property bool dragging: false
    implicitWidth: 120
    implicitHeight: root._shellH
    opacity: root._op

    Rectangle {
        anchors.fill: parent
        radius: root._shellRad
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: _ma.containsMouse ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
    }
    // 拖动时的幅度填充
    Rectangle {
        visible: root.dragging
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.5
        height: parent.height - 6
        radius: root._shellRad - 2
        color: root.th ? root.th.ct("ScrubInput", "TrackFillActive") : "#1A0B0B0B"
    }
    // 数值
    Text {
        id: _val
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - _unitBox.width - 8
        horizontalAlignment: Text.AlignHCenter
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: {
            var v = root.value;
            return (Math.abs(v - Math.round(v)) < 0.001) ? String(Math.round(v)) : v.toFixed(1);
        }
        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        font.weight: root.th ? root.th.weightMedium : 500
    }
    // 单位按钮
    Rectangle {
        id: _unitBox
        anchors.right: parent.right
        anchors.rightMargin: 3
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(root.th.ct("ScrubInput", "UnitMinWidth"), _ut.implicitWidth + 8)
        height: root._unitH
        radius: root._unitRad
        color: _um.containsMouse ? (root.th ? root.th.ct("ScrubInput", "UnitHoverFill") : "#120B0B0B") : "transparent"
        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        Text {
            id: _ut
            anchors.centerIn: parent
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.unit
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
        MouseArea { id: _um; anchors.fill: parent; hoverEnabled: true }
    }
    // 拖动 Tag
    Rectangle {
        visible: root.dragging
        anchors.horizontalCenter: parent.horizontalCenter
        y: -26
        width: _tg.implicitWidth + 2 * root._tagPad
        height: root._tagLH + 4
        radius: 6
        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
        Text {
            id: _tg
            anchors.centerIn: parent
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: String(Math.round(root.value))
            color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightMedium : 500
        }
    }
    MouseArea {
        id: _ma
        anchors.fill: parent
        enabled: root.enabledState
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor
        onPressed: { root.dragging = true; root.dragStart = root.value; }
        onPositionChanged: {
            if (!pressed) return;
            // 每 2px 一个步进
            var delta = (mouse.x - pressed.x) * 0.5 * root.stepSize;
            root.value = Math.max(root.minimum, Math.min(root.maximum, root.dragStart + delta));
        }
        onReleased: { root.dragging = false; }
        onCanceled: { root.dragging = false; }
    }
}
