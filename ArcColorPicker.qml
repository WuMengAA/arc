// arc:ColorPicker —— Pickers/ColorPicker 真源码移植（ColorPicker.cs + ColorPickerToken.cs）。
// 触发药丸（TriggerHeight44 / TriggerRadius22 / TriggerInset[6,5,16,5]）+ 下拉面板（PanelWidth304），
// 面板正文见 ColorPickerPanel（SV 色板 / 色相条 / 色块 / Hex / 对比度分级）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property color color: "#2FB8C6"
    property string format: "HEX"
    property bool isDropDownOpen: false
    property var swatches: []
    property int maxSwatches: 8
    property color contrastBackground: "#FFFFFFFF"

    readonly property real _triggerH: root.th.ct("ColorPicker", "TriggerHeight")
    readonly property real _triggerRad: root.th.pad(root.th.ct("ColorPicker", "TriggerRadius"))
    readonly property real _triggerPadL: root.th.t4(root.th.ct("ColorPicker", "TriggerInset"), 0)
    readonly property real _triggerPadR: root.th.t4(root.th.ct("ColorPicker", "TriggerInset"), 2)
    readonly property real _chip: root.th.ct("ColorPicker", "ChipDiameter")
    readonly property real _panelW: root.th.ct("ColorPicker", "PanelWidth")
    readonly property real _bodyInset: root.th.pad(root.th.ct("ColorPicker", "BodyInset"))
    readonly property string _hex: root.color.toString().toUpperCase()
    // WCAG 相对亮度与对比度
    function _lin(c) { return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); }
    function _lum(c) { return 0.2126 * _lin(c.r) + 0.7152 * _lin(c.g) + 0.0722 * _lin(c.b); }
    readonly property real _contrast: {
        var a = _lum(root.color), b = _lum(root.contrastBackground);
        var hi = Math.max(a, b), lo = Math.min(a, b);
        return (hi + 0.05) / (lo + 0.05);
    }
    implicitWidth: Math.max(220, root._panelW)
    implicitHeight: root._triggerH + (root.isDropDownOpen ? 8 + _panel.height : 0)
    width: Math.max(220, root._panelW)

    Rectangle {
        id: _trigger
        width: parent.width
        height: root._triggerH
        radius: root._triggerRad
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root.isDropDownOpen ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        Rectangle {
            x: root._triggerPadL
            anchors.verticalCenter: parent.verticalCenter
            width: root._chip; height: root._chip
            radius: width / 2
            color: root.color
            border.width: 1
            border.color: root.th ? root.th.fade(root.th.c("Border"), 0.8) : "#33E0E0E0"
        }
        Text {
            x: root._triggerPadL + root._chip + 10
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.monoFamily : "Consolas"
            text: root._hex
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: root._triggerPadR
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.format
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
        MouseArea { anchors.fill: parent; onClicked: root.isDropDownOpen = !root.isDropDownOpen }
    }
    Rectangle {
        id: _panel
        visible: root.isDropDownOpen
        y: root._triggerH + 8
        width: parent.width
        height: root._bodyInset * 2 + root.th.ct("ColorPicker", "AreaHeight") + 3 * root.th.ct("ColorPicker", "BodyGap")
                + root.th.ct("ColorPicker", "FieldHeight") + 30
        radius: 16
        color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
        border.width: 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        Arc.ArcColorPickerPanel {
            th: root.th
            width: parent.width
            color: root.color
            swatches: root.swatches
            maxSwatches: root.maxSwatches
            contrastBackground: root.contrastBackground
            contrastRatio: root._contrast
        }
    }
}
