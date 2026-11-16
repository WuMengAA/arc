// arc:MonthCalendar（DatePicker 的 PART_Calendar）—— Pickers 真源码令牌：
// MonthCalendar.DayNumberSize 24 / WeekdayRowHeight 32 / ChipHeight 19 / PanelWidth 340；
// Calendar.HeaderMinHeight 34 / NavButtonSize 32。纯 QML 月历网格（轻量展示计算）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property int year: 2026
    property int month: 10            // 0-11
    property int selectedDay: 14
    signal picked(int year, int month, int day)
    signal navigated(int year, int month)

    readonly property real _daySz: th.ct("MonthCalendar", "DayNumberSize")
    readonly property real _weekH: th.ct("MonthCalendar", "WeekdayRowHeight")
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _navSz: th.ct("Calendar", "NavButtonSize")

    readonly property var _week: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    readonly property string _monthName: ["January","February","March","April","May","June",
        "July","August","September","October","November","December"][month]

    function _firstWeekday(y, m) { var d = new Date(y, m, 1).getDay(); return (d + 6) % 7; }
    function _days(y, m) { return new Date(y, m + 1, 0).getDate(); }
    function _nav(delta) {
        var m = month + delta, y = year;
        if (m < 0) { m = 11; y--; } else if (m > 11) { m = 0; y++; }
        month = m; year = y; navigated(y, m);
    }

    implicitWidth: 7 * (_daySz + 8) + 16
    implicitHeight: _hdrH + _weekH + 6 * (_daySz + 6) + 12
    width: implicitWidth; height: implicitHeight
    readonly property real _hdrH: th.ct("Calendar", "HeaderMinHeight")

    // 顶部：月份 + 前后翻页
    Item {
        id: _hdr
        width: parent.width; height: root._hdrH
        Arc.ArcIcon {
            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
            th: root.th; kind: "ChevronLeft"; color: root.th.c("TextSecondary")
            width: 16; height: 16
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root._nav(-1) }
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            anchors.centerIn: parent
            text: root._monthName + " " + root.year
            color: root.th.c("Foreground")
            font.pixelSize: root.th.design("TypeSM")
            font.weight: root.th.design("WeightMedium")
        }
        Arc.ArcIcon {
            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
            th: root.th; kind: "ChevronRight"; color: root.th.c("TextSecondary")
            width: 16; height: 16
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root._nav(1) }
        }
    }

    // 星期表头
    Row {
        id: _wk
        y: root._hdrH
        Repeater {
            model: root._week
            delegate: Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                required property var modelData
                width: root._daySz + 8; height: root._weekH
                text: modelData
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: root.th.c("TextMuted")
                font.pixelSize: root.th.design("TypeXS")
            }
        }
    }

    // 日期网格：6 行 × 7 列
    Grid {
        id: _grid
        x: 8; y: root._hdrH + root._weekH
        columns: 7; spacing: 0
        Repeater {
            model: 42
            delegate: Item {
                required property int index
                readonly property int _off: root._firstWeekday(root.year, root.month)
                readonly property int _d: index - _off + 1
                readonly property bool _valid: _d >= 1 && _d <= root._days(root.year, root.month)
                readonly property bool _sel: _valid && _d === root.selectedDay
                width: root._daySz + 8; height: root._daySz + 6
                Rectangle {
                    anchors.centerIn: parent
                    width: root._daySz + 4; height: root.th.ct("MonthCalendar", "ChipHeight") + 6
                    radius: root.th.ct("MonthCalendar", "ChipRadius")
                    color: parent._sel ? root.th.c("Foreground") : "transparent"
                    visible: parent._valid
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        anchors.centerIn: parent
                        text: parent.parent._valid ? parent.parent._d : ""
                        color: parent.parent._sel ? root.th.c("Background") : root.th.c("Foreground")
                        font.pixelSize: root.th.ct("MonthCalendar", "TextSize")
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (parent.parent._valid) { root.selectedDay = parent.parent._d; root.picked(root.year, root.month, parent.parent._d); }
                    }
                }
            }
        }
    }
}

