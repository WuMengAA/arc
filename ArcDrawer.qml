// arc:Drawer —— Overlays/Drawer + DrawerSurface 真值移植。
// side: left|right|top|bottom；RadiusLeft/Right/Top/Bottom 四元令牌按 side 取。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property bool open: true
    property string side: "right"
    property string title: ""
    property string description: ""
    default property alias body: _body.data
    signal closed()

    readonly property real _panel: th.ct("DrawerSurface", "PanelSize")
    readonly property real _close: th.ct("DrawerSurface", "CloseButtonSize")
    readonly property real _gap: th.ct("DrawerSurface", "HeaderGap")
    readonly property real _secP: th.pad(th.ct("DrawerSurface", "SectionPadding"))
    readonly property string _radKey: root.side === "left" ? "RadiusLeft" : root.side === "top" ? "RadiusTop" : root.side === "bottom" ? "RadiusBottom" : "RadiusRight"
    readonly property real _rad: th.pad(th.ct("DrawerSurface", _radKey))
    readonly property real _grabW: th.ct("DrawerSurface", "GrabberWidth")
    readonly property real _grabH: th.ct("DrawerSurface", "GrabberHeight")
    implicitWidth: 460; implicitHeight: 330
    width: implicitWidth; height: implicitHeight

    Rectangle {
        anchors.fill: parent
        visible: root.open
        color: th.ct("Drawer", "ScrimColor")
        MouseArea { anchors.fill: parent; onClicked: root.closed() }
    }
    Rectangle {
        id: _panelRect
        visible: root.open
        color: th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        radius: root._rad
        width: (root.side === "left" || root.side === "right") ? Math.min(root._panel, parent.width) : parent.width
        height: (root.side === "top" || root.side === "bottom") ? Math.min(root._panel, parent.height) : parent.height
        x: root.side === "right" ? parent.width - width : 0
        y: root.side === "bottom" ? parent.height - height : 0
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 8; width: root._grabW; height: root._grabH
            radius: root._grabH / 2
            color: th.c("BorderStrong")
            opacity: th.ct("DrawerSurface", "GrabberOpacity")
        }
        Rectangle {
            anchors.right: parent.right; anchors.rightMargin: root._secP
            y: root._secP; width: root._close; height: root._close
            radius: th.t4(th.design("RadiusControl"), 0)
            color: th.ct("DrawerSurface", "CloseButtonBackground")
            Arc.ArcIcon {
                anchors.centerIn: parent; th: root.th; kind: "X"
                width: 16; height: 16; color: th.c("TextSecondary")
            }
            MouseArea { anchors.fill: parent; onClicked: root.closed() }
        }
        Column {
            x: root._secP; y: root._secP + root._close + root._gap
            width: parent.width - 2 * root._secP
            spacing: 8
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                text: root.title; color: th.c("Foreground")
                font.pixelSize: th.design("TypeLG"); font.weight: th.design("WeightMedium")
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                visible: root.description !== ""; text: root.description
                width: th.ct("DrawerSurface", "DescriptionMaxWidth")
                wrapMode: Text.WordWrap
                color: th.c("TextSecondary"); font.pixelSize: th.design("TypeSM")
            }
            Column { id: _body; width: parent.width }
        }
    }
}
