// arc:DataGrid PART_Cell —— 单击进入行内编辑，Enter 提交、Esc 取消、失焦自动提交。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property string colKey: ""
    property string value: ""
    property bool editing: false
    property bool alignRight: false
    property real pad: 12
    signal committed(string value)
    signal cancelled()
    signal editRequested()
    clip: true
    property bool _submitting: false
    // 官方 DataGrid.Editing.cs:51 CommitEdit() / :54 CancelEdit() —— 一次编辑只允许一次提交。
    function submitEdit(txt) {
        if (root._submitting || !root.editing) return;
        root._submitting = true; root.committed(txt);
    }
    onEditingChanged: if (!editing) root._submitting = false
    Rectangle {
        visible: root.editing; anchors.fill: parent
        color: root.th.c("Surface"); border.width: 2; border.color: root.th.c("Foreground")
        Rectangle { anchors.right: parent.right; anchors.bottom: parent.bottom; width: 6; height: 6; color: root.th.c("Foreground") }
    }
    TextInput { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
        id: _ti
        visible: root.editing; x: root.pad; width: parent.width - root.pad * 2
        anchors.verticalCenter: parent.verticalCenter
        color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM")
        horizontalAlignment: root.alignRight ? Text.AlignRight : Text.AlignLeft
        selectByMouse: true
        onVisibleChanged: if (visible) { text = root.value; forceActiveFocus(); selectAll(); }
        onAccepted: root.submitEdit(text)
        onEditingFinished: root.submitEdit(text)
        Keys.onEscapePressed: root.cancelled()
    }
    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
        visible: !root.editing; x: root.pad; width: parent.width - root.pad * 2
        anchors.verticalCenter: parent.verticalCenter
        text: root.value; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM")
        elide: Text.ElideRight
        horizontalAlignment: root.alignRight ? Text.AlignRight : Text.AlignLeft
    }
    MouseArea {
        anchors.fill: parent; visible: !root.editing
        cursorShape: Qt.IBeamCursor
        onClicked: root.editRequested()
    }
}
