// arc:Input —— TextFields/Input/InputTheme.axaml（内联 FieldFrame / FieldMessage）真值移植。
// 令牌域 FieldFrame / Field / FieldMessage / FieldTextBox / Input 全走 th.ct()，颜色走 th.c()/th.design()。
import QtQuick 2.15

Item {
    id: root

    property var th: null
    property string label: ""
    property string placeholder: ""
    property string description: ""
    property string error: ""
    property string text: ""
    property string size: "md"         // ControlSize: sm 36 / md 44 / lg 50
    property bool isInvalid: false
    property bool readOnly: false
    property bool password: false
    property bool revealPassword: false
    signal textEdited(string text)

    readonly property real _h: size === "sm" ? th.design("ControlSizeSM")
                            : (size === "lg" ? th.design("ControlSizeLG") : th.design("ControlSizeMD"))
    readonly property real _padL: th.t4(size === "sm" ? th.ct("FieldFrame", "InlinePaddingSM") : (size === "lg" ? th.ct("FieldFrame", "InlinePaddingLG") : th.ct("FieldFrame", "InlinePaddingMD")), 0)
    readonly property real _padR: th.t4(size === "sm" ? th.ct("FieldFrame", "InlinePaddingSM") : (size === "lg" ? th.ct("FieldFrame", "InlinePaddingLG") : th.ct("FieldFrame", "InlinePaddingMD")), 2)
    readonly property bool _invalid: isInvalid || error !== ""
    readonly property bool _focus: _input.activeFocus
    readonly property color _bd: !enabled ? th.c("Border")
        : (_invalid ? th.c("Danger")
        : (_focus ? th.c("ControlOn") : (_ma.containsMouse ? th.c("BorderStrong") : th.c("Border"))))

    width: implicitWidth
    height: implicitHeight
    implicitWidth: 220
    implicitHeight: _col.implicitHeight
    opacity: enabled ? 1 : th.ct("Input", "DisabledOpacity")

    Column {
        id: _col
        width: root.width
        spacing: 0

        // PART_Label：Field.LabelMargin [0,0,0,8] / LabelLineHeight 19.6 / WeightMedium
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

        // PART_Frame：Surface 底 + EdgeThickness 边，hover/focus/invalid 变色
        Rectangle {
            id: _frame
            width: parent.width
            height: root._h
            radius: root.th.t4(root.th.design("RadiusControl"), 0)
            color: root.th.c("Surface")
            border.width: root.th.t4(root.th.design("EdgeThickness"), 0) + (root._focus ? 1 : 0)
            border.color: root._bd
            Behavior on border.color { ColorAnimation { duration: th.dur("Instant") } }

            // PART_Placeholder（TextMuted，仅空值时显示）
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                visible: root.text === "" && root.placeholder !== ""
                x: root._padL
                anchors.verticalCenter: parent.verticalCenter
                text: root.placeholder
                color: root.th.c("TextMuted")
                font.pixelSize: root.th.design("TypeSM")
                lineHeight: root.th.ct("FieldTextBox", "TextLineHeight")
                lineHeightMode: Text.FixedHeight
            }

            // PART_TextPresenter：保留 TextInput 的光标/选择/IME/剪贴板
            TextInput { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                id: _input
                x: root._padL
                width: parent.width - root._padL - root._padR
                anchors.verticalCenter: parent.verticalCenter
                text: root.text
                color: root.th.c("Foreground")
                font.pixelSize: root.th.design("TypeSM")
                selectionColor: root.th.ct("FieldTextBox", "SelectionFill")
                selectedTextColor: root.th.c("Foreground")
                echoMode: root.password && !root.revealPassword ? TextInput.Password : TextInput.Normal
                readOnly: root.readOnly || !root.enabled
                selectByMouse: true
                clip: true
                onTextEdited: { root.text = text; root.textEdited(text); }
            }

            MouseArea {
                id: _ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor
                onClicked: _input.forceActiveFocus()
            }
        }

        // PART_Description / PART_Error：FieldMessage.RowPadding [0,8,0,0]
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
