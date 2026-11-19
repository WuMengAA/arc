// arc:TokenTextEditor —— SpecialInputs/TokenTextEditor 真源码移植（TokenTextEditor.cs 1687 行 + TokenTextEditorTypes +
// TokenTextEngine/TokenRenderer/TokenTextBox）。
// 令牌化文本编辑：@提及 / #频道 / 命令等片段渲染成带底色的小令牌（TokenFillOpacity0.12 / TokenCornerRadius6 /
// TokenOutset2），其余是普通文本；EditorLineHeight24 / EditorLetterSpacing-0.16 / EditorPadding[8,8,8,8]。
// QML 侧用富文本近似：令牌片段用 <span> 着色，编辑仍走一个 TextEdit。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string text: ""
    property string placeholder: "Type @ to mention"
    property var tokens: []          // [{start,len,kind}]（kind: mention/channel/command）
    property bool readOnly: false
    signal edited(string text)

    readonly property real _lineH: root.th.ct("TokenTextEditor", "EditorLineHeight")
    readonly property real _pad: root.th.pad(root.th.ct("TokenTextEditor", "EditorPadding"))
    readonly property real _track: root.th.ct("TokenTextEditor", "EditorLetterSpacing")
    readonly property real _fillOp: root.th.ct("TokenTextEditor", "TokenFillOpacity")
    readonly property real _radius: root.th.ct("TokenTextEditor", "TokenCornerRadius")
    // 富文本：按 tokens 把文本切段着色
    readonly property string _rich: {
        if (!root.tokens || root.tokens.length === 0) return root._esc(root.text);
        var sorted = root.tokens.slice().sort(function (a, b) { return a.start - b.start; });
        var out = "", cur = 0;
        for (var i = 0; i < sorted.length; i++) {
            var t = sorted[i];
            if (t.start < cur) continue;
            out += root._esc(root.text.substring(cur, t.start));
            var seg = root._esc(root.text.substring(t.start, t.start + t.len));
            var col = t.kind === "channel" ? (root.th ? root.th.c("Accent") : "#FF2FB8C6")
                    : t.kind === "command" ? (root.th ? root.th.ct("TokenTextEditor", "SyntaxKeyword") : "#FF584CAD")
                    : (root.th ? root.th.c("Success") : "#FF007824");
            out += '<span style="background-color:' + (root.th ? root.th.fade(col, root._fillOp) : "#1F2FB8C6")
                 + '; color:' + col + ';">' + seg + '</span>';
            cur = t.start + t.len;
        }
        out += root._esc(root.text.substring(cur));
        return out;
    }
    function _esc(s) { return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"); }
    implicitWidth: 320
    implicitHeight: Math.max(64, _ti.implicitHeight + 2 * root._pad)

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: _ti.activeFocus ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
    }
    TextEdit {
        id: _ti
        anchors.fill: parent
        anchors.margins: root._pad
        readOnly: root.readOnly
        textFormat: TextEdit.RichText
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        font.letterSpacing: root._track
        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
        selectionColor: root.th ? root.th.fade(root.th.a("accent"), 0.24) : "#3D2FB8C6"
        wrapMode: TextEdit.Wrap
        text: root._rich
        onTextChanged: if (text !== root._rich) root.edited(text)
    }
    Text {
        anchors.fill: parent
        anchors.margins: root._pad
        visible: _ti.text === ""
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        text: root.placeholder
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        wrapMode: Text.WordWrap
    }
}
