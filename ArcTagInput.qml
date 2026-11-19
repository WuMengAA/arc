// arc:TagInput —— SpecialInputs/TagInput 真源码移植（TagInput.cs 732 行 + TagInputToken.cs + TagInputPanel/TagInputParts）。
// 标签输入：每个标签一个 chip（ChipMinHeight28 / ChipInset[9,0,4,0] / ChipLabelGap3），
// 删除按钮 RemoveButtonDiameter22（RemoveGlyphSize14 / RemoveGlyphStroke2 / 按下 RemovePressScale0.96）；
// 内容区 ContentMinHeight42 / ContentInset[7,7,7,7]，chip 间距 ItemGap6，行内输入 EditorMinWidth80。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var tags: []             // [string]
    property string placeholder: "Add a tag"
    property int maxTags: 0
    signal tagAdded(string tag)
    signal tagRemoved(int index)

    readonly property real _chipH: root.th.ct("TagInput", "ChipMinHeight")
    readonly property real _chipInsetL: root.th.t4(root.th.ct("TagInput", "ChipInset"), 0)
    readonly property real _chipInsetR: root.th.t4(root.th.ct("TagInput", "ChipInset"), 2)
    readonly property real _labelGap: root.th.ct("TagInput", "ChipLabelGap")
    readonly property real _remD: root.th.ct("TagInput", "RemoveButtonDiameter")
    readonly property real _remGlyph: root.th.ct("TagInput", "RemoveGlyphSize")
    readonly property real _remPress: root.th.ct("TagInput", "RemovePressScale")
    readonly property real _itemGap: root.th.ct("TagInput", "ItemGap")
    readonly property real _contentMinH: root.th.ct("TagInput", "ContentMinHeight")
    readonly property real _contentPad: root.th.pad(root.th.ct("TagInput", "ContentInset"))
    readonly property real _editorMinW: root.th.ct("TagInput", "EditorMinWidth")
    readonly property real _editorMinH: root.th.ct("TagInput", "EditorMinHeight")
    function _add(t) {
        if (t === "") return;
        if (root.maxTags > 0 && root.tags.length >= root.maxTags) return;
        var arr = root.tags.slice();
        arr.push(t);
        root.tags = arr;
        root.tagAdded(t);
    }
    function _remove(i) {
        var arr = root.tags.slice();
        arr.splice(i, 1);
        root.tags = arr;
        root.tagRemoved(i);
    }
    implicitWidth: 320
    implicitHeight: Math.max(root._contentMinH, _flow.implicitHeight + 2 * root._contentPad)

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: _editor.activeFocus ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
    }
    Flow {
        id: _flow
        x: root._contentPad
        y: root._contentPad
        width: parent.width - 2 * root._contentPad
        spacing: root._itemGap
        Repeater {
            model: root.tags.length
            delegate: Rectangle {
                required property int index
                width: _tl.implicitWidth + root._chipInsetL + root._labelGap + root._remD + root._chipInsetR
                height: root._chipH
                radius: root._chipH / 2
                color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
                Text {
                    id: _tl
                    x: root._chipInsetL
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: String(root.tags[index])
                    color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
                // PART_Remove
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: root._chipInsetR
                    anchors.verticalCenter: parent.verticalCenter
                    width: root._remD; height: root._remD
                    radius: width / 2
                    scale: _xm.pressed ? root._remPress : 1
                    color: _xm.containsMouse ? (root.th ? root.th.fade(root.th.c("Danger"), 0.12) : "#1FCD1526") : "transparent"
                    Behavior on scale { NumberAnimation { duration: root.th ? root.th.dur("Instant") : 120 } }
                    Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                    Arc.ArcIcon {
                        anchors.centerIn: parent
                        width: root._remGlyph; height: root._remGlyph
                        th: root.th; kind: "X"
                        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                    }
                    MouseArea {
                        id: _xm
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root._remove(index)
                    }
                }
            }
        }
        // 行内输入
        TextInput {
            id: _editor
            width: Math.max(root._editorMinW, implicitWidth)
            height: root._editorMinH
            verticalAlignment: TextInput.AlignVCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            clip: true
            onAccepted: { root._add(text.trim()); text = ""; }
            Keys.onBackPressed: {
                if (text === "" && root.tags.length > 0) root._remove(root.tags.length - 1);
            }
        }
    }
    Text {
        visible: root.tags.length === 0 && _editor.text === ""
        x: root._contentPad + 4
        anchors.verticalCenter: parent.verticalCenter
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.placeholder
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
    }
}
