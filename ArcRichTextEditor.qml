// arc:RichTextEditor —— Editors/RichTextEditor 真源码移植（RichTextEditor.cs 2381 行 + RichTextEditorToken.cs +
// RichTextEditor/ 下 16 个分部：BlockHandle/BlockView/Engine*/Find*/Floating/Html/Images/Import/Markdown/Model/Surface/Toggles）。
// 富文本编辑：工具条（ToolbarRadius16 / ToolButtonSize32 / ToolButtonRadius11）+ 可编辑面（SurfaceMinHeight128）；
// 高亮色板 Fill*/Text* 共 7 对（blue/gray/green/orange/purple/red/yellow）；斜杠菜单 SlashMenuRadius18 / SlashRowHeight34。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string html: ""
    property string markdown: ""
    property string placeholder: "Start typing"
    property bool isReadOnly: false

    readonly property real _toolSize: root.th.ct("RichTextEditor", "ToolButtonSize")
    readonly property real _toolRad: root.th.pad(root.th.ct("RichTextEditor", "ToolButtonRadius"))
    readonly property real _toolbarRad: root.th.pad(root.th.ct("RichTextEditor", "ToolbarRadius"))
    readonly property real _minH: root.th.ct("RichTextEditor", "SurfaceMinHeight")
    readonly property real _slashH: root.th.ct("RichTextEditor", "SlashRowHeight")
    readonly property real _slashRad: root.th.pad(root.th.ct("RichTextEditor", "SlashMenuRadius"))
    readonly property var _swatches: [
        { key: "Blue", fill: "FillBlue", text: "TextBlue" },
        { key: "Green", fill: "FillGreen", text: "TextGreen" },
        { key: "Orange", fill: "FillOrange", text: "TextOrange" },
        { key: "Purple", fill: "FillPurple", text: "TextPurple" },
        { key: "Red", fill: "FillRed", text: "TextRed" },
        { key: "Yellow", fill: "FillYellow", text: "TextYellow" },
        { key: "Gray", fill: "FillGray", text: "TextGray" }
    ]
    property bool slashOpen: false
    implicitWidth: 460
    implicitHeight: _toolbar.height + 10 + Math.max(root._minH, _surface.implicitHeight)

    // PART_Toolbar
    Rectangle {
        id: _toolbar
        width: parent.width
        height: 48
        radius: root._toolbarRad
        color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
        Row {
            x: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            // 加粗 / 斜体 / 下划线 / 列表 / 引用
            Repeater {
                model: ["Bold", "Italic", "Underline", "List", "Quote"]
                delegate: Rectangle {
                    required property string modelData
                    width: root._toolSize; height: root._toolSize
                    radius: root._toolRad
                    color: _tb.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                    Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                    Text {
                        anchors.centerIn: parent
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: modelData === "Bold" ? "B" : modelData === "Italic" ? "I"
                            : modelData === "Underline" ? "U" : modelData === "List" ? "•" : "“"
                        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                        font.weight: modelData === "Bold" ? (root.th ? root.th.weightSemibold : 600) : (root.th ? root.th.weightRegular : 400)
                        font.italic: modelData === "Italic"
                        font.underline: modelData === "Underline"
                    }
                    MouseArea { id: _tb; anchors.fill: parent; hoverEnabled: true }
                }
            }
            // 颜色
            Repeater {
                model: root._swatches.length
                delegate: Rectangle {
                    required property int index
                    width: 16; height: 16
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.th ? root.th.ct("RichTextEditor", root._swatches[index].fill) : "#FFE4E8EF"
                    border.width: 1
                    border.color: root.th ? root.th.fade(root.th.c("Border"), 0.6) : "#66E0E0E0"
                }
            }
        }
    }
    // PART_Surface
    Rectangle {
        id: _surface
        y: _toolbar.height + 10
        width: parent.width
        height: Math.max(root._minH, _te.implicitHeight + 24)
        radius: root._toolbarRad
        color: root.th ? root.th.c("Surface") : "#FFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: _te.activeFocus ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        TextEdit {
            id: _te
            anchors.fill: parent
            anchors.margins: 12
            readOnly: root.isReadOnly
            textFormat: TextEdit.RichText
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            font.pixelSize: root.th ? root.th.design("TypeSM") : 13
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            selectionColor: root.th ? root.th.fade(root.th.a("accent"), 0.24) : "#3D2FB8C6"
            wrapMode: TextEdit.Wrap
            text: root.html
            onTextChanged: {
                root.html = text;
                root.slashOpen = /^\/$/.test(text);
            }
        }
        Text {
            anchors.fill: parent
            anchors.margins: 12
            visible: _te.text === ""
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            font.pixelSize: root.th ? root.th.design("TypeSM") : 13
            text: root.placeholder
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            wrapMode: Text.WordWrap
        }
        // PART_SlashMenu
        Rectangle {
            visible: root.slashOpen
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 20
            width: 200
            height: 4 * root._slashH + 8
            radius: root._slashRad
            color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
            border.width: 1
            border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
            Column {
                x: 4; y: 4
                width: parent.width - 8
                Repeater {
                    model: ["Heading 1", "Bulleted list", "Quote", "Code block"]
                    delegate: Rectangle {
                        required property string modelData
                        width: parent.width; height: root._slashH
                        radius: root.th.pad(root.th.ct("RichTextEditor", "SlashRowRadius"))
                        color: _sm5.containsMouse ? (root.th ? root.th.ct("RichTextEditor", "SlashHighlightColor") : "#110B0B0B") : "transparent"
                        Text {
                            x: 8
                            anchors.verticalCenter: parent.verticalCenter
                            renderType: Text.NativeRendering
                            font.family: root.th ? root.th.fontFamily : "Segoe UI"
                            text: modelData
                            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                        }
                        MouseArea { id: _sm5; anchors.fill: parent; hoverEnabled: true; onClicked: root.slashOpen = false }
                    }
                }
            }
        }
    }
}
