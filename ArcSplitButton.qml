// arc:SplitButton —— Buttons/SplitButton 真值移植。
// PART_PrimaryButton + PART_MenuButton；StartRadius/EndRadius 四元；菜单复用 ArcMenuPanel。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string label: "Export"
    property string icon: "Download"
    property bool open: false
    property var menuItems: []
    signal clicked()
    signal menuActivated(int index)

    readonly property real _h: th.design("ControlSizeMD")
    readonly property real _primaryPx: th.t4(th.ct("SplitButton", "PrimaryInset"), 0)
    readonly property real _secondaryW: th.ct("SplitButton", "TriggerExtentSecondary")
    readonly property real _gap: th.ct("SplitButton", "LabelGap")
    readonly property real _glyph: th.ct("SplitButton", "GlyphExtent")
    readonly property real _rStart: th.t4(th.ct("SplitButton", "StartRadius"), 0)
    readonly property real _rEnd: th.t4(th.ct("SplitButton", "EndRadius"), 3)
    readonly property color _div: th.ct("SplitButton", "PrimaryDividerColor")
    readonly property color _hover: th.ct("SplitButton", "PrimaryHoverColor")
    implicitWidth: 230
    implicitHeight: _panel && root.open ? _h + 8 + _panel.height : _h
    width: implicitWidth; height: implicitHeight

    Rectangle {
        id: _primary
        width: root.width - root._secondaryW; height: root._h
        radius: root._rStart
        color: _maP.containsMouse ? root._hover : th.c("Foreground")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Row {
            anchors.centerIn: parent; spacing: root._gap
            Arc.ArcIcon { anchors.verticalCenter: parent.verticalCenter; th: root.th; kind: root.icon; width: root._glyph; height: root._glyph; color: th.c("Background") }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.verticalCenter: parent.verticalCenter; text: root.label; color: th.c("Background"); font.pixelSize: th.design("TypeSM") }
        }
        MouseArea { id: _maP; anchors.fill: parent; hoverEnabled: true; onClicked: root.clicked() }
    }
    Rectangle {
        id: _secondary
        x: root.width - root._secondaryW
        width: root._secondaryW; height: root._h
        radius: root._rEnd
        color: _maS.containsMouse ? root._hover : th.c("Foreground")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Rectangle { x: 0; width: 1; height: root._h * 0.6; anchors.verticalCenter: parent.verticalCenter; color: root._div }
        Arc.ArcIcon {
            anchors.centerIn: parent; th: root.th; kind: "ChevronDown"
            width: 16; height: 16; color: th.c("Background")
            rotation: root.open ? 180 : 0
        }
        MouseArea { id: _maS; anchors.fill: parent; hoverEnabled: true; onClicked: root.open = !root.open }
    }
    Arc.ArcMenuPanel {
        id: _panel; visible: root.open
        y: root._h + 8; x: root.width - width
        th: root.th; items: root.menuItems; rowWidth: 200
        onActivated: function (i) { root.menuActivated(i); root.open = false; }
    }
}
