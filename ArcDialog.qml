// arc:Dialog —— Overlays/Dialog + DialogSurface 真源码移植。
// ScrimColor 遮罩；面板宽 360/440/560，RadiusSurface(34)、SurfaceRaised 底。
// PART: Frame / Header / Title / Description / CloseButton / Body / Actions。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property bool open: false
    property string title: ""
    property string description: ""
    property string size: "md"          // sm | md | lg
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property bool closeOnScrim: true
    default property alias body: _body.data
    signal accepted()
    signal rejected()

    visible: open

    readonly property real _w: size === "sm" ? th.ct("DialogSurface", "PanelWidthSM")
                            : size === "lg" ? th.ct("DialogSurface", "PanelWidthLG")
                            : th.ct("DialogSurface", "PanelWidthMD")
    readonly property real _pad: th.pad(th.ct("DialogSurface", "HeaderPadding"))
    readonly property real _r: th.t4(th.design("RadiusSurface"), 0)
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _close: th.ct("DialogSurface", "CloseButtonSize")

    Rectangle {
        anchors.fill: parent
        color: root.th.ct("Dialog", "ScrimColor")
        MouseArea {
            anchors.fill: parent
            onClicked: if (root.closeOnScrim) { root.rejected(); root.open = false; }
        }
    }

    Rectangle {
        id: _panel
        anchors.centerIn: parent
        width: Math.min(root._w, root.width - 2 * root.th.pad(root.th.ct("DialogSurface", "ViewportMargin")))
        height: Math.min(_col.implicitHeight + 2 * root._pad, root.height - 32)
        radius: root._r
        color: root.th.c("SurfaceRaised")
        border.width: root._edge
        border.color: root.th.c("Border")
        clip: true

        Column {
            id: _col
            x: root._pad; y: root._pad
            width: parent.width - 2 * root._pad
            spacing: 0

            // PART_Header：标题 + 32px 关闭按钮
            Item {
                width: parent.width
                height: Math.max(root._close, _title.implicitHeight)
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    id: _title
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - root._close - 8
                    text: root.title
                    color: root.th.c("Foreground")
                    font.pixelSize: root.th.design("TypeLG")
                    font.weight: root.th.design("WeightMedium")
                    elide: Text.ElideRight
                }
                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: root._close; height: root._close
                    radius: root.th.t4(root.th.design("RadiusControl"), 0)
                    color: root.th.ct("DialogSurface", "CloseButtonBackground")
                    border.width: root._edge
                    border.color: root.th.c("Border")
                    Arc.ArcIcon {
                        anchors.centerIn: parent
                        th: root.th; kind: "X"; color: root.th.c("TextSecondary")
                        width: 15; height: 15
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.rejected(); root.open = false; }
                    }
                }
            }

            // PART_Description：上距 DescriptionMargin(8)
            Item { width: 1; height: root.description !== "" ? root.th.t4(root.th.ct("DialogSurface", "DescriptionMargin"), 1) : 0 }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                visible: root.description !== ""
                width: parent.width
                text: root.description
                color: root.th.c("TextSecondary")
                font.pixelSize: root.th.design("TypeSM")
                wrapMode: Text.WordWrap
            }

            // PART_Body：调用方内容
            Item { width: 1; height: root.th.ct("DialogSurface", "HeaderGap") }
            Column { id: _body; width: parent.width; spacing: 8 }

            // PART_Actions：上距 ActionsMargin(24)
            Item { width: 1; height: root.th.t4(root.th.ct("DialogSurface", "ActionsMargin"), 1) }
            Item {
                width: parent.width
                height: root.th.design("ControlSizeMD")
                Row {
                    anchors.right: parent.right
                    spacing: 8
                    Arc.ArcButton {
                        th: root.th; text: root.cancelText; variant: "secondary"
                        onClicked: { root.rejected(); root.open = false; }
                    }
                    Arc.ArcButton {
                        th: root.th; text: root.confirmText; variant: "primary"
                        onClicked: { root.accepted(); root.open = false; }
                    }
                }
            }
        }
    }
}

