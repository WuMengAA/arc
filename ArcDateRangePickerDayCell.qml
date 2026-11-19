// arc:DateRangePickerDayCell —— Pickers/DateRangePicker/DateRangePickerDayCell.cs 真源码移植。
// 一天的格子：Cell 34 见方、圆角圆形；范围内用 AccentSubtle 底色，悬停 DayHoverFill；非本月日隐藏。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property int day: 0
    property bool inRange: false
    property bool valid: true
    readonly property real _cell: 34
    signal picked()

    width: root._cell
    height: root._cell
    visible: root.valid

    Rectangle {
        anchors.fill: parent
        radius: parent.width / 2
        color: root.inRange
               ? (root.th ? root.th.fade(root.th.a("accent"), 0.14) : "#242FB8C6")
               : (_dm.containsMouse ? (root.th ? root.th.ct("DateRangePicker", "DayHoverFill") : "#120B0B0B") : "transparent")
        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
    }
    Text {
        anchors.centerIn: parent
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.day
        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
    }
    MouseArea {
        id: _dm
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.picked()
    }
}
