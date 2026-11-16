// arc:InlineEdit —— TextFields/InlineEdit 真值：BodyPadding [8,5,8,5] / BodyEditingPadding [8,5,24,5] /
// BodyLineHeight 21 / SlotMinHeight 28 / ActionSize 28 / FlashBorder #4CCD1526 / SaveHoverFill。
// 单击显示、双击进入编辑、Enter 保存、Esc 取消；保存瞬间描边闪一下 FlashBorder。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property string text: ""
    property string placeholder: "Click to edit"
    property bool multiline: false
    property bool editing: false
    property bool invalid: false
    signal saved(string value)
    readonly property real _padL: th.t4(th.ct("InlineEdit", "BodyPadding"), 0)
    readonly property real _padT: th.t4(th.ct("InlineEdit", "BodyPadding"), 1)
    readonly property real _edR: th.t4(th.ct("InlineEdit", "BodyEditingPadding"), 2)
    readonly property real _minH: th.ct("InlineEdit", "SlotMinHeight")
    readonly property real _act: th.ct("InlineEdit", "ActionSize")
    width: 260; height: Math.max(root._minH, _edit.implicitHeight + 2 * root._padT)
    Rectangle {
        id: _frame
        anchors.fill: parent
        radius: th.t4(th.design("RadiusControl"), 0)
        color: root.editing ? root.th.ct("InlineEdit", "FlashFill") : "transparent"
        border.width: root.editing ? 2 : 1
        border.color: root.editing ? root.th.ct("InlineEdit", "FlashBorder") : (root.invalid ? root.th.ct("InlineEdit", "InvalidRing") : "transparent")
        Behavior on color { ColorAnimation { duration: root.th.dur("Instant") } }
        Behavior on border.color { ColorAnimation { duration: root.th.dur("Instant") } }
    }
    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
        id: _label
        visible: !root.editing
        anchors.verticalCenter: parent.verticalCenter
        x: root._padL; width: parent.width - root._padL - root._act
        text: root.text !== "" ? root.text : root.placeholder
        color: root.text !== "" ? root.th.c("Foreground") : root.th.c("TextMuted")
        font.pixelSize: root.th.design("TypeSM")
        elide: Text.ElideRight
    }
    TextInput { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
        id: _edit
        visible: root.editing
        x: root._padL; y: root._padT
        width: parent.width - root._padL - root._edR - root._act
        text: root.text
        color: root.th.c("Foreground")
        font.pixelSize: root.th.design("TypeSM")
        selectByMouse: true
        onAccepted: root.commit(true)
        Keys.onEscapePressed: root.commit(false)
        Component.onCompleted: if (root.editing) forceActiveFocus()
        onVisibleChanged: if (visible) { text = root.text; forceActiveFocus(); selectAll(); }
    }
    Rectangle {
        visible: root.editing
        anchors.right: parent.right; anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        width: root._act - 4; height: root._act - 4
        radius: 6; color: _saveMa.containsMouse ? root.th.ct("InlineEdit", "SaveHoverFill") : root.th.c("Foreground")
        ArcIcon { anchors.centerIn: parent; th: root.th; kind: "Check"; width: 14; height: 14; color: root.th.c("Background") }
        MouseArea { id: _saveMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.commit(true) }
    }
    MouseArea {
        anchors.fill: parent
        enabled: !root.editing
        cursorShape: Qt.IBeamCursor
        onClicked: root.editing = true
    }
    function commit(ok) {
        if (ok) { root.text = _edit.text; root.saved(root.text); }
        root.editing = false;
    }
}
