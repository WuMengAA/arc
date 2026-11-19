// arc:RangeHistogramSlider —— Sliders/RangeHistogramSlider 真源码移植（RangeHistogramSlider.cs 928 行 +
// RangeHistogramSliderToken.cs + RangeHistogramRail）。
// 带直方图的区间滑块：上方是分布柱（ChartHeight76 / BarGap2 / BarColor），下方是 TrackThickness4 轨 + 两个
// ThumbDiameter22 手柄；GuideOverhang2 是引导线外扩；ReadoutGap4.2 是两端读数与轨的距离。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property real low: 20
    property real high: 80
    property real minimum: 0
    property real maximum: 100
    property var histogram: []        // [number] 分布
    property string lowLabel: ""
    property string highLabel: ""

    readonly property real _chartH: root.th.ct("RangeHistogramSlider", "ChartHeight")
    readonly property real _barGap: root.th.ct("RangeHistogramSlider", "BarGap")
    readonly property real _trackH: root.th.ct("RangeHistogramSlider", "TrackThickness")
    readonly property real _thumbD: root.th.ct("RangeHistogramSlider", "ThumbDiameter")
    readonly property real _readoutGap: root.th.ct("RangeHistogramSlider", "ReadoutGap")
    readonly property real _rowGap: root.th.ct("RangeHistogramSlider", "RowGap")
    readonly property real _barColor: root.th ? root.th.ct("RangeHistogramSlider", "BarColor") : "#1C0B0B0B"
    readonly property real _guideColor: root.th ? root.th.ct("RangeHistogramSlider", "GuideColor") : "#660B0B0B"
    readonly property real _span: root.maximum - root.minimum || 1
    readonly property real _lowF: Math.max(0, Math.min(1, (root.low - root.minimum) / root._span))
    readonly property real _highF: Math.max(0, Math.min(1, (root.high - root.minimum) / root._span))
    readonly property real _maxHist: {
        var m = 0;
        for (var i = 0; i < root.histogram.length; i++) m = Math.max(m, Number(root.histogram[i]) || 0);
        return m || 1;
    }
    implicitWidth: 300
    implicitHeight: root._chartH + root._rowGap + root._thumbD + root._readoutGap + 16

    // 直方图
    Row {
        id: _bars
        width: parent.width
        height: root._chartH
        spacing: root._barGap
        Repeater {
            model: root.histogram.length
            delegate: Item {
                required property int index
                readonly property real frac: (Number(root.histogram[index]) || 0) / root._maxHist
                width: (root.width - (root.histogram.length - 1) * root._barGap) / Math.max(1, root.histogram.length)
                height: root._chartH
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Math.max(2, parent.height * frac)
                    radius: 2
                    color: root._barColor
                }
            }
        }
    }
    // 轨
    Item {
        id: _rail
        y: root._chartH + root._rowGap
        width: parent.width
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
            x: parent.width * root._lowF
            width: Math.max(0, parent.width * (root._highF - root._lowF))
            height: root._trackH
            radius: root._trackH / 2
            color: root.th ? root.th.a("accent") : "#FF2FB8C6"
        }
        // 低手柄
        Rectangle {
            x: Math.max(0, Math.min(parent.width - width, parent.width * root._lowF - width / 2))
            anchors.verticalCenter: parent.verticalCenter
            width: root._thumbD; height: root._thumbD
            radius: width / 2
            color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
            border.width: 2
            border.color: root.th ? root.th.a("accent") : "#FF2FB8C6"
        }
        // 高手柄
        Rectangle {
            x: Math.max(0, Math.min(parent.width - width, parent.width * root._highF - width / 2))
            anchors.verticalCenter: parent.verticalCenter
            width: root._thumbD; height: root._thumbD
            radius: width / 2
            color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
            border.width: 2
            border.color: root.th ? root.th.a("accent") : "#FF2FB8C6"
        }
        MouseArea {
            anchors.fill: parent
            onPositionChanged: {
                if (!pressed) return;
                var f = Math.max(0, Math.min(1, mouse.x / width));
                var v = root.minimum + f * root._span;
                // 就近取最近的手柄
                if (Math.abs(f - root._lowF) < Math.abs(f - root._highF)) root.low = Math.min(v, root.high);
                else root.high = Math.max(v, root.low);
            }
        }
    }
    // 两端读数
    Text {
        y: root._chartH + root._rowGap + root._thumbD + root._readoutGap
        x: 0
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.lowLabel !== "" ? root.lowLabel : String(Math.round(root.low))
        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
    }
    Text {
        y: root._chartH + root._rowGap + root._thumbD + root._readoutGap
        anchors.right: parent.right
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.highLabel !== "" ? root.highLabel : String(Math.round(root.high))
        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
    }
}
