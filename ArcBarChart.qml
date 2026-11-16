// Charts/BarChart —— GutterWidth 52 / AxisRowHeight 26 / MaxBarWidth 28 /
// SectionGap 20 / UnitMargin[0,0,0,6]；PART_Kind/Value/When + PART_Plot。
// 柱用 Rectangle 排布（不用 Canvas，规避 Qt 6.12 该环境首帧空绘）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var values: []        // [number, ...]
    property var labels: []        // [string, ...]
    property string kind: "Revenue"
    property string unit: "$"
    property real plotHeight: 160
    property real yMax: 0

    implicitWidth: 420
    implicitHeight: _col.implicitHeight

    readonly property real _gutter: th.ct("BarChart", "GutterWidth")
    readonly property real _axisH: th.ct("BarChart", "AxisRowHeight")
    readonly property real _barW: th.ct("BarChart", "MaxBarWidth")
    readonly property real _gap: th.ct("BarChart", "SectionGap")
    readonly property real _peak: {
        var m = 0;
        for (var i = 0; i < values.length; i++) m = Math.max(m, Number(values[i]) || 0);
        return yMax > 0 ? yMax : (m || 1);
    }
    readonly property real _avg: {
        var s = 0;
        for (var j = 0; j < values.length; j++) s += Number(values[j]) || 0;
        return values.length ? s / values.length : 0;
    }

    function _fmt(v) { return v >= 1000 ? unit + (v / 1000).toFixed(1) + "k" : unit + Math.round(v); }

    Column {
        id: _col
        width: root.width
        spacing: root._gap
        Row {
            spacing: 6
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                text: root.kind
                color: root.th.c("TextSecondary")
                font.pixelSize: root.th.design("TypeSM")
                lineHeight: root.th.ct("BarChart", "HeadlineLineHeight")
                lineHeightMode: Text.FixedHeight
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                text: root._fmt(root._avg)
                color: root.th.c("Foreground")
                font.pixelSize: root.th.design("TypeLG")
                font.weight: root.th.weightSemibold
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                text: root.unit
                color: root.th.c("TextMuted")
                font.pixelSize: root.th.design("TypeSM")
                anchors.baseline: parent.children[1].baseline
            }
        }
        Item {
            width: root.width
            height: root.plotHeight
            readonly property real _plotW: width - root._gutter
            readonly property real _step: values.length > 0 ? _plotW / values.length : _plotW
            Column {
                anchors.right: parent.right
                width: root._gutter
                spacing: (root.plotHeight - 4 * 12) / 4
                Repeater {
                    model: 5
                    delegate: Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        required property int index
                        text: root._fmt(root._peak * (4 - index) / 4)
                        color: root.th.c("TextMuted")
                        font.pixelSize: root.th.design("TypeXS")
                        height: 12
                    }
                }
            }
            Repeater {
                model: 4
                delegate: Rectangle {
                    required property int index
                    x: 0; y: (root.plotHeight / 4) * index
                    width: parent._plotW; height: 1
                    color: root.th.c("BorderSubtle")
                }
            }
            Repeater {
                model: root.values
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    x: parent._step * index + (parent._step - Math.min(root._barW, parent._step - 6)) / 2
                    y: root.plotHeight - height
                    width: Math.min(root._barW, parent._step - 6)
                    height: Math.max(2, (Number(modelData) || 0) / root._peak * root.plotHeight)
                    radius: 4
                    color: root.th.a("accent")
                }
            }
        }
        Row {
            width: root.width
            spacing: 0
            Repeater {
                model: root.labels
                delegate: Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    required property var modelData
                    required property int index
                    width: (root.width - root._gutter) / Math.max(1, root.labels.length)
                    height: root._axisH
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: modelData
                    color: root.th.c("TextMuted")
                    font.pixelSize: root.th.design("TypeXS")
                }
            }
        }
    }
}
