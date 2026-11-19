// arc:SplitBar —— Charts/SplitBar 真源码移植（SplitBar.cs + SplitBarToken.cs + 7 个 PART）。
// 单条占比条：Title + Description 在头（HeadRowGap8 / HeadColumnGap16），下面是 BarHeight44 的条，
// 每段 SegmentGap2 分开、CapWidth3 圆头；HighlightedIndex 的那段抬起（HighlightLift）+ 变亮（HighlightFillMix0.62）。
// Total/Remainder 决定是否补一段余量；图例 LegendItemPadding[8,6,10,6] / LegendLineGap2 / LegendShareMinWidth33.8。
// 读数 ReadoutFontSize17 / ReadoutSwatchSize8 / ReadoutLineHeight20.4。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string title: ""
    property string description: ""
    property string unit: ""
    property string totalLabel: "Total"
    property real total: -1
    property string remainderLabel: "Remaining"
    property int valueDecimals: 0
    property string valuePrefix: ""
    property string valueSuffix: ""
    property bool isLegendVisible: true
    property bool isSumVisible: true
    property bool showsPercent: true
    property int highlightedIndex: -1
    property var segments: []         // [{label,value,color?}]

    readonly property real _barH: root.th.ct("SplitBar", "BarHeight")
    readonly property real _segGap: root.th.ct("SplitBar", "SegmentGap")
    readonly property real _capW: root.th.ct("SplitBar", "CapWidth")
    readonly property real _headRowGap: root.th.ct("SplitBar", "HeadRowGap")
    readonly property real _sectionGap: root.th.ct("SplitBar", "SectionGap")
    readonly property real _titleSize: root.th.ct("SplitBar", "TitleFontSize")
    readonly property real _titleGap: root.th.ct("SplitBar", "TitleGap")
    readonly property real _bodySize: root.th.ct("SplitBar", "BodyFontSize")
    readonly property real _legendLineGap: root.th.ct("SplitBar", "LegendLineGap")
    readonly property real _legendItemGap: root.th.ct("SplitBar", "LegendItemGap")
    readonly property real _readoutSize: root.th.ct("SplitBar", "ReadoutFontSize")
    readonly property real _swatch: root.th.ct("SplitBar", "ReadoutSwatchSize")
    readonly property real _dimOp: root.th.ct("SplitBar", "DimOpacity")
    readonly property real _lift: root.th.ct("SplitBar", "HighlightLift")
    readonly property real _grow: root.th.ct("SplitBar", "HighlightGrow")
    readonly property real _sum: {
        var s = 0;
        for (var i = 0; i < root.segments.length; i++) s += Math.max(0, Number(root.segments[i].value) || 0);
        return s;
    }
    readonly property real _denom: root.total > 0 ? root.total : Math.max(root._sum, 0.0001)
    readonly property real _remainder: Math.max(0, root._denom - root._sum)
    function _segW(index) {
        var frac = Math.max(0, Number(root.segments[index].value) || 0) / root._denom;
        return Math.max(2, _track._avail * frac);
    }
    function _segX(index) {
        var acc = 0;
        for (var j = 0; j < index; j++) acc += root._segW(j) + root._segGap;
        return acc;
    }
    function _fmt(v) {
        var d = Math.max(0, root.valueDecimals);
        var s = (Math.round(v * Math.pow(10, d)) / Math.pow(10, d)).toFixed(d);
        return root.valuePrefix + s + (root.unit !== "" ? " " + root.unit : root.valueSuffix);
    }
    implicitWidth: 420
    implicitHeight: _col.implicitHeight

    Column {
        id: _col
        width: parent.width
        spacing: root._sectionGap
        // PART_Head：标题 + 描述
        Column {
            width: parent.width
            spacing: root._titleGap
            Text {
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root.title
                visible: root.title !== ""
                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                font.pixelSize: root._titleSize
                font.weight: root.th ? root.th.weightMedium : 500
                lineHeight: root.th.ct("SplitBar", "TitleLineHeight")
                lineHeightMode: Text.FixedHeight
            }
            Text {
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root.description
                visible: root.description !== ""
                width: parent.width
                wrapMode: Text.WordWrap
                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                font.pixelSize: root._bodySize
                lineHeight: root.th.ct("SplitBar", "BodyLineHeight")
                lineHeightMode: Text.FixedHeight
            }
        }
        // PART_Track：分段条（手工定位，避免 Row 子项宽度回指父宽的 polish 循环）
        Item {
            id: _track
            width: parent.width
            height: root._barH
            // 段宽按根宽算（不是 parent.width，否则 Row/子项互相回指）
            readonly property real _avail: Math.max(0,
                root.width - (root.segments.length + (root._remainder > 0.0001 ? 1 : 0) - 1) * root._segGap)
            readonly property real _barH2: root._barH - root._lift
            Repeater {
                model: root.segments.length
                delegate: Rectangle {
                    required property int index
                    readonly property real frac: Math.max(0, Number(root.segments[index].value) || 0) / root._denom
                    readonly property bool hi: root.highlightedIndex === index
                    readonly property bool dim: root.highlightedIndex >= 0 && !hi
                    // 段高亮时按 HighlightGrow 加宽；x 由 root._segX 累加（不回指父宽，无 polish 循环）
                    x: root._segX(index)
                    y: hi ? root._lift * 0.4 : root._lift
                    width: root._segW(index) + (hi ? _track._barH2 * root._grow : 0)
                    height: hi ? _track._barH : _track._barH2
                    radius: Math.min(root._capW, height / 2)
                    color: {
                        var c = root.segments[index].color || (root.th ? root.th.series(index) : "#FF2FB8C6");
                        if (hi && root.th) return root.th.fade(c, 0.92);
                        return root.th ? root.th.fade(c, dim ? 0.42 : 0.72) : c;
                    }
                    Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                }
            }
            // 余量段
            Rectangle {
                visible: root._remainder > 0.0001
                readonly property real frac: root._remainder / root._denom
                x: root._segX(root.segments.length)
                y: root._lift
                width: Math.max(2, _track._avail * frac)
                height: _track._barH - root._lift
                radius: Math.min(root._capW, height / 2)
                color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
            }
        }
        // PART_Sum：总计读数
        Row {
            visible: root.isSumVisible
            spacing: 6
            Rectangle {
                width: root._swatch; height: root._swatch; radius: 2
                anchors.verticalCenter: parent.verticalCenter
                color: root.th ? root.th.a("accent") : "#FF2FB8C6"
            }
            Text {
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root.totalLabel + "  " + root._fmt(root._denom)
                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                font.pixelSize: root._readoutSize
                font.weight: root.th ? root.th.weightMedium : 500
                lineHeight: root.th.ct("SplitBar", "ReadoutLineHeight")
                lineHeightMode: Text.FixedHeight
            }
        }
        // PART_Legend：每项 = 色块 + 名称 + 占比
        Flow {
            visible: root.isLegendVisible
            width: parent.width
            spacing: root._legendItemGap
            Repeater {
                model: root.isLegendVisible ? root.segments.length : 0
                delegate: Item {
                    required property int index
                    readonly property real share: 100 * (Math.max(0, Number(root.segments[index].value) || 0)) / root._denom
                    width: _lr.implicitWidth + 18
                    height: 24
                    Row {
                        id: _lr
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        Rectangle {
                            width: 8; height: 8; radius: 2
                            anchors.verticalCenter: parent.verticalCenter
                            color: root.segments[index].color || (root.th ? root.th.series(index) : "#FF2FB8C6")
                        }
                        Text {
                            renderType: Text.NativeRendering
                            font.family: root.th ? root.th.fontFamily : "Segoe UI"
                            text: (root.segments[index].label || "")
                                   + "  " + (root.showsPercent ? (Math.round(share * 10) / 10 + "%") : root._fmt(Number(root.segments[index].value) || 0))
                            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                            font.pixelSize: root._bodySize
                            lineHeight: root._legendLineGap + root._bodySize
                            lineHeightMode: Text.FixedHeight
                        }
                    }
                }
            }
        }
    }
}
