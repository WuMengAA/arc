// arc:BottomSheet —— Overlays/BottomSheet + BottomSheetSurface 真值移植。
// PART_Grabber/Header/Title/Description/CloseButton/Body/Actions + ScrimColor 遮罩。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property bool open: true
    property string title: ""
    property string description: ""
    default property alias body: _body.data
    property alias actions: _actions.data
    signal closed()

    readonly property real _padL: th.t4(th.ct("BottomSheetSurface", "HeaderPadding"), 0)
    readonly property real _padT: th.t4(th.ct("BottomSheetSurface", "HeaderPadding"), 1)
    readonly property real _grabW: th.ct("BottomSheetSurface", "GrabberBarWidth")
    readonly property real _grabH: th.ct("BottomSheetSurface", "GrabberBarHeight")
    readonly property real _close: th.ct("BottomSheetSurface", "CloseButtonSize")
    readonly property real _gap: th.ct("BottomSheetSurface", "HeaderGap")
    readonly property real _actM: th.t4(th.ct("BottomSheetSurface", "ActionsMargin"), 1)
    readonly property real _rad: th.t4(th.ct("MenuSurface", "SheetRadius"), 0)
    readonly property real _bodyPadT: th.t4(th.ct("BottomSheetSurface", "BodyPadding"), 1)
    readonly property real _actH: _actions.children.length ? 44 : 0
    readonly property real _panelH: 20 + _grabH + _gap + (title !== "" ? 40 : 0) + (description !== "" ? 26 : 0) + _bodyPadT + _body.implicitHeight + _actM + _actH + 24
    implicitWidth: 420; implicitHeight: 320
    width: implicitWidth; height: implicitHeight

    Rectangle {
        anchors.fill: parent
        visible: root.open
        color: th.ct("BottomSheet", "ScrimColor")
        MouseArea { anchors.fill: parent; onClicked: root.closed() }
    }
    Rectangle {
        id: _sheet
        visible: root.open
        width: Math.min(parent.width, th.ct("BottomSheetSurface", "PanelMaxWidth"))
        height: Math.min(root._panelH, parent.height)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        radius: root._rad
        color: th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 10; width: root._grabW; height: root._grabH
            radius: root._grabH / 2
            color: th.c("BorderStrong")
        }
        Arc.ArcIcon {
            anchors.right: parent.right; anchors.rightMargin: 12
            y: 18; th: root.th; kind: "X"
            width: 16; height: 16; color: th.c("TextMuted")
            MouseArea { anchors.fill: parent; onClicked: root.closed() }
        }
        Column {
            id: _head
            x: root._padL; y: 20 + root._grabH + root._gap
            width: parent.width - 2 * root._padL
            spacing: 0
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                visible: root.title !== ""; text: root.title
                color: th.c("Foreground")
                font.pixelSize: th.design("TypeLG"); font.weight: th.design("WeightMedium")
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                visible: root.description !== ""; text: root.description
                color: th.c("TextSecondary"); font.pixelSize: th.design("TypeSM")
            }
        }
        Item {
            id: _bodyHost
            x: root._padL; y: _head.y + _head.implicitHeight + root._bodyPadT
            width: parent.width - 2 * root._padL
            height: _body.implicitHeight
            Column { id: _body; width: parent.width }
        }
        Row {
            id: _actions
            x: root._padL
            y: _bodyHost.y + _bodyHost.height + root._actM
            spacing: 8
        }
    }
}
