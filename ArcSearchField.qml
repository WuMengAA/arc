// arc:SearchField —— TextFields/SearchField 真源码移植（SearchField.cs + SearchFieldToken.cs）。
// 搜索框圆壳：放大镜 SearchIconSize18（IconStroke2），清除按钮 ClearSlotSize24 / ClearIconSize16，
// 按下缩放 ClearEnterScale0.8；Enter 触发 submit。外观与 ArcInput 同口径（ArcSearchField 已存在，此件保留上游专属交互）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string text: ""
    property string placeholder: "Search"
    property bool clearVisible: true
    signal accepted(string text)
    signal cleared()

    readonly property real _icon: root.th.ct("SearchField", "SearchIconSize")
    readonly property real _clearSlot: root.th.ct("SearchField", "ClearSlotSize")
    readonly property real _clearIcon: root.th.ct("SearchField", "ClearIconSize")
    readonly property real _stroke: root.th.ct("SearchField", "IconStroke")
    readonly property real _enterScale: root.th.ct("SearchField", "ClearEnterScale")
    implicitWidth: 240
    implicitHeight: 36

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: _ti.activeFocus ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
    }
    Arc.ArcIcon {
        x: 11
        anchors.verticalCenter: parent.verticalCenter
        width: root._icon; height: root._icon
        th: root.th
        kind: "Search"
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
    }
    TextInput {
        id: _ti
        anchors.fill: parent
        anchors.leftMargin: 11 + root._icon + 8
        anchors.rightMargin: root._clearSlot + 8
        verticalAlignment: TextInput.AlignVCenter
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
        text: root.text
        selectByMouse: true
        onTextChanged: root.text = text
        onAccepted: root.accepted(text)
    }
    Text {
        anchors.left: parent.left
        anchors.leftMargin: 11 + root._icon + 8
        anchors.verticalCenter: parent.verticalCenter
        visible: _ti.text === ""
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        text: root.placeholder
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
    }
    // 清除
    Rectangle {
        visible: root.clearVisible && _ti.text !== ""
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: root._clearSlot; height: root._clearSlot
        radius: width / 2
        scale: _cm.pressed ? root._enterScale : 1
        color: _cm.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        Behavior on scale { NumberAnimation { duration: root.th ? root.th.dur("Instant") : 120 } }
        Arc.ArcIcon {
            anchors.centerIn: parent
            width: root._clearIcon; height: root._clearIcon
            th: root.th
            kind: "X"
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
        }
        MouseArea {
            id: _cm
            anchors.fill: parent
            hoverEnabled: true
            onClicked: { _ti.text = ""; root.text = ""; root.cleared(); }
        }
    }
}
