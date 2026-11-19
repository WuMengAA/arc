// arc:DateRangePickerMonthPane —— Pickers/DateRangePicker/DateRangePickerMonthPane.cs 真源码移植。
// 一个月面板：月份标题 + 星期头（S M T W T F S）+ 6×7 天格子（用 DateRangePickerDayCell）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property int year: 2026
    property int month: 0
    property var rangeStart: null
    property var rangeEnd: null
    readonly property real _cell: 34
    signal dayPicked(int y, int m, int d)

    function daysIn(y, m) { return new Date(y, m + 1, 0).getDate(); }
    function firstWeekday(y, m) { return new Date(y, m, 1).getDay(); }
    function inRange(d) {
        if (!root.rangeStart || !root.rangeEnd) return false;
        var t = new Date(root.year, root.month, d).getTime();
        return t >= root.rangeStart.getTime() && t <= root.rangeEnd.getTime();
    }
    width: 7 * root._cell
    height: 26 + 18 + 6 * root._cell

    Text {
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.year + " · " + ("0" + (root.month + 1)).slice(-2)
        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        font.weight: root.th ? root.th.weightMedium : 500
    }
    Row {
        y: 26
        Repeater {
            model: 7
            delegate: Text {
                required property int index
                width: root._cell
                horizontalAlignment: Text.AlignHCenter
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: ["S", "M", "T", "W", "T", "F", "S"][index]
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
        }
    }
    Grid {
        y: 26 + 18
        columns: 7
        Repeater {
            model: 42
            delegate: Arc.ArcDateRangePickerDayCell {
                required property int index
                readonly property int dayNum: index - root.firstWeekday(root.year, root.month) + 1
                th: root.th
                day: dayNum
                valid: dayNum >= 1 && dayNum <= root.daysIn(root.year, root.month)
                inRange: valid && root.inRange(dayNum)
                onPicked: root.dayPicked(root.year, root.month, dayNum)
            }
        }
    }
}
