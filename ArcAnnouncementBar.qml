// Messages/AnnouncementBar —— BarPadding[16,6,8,6] / FaceMinHeight 32 /
// IconDiameter 32 / ColumnGap 12 / MessageLineHeight 19.6 / InvertedMutedForeground #A8FFFFFF。
// PART_Bar / PART_Viewport(多条轮换) / PART_Controls(Previous/Next/Dismiss)。
import QtQuick 2.15
import "." as Arc

Rectangle {
    id: root
    property var th: null
    property var messages: []      // [{text,link?}]
    property bool inverted: false
    property bool dismissible: true
    property bool navigable: true
    property int index: 0
    property bool isShown: true
    signal dismissed()

    implicitWidth: 720
    implicitHeight: Math.max(th.ct("AnnouncementBar", "FaceMinHeight"), _bar.implicitHeight + _pxT + _pxB)
    visible: isShown && messages.length > 0
    color: inverted ? th.c("Foreground") : th.c("SurfaceMuted")
    border.width: th.t4(th.design("EdgeThicknessBottom"), 3)
    border.color: inverted ? "transparent" : th.c("Border")

    readonly property real _pxL: th.t4(th.ct("AnnouncementBar", "BarPadding"), 0)
    readonly property real _pxT: th.t4(th.ct("AnnouncementBar", "BarPadding"), 1)
    readonly property real _pxB: th.t4(th.ct("AnnouncementBar", "BarPadding"), 3)
    readonly property real _gap: th.ct("AnnouncementBar", "ColumnGap")
    readonly property real _iconD: th.ct("AnnouncementBar", "IconDiameter")
    readonly property color _fg: inverted ? th.c("Background") : th.c("Foreground")
    readonly property color _muted: inverted ? th.ct("AnnouncementBar", "InvertedMutedForeground")
                                             : th.c("TextSecondary")
    readonly property color _hover: inverted ? th.ct("AnnouncementBar", "InvertedIconHoverFill")
                                             : th.ct("AnnouncementBar", "IconHoverFill")

    function _next(d) {
        if (messages.length === 0) return;
        index = (index + d + messages.length) % messages.length;
    }

    Row {
        id: _bar
        anchors.left: parent.left; anchors.leftMargin: root._pxL
        anchors.right: parent.right; anchors.rightMargin: 16
        y: root._pxT
        spacing: root._gap
        Rectangle {
            width: root._iconD; height: root._iconD; radius: width / 2
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            Arc.ArcIcon {
                anchors.centerIn: parent
                width: 18; height: 18
                th: root.th; kind: "Megaphone"; color: root._fg
            }
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            width: parent.width - root._iconD - _ctl.width - 2 * root._gap
            anchors.verticalCenter: parent.verticalCenter
            text: root.messages.length ? root.messages[Math.min(root.index, root.messages.length - 1)].text : ""
            color: root._fg
            font.pixelSize: root.th.design("TypeSM")
            lineHeight: root.th.ct("AnnouncementBar", "MessageLineHeight")
            lineHeightMode: Text.FixedHeight
            elide: Text.ElideRight
        }
        Row {
            id: _ctl
            spacing: root.th.ct("AnnouncementBar", "ControlGap")
            anchors.verticalCenter: parent.verticalCenter
            Repeater {
                model: root.navigable ? ["ChevronLeft", "ChevronRight"] : []
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: 26; height: 26; radius: 13
                    color: _m1.containsMouse ? root._hover : "transparent"
                    Arc.ArcIcon {
                        anchors.centerIn: parent
                        width: 14; height: 14
                        th: root.th; kind: modelData; color: root._muted
                    }
                    MouseArea {
                        id: _m1
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: root._next(index === 0 ? -1 : 1)
                    }
                }
            }
            Rectangle {
                visible: root.dismissible
                width: 26; height: 26; radius: 13
                color: _m2.containsMouse ? root._hover : "transparent"
                Arc.ArcIcon {
                    anchors.centerIn: parent
                    width: 14; height: 14
                    th: root.th; kind: "X"; color: root._muted
                }
                MouseArea {
                    id: _m2
                    anchors.fill: parent; hoverEnabled: true
                    onClicked: { root.isShown = false; root.dismissed(); }
                }
            }
        }
    }
}
