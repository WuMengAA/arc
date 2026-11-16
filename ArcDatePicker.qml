// arc:DatePicker —— Pickers/DatePicker 真源码移植：PART_Field(前缀日历图标 + 值 +
// chevron 切换) + PART_Popup(320 宽 / 8px 间距 / RadiusPanel) + PART_Calendar + PART_Footer(清除/今天)。
// 令牌 DatePicker.* / Calendar.* / MonthCalendar.*。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string label: ""
    property string placeholder: "Select a date"
    property string value: ""         // "YYYY-MM-DD"，空=未选
    property bool isOpen: false
    signal datePicked(string value)

    readonly property real _h: th.design("ControlSizeMD")
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _r: th.t4(th.design("RadiusControl"), 0)
    readonly property real _gap: th.ct("DatePicker", "AffixGap")
    readonly property real _btn: th.ct("DatePicker", "DropDownButtonSize")
    readonly property real _popW: th.ct("DatePicker", "PopupWidth")
    readonly property real _popInset: th.pad(th.ct("DatePicker", "PopupInset"))
    readonly property real _popGap: th.ct("DatePicker", "PopupGap")
    readonly property real _pr: th.t4(th.design("RadiusPanel"), 0)

    implicitWidth: 260
    implicitHeight: _h + (label !== "" ? 22 : 0) + (_pop.visible ? 0 : 0)
    width: implicitWidth; height: implicitHeight

    readonly property var _parsed: (function () {
        var m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
        return m ? { y: +m[1], mo: +m[2] - 1, d: +m[3] } : { y: 2026, mo: 10, d: 14 };
    })()
    function _fmt(y, mo, d) {
        function p(n) { return (n < 10 ? "0" : "") + n; }
        return y + "-" + p(mo + 1) + "-" + p(d);
    }
    function _display() {
        if (!value) return placeholder;
        var p = _parsed;
        var names = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
        return names[p.mo] + " " + p.d + ", " + p.y;
    }

    // PART_Field / PART_Frame
    Column {
        width: root.width
        spacing: 4
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.label !== ""
            text: root.label
            color: root.th.c("Foreground")
            font.pixelSize: root.th.design("TypeSM")
            font.weight: root.th.design("WeightMedium")
        }
        Rectangle {
            id: _frame
            width: root.width; height: root._h
            radius: root._r
            color: root.th.c("Surface")
            border.width: root._edge
            border.color: root.isOpen ? root.th.c("BorderStrong") : root.th.c("Border")
            Behavior on border.color { ColorAnimation { duration: th.dur("Instant") } }

            Arc.ArcIcon {
                anchors.left: parent.left; anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                th: root.th; kind: "Calendar"; color: root.th.c("TextMuted")
                width: 16; height: 16
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                anchors.left: parent.left; anchors.leftMargin: 12 + 16 + root._gap
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - (12 + 16 + root._gap) - root._btn - 6
                text: root._display()
                color: root.value ? root.th.c("Foreground") : root.th.c("TextMuted")
                font.pixelSize: root.th.design("TypeSM")
                elide: Text.ElideRight
            }
            Arc.ArcIcon {
                anchors.right: parent.right; anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                th: root.th; kind: "ChevronDown"; color: root.th.c("TextMuted")
                width: 16; height: 16
                rotation: root.isOpen ? 180 : 0
                Behavior on rotation { NumberAnimation { duration: th.dur("Fast") } }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.isOpen = !root.isOpen
            }
        }
    }

    // PART_Popup：面板宽 320，8px 下距，SurfaceRaised 底
    Rectangle {
        id: _pop
        y: root._h + (root.label !== "" ? 22 : 0) + root._popGap
        width: Math.min(root._popW, root._popW)
        height: _cal.implicitHeight + _popInset * 2 + _footerH + 8
        radius: root._pr
        color: root.th.c("SurfaceRaised")
        border.width: root._edge
        border.color: root.th.c("Border")
        visible: root.isOpen
        z: 99
        readonly property real _footerH: 36

        Arc.ArcCalendar {
            id: _cal
            x: root._popInset; y: root._popInset
            th: root.th
            year: root._parsed.y; month: root._parsed.mo; selectedDay: root._parsed.d
            onPicked: function (y, mo, d) {
                root.value = root._fmt(y, mo, d);
                root.isOpen = false;
                root.datePicked(root.value);
            }
        }

        // PART_Footer：清除 / 今天
        Rectangle {
            anchors.left: parent.left; anchors.right: parent.right
            y: _cal.y + _cal.implicitHeight + 8
            height: 1
            color: root.th.c("BorderSubtle")
        }
        Row {
            anchors.right: parent.right; anchors.rightMargin: root._popInset
            y: _cal.y + _cal.implicitHeight + 12
            spacing: 8
            Arc.ArcButton {
                th: root.th; text: "Clear"; variant: "text"; size: "sm"
                onClicked: { root.value = ""; root.isOpen = false; root.datePicked(""); }
            }
            Arc.ArcButton {
                th: root.th; text: "Today"; variant: "secondary"; size: "sm"
                onClicked: {
                    var n = new Date();
                    root.value = root._fmt(n.getFullYear(), n.getMonth(), n.getDate());
                    root.isOpen = false; root.datePicked(root.value);
                }
            }
        }
    }
}

