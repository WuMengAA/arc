// arc:NumberField —— SpecialInputs/NumberField 真源码移植（NumberField.cs + NumberFieldToken.cs + NumberFieldParts/
// NumberFieldNumbers/NumberFieldAutomationPeer）。
// 数字输入壳：左右各一个步进按钮（StepSizeMD34 / SM28 / LG40，圆角 StepRadius14，按下 StepPressedFill），
// 壳内边距 ShellPadding[3,3,3,3]；超界时 LimitColor 高亮 + WarnBorder 提示；NoteMargin 右挂说明文字。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property real value: 0
    property real minimum: -Infinity
    property real maximum: Infinity
    property real smallChange: 1
    property real largeChange: 10
    property int decimals: 0
    property bool useGrouping: true
    property string size: "md"        // sm | md | lg
    property string note: ""
    signal edited(real v)

    readonly property real _step: root.size === "sm" ? root.th.ct("NumberField", "StepSizeSM")
                                : root.size === "lg" ? root.th.ct("NumberField", "StepSizeLG")
                                : root.th.ct("NumberField", "StepSizeMD")
    readonly property real _stepRad: root.th.pad(root.th.ct("NumberField", root.size === "lg" ? "StepRadiusLG" : "StepRadius"))
    readonly property real _shellPad: root.th.pad(root.th.ct("NumberField", root.size === "lg" ? "ShellPaddingLG" : "ShellPadding"))
    readonly property real _shellW: root.size === "sm" ? root.th.ct("NumberField", "ShellWidthSM")
                                : root.size === "lg" ? root.th.ct("NumberField", "ShellWidthLG")
                                : root.th.ct("NumberField", "ShellWidthMD")
    readonly property real _glyph: root.th.ct("NumberField", "StepGlyphSize")
    readonly property real _noteGap: root.th.t4(root.th.ct("NumberField", "NoteMargin"), 0)
    readonly property bool _outOfRange: root.value < root.minimum || root.value > root.maximum
    readonly property string _shown: root._format(root.value)
    readonly property real _h: root.size === "sm" ? 34 : (root.size === "lg" ? 46 : 40)
    function _format(v) {
        var d = Math.max(0, root.decimals);
        var s = (Math.round(v * Math.pow(10, d)) / Math.pow(10, d)).toFixed(d);
        if (!root.useGrouping) return s;
        var neg = s.charAt(0) === "-"; if (neg) s = s.substring(1);
        var parts = s.split("."), ip = parts[0], out = "";
        for (var i = 0; i < ip.length; i++) {
            if (i > 0 && (ip.length - i) % 3 === 0) out += ",";
            out += ip.charAt(i);
        }
        return (neg ? "-" : "") + out + (parts.length > 1 ? "." + parts[1] : "");
    }
    function _clamp(v) { return Math.max(root.minimum, Math.min(root.maximum, v)); }
    function step(delta) {
        root.value = root._clamp(root.value + delta);
        root.edited(root.value);
    }
    implicitWidth: root._shellW
    implicitHeight: root._h + (root.note !== "" ? root._noteGap + _noteTxt.implicitHeight : 0)
    focus: true
    Keys.onUpPressed: root.step(root.smallChange)
    Keys.onDownPressed: root.step(-root.smallChange)
    Keys.onPressed: function (e) {
        if (e.modifiers & Qt.ShiftModifier) {
            if (e.key === Qt.Key_Up) { root.step(root.largeChange); e.accepted = true; }
            if (e.key === Qt.Key_Down) { root.step(-root.largeChange); e.accepted = true; }
        }
    }

    Rectangle {
        id: _shell
        width: parent.width
        height: root._h
        radius: 12
        color: root.th ? (root._outOfRange ? root.th.ct("NumberField", "WarnSurface") : root.th.c("Surface")) : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root._outOfRange ? (root.th ? root.th.ct("NumberField", "WarnBorder") : "#FFC8A47B")
                                       : (root.th ? root.th.c("Border") : "#FFE0E0E0")
    }
    // 减
    Rectangle {
        x: root._shellPad
        anchors.verticalCenter: _shell.verticalCenter
        width: root._step; height: root._step
        radius: root._stepRad
        color: _dm.pressed ? (root.th ? root.th.ct("NumberField", "StepPressedFill") : "#FFE3E3E3")
                           : (_dm.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent")
        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        Rectangle {
            anchors.centerIn: parent
            width: root._glyph * 0.7; height: 1.75; radius: 1
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
        }
        MouseArea {
            id: _dm
            anchors.fill: parent
            hoverEnabled: true
            enabled: root.value > root.minimum
            onClicked: root.step(-root.smallChange)
        }
    }
    // 加
    Rectangle {
        anchors.right: _shell.right
        anchors.rightMargin: root._shellPad
        anchors.verticalCenter: _shell.verticalCenter
        width: root._step; height: root._step
        radius: root._stepRad
        color: _pm.pressed ? (root.th ? root.th.ct("NumberField", "StepPressedFill") : "#FFE3E3E3")
                           : (_pm.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent")
        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        Rectangle {
            anchors.centerIn: parent
            width: root._glyph * 0.7; height: 1.75; radius: 1
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
        }
        Rectangle {
            anchors.centerIn: parent
            width: 1.75; height: root._glyph * 0.7; radius: 1
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
        }
        MouseArea {
            id: _pm
            anchors.fill: parent
            hoverEnabled: true
            enabled: root.value < root.maximum
            onClicked: root.step(root.smallChange)
        }
    }
    // 值
    TextInput {
        id: _ti
        anchors.left: _shell.left
        anchors.leftMargin: root._shellPad + root._step + 4
        anchors.right: _shell.right
        anchors.rightMargin: root._shellPad + root._step + 4
        anchors.verticalCenter: _shell.verticalCenter
        height: root._h
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.th ? root.th.design(root.size === "lg" ? "TypeLG" : "TypeSM") : 13
        font.weight: root.th ? root.th.weightMedium : 500
        color: root._outOfRange ? (root.th ? root.th.ct("NumberField", "LimitColor") : "#FF794E13")
                                : (root.th ? root.th.c("Foreground") : "#FF1D1D1D")
        text: root._shown
        selectByMouse: true
        validator: DoubleValidator { bottom: -1e12; top: 1e12; decimals: Math.max(0, root.decimals) }
        onEditingFinished: {
            var v = parseFloat(text.replace(/,/g, ""));
            if (isNaN(v)) v = root.value;
            root.value = root._clamp(v);
            text = root._shown;
            root.edited(root.value);
        }
    }
    // 说明
    Text {
        id: _noteTxt
        visible: root.note !== ""
        y: root._h + root._noteGap
        width: parent.width
        wrapMode: Text.WordWrap
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.note
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        lineHeight: root.th.ct("NumberField", "NoteLineHeight")
        lineHeightMode: Text.FixedHeight
    }
}
