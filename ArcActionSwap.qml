// arc:ActionSwap —— Buttons/ActionSwap 真值移植。
// enum ActionSwapTone Success/Warning/Danger，ActionSwapPhase Idle/Hover/Committed；三档 Fill/Edge/HoverEdge。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string tone: "success"       // success | warning | danger
    property string label: "Swap state"
    property string sizeName: "md"        // sm | md | lg
    property bool committed: false
    signal activated()

    readonly property real _h: sizeName === "sm" ? th.design("ControlSizeSM") : sizeName === "lg" ? th.design("ControlSizeLG") : th.design("ControlSizeMD")
    readonly property real _px: th.t4(th.ct("ActionSwap", sizeName === "sm" ? "InlinePaddingSM" : sizeName === "lg" ? "InlinePaddingLG" : "InlinePaddingMD"), 0)
    readonly property real _gap: th.ct("ActionSwap", "LabelGap")
    readonly property real _icon: th.ct("ActionSwap", "IconExtent")
    // issue 7：静态键表，未知 tone 兜到 Success*（不会拼出缺失键）。
    readonly property color _fill: root.tone === "warning" ? th.ct("ActionSwap", "WarningFill") : root.tone === "danger" ? th.ct("ActionSwap", "DangerFill") : th.ct("ActionSwap", "SuccessFill")
    readonly property color _edge: root.tone === "warning" ? th.ct("ActionSwap", "WarningEdge") : root.tone === "danger" ? th.ct("ActionSwap", "DangerEdge") : th.ct("ActionSwap", "SuccessEdge")
    readonly property color _edgeHover: root.tone === "warning" ? th.ct("ActionSwap", "WarningEdgeHover") : root.tone === "danger" ? th.ct("ActionSwap", "DangerEdgeHover") : th.ct("ActionSwap", "SuccessEdgeHover")
    implicitWidth: _row.implicitWidth + 2 * _px
    implicitHeight: _h
    width: implicitWidth; height: implicitHeight

    Rectangle {
        id: _pill
        anchors.fill: parent
        radius: parent.height / 2
        color: root._fill
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: _ma.containsMouse ? root._edgeHover : root._edge
        Behavior on border.color { ColorAnimation { duration: th.dur("Instant") } }
        Row {
            id: _row
            anchors.centerIn: parent
            spacing: root._gap
            Arc.ArcIcon {
                anchors.verticalCenter: parent.verticalCenter
                th: root.th; kind: root.committed ? "CheckCheck" : "RotateCw"
                width: root._icon; height: root._icon
                color: root.tone === "danger" ? th.c("Danger") : root.tone === "warning" ? th.c("Warning") : th.c("Success")
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                anchors.verticalCenter: parent.verticalCenter
                text: root.label
                color: th.c("Foreground")
                font.pixelSize: th.design("TypeSM")
            }
        }
        MouseArea { id: _ma; anchors.fill: parent; hoverEnabled: true; onClicked: root.activated()
            Accessible.role: Accessible.Button; Accessible.name: root.label; Accessible.onPressAction: root.activated() }
    }
}
