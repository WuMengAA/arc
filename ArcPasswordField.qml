// arc:PasswordField —— TextFields/PasswordField 真源码移植（PasswordField.cs + PasswordFieldToken.cs + PasswordEyeGlyph）。
// 密码框：掩码与明文切换，眼睛按钮 RevealButtonSize30（SM 26），EyeSize18；
// 内边距 FramePaddingLG[14,0,9,0] / MD[12,0,6,0] / SM[10,0,4,0] 按 size 取。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string text: ""
    property bool isRevealed: false
    property string size: "md"        // sm | md | lg
    property string placeholder: "Password"
    property string showPasswordText: "Show password"
    property string hidePasswordText: "Hide password"
    signal accepted(string text)

    readonly property real _eye: root.th.ct("PasswordField", "EyeSize")
    readonly property real _btn: root.size === "sm" ? root.th.ct("PasswordField", "RevealButtonSizeSM")
                                                   : root.th.ct("PasswordField", "RevealButtonSize")
    readonly property var _pad: root.size === "sm" ? root.th.ct("PasswordField", "FramePaddingSM")
                               : root.size === "lg" ? root.th.ct("PasswordField", "FramePaddingLG")
                               : root.th.ct("PasswordField", "FramePaddingMD")
    readonly property real _padL: root.th.t4(root._pad, 0)
    readonly property real _padR: root.th.t4(root._pad, 2)
    readonly property real _h: root.size === "sm" ? 32 : (root.size === "lg" ? 44 : 38)
    implicitWidth: 240
    implicitHeight: root._h

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: _ti.activeFocus ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
    }
    TextInput {
        id: _ti
        anchors.fill: parent
        anchors.leftMargin: root._padL
        anchors.rightMargin: root._padR + root._btn + 4
        verticalAlignment: TextInput.AlignVCenter
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
        text: root.text
        echoMode: root.isRevealed ? TextInput.Normal : TextInput.Password
        passwordCharacter: "\u2022"
        selectByMouse: true
        onTextChanged: root.text = text
        onAccepted: root.accepted(text)
    }
    Text {
        anchors.left: parent.left
        anchors.leftMargin: root._padL
        anchors.verticalCenter: parent.verticalCenter
        visible: _ti.text === ""
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        text: root.placeholder
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
    }
    // PART_Reveal：眼睛
    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        width: root._btn; height: root._btn
        radius: width / 2
        color: _rm.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        Arc.ArcIcon {
            anchors.centerIn: parent
            width: root._eye; height: root._eye
            th: root.th
            kind: root.isRevealed ? "EyeOff" : "Eye"
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
        }
        MouseArea {
            id: _rm
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.isRevealed = !root.isRevealed
        }
    }
}
