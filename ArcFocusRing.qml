// arc:ArcFocusRing —— Core/Primitives/LazyFocusRing.cs + FocusModality.cs：
// 懒建焦点环；只在上一次输入是键盘（:focus-visible 语义）时显示，指针按下不显示。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property bool focused: false
    property bool keyboard: false      // FocusModality.LastWasPointer 的反面
    property bool demoKeyboard: false
    property real ringWidth: 2
    property color color: th ? th.c("Accent") : "#FF3B5DC9"
    default property alias content: _body.data
    signal focusGained()
    function simulateKey() { root.keyboard = true; root.focused = true; root.focusGained(); }
    function simulatePointer() { root.keyboard = false; root.focused = true; }

    readonly property bool ringVisible: (root.focused || root.demoKeyboard) && (root.keyboard || root.demoKeyboard)
    implicitWidth: _body.childrenRect.width + 16
    implicitHeight: _body.childrenRect.height + 16

    Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        radius: root.th !== null ? root.th.t4(root.th.design("RadiusControl"), 0) + 3 : 21
        color: "transparent"
        border.width: root.ringVisible ? root.ringWidth : 0
        border.color: root.color
        opacity: root.ringVisible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: root.th !== null ? root.th.dur("Instant") : 120 } }
    }
    Item { id: _body; anchors.centerIn: parent; width: root.width - 16; height: root.height - 16 }
    MouseArea { anchors.fill: parent; z: -1; onPressed: root.simulatePointer() }
}
