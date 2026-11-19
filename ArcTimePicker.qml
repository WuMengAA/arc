// arc:TimePicker —— Pickers/TimePicker 真源码移植（TimePicker.cs + TimePickerToken.cs + TimePickerList/TimePickerPanel）。
// 时间选择：触发框 + 下拉两列（小时 / 分钟，MinuteStep 步进），列内 OptionHeight36 / OptionRadius21 / OptionInset12；
// 列表内边距 ListInset[5,5,5,5]；冒号 DotDiameter6、AffixGap9；PopupGap6 是触发到弹层的距离。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property int hour: 9
    property int minute: 0
    property int minuteStep: 5
    property bool use12Hour: false
    property bool isDropDownOpen: false
    property string placeholder: "Pick a time"

    readonly property real _optH: root.th.ct("TimePicker", "OptionHeight")
    readonly property real _optRad: root.th.ct("TimePicker", "OptionRadius")
    readonly property real _optInset: root.th.ct("TimePicker", "OptionInset")
    readonly property real _listInset: root.th.pad(root.th.ct("TimePicker", "ListInset"))
    readonly property real _dot: root.th.ct("TimePicker", "DotDiameter")
    readonly property real _affixGap: root.th.ct("TimePicker", "AffixGap")
    readonly property real _popupGap: root.th.ct("TimePicker", "PopupGap")
    readonly property real _lineH: root.th.ct("TimePicker", "ValueLineHeight")
    readonly property int _minCount: Math.ceil(60 / Math.max(1, root.minuteStep))
    readonly property int _hourCount: root.use12Hour ? 12 : 24
    readonly property string _label: {
        var h = root.hour, m = root.minute, ap = "";
        if (root.use12Hour) { ap = h >= 12 ? " PM" : " AM"; h = h % 12; if (h === 0) h = 12; }
        return (h < 10 ? "0" + h : String(h)) + ":" + (m < 10 ? "0" + m : String(m)) + ap;
    }
    function pickHour(v) {
        root.hour = root.use12Hour ? (root.hour >= 12 ? (v === 12 ? 12 : v + 12) : (v === 12 ? 0 : v)) : v;
    }
    function hourIndex() {
        var h = root.hour;
        if (root.use12Hour) { h = h % 12; if (h === 0) h = 12; return h - 1; }
        return h;
    }
    implicitWidth: 220
    implicitHeight: 38 + (root.isDropDownOpen ? root._popupGap + 6 * root._optH + 2 * root._listInset : 0)

    Rectangle {
        id: _trigger
        width: parent.width
        height: 38
        radius: 12
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root.isDropDownOpen ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        Row {
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text {
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root._label
                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                font.pixelSize: root.th ? root.th.design("TypeSM") : 13
            }
        }
        Arc.ArcIcon {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 16; height: 16
            th: root.th; kind: "Clock"
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        }
        MouseArea { anchors.fill: parent; onClicked: root.isDropDownOpen = !root.isDropDownOpen }
    }
    // PART_Panel：小时列 + 分钟列
    Rectangle {
        id: _panel
        visible: root.isDropDownOpen
        y: 38 + root._popupGap
        width: parent.width
        height: 6 * root._optH + 2 * root._listInset
        radius: 16
        color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
        border.width: 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        // 列宽按面板宽算（不读 Row 的宽度，避免 Row↔子项宽度互相回指的 polish 循环）
        Row {
            id: _cols
            x: root._listInset
            y: root._listInset
            width: _panel.width - 2 * root._listInset
            spacing: 2
            readonly property real colW: (width - root._dot * 2 - 2 * root._affixGap) / 2
            // 小时
            ListView {
                width: _cols.colW
                height: 6 * root._optH
                model: root._hourCount
                clip: true
                delegate: Rectangle {
                    required property int index
                    width: parent.width
                    height: root._optH
                    radius: root._optRad
                    color: root.hourIndex() === index ? (root.th ? root.th.fade(root.th.a("accent"), 0.14) : "#242FB8C6")
                                                     : (_hmm.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent")
                    Text {
                        anchors.centerIn: parent
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: {
                            var v = index;
                            if (root.use12Hour) { v = index + 1; }
                            return v < 10 ? "0" + v : String(v);
                        }
                        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
                    }
                    MouseArea {
                        id: _hmm
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.pickHour(root.use12Hour ? index + 1 : index)
                    }
                }
            }
            // 冒号
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: root._dot * 2
                horizontalAlignment: Text.AlignHCenter
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: ":"
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                font.pixelSize: root.th ? root.th.design("TypeSM") : 13
            }
            // 分钟
            ListView {
                width: _cols.colW
                height: 6 * root._optH
                model: root._minCount
                clip: true
                delegate: Rectangle {
                    required property int index
                    readonly property int value: index * root.minuteStep
                    width: parent.width
                    height: root._optH
                    radius: root._optRad
                    color: root.minute === value ? (root.th ? root.th.fade(root.th.a("accent"), 0.14) : "#242FB8C6")
                                                : (_mmm.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent")
                    Text {
                        anchors.centerIn: parent
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: value < 10 ? "0" + value : String(value)
                        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
                    }
                    MouseArea {
                        id: _mmm
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: { root.minute = value; root.isDropDownOpen = false; }
                    }
                }
            }
        }
    }
}
