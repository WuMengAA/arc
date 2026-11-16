// arc:MetricCard —— MetricCardTheme：圆角 RadiusSurface 34、1px Border、内边距 24、标题 TypeSM TextSecondary、
// 右上角变化胶囊（Success/Danger 底 + 12px 箭头）、数值 Type3XL Medium、迷你折线 96x36、上下文 TypeSM TextMuted。
import QtQuick 2.15

Rectangle {
    id: root

    property var th: null
    property string label: ""
    property real value: 0
    property string prefix: ""
    property string suffix: ""
    property int decimals: 0
    property string change: ""
    property string context: ""
    property var sparkValues: []
    property bool up: true

    readonly property real _pad: th.pad(th.n("metricCard","CardPadding"))
    readonly property bool _hasChange: change !== ""

    function formatted() {
        var v = Math.abs(value);
        var s = v.toFixed(decimals);
        var parts = s.split(".");
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return prefix + parts.join(".") + suffix;
    }

    radius: th.t4(th.design("RadiusSurface"), 0)
    color: th.c("Surface")
    border.width: th.design("EdgeThickness")
    border.color: th.c("Border")
    implicitHeight: _col.implicitHeight + 2 * _pad

    Column {
        id: _col
        x: root._pad
        y: root._pad
        width: root.width - 2 * root._pad
        spacing: 0

        // 标题 + 变化胶囊
        Item {
            width: parent.width
            height: Math.max(_labelT.implicitHeight, _chip.height)

            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                id: _labelT
                anchors.left: parent.left
                anchors.top: parent.top
                text: root.label
                color: root.th.c("TextSecondary")
                font.pixelSize: root.th.design("TypeSM")
            }

            Rectangle {
                id: _chip
                visible: root._hasChange
                anchors.right: parent.right
                anchors.top: parent.top
                height: 22
                width: _chipRow.implicitWidth + 16
                radius: height / 2
                color: root.th.fade(root.th.c(root.up ? "Success" : "Danger"), 0.12)

                Row {
                    id: _chipRow
                    anchors.centerIn: parent
                    spacing: 3
                    ArcIcon {
                        th: root.th
                        kind: root.up ? "TrendingUp" : "TrendingDown"
                        width: 12; height: 12
                        color: root.th.c(root.up ? "Success" : "Danger")
                        strokeWidth: 2
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.change
                        color: root.th.c(root.up ? "Success" : "Danger")
                        font.pixelSize: root.th.design("TypeSM")
                        font.weight: root.th.design("WeightMedium")
                    }
                }
            }
        }

        // 数值 + 迷你折线
        Item {
            width: parent.width
            height: Math.max(_value.implicitHeight, 36)
            y: 8

            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                id: _value
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.formatted()
                color: root.th.c("Foreground")
                font.pixelSize: root.th.design("Type3XL")
                font.weight: root.th.design("WeightMedium")
                font.letterSpacing: -0.6
            }

            ArcSparkline {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                th: root.th
                values: root.sparkValues
                up: root.up
            }
        }

        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            width: parent.width
            topPadding: 10
            text: root.context
            color: root.th.c("TextMuted")
            font.pixelSize: root.th.design("TypeSM")
            elide: Text.ElideRight
        }
    }
}
