// arc:ElasticSlider —— Sliders/ElasticSlider 真源码移植（ElasticSlider.cs 892 行 + ElasticSliderToken.cs +
// ElasticSliderRail/ElasticSliderSway）。
// 弹性滑块：轨道 TrackThickness8 / RailMinHeight24，滑块 ThumbDiameter24（拖动时有弹性摆动）；
// 刻度 MarkHeight20 / TickDiameter4；两端标签 StartMargin[0,0,12,0] / EndMargin[12,0,0,0]；
// 读数标签 TagMinHeight28 / TagInset[12,0,12,0] / TagGap10。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property real value: 0
    property real minimum: 0
    property real maximum: 100
    property real stepSize: 1
    property string startLabel: ""
    property string endLabel: ""
    property string unit: ""
    property bool showValue: true
    property bool enabledState: true

    readonly property real _trackH: root.th.ct("ElasticSlider", "TrackThickness")
    readonly property real _thumbD: root.th.ct("ElasticSlider", "ThumbDiameter")
    readonly property real _tickD: root.th.ct("ElasticSlider", "TickDiameter")
    readonly property real _marksH: root.th.ct("ElasticSlider", "MarksHeight")
    readonly property real _tagH: root.th.ct("ElasticSlider", "TagMinHeight")
    readonly property real _tagPadL: root.th.t4(root.th.ct("ElasticSlider", "TagInset"), 0)
    readonly property real _tagGap: root.th.ct("ElasticSlider", "TagGap")
    readonly property real _startM: root.th.t4(root.th.ct("ElasticSlider", "StartMargin"), 2)
    readonly property real _endM: root.th.t4(root.th.ct("ElasticSlider", "EndMargin"), 0)
    readonly property real _frac: root.maximum > root.minimum
            ? Math.max(0, Math.min(1, (root.value - root.minimum) / (root.maximum - root.minimum))) : 0
    readonly property real _op: root.enabledState ? 1 : root.th.ct("ElasticSlider", "DisabledOpacity")
    implicitWidth: 260
    implicitHeight: root._marksH + root._tagH + 2 * root.th.ct("ElasticSlider", "RowGap") + 22

    opacity: root._op
    // 标签行
    Row {
        y: 0
        width: parent.width
        spacing: 0
        Text {
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.startLabel
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            rightPadding: root._startM
        }
        Item { width: parent.width - 80; height: 1 }
        Text {
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.endLabel
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            leftPadding: root._endM
        }
    }
    // 读数签（跟随 thumb）
    Rectangle {
        visible: root.showValue
        x: Math.max(0, Math.min(parent.width - width,
                root._startM + (parent.width - root._startM - root._endM) * root._frac - width / 2))
        y: 18
        width: _tv.implicitWidth + 2 * root._tagPadL
        height: root._tagH
        radius: height / 2
        color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
        border.width: 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        Text {
            id: _tv
            anchors.centerIn: parent
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: {
                var v = root.value;
                var s = (Math.abs(v - Math.round(v)) < 0.001) ? String(Math.round(v)) : v.toFixed(1);
                return s + (root.unit !== "" ? " " + root.unit : "");
            }
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightMedium : 500
        }
    }
    // 轨 + thumb
    Item {
        id: _railBox
        x: root._startM
        y: 18 + root._tagH + root.th.ct("ElasticSlider", "RowGap") + 4
        width: parent.width - root._startM - root._endM
        height: root._thumbD
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: root._trackH
            radius: root._trackH / 2
            color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
        }
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * root._frac
            height: root._trackH
            radius: root._trackH / 2
            color: root.th ? root.th.a("accent") : "#FF2FB8C6"
        }
        // thumb（拖动时轻微弹性放大）
        Rectangle {
            id: _thumb
            x: Math.max(0, Math.min(parent.width - width, parent.width * root._frac - width / 2))
            anchors.verticalCenter: parent.verticalCenter
            width: root._thumbD; height: root._thumbD
            radius: width / 2
            color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
            border.width: 2
            border.color: root.th ? root.th.a("accent") : "#FF2FB8C6"
            scale: _ma2.pressed ? 1.15 : 1
            Behavior on scale { NumberAnimation { duration: root.th ? root.th.dur("Fast") : 160
                easing.type: Easing.Bezier; easing.bezierCurve: root.th ? root.th.ease("Enter") : [0.16, 1, 0.3, 1, 1, 1] } }
        }
        MouseArea {
            id: _ma2
            anchors.fill: parent
            enabled: root.enabledState
            onPositionChanged: {
                if (!pressed) return;
                var f = Math.max(0, Math.min(1, mouse.x / width));
                var raw = root.minimum + f * (root.maximum - root.minimum);
                var st = Math.max(0.0001, root.stepSize);
                root.value = Math.round((Math.round((raw - root.minimum) / st) * st + root.minimum) * 1000) / 1000;
            }
        }
    }
    // 刻度点（MarksHeight 区域）
    Row {
        visible: root._marksH > 0
        y: 18 + root._tagH + root.th.ct("ElasticSlider", "RowGap") + 4 + root._thumbD + 4
        x: root._startM
        width: parent.width - root._startM - root._endM
        Repeater {
            model: 11
            delegate: Rectangle {
                required property int index
                width: (root.width - root._startM - root._endM) / 10
                height: root._marksH
                color: "transparent"
                Rectangle {
                    anchors.centerIn: parent
                    width: root._tickD; height: root._tickD
                    radius: width / 2
                    color: root.th ? root.th.ct("ElasticSlider", "TickColor") : "#520B0B0B"
                }
            }
        }
    }
}
