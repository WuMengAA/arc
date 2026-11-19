// arc:RulerSlider —— Sliders/RulerSlider 真源码移植（RulerSlider.cs 587 行 + RulerSliderToken.cs + RulerTape）。
// 刻度尺滑块：ViewportHeight72 的尺带，主刻度 MajorTickHeight28（MajorTickColor），小刻度 SmallTickHeight12
// （TickColor/TickWidth1），半刻度 HalfTickHeight20；指针 NeedleWidth2 / NeedleHeight36；读数在上（ReadoutMargin[0,0,0,12]）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property real value: 50
    property real minimum: 0
    property real maximum: 100
    property real stepSize: 1
    property string unit: ""
    property bool enabledState: true

    readonly property real _viewH: root.th.ct("RulerSlider", "ViewportHeight")
    readonly property real _majorH: root.th.ct("RulerSlider", "MajorTickHeight")
    readonly property real _smallH: root.th.ct("RulerSlider", "SmallTickHeight")
    readonly property real _halfH: root.th.ct("RulerSlider", "HalfTickHeight")
    readonly property real _tickW: root.th.ct("RulerSlider", "TickWidth")
    readonly property real _needleW: root.th.ct("RulerSlider", "NeedleWidth")
    readonly property real _needleH: root.th.ct("RulerSlider", "NeedleHeight")
    readonly property real _labelTop: root.th.ct("RulerSlider", "LabelTop")
    readonly property real _readoutM: root.th.t4(root.th.ct("RulerSlider", "ReadoutMargin"), 3)
    readonly property real _majorColor: root.th ? root.th.ct("RulerSlider", "MajorTickColor") : "#7A0B0B0B"
    readonly property real _tickColor: root.th ? root.th.ct("RulerSlider", "TickColor") : "#330B0B0B"
    readonly property real _span: root.maximum - root.minimum || 1
    readonly property real _frac: Math.max(0, Math.min(1, (root.value - root.minimum) / root._span))
    readonly property int _tickCount: 41
    implicitWidth: 300
    implicitHeight: 20 + root._viewH + root._readoutM
    opacity: root.enabledState ? 1 : root.th.ct("RulerSlider", "DisabledOpacity")

    // 读数
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: {
            var v = root.value;
            var s = (Math.abs(v - Math.round(v)) < 0.001) ? String(Math.round(v)) : v.toFixed(1);
            return s + (root.unit !== "" ? " " + root.unit : "");
        }
        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        font.weight: root.th ? root.th.weightMedium : 500
    }
    // 尺带
    Item {
        id: _tape
        y: 20
        width: parent.width
        height: root._viewH
        clip: true
        Repeater {
            model: root._tickCount
            delegate: Item {
                required property int index
                readonly property bool major: index % 4 === 0
                readonly property bool half: index % 2 === 0 && !major
                x: (root.width - root._tickW) * (index / (root._tickCount - 1))
                width: root._tickW
                height: root._viewH
                Rectangle {
                    anchors.top: parent.top
                    width: root._tickW
                    height: major ? root._majorH : (half ? root._halfH : root._smallH)
                    color: major ? root._majorColor : root._tickColor
                }
                // 每 4 格一个刻度值
                Text {
                    visible: major
                    anchors.top: parent.top
                    anchors.topMargin: root._labelTop
                    x: -implicitWidth / 2 + root._tickW / 2
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: Math.round(root.minimum + (index / (root._tickCount - 1)) * root._span)
                    color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
            }
        }
        // 指针
        Rectangle {
            id: _needle
            x: Math.max(0, Math.min(parent.width - width, parent.width * root._frac - width / 2))
            y: root._viewH - root._needleH
            width: root._needleW
            height: root._needleH
            radius: root._needleW / 2
            color: root.th ? root.th.a("accent") : "#FF2FB8C6"
            Behavior on x { NumberAnimation { duration: root.th ? root.th.dur("Fast") : 160
                easing.type: Easing.Bezier; easing.bezierCurve: root.th ? root.th.ease("Standard") : [0.22, 1, 0.36, 1, 1, 1] } }
        }
        MouseArea {
            anchors.fill: parent
            enabled: root.enabledState
            onPositionChanged: {
                if (!pressed) return;
                var f = Math.max(0, Math.min(1, mouse.x / width));
                var raw = root.minimum + f * root._span;
                var st = Math.max(0.0001, root.stepSize);
                root.value = Math.round((Math.round((raw - root.minimum) / st) * st + root.minimum) * 1000) / 1000;
            }
        }
    }
}
