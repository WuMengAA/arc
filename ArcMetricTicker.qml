// arc:MetricTicker —— Cards/MetricTicker 真源码移植（MetricTicker.cs + MetricTickerToken.cs + MetricTickerCell +
// MetricTickerItem + MetricTickerStrip）。
// 指标条：横向若干指标，每项 = 标签 + 数值（ValueFontSize14）+ 变化量（三角 + 百分比）；
// 项间距 ItemGap24，行距 RowGap8，最小列宽 MinColumnWidth150，两端 FadeWidth28 渐隐（溢出可滚）。
// StripPadding[12,6,6,6] 是整条的内边距；CellPadding[8,4,8,4] 是每格的内边距。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var items: []           // [{label, value, delta?, up?}]
    property bool stacked: false
    property real valueFontSize: 0

    readonly property real _itemGap: root.th.ct("MetricTicker", "ItemGap")
    readonly property real _rowGap: root.th.ct("MetricTicker", "RowGap")
    readonly property real _minW: root.th.ct("MetricTicker", "MinColumnWidth")
    readonly property real _fade: root.th.ct("MetricTicker", "FadeWidth")
    readonly property real _vfs: root.valueFontSize > 0 ? root.valueFontSize : root.th.ct("MetricTicker", "ValueFontSize")
    readonly property real _padV: root.th.pad(root.th.ct("MetricTicker", "StripPadding"))
    implicitWidth: _strip.implicitWidth + 2 * root._padV
    implicitHeight: _strip.implicitHeight + 2 * root._padV
    clip: true

    Item {
        id: _strip
        x: root._padV
        y: root._padV
        width: childrenRect.width
        height: childrenRect.height
        Row {
            spacing: root._itemGap
            Repeater {
                model: root.items.length
                delegate: Column {
                    required property int index
                    spacing: root._rowGap
                    width: Math.max(root._minW, _lbl.implicitWidth)
                    Text {
                        id: _lbl
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: root.items[index].label || ""
                        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    }
                    Row {
                        spacing: 6
                        Text {
                            renderType: Text.NativeRendering
                            font.family: root.th ? root.th.fontFamily : "Segoe UI"
                            text: root.items[index].value !== undefined ? String(root.items[index].value) : ""
                            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                            font.pixelSize: root._vfs
                            font.weight: root.th ? root.th.weightMedium : 500
                        }
                        // 变化量：三角按 up 取 Success/Danger
                        Arc.ArcIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: root.items[index].delta !== undefined
                            width: 10; height: 10
                            th: root.th
                            kind: root.items[index].up === false ? "TrendingDown" : "TrendingUp"
                            color: root.th ? root.th.c(root.items[index].up === false ? "Danger" : "Success") : "#FF2E7D32"
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: root.items[index].delta !== undefined
                            renderType: Text.NativeRendering
                            font.family: root.th ? root.th.fontFamily : "Segoe UI"
                            text: (root.items[index].delta !== undefined ? String(root.items[index].delta) : "")
                            color: root.th ? root.th.c(root.items[index].up === false ? "Danger" : "Success") : "#FF2E7D32"
                            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                        }
                    }
                }
            }
        }
    }
    // 两端渐隐遮罩（FadeWidth）
    Rectangle {
        width: root._fade; height: parent.height
        anchors.right: parent.right
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 1; color: root.th ? root.th.c("Surface") : "#FFFFFFFF" }
        }
    }
}
