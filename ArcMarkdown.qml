// arc:Markdown —— Content/Markdown 真源码移植（Markdown.cs 755 行 + MarkdownCodeHighlighter/MarkdownHighlightPlugin）。
// 块级渲染：标题 / 段落 / 列表 / 引用 / 代码块；BlockGap12 是块间距，BodyLeading1.65 是正文行高倍数。
// QML 侧无 Markdown 解析器：只按行做块分类，行内不解析（不发网络请求、不解析原始 JSON）。
// 代码围栏用 String.fromCharCode(96) 拼出，避免在 QML 源码里写反引号。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string text: ""
    property real blockSpacing: 0
    property real leading: -1

    readonly property real _gap: root.blockSpacing > 0 ? root.blockSpacing : root.th.ct("Markdown", "BlockGap")
    readonly property real _leading: root.leading > 0 ? root.leading : root.th.ct("Markdown", "BodyLeading")
    readonly property string _fence: String.fromCharCode(96, 96, 96)
    readonly property var _blocks: root._parse(String(root.text))

    function _isFence(s) { return s.replace(/^\s+/, "").slice(0, 3) === root._fence; }
    function _parse(src) {
        var lines = src.split("\n"), out = [], i = 0, ln, m;
        while (i < lines.length) {
            ln = lines[i];
            if (/^\s*$/.test(ln)) { i++; continue; }
            m = ln.match(/^(#{1,6})\s+(.*)$/);
            if (m) { out.push({ kind: "h" + m[1].length, text: m[2] }); i++; continue; }
            if (root._isFence(ln)) {
                var code = [];
                i++;
                while (i < lines.length && !root._isFence(lines[i])) { code.push(lines[i]); i++; }
                i++;
                out.push({ kind: "code", text: code.join("\n") });
                continue;
            }
            if (/^\s*>\s?/.test(ln)) {
                var q = [];
                while (i < lines.length && /^\s*>\s?/.test(lines[i])) { q.push(lines[i].replace(/^\s*>\s?/, "")); i++; }
                out.push({ kind: "quote", text: q.join(" ") });
                continue;
            }
            if (/^\s*([-*+]|\d+\.)\s+/.test(ln)) {
                var items = [];
                while (i < lines.length && /^\s*([-*+]|\d+\.)\s+/.test(lines[i])) {
                    items.push(lines[i].replace(/^\s*([-*+]|\d+\.)\s+/, ""));
                    i++;
                }
                out.push({ kind: "list", items: items });
                continue;
            }
            var para = [];
            while (i < lines.length && !/^\s*$/.test(lines[i]) && !/^#{1,6}\s/.test(lines[i])
                   && !root._isFence(lines[i]) && !/^\s*>/.test(lines[i])) { para.push(lines[i]); i++; }
            out.push({ kind: "p", text: para.join(" ") });
        }
        return out;
    }
    function _size(kind) {
        if (kind === "h1") return root.th.design("Type2XL");
        if (kind === "h2") return root.th.design("TypeXL");
        if (kind === "h3") return root.th.design("TypeLG");
        if (kind === "h4" || kind === "h5" || kind === "h6") return root.th.design("TypeBase");
        return root.th.design("TypeSM");
    }
    function _listText(blk) {
        var out = [];
        for (var i = 0; i < blk.items.length; i++) out.push("\u2022  " + blk.items[i]);
        return out.join("\n");
    }
    function _hOf(blk) {
        var fs = blk.kind === "list" ? root.th.design("TypeSM") : root._size(blk.kind);
        var n = blk.kind === "list" ? blk.items.length : String(blk.text || "").split("\n").length;
        return Math.ceil(n * fs * root._leading) + (blk.kind === "code" ? 16 : 0);
    }
    implicitWidth: 420
    implicitHeight: _col.implicitHeight

    Column {
        id: _col
        width: parent.width
        spacing: root._gap
        Repeater {
            model: root._blocks.length
            delegate: Item {
                required property int index
                readonly property var blk: root._blocks[index]
                readonly property bool isList: blk.kind === "list"
                readonly property bool isCode: blk.kind === "code"
                readonly property bool isQuote: blk.kind === "quote"
                width: _col.width
                height: root._hOf(blk)
                Rectangle {
                    visible: parent.isQuote
                    width: 3
                    height: parent.height
                    radius: 1.5
                    color: root.th ? root.th.a("accent") : "#FF2FB8C6"
                    opacity: 0.5
                }
                Rectangle {
                    visible: parent.isCode
                    anchors.fill: _txt
                    radius: 10
                    color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
                }
                Text {
                    id: _txt
                    x: parent.isQuote ? 12 : 0
                    y: parent.isCode ? 8 : 0
                    width: parent.width - x - (parent.isCode ? 16 : 0)
                    text: parent.isList ? root._listText(parent.blk) : parent.blk.text
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    renderType: Text.NativeRendering
                    font.family: root.th ? (parent.isCode ? root.th.monoFamily : root.th.fontFamily) : "Segoe UI"
                    font.pixelSize: parent.isList ? root.th.design("TypeSM") : root._size(parent.blk.kind)
                    font.weight: (parent.blk.kind.charAt(0) === "h") ? (root.th ? root.th.weightSemibold : 600) : (root.th ? root.th.weightRegular : 400)
                    color: parent.isQuote ? (root.th ? root.th.c("TextSecondary") : "#FF6D6D6D")
                                           : (root.th ? root.th.c("Foreground") : "#FF1D1D1D")
                    lineHeight: root._leading
                    lineHeightMode: parent.isCode ? Text.FixedHeight : Text.ProportionalHeight
                }
            }
        }
    }
}
