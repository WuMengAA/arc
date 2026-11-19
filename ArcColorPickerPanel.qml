// arc:ColorPickerPanel —— Pickers/ColorPicker/ColorPickerPanel.cs 真源码移植。
// 面板正文：SV 色板（AreaHeight164 / AreaRadius16）+ 色相条 + 色块行（ChipDiameterSM24）+ Hex 输入（FieldHeight40）+
// 对比度分级（GradeHeight22，Pass / Large / Fail 三档）。色板与色相条用渐变近似真源码的绘制。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property color color: "#2FB8C6"
    property var swatches: []
    property int maxSwatches: 8
    property color contrastBackground: "#FFFFFFFF"
    property real contrastRatio: 1

    readonly property real _bodyInset: root.th.pad(root.th.ct("ColorPicker", "BodyInset"))
    readonly property real _areaH: root.th.ct("ColorPicker", "AreaHeight")
    readonly property real _areaRad: root.th.pad(root.th.ct("ColorPicker", "AreaRadius"))
    readonly property real _chipSM: root.th.ct("ColorPicker", "ChipDiameterSM")
    readonly property real _fieldH: root.th.ct("ColorPicker", "FieldHeight")
    readonly property real _fieldRad: root.th.pad(root.th.ct("ColorPicker", "FieldRadius"))
    readonly property real _bodyGap: root.th.ct("ColorPicker", "BodyGap")
    readonly property string _hex: root.color.toString().toUpperCase()
    width: parent ? parent.width : 304
    height: root._bodyInset * 2 + root._areaH + 3 * root._bodyGap + root._fieldH + 30

    Rectangle {
        x: root._bodyInset
        y: root._bodyInset
        width: parent.width - 2 * root._bodyInset
        height: root._areaH
        radius: root._areaRad
        clip: true
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: "#FFFFFFFF" }
            GradientStop { position: 1; color: Qt.hsva(0, 1, 1, 1) }
        }
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0; color: "#00000000" }
                GradientStop { position: 1; color: "#FF000000" }
            }
        }
        MouseArea {
            anchors.fill: parent
            onPositionChanged: {
                if (!pressed) return;
                var s = Math.max(0, Math.min(1, mouse.x / width));
                var v = 1 - Math.max(0, Math.min(1, mouse.y / height));
                root.color = Qt.hsva(root.color.hsvHue < 0 ? 0 : root.color.hsvHue, s, v, 1);
            }
        }
    }
    Rectangle {
        x: root._bodyInset
        y: root._bodyInset + root._areaH + root._bodyGap
        width: parent.width - 2 * root._bodyInset
        height: 14
        radius: 7
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#FFFF0000" }
            GradientStop { position: 0.17; color: "#FFFFFF00" }
            GradientStop { position: 0.33; color: "#FF00FF00" }
            GradientStop { position: 0.5; color: "#FF00FFFF" }
            GradientStop { position: 0.67; color: "#FF0000FF" }
            GradientStop { position: 0.83; color: "#FFFF00FF" }
            GradientStop { position: 1.0; color: "#FFFF0000" }
        }
        MouseArea {
            anchors.fill: parent
            onPositionChanged: {
                if (!pressed) return;
                var h = Math.max(0, Math.min(1, mouse.x / width));
                root.color = Qt.hsva(h, root.color.hsvSaturation < 0 ? 1 : root.color.hsvSaturation,
                                     root.color.hsvValue < 0 ? 1 : root.color.hsvValue, 1);
            }
        }
    }
    Row {
        x: root._bodyInset
        y: root._bodyInset + root._areaH + 2 * root._bodyGap + 14
        spacing: 8
        Repeater {
            model: Math.min(root.maxSwatches, root.swatches.length)
            delegate: Rectangle {
                required property int index
                width: root._chipSM; height: root._chipSM
                radius: width / 2
                color: root.swatches[index]
                border.width: 1
                border.color: root.th ? root.th.fade(root.th.c("Border"), 0.6) : "#66E0E0E0"
                MouseArea { anchors.fill: parent; onClicked: root.color = root.swatches[index] }
            }
        }
    }
    Rectangle {
        x: root._bodyInset
        y: root._bodyInset + root._areaH + 2 * root._bodyGap + 14 + root._chipSM + root._bodyGap
        width: parent.width - 2 * root._bodyInset
        height: root._fieldH
        radius: root._fieldRad
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        TextInput {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            verticalAlignment: TextInput.AlignVCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.monoFamily : "Consolas"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            text: root._hex
            selectByMouse: true
            onEditingFinished: if (text.charAt(0) === "#") root.color = text
        }
    }
    // 对比度分级
    Row {
        x: root._bodyInset
        y: root._bodyInset + root._areaH + 2 * root._bodyGap + 14 + root._chipSM + root._bodyGap + root._fieldH + 8
        spacing: 6
        Rectangle {
            width: _g1.implicitWidth + 16; height: 22; radius: 11
            color: root.contrastRatio >= 4.5 ? (root.th ? root.th.ct("ColorPicker", "GradePassFill") : "#24007824") : "transparent"
            Text {
                id: _g1
                anchors.centerIn: parent
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: "AA " + (Math.round(root.contrastRatio * 100) / 100) + ":1"
                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
        }
        Rectangle {
            width: _g2.implicitWidth + 16; height: 22; radius: 11
            color: root.contrastRatio >= 3 && root.contrastRatio < 4.5 ? (root.th ? root.th.ct("ColorPicker", "GradeLargeFill") : "#29AA6B00") : "transparent"
            Text {
                id: _g2
                anchors.centerIn: parent
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: "AA Large"
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
        }
        Rectangle {
            width: _g3.implicitWidth + 16; height: 22; radius: 11
            color: root.contrastRatio < 3 ? (root.th ? root.th.ct("ColorPicker", "GradeFailFill") : "#1FCD1526") : "transparent"
            Text {
                id: _g3
                anchors.centerIn: parent
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: "Fail"
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
        }
    }
}
