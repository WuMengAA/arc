// arc:ShortcutRecorder —— SpecialInputs/ShortcutRecorder 真源码移植（ShortcutRecorder.cs 762 行 + ShortcutRecorderToken.cs
// + ShortcutFormatter/ShortcutRecorderButton/ShortcutRecorderParts）。
// 快捷键录制：每个键帽 KeyCapHeight26 / KeyCapMinWidth26 / KeyCapRadius8 / KeyCapPadding[7,0,7,1] / KeyCapGap4；
// 录制中显示红点（RecordingDotDiameter7）；冲突时键帽用 KeyCapWarningFill/KeyCapWarningEdge；右侧动作按钮 ActionButtonSize32。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var keys: []             // ["Ctrl", "K"]
    property bool recording: false
    property bool warning: false
    property string message: ""
    property string recordText: ""
    signal recordingRequested()

    readonly property real _capH: root.th.ct("ShortcutRecorder", "KeyCapHeight")
    readonly property real _capMinW: root.th.ct("ShortcutRecorder", "KeyCapMinWidth")
    readonly property real _capRad: root.th.pad(root.th.ct("ShortcutRecorder", "KeyCapRadius"))
    readonly property real _capPadL: root.th.t4(root.th.ct("ShortcutRecorder", "KeyCapPadding"), 0)
    readonly property real _capPadB: root.th.t4(root.th.ct("ShortcutRecorder", "KeyCapPadding"), 3)
    readonly property real _capGap: root.th.ct("ShortcutRecorder", "KeyCapGap")
    readonly property real _dotD: root.th.ct("ShortcutRecorder", "RecordingDotDiameter")
    readonly property real _actionW: root.th.ct("ShortcutRecorder", "ActionButtonSize")
    readonly property real _msgLH: root.th.ct("ShortcutRecorder", "MessageLineHeight")
    readonly property real _warnFill: root.th ? root.th.ct("ShortcutRecorder", "KeyCapWarningFill") : "#FFF5EDE4"
    readonly property real _warnEdge: root.th ? root.th.ct("ShortcutRecorder", "KeyCapWarningEdge") : "#FFB8946C"
    implicitWidth: 260
    implicitHeight: _row.implicitHeight + (root.message !== "" ? 6 + _msgTxt.implicitHeight : 0)

    Row {
        id: _row
        spacing: root._capGap
        // 录制红点
        Rectangle {
            visible: root.recording
            width: root._dotD; height: root._dotD
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            color: root.th ? root.th.c("Danger") : "#FFCD1526"
        }
        // 键帽
        Repeater {
            model: root.keys.length
            // 键帽里把底边内距用「文本下移」实现（Rectangle 无 bottomPadding）
            delegate: Rectangle {
                required property int index
                width: Math.max(root._capMinW, _kt.implicitWidth + 2 * root._capPadL)
                height: root._capH
                radius: root._capRad
                color: root.warning ? root._warnFill : (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0")
                border.width: root.warning ? 1 : 0
                border.color: root.warning ? root._warnEdge : "transparent"
                Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                Text {
                    id: _kt
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -root._capPadB / 2
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: String(root.keys[index])
                    color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    font.weight: root.th ? root.th.weightMedium : 500
                }
            }
        }
        // 录制提示
        Text {
            visible: root.recording && root.recordText !== ""
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.recordText
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
        // 动作按钮
        Rectangle {
            width: root._actionW; height: root._actionW
            radius: root.th.pad(root.th.ct("ShortcutRecorder", "ActionButtonRadius"))
            anchors.verticalCenter: parent.verticalCenter
            color: _am2.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
            Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
            Arc.ArcIcon {
                anchors.centerIn: parent
                width: root.th.ct("ShortcutRecorder", "ActionGlyphSize")
                height: width
                th: root.th; kind: root.recording ? "Square" : "CircleDot"
                color: root.recording ? (root.th ? root.th.c("Danger") : "#FFCD1526")
                                      : (root.th ? root.th.c("TextSecondary") : "#FF6D6D6D")
            }
            MouseArea { id: _am2; anchors.fill: parent; hoverEnabled: true; onClicked: root.recordingRequested() }
        }
    }
    Text {
        id: _msgTxt
        visible: root.message !== ""
        y: _row.implicitHeight + 6
        width: parent.width
        wrapMode: Text.WordWrap
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.message
        color: root.warning ? (root.th ? root.th.c("Warning") : "#FFB08000")
                            : (root.th ? root.th.c("TextMuted") : "#FF9A9A9A")
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        lineHeight: root._msgLH
        lineHeightMode: Text.FixedHeight
    }
}
