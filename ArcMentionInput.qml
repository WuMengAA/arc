// arc:MentionInput —— SpecialInputs/MentionInput 真源码移植（MentionInput.cs 1001 行 + MentionInputToken.cs +
// MentionInputEditor/Engine/Suggestions/Types）。
// @ 提及输入：正文里 @ 片段染 ChannelTokenFill 底色、TokenCornerRadius6；弹出建议列表
// （SuggestionHighlightFill）；编辑器 EditorPadding[14,11,14,11] / EditorLineHeight24 / EditorLetterSpacing-0.16。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string text: ""
    property var suggestions: []      // [{label, kind?}]
    property bool open: false
    property string placeholder: "Type @ to mention"
    signal picked(string label)

    readonly property real _pad: root.th.pad(root.th.ct("MentionInput", "EditorPadding"))
    readonly property real _lineH: root.th.ct("MentionInput", "EditorLineHeight")
    readonly property real _track: root.th.ct("MentionInput", "EditorLetterSpacing")
    // ChannelTokenFill 是颜色令牌（#AARRGGBB），不是数值——直接当底色用
    readonly property color _tokFill: root.th ? root.th.ct("MentionInput", "ChannelTokenFill") : "#120B0B0B"
    readonly property real _tokRad: root.th.ct("MentionInput", "TokenCornerRadius")
    readonly property real _hiFill: root.th.ct("MentionInput", "SuggestionHighlightFill")
    // 富文本：把 @xxx 染成令牌样式
    readonly property string _rich: {
        var esc = function (s) { return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"); };
        var col = root.th ? root.th.a("accent") : "#FF2FB8C6";
        var bg = root._tokFill;
        return esc(root.text).replace(/(@[A-Za-z0-9_]+)/g, function (m) {
            return '<span style="background-color:' + bg + '; color:' + col + ';">' + m + '</span>';
        });
    }
    implicitWidth: 320
    implicitHeight: _ti.implicitHeight + 2 * root._pad + (root.open && root.suggestions.length > 0 ? 4 + Math.min(5, root.suggestions.length) * 32 + 8 : 0)

    Rectangle {
        id: _shell
        width: parent.width
        height: _ti.implicitHeight + 2 * root._pad
        radius: 14
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: _ti.activeFocus ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
    }
    TextEdit {
        id: _ti
        anchors.fill: _shell
        anchors.margins: root._pad
        textFormat: TextEdit.RichText
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        font.letterSpacing: root._track
        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
        wrapMode: TextEdit.Wrap
        text: root.text
        onTextChanged: {
            if (text !== root.text) root.text = text;
            root.open = /@[A-Za-z0-9_]*$/.test(root.text);
        }
    }
    Text {
        anchors.fill: _shell
        anchors.margins: root._pad
        visible: _ti.text !== "" && !_ti.activeFocus
        textFormat: Text.RichText
        wrapMode: Text.WordWrap
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        font.letterSpacing: root._track
        text: root._rich
        z: 1
    }
    Text {
        anchors.fill: _shell
        anchors.margins: root._pad
        visible: _ti.text === ""
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        text: root.placeholder
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        wrapMode: Text.WordWrap
        z: -1
    }
    // 建议列表
    Rectangle {
        visible: root.open && root.suggestions.length > 0
        y: _shell.height + 4
        width: parent.width
        height: Math.min(5, root.suggestions.length) * 32 + 8
        radius: 14
        color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
        border.width: 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        Column {
            x: 4; y: 4
            width: parent.width - 8
            Repeater {
                model: Math.min(5, root.suggestions.length)
                delegate: Rectangle {
                    required property int index
                    width: parent.width; height: 32; radius: 10
                    color: _sm3.containsMouse ? root._hiFill : "transparent"
                    Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 10
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: root.suggestions[index].label || ""
                        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    }
                    MouseArea {
                        id: _sm3
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var lbl = root.suggestions[index].label || "";
                            var base = root.text.replace(/@[A-Za-z0-9_]*$/, "");
                            root.text = base + "@" + lbl + " ";
                            root.open = false;
                            root.picked(lbl);
                        }
                    }
                }
            }
        }
    }
}
