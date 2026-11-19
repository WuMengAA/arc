// arc:CodeBlock —— Tables/CodeBlock 真源码移植（CodeBlock.cs + CodeBlockToken.cs + CodeBlockHeaderLabel/Viewport/Text/
// ExpandButton/Highlighter）。圆角 HeaderCornerRadius[25,25,0,0] / ExpandCornerRadius[0,0,25,25]；
// 头 HeaderMinHeight52（文件名 + 语言 + 复制按钮），代码区 CodePadding[20,20,20,20] + 行号列（LineNumbersPadding[20,20,0,20]）。
// 折叠：IsCollapsible + MaxLines，展开按钮 ExpandMinHeight44。语法着色按 13 个 Syntax* 令牌（关键字/字符串/数字/类型/函数/属性/标签/标点/注释/插入/删除）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string code: ""
    property string language: ""
    property string fileName: ""
    property bool showLineNumbers: true
    property bool isCollapsible: false
    property int maxLines: 12
    property bool isExpanded: false
    property string copyLabel: "Copy"
    property string showAllLinesFormat: "Show all %1 lines"
    property string showFewerLinesLabel: "Show fewer"
    property bool compact: false

    readonly property real _lineH: root.compact ? root.th.ct("CodeBlock", "CodeLineHeightCompact") : root.th.ct("CodeBlock", "CodeLineHeight")
    readonly property real _pad: root.th.pad(root.th.ct("CodeBlock", root.compact ? "CodePaddingCompact" : "CodePadding"))
    readonly property real _hdrH: root.th.ct("CodeBlock", "HeaderMinHeight")
    readonly property real _hdrRadTop: root.th.t4(root.th.ct("CodeBlock", "HeaderCornerRadius"), 0)
    readonly property real _expRadBottom: root.th.t4(root.th.ct("CodeBlock", "ExpandCornerRadius"), 2)
    readonly property real _expH: root.th.ct("CodeBlock", "ExpandMinHeight")
    readonly property var _lines: root.code.split("\n")
    readonly property int _n: root._lines.length
    readonly property int _shownCount: (!root.isCollapsible || root.isExpanded)
            ? root._n : Math.min(root._n, root.maxLines)
    readonly property real _codeH: root._shownCount * root._lineH + 2 * root._pad
    readonly property bool _overflow: root.isCollapsible && root._n > root.maxLines
    implicitWidth: 520
    implicitHeight: root._hdrH + root._codeH + (root._overflow ? root._expH : 0)

    Rectangle {
        anchors.fill: parent
        radius: root.th.pad(root.th.ct("CodeBlock", "HeaderCornerRadius"))
        color: root.th ? root.th.c("SurfaceRaised") : "#FFFCFCFC"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        clip: true
    }
    // PART_Header
    Rectangle {
        width: parent.width
        height: root._hdrH
        color: "transparent"
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 1
            color: root.th ? root.th.fade(root.th.c("Border"), 0.7) : "#33E0E0E0"
        }
        Text {
            id: _file
            x: root.th.pad(root.th.ct("CodeBlock", root.compact ? "HeaderPaddingCompact" : "HeaderPadding"))
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.monoFamily : "Consolas"
            text: root.fileName !== "" ? root.fileName : (root.language !== "" ? root.language : "")
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightMedium : 500
        }
        Rectangle {
            visible: root.language !== "" && root.fileName !== ""
            x: _file.x + _file.implicitWidth + 8
            anchors.verticalCenter: parent.verticalCenter
            width: _lang.implicitWidth + 12; height: 18; radius: 9
            color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
            Text {
                id: _lang
                anchors.centerIn: parent
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root.language
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
        }
        // PART_Copy（右上）
        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: _cp.implicitWidth + 16; height: 26; radius: 13
            color: _cpMa.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
            Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
            Text {
                id: _cp
                anchors.centerIn: parent
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root.copyLabel
                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
            MouseArea { id: _cpMa; anchors.fill: parent; hoverEnabled: true; onClicked: root._copy() }
        }
    }
    // PART_Viewport：行号 + 代码
    Item {
        y: root._hdrH
        width: parent.width
        height: root._codeH
        clip: true
        // PART_LineNumbers
        Text {
            visible: root.showLineNumbers
            x: root.th.pad(root.th.ct("CodeBlock", root.compact ? "LineNumbersPaddingCompact" : "LineNumbersPadding"))
            y: root._pad
            width: 28
            horizontalAlignment: Text.AlignRight
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.monoFamily : "Consolas"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            color: root.th ? root.th.ct("CodeBlock", "LineNumberForeground") : "#FF9C9C9C"
            lineHeight: root._lineH
            lineHeightMode: Text.FixedHeight
            text: {
                var s = [];
                for (var i = 0; i < root._shownCount; i++) s.push(String(i + 1));
                return s.join("\n");
            }
        }
        // PART_Text：逐行着色（每行一个 Text，按 13 个 Syntax 令牌取色）
        Column {
            x: root._pad + (root.showLineNumbers ? 40 : 0)
            y: root._pad
            width: parent.width - x - root._pad
            Repeater {
                model: root._shownCount
                delegate: Text {
                    required property int index
                    width: parent.width
                    height: root._lineH
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.monoFamily : "Consolas"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    lineHeight: root._lineH
                    lineHeightMode: Text.FixedHeight
                    textFormat: Text.StyledText
                    color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                    text: root._paint(root._lines[index] || "")
                }
            }
        }
    }
    // PART_Expand
    Rectangle {
        visible: root._overflow
        y: root._hdrH + root._codeH
        width: parent.width
        height: root._expH
        color: "transparent"
        Rectangle {
            anchors.top: parent.top
            width: parent.width; height: 1
            color: root.th ? root.th.fade(root.th.c("Border"), 0.7) : "#33E0E0E0"
        }
        Text {
            anchors.centerIn: parent
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.isExpanded ? root.showFewerLinesLabel
                                  : root.showAllLinesFormat.replace("%1", String(root._n))
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightMedium : 500
        }
        MouseArea { anchors.fill: parent; onClicked: root.isExpanded = !root.isExpanded }
    }
    // 极简高亮：注释 / 字符串 / 数字 / 关键字（真源码 13 色，这里覆盖最高频的四类）
    function _paint(line) {
        var esc = function (s) { return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"); };
        var c = function (key) { return root.th ? root.th.ct("CodeBlock", key) : "#FF585858"; };
        var out = esc(line);
        out = out.replace(/(\/\/[^\n]*|#.*)$/, function (m) { return '<font color="' + c("SyntaxComment") + '">' + m + '</font>'; });
        // 字符串：双引号与单引号（用 \x27 表示单引号，避免与 QML 字符串定界符混看）
        var q = "\u0027";
        out = out.replace(new RegExp('"[^"]*"|' + q + '[^' + q + ']*' + q, "g"), function (m) {
            return '<font color="' + c("SyntaxString") + '">' + m + '</font>';
        });
        out = out.replace(/\b\d+(\.\d+)?\b/g, function (m) { return '<font color="' + c("SyntaxNumber") + '">' + m + '</font>'; });
        out = out.replace(/\b(function|return|const|let|var|if|else|for|while|class|new|import|from|export|await|async)\b/g,
            function (m) { return '<font color="' + c("SyntaxKeyword") + '">' + m + '</font>'; });
        return out;
    }
    function _copy() {
        if (root.th === null) return;
        // 复制走宿主注入（QML 不得直连网络/系统剪贴板 API）
        root.copyRequested(root.code);
    }
    signal copyRequested(string text)
}
