// arc:DateRangePicker —— Pickers/DateRangePicker 真源码移植（DateRangePicker.cs + DateRangePickerToken.cs）。
// 触发框（TriggerRadius18 / TriggerInset[13,0,11,0]）+ 弹层（PanelInset[10,10,10,10]）：
// 左侧预设栏（RailWidth148 / PresetHeight32 / PresetRadius12），右侧 MonthCount 个月并排（MonthPane）；
// 底部 Apply/Cancel（ActionHeight36）。范围高亮用 AccentSubtle。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var selectedRange: [null, null]
    property bool isDropDownOpen: false
    property string placeholder: "Pick a date range"
    property int monthCount: 2
    property var presets: []
    property string applyText: "Apply"
    property string cancelText: "Cancel"
    property bool showFooter: true
    signal applied(var range)

    readonly property real _triggerH: 38
    readonly property real _triggerRad: root.th.t4(root.th.ct("DateRangePicker", "TriggerRadius"), 0)
    readonly property real _triggerPadL: root.th.t4(root.th.ct("DateRangePicker", "TriggerInset"), 0)
    readonly property real _panelInset: root.th.pad(root.th.ct("DateRangePicker", "PanelInset"))
    readonly property real _railW: root.th.ct("DateRangePicker", "RailWidth")
    readonly property real _presetH: root.th.ct("DateRangePicker", "PresetHeight")
    readonly property real _presetRad: root.th.pad(root.th.ct("DateRangePicker", "PresetRadius"))
    readonly property real _actionH: root.th.ct("DateRangePicker", "ActionHeight")
    readonly property real _railHi: root.th.ct("DateRangePicker", "RailHighlightFill")
    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()
    property var pendingStart: null
    readonly property string _label: {
        var r = root.selectedRange || [];
        if (!r[0]) return root.placeholder;
        var f = function (d) {
            if (!d) return "…";
            var dt = (d instanceof Date) ? d : new Date(d);
            if (isNaN(dt.getTime())) return String(d);
            return dt.getFullYear() + "-" + ("0" + (dt.getMonth() + 1)).slice(-2) + "-" + ("0" + dt.getDate()).slice(-2);
        };
        return f(r[0]) + " → " + f(r[1]);
    }
    function pickDay(y, m, d) {
        var picked = new Date(y, m, d);
        if (root.pendingStart === null) { root.pendingStart = picked; root.selectedRange = [picked, null]; return; }
        var a = root.pendingStart, b = picked;
        if (b < a) { var t = a; a = b; b = t; }
        root.selectedRange = [a, b];
        root.pendingStart = null;
    }
    implicitWidth: 280
    implicitHeight: root._triggerH + (root.isDropDownOpen ? 8 + _panel.height : 0)

    Rectangle {
        id: _trigger
        width: parent.width
        height: root._triggerH
        radius: root._triggerRad
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root.isDropDownOpen ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        Text {
            x: root._triggerPadL
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - x - 36
            elide: Text.ElideRight
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root._label
            color: (root.selectedRange && root.selectedRange[0])
                   ? (root.th ? root.th.c("Foreground") : "#FF1D1D1D")
                   : (root.th ? root.th.c("TextMuted") : "#FF9A9A9A")
            font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        }
        Arc.ArcIcon {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 16; height: 16
            th: root.th; kind: "Calendar"
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        }
        MouseArea { anchors.fill: parent; onClicked: root.isDropDownOpen = !root.isDropDownOpen }
    }
    Rectangle {
        id: _panel
        visible: root.isDropDownOpen
        y: root._triggerH + 8
        width: parent.width + root._railW + 16
        height: root._panelInset * 2 + 6 * 34 + 44 + (root.showFooter ? root._actionH + 10 : 0)
        radius: 20
        color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
        border.width: 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        Column {
            x: root._panelInset
            y: root._panelInset
            width: root._railW
            spacing: 2
            Repeater {
                model: root.presets.length
                delegate: Rectangle {
                    required property int index
                    width: parent.width; height: root._presetH
                    radius: root._presetRad
                    color: _pm.containsMouse ? root._railHi : "transparent"
                    Text {
                        x: 12
                        anchors.verticalCenter: parent.verticalCenter
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: root.presets[index].label || ""
                        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    }
                    MouseArea {
                        id: _pm
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var days = root.presets[index].days || 7;
                            root.selectedRange = [new Date(Date.now() - days * 86400000), new Date()];
                            root.pendingStart = null;
                        }
                    }
                }
            }
        }
        Row {
            x: root._panelInset + root._railW + 10
            y: root._panelInset
            spacing: 12
            Repeater {
                model: Math.max(1, root.monthCount)
                delegate: Arc.ArcDateRangePickerMonthPane {
                    required property int index
                    readonly property int shift: root.viewMonth + index
                    th: root.th
                    year: root.viewYear + Math.floor(shift / 12)
                    month: shift % 12
                    rangeStart: root.selectedRange && root.selectedRange[0] ? root.selectedRange[0] : null
                    rangeEnd: root.selectedRange && root.selectedRange[1] ? root.selectedRange[1] : null
                    onDayPicked: function (y, m, d) { root.pickDay(y, m, d); }
                }
            }
        }
        Row {
            visible: root.showFooter
            y: parent.height - root._actionH - 8
            x: parent.width - width - root._panelInset
            spacing: 6
            Arc.ArcButton {
                th: root.th; text: root.cancelText; variant: "text"; size: "sm"
                onClicked: root.isDropDownOpen = false
            }
            Arc.ArcButton {
                th: root.th; text: root.applyText; variant: "primary"; size: "sm"
                onClicked: { root.applied(root.selectedRange); root.isDropDownOpen = false; }
            }
        }
    }
}
