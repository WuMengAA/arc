// arc:Checkbox —— Toggles/Checkbox/CheckboxTheme.axaml + CheckboxMark.cs 真值移植。
// 44 命中区 / 18 方块 / 三点折线勾（半选 morph 成横杠），几何全走 th.ct("Checkbox",...)。
import QtQuick 2.15

Item {
    id: root

    property var th: null
    property string text: ""
    property string description: ""
    property int checkState: 0            // CheckboxState: 0=Unchecked 1=Checked 2=Indeterminate
    property bool isInvalid: false
    signal toggled(int checkState)

    readonly property bool _on: checkState !== 0
    readonly property real _box: th.ct("Checkbox", "BoxSize")
    readonly property real _hit: th.design("ControlSizeMD")
    readonly property real _rad: th.pad(th.ct("Checkbox", "BoxRadius"))
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property color _markColor: th.c("ControlGlyph")
    readonly property color _bd: !enabled ? th.c("Border")
        : (_on ? th.c("ControlOn")
        : (isInvalid ? th.c("Danger")
        : (_ma.containsMouse ? th.c("TextMuted") : th.c("BorderStrong"))))

    width: implicitWidth
    height: implicitHeight
    implicitWidth: _hit + th.t4(th.ct("Checkbox", "CopyMargin"), 0) + _copy.implicitWidth
    implicitHeight: Math.max(_hit, th.t4(th.ct("Checkbox", "CopyMargin"), 1) + _copy.implicitHeight)
    opacity: enabled ? 1 : th.ct("Checkbox", "DisabledOpacity")

    // PART_Visual：:pressed 时 scale(0.95)（Theme.axaml 的 RenderTransform）
    Item {
        id: _visual
        width: root._hit; height: root._hit
        scale: _ma.pressed ? 0.95 : 1
        Behavior on scale { NumberAnimation { duration: th.dur("Instant") } }

        // PART_Square：Background=Surface，选中时填充 ControlOn
        Rectangle {
            anchors.centerIn: parent
            width: root._box; height: root._box
            radius: root._rad
            color: root._on ? th.c("ControlOn") : th.c("Surface")
            border.width: root._edge
            border.color: root._bd
            Behavior on border.color { ColorAnimation { duration: th.dur("Instant") } }
        }

        // PART_Mark：check (4.25,9.25)->(7.25,12.25)->(13.75,5.75) / dash (4.75,9)->(9,9)->(13.25,9)
        // 与 ArcIcon.qml 同用 SVG data URI（真机已验证渲染路径），避开 Qt Canvas 首帧时序问题。
        Image {
            id: _mark
            anchors.centerIn: parent
            width: root._box; height: root._box
            visible: root._on
            sourceSize.width: 36; sourceSize.height: 36
            readonly property string _path: root.checkState === 2
                ? "M4.75 9 L9 9 L13.25 9"
                : "M4.25 9.25 L7.25 12.25 L13.75 5.75"
            source: "data:image/svg+xml;utf8," + encodeURIComponent(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 18 18" fill="none" stroke="' +
                root._markColor + '" stroke-width="' + root.th.ct("Checkbox", "MarkStrokeThickness") +
                '" stroke-linecap="round" stroke-linejoin="round"><path d="' + _path + '"/></svg>')
        }
    }

    // PART_Copy：CopyMargin [1,12.2,0,0] / CopySpacing 2 / 两段行高
    Column {
        id: _copy
        x: root._hit + th.t4(th.ct("Checkbox", "CopyMargin"), 0)
        y: th.t4(th.ct("Checkbox", "CopyMargin"), 1)
        spacing: th.ct("Checkbox", "CopySpacing")
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.text !== ""
            text: root.text
            color: root.th.c("Foreground")
            font.pixelSize: root.th.design("TypeSM")
            font.weight: root.th.design("WeightMedium")
            lineHeight: root.th.ct("Checkbox", "LabelLineHeight")
            lineHeightMode: Text.FixedHeight
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.description !== ""
            text: root.description
            color: root.th.c("TextSecondary")
            font.pixelSize: root.th.design("TypeSM")
            lineHeight: root.th.ct("Checkbox", "DescriptionLineHeight")
            lineHeightMode: Text.FixedHeight
        }
    }

    MouseArea {
        id: _ma
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var s = root.checkState === 0 ? 1 : 0;
            root.checkState = s;
            root.toggled(s);
        }
    }
}
