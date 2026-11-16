// arc:Textarea —— TextFields/Textarea 真源码移植：TextareaToken.cs + TextareaTheme.axaml。
// 内联 FieldFrame（复用 FieldFrame/Field/FieldMessage/FieldTextBox 令牌）+ 多行 TextEdit
// + placeholder + 右下角 resize 三角 grip + description/error 行。FrameMinHeight 110。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property string label: ""
    property string placeholder: ""
    property string description: ""
    property string error: ""
    property string text: ""
    property string size: "md"         // sm | md | lg
    property bool isInvalid: false
    property bool readOnly: false
    signal textEdited(string text)

    readonly property real _minH: th.ct("Textarea", "FrameMinHeight")
    readonly property real _pad: th.t4(th.ct("Textarea", "FramePadding"), 0)
    readonly property real _frameH: Math.max(_minH, _edit.contentHeight + 2 * _pad)
    readonly property real _padL: th.t4(size === "sm" ? th.ct("FieldFrame", "InlinePaddingSM") : (size === "lg" ? th.ct("FieldFrame", "InlinePaddingLG") : th.ct("FieldFrame", "InlinePaddingMD")), 0)
    readonly property bool _invalid: isInvalid || error !== ""
    readonly property bool _focus: _edit.activeFocus
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property color _bd: !enabled ? th.c("Border")
        : (_invalid ? th.c("Danger")
        : (_focus ? th.c("ControlOn") : (_ma.containsMouse ? th.c("BorderStrong") : th.c("Border"))))

    width: implicitWidth; height: implicitHeight
    implicitWidth: 320
    implicitHeight: _col.implicitHeight
    opacity: enabled ? 1 : th.ct("Textarea", "DisabledOpacity")

    Column {
        id: _col
        width: root.width
        spacing: 0

        // PART_Label
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.label !== ""
            width: parent.width
            text: root.label
            color: root.th.c("Foreground")
            font.pixelSize: root.th.design("TypeSM")
            font.weight: root.th.design("WeightMedium")
            lineHeight: root.th.ct("Field", "LabelLineHeight")
            lineHeightMode: Text.FixedHeight
            bottomPadding: root.th.t4(root.th.ct("Field", "LabelMargin"), 3)
        }

        // PART_Frame
        Rectangle {
            width: parent.width
            height: root._frameH
            radius: root.th.t4(root.th.design("RadiusControl"), 0)
            color: root.th.c("Surface")
            border.width: root._edge + (root._focus ? 1 : 0)
            border.color: root._bd
            clip: true
            Behavior on border.color { ColorAnimation { duration: th.dur("Instant") } }

            // PART_Placeholder
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                visible: root.text === "" && root.placeholder !== ""
                x: root._padL; y: root._pad
                width: parent.width - 2 * root._padL
                text: root.placeholder
                color: root.th.c("TextMuted")
                font.pixelSize: root.th.design("TypeSM")
                lineHeight: root.th.ct("FieldTextBox", "TextLineHeight")
                lineHeightMode: Text.FixedHeight
                wrapMode: Text.WordWrap
            }

            // PART_TextPresenter（Qt 6.12 用 TextEdit 支持多行）
            TextEdit { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                id: _edit
                x: root._padL; y: root._pad
                width: parent.width - 2 * root._padL
                height: Math.max(root._minH - 2 * root._pad, contentHeight)
                text: root.text
                color: root.th.c("Foreground")
                font.pixelSize: root.th.design("TypeSM")
                selectionColor: root.th.ct("FieldTextBox", "SelectionFill")
                selectedTextColor: root.th.c("Foreground")
                readOnly: root.readOnly || !root.enabled
                selectByMouse: true
                wrapMode: TextEdit.WordWrap
                // QtQuick 2.15 的 TextEdit 无 onTextEdited（仅 TextInput 有），改用 onTextChanged
                // 并守卫 root.text，避免 set → 回调 → set 的绑定回路。
                onTextChanged: {
                    if (text !== root.text) { root.text = text; root.textEdited(text); }
                }
            }

            // PART_ResizeGrip：SVG data URI（不用 Canvas —— 真机 Qt 6.12 该环境
            // Canvas 首帧渲染路径不可靠，历史 Checkbox 勾不显示即栽在这里）
            Image {
                anchors.right: parent.right; anchors.bottom: parent.bottom
                anchors.rightMargin: 2; anchors.bottomMargin: 2
                width: 12; height: 12
                sourceSize.width: 24; sourceSize.height: 24
                source: "data:image/svg+xml;utf8," + encodeURIComponent(
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 12" fill="none" stroke="' +
                    root.th.c("TextMuted") + '" stroke-width="1" stroke-linecap="round">' +
                    '<path d="M11 3 L3 11 M11 7 L7 11"/></svg>')
            }

            MouseArea {
                id: _ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor
                onClicked: _edit.forceActiveFocus()
            }
        }

        // PART_Description / PART_Error
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root._invalid ? root.error !== "" : root.description !== ""
            width: parent.width
            topPadding: root.th.t4(root.th.ct("FieldMessage", "RowPadding"), 1)
            text: root._invalid ? root.error : root.description
            color: root._invalid ? root.th.c("Danger") : root.th.c("TextSecondary")
            font.pixelSize: root.th.design("TypeXS")
            lineHeight: root.th.ct("FieldMessage", "TextLineHeight")
            lineHeightMode: Text.FixedHeight
        }
    }
}
