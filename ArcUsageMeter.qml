// arc:UsageMeter —— Progress/UsageMeter 真源码移植（UsageMeter.cs + UsageMeterToken.cs + UsageMeterBar/UsageMeterLegendItem）。
// 用量条：TrackColor 底轨 + 序列色填充；顶部徽标 BadgeHeight28 / BadgePadding[12,0,12,0]（接近上限 NearBadgeBackground、
// 超限 OverBadgeBackground）；图例 LegendItemPadding[8,8,8,8] / LegendItemRadius12 / LegendValueMargin[20,0,0,0]。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property real used: 0
    property real limit: 100
    property string label: ""
    property string valueText: ""
    property var legend: []           // [{label, value, color?}]
    property bool showLegend: true

    readonly property real _badgeH: root.th.ct("UsageMeter", "BadgeHeight")
    readonly property real _badgePadL: root.th.t4(root.th.ct("UsageMeter", "BadgePadding"), 0)
    readonly property real _capTop: root.th.t4(root.th.ct("UsageMeter", "CaptionMargin"), 3)
    readonly property real _legendPad: root.th.pad(root.th.ct("UsageMeter", "LegendItemPadding"))
    readonly property real _legendRad: root.th.pad(root.th.ct("UsageMeter", "LegendItemRadius"))
    readonly property real _valMargin: root.th.t4(root.th.ct("UsageMeter", "LegendValueMargin"), 0)
    readonly property real _topMinH: root.th.ct("UsageMeter", "TopMinHeight")
    readonly property real _frac: root.limit > 0 ? Math.max(0, Math.min(1, root.used / root.limit)) : 0
    readonly property bool _near: root.limit > 0 && root.used / root.limit >= 0.8 && root.used <= root.limit
    readonly property bool _over: root.used > root.limit
    implicitWidth: 340
    implicitHeight: _col.implicitHeight

    Column {
        id: _col
        width: parent.width
        spacing: 8
        // 头：标题 + 徽标
        Row {
            width: parent.width
            height: root._topMinH
            Text {
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root.label
                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                font.weight: root.th ? root.th.weightMedium : 500
            }
            Item { width: parent.width - 120; height: 1 }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: _bt.implicitWidth + 2 * root._badgePadL
                height: root._badgeH
                radius: height / 2
                color: root._over ? (root.th ? root.th.ct("UsageMeter", "OverBadgeBackground") : "#FFFEE7E4")
                     : root._near ? (root.th ? root.th.ct("UsageMeter", "NearBadgeBackground") : "#FFF4EADF")
                     : (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0")
                Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                Text {
                    id: _bt
                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root.valueText !== "" ? root.valueText
                                               : (Math.round(root.used) + " / " + Math.round(root.limit))
                    color: root._over ? (root.th ? root.th.c("Danger") : "#FFCD1526")
                         : root._near ? (root.th ? root.th.c("Warning") : "#FFB08000")
                         : (root.th ? root.th.c("TextSecondary") : "#FF6D6D6D")
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    font.weight: root.th ? root.th.weightMedium : 500
                }
            }
        }
        // 轨
        Rectangle {
            width: parent.width
            height: 8
            radius: 4
            color: root.th ? root.th.ct("UsageMeter", "TrackColor") : "#FFEBEBEB"
            Rectangle {
                width: parent.width * root._frac
                height: parent.height
                radius: parent.radius
                color: root._over ? (root.th ? root.th.c("Danger") : "#FFCD1526")
                     : root._near ? (root.th ? root.th.c("Warning") : "#FFB08000")
                     : (root.th ? root.th.a("accent") : "#FF2FB8C6")
                Behavior on width { NumberAnimation { duration: root.th ? root.th.dur("Standard") : 240
                    easing.type: Easing.Bezier; easing.bezierCurve: root.th ? root.th.ease("Standard") : [0.22, 1, 0.36, 1, 1, 1] } }
                Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
            }
        }
        // 图例
        Column {
            visible: root.showLegend
            width: parent.width
            spacing: 2
            Repeater {
                model: root.showLegend ? root.legend.length : 0
                delegate: Rectangle {
                    required property int index
                    width: parent.width
                    height: 34
                    radius: root._legendRad
                    color: "transparent"
                    Rectangle {
                        x: root._legendPad
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8; height: 8; radius: 2
                        color: root.legend[index].color || (root.th ? root.th.series(index) : "#FF2FB8C6")
                    }
                    Text {
                        x: root._legendPad + 16
                        anchors.verticalCenter: parent.verticalCenter
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: root.legend[index].label || ""
                        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: root._legendPad
                        anchors.verticalCenter: parent.verticalCenter
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: root.legend[index].value !== undefined ? String(root.legend[index].value) : ""
                        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    }
                }
            }
        }
    }
}
