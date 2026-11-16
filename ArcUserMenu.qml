// arc:UserMenu —— Menus/UserMenu 真值移植（PART_Trigger/Face/Avatar/StatusDot/Name/Chevron）。
// 状态 online|busy|away|offline；accountStyle 菜单面复核带账户分隔线。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property bool open: false
    property string name: "Ada Lovelace"
    property string role: "Workspace owner"
    property string status: "online"
    property var items: []
    signal activated(int index)
    signal themeChangeRequested(string next)

    readonly property real _face: th.ct("UserMenu", "FaceSize")
    readonly property real _trigH: th.ct("UserMenu", "TriggerHeight")
    readonly property real _dot: th.ct("UserMenu", "TriggerDotSize")
    readonly property real _chev: th.ct("UserMenu", "ChevronSize")
    readonly property real _gap: th.ct("UserMenu", "TriggerGap")
    readonly property real _inset: th.t4(th.ct("UserMenu", "NamedTriggerInset"), 0)
    readonly property real _panelGap: th.ct("UserMenu", "PanelGap")
    readonly property color _status: root.status === "online" ? th.c("Success")
                                  : root.status === "busy" ? th.c("Danger")
                                  : th.c("TextMuted")
    implicitWidth: 240
    implicitHeight: _panel && root.open ? _trigH + _panelGap + _panel.height : _trigH
    width: implicitWidth; height: implicitHeight

    Rectangle {
        id: _trigger
        width: root.width; height: root._trigH
        radius: th.t4(th.design("RadiusControl"), 0)
        color: _ma.containsMouse ? th.c("SurfaceMuted") : th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Row {
            x: root._inset; anchors.verticalCenter: parent.verticalCenter
            spacing: root._gap
            Item {
                width: root._face; height: root._face
                anchors.verticalCenter: parent.verticalCenter
                Arc.ArcAvatar { anchors.fill: parent; th: root.th; name: root.name; size: "md" }
                Rectangle {
                    x: parent.width - root._dot; y: parent.height - root._dot
                    width: root._dot; height: root._dot; radius: root._dot / 2
                    color: root._status
                    border.width: th.pad(th.ct("UserMenu", "DotRing"))
                    border.color: th.c("Surface")
                }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.name; color: th.c("Foreground"); font.pixelSize: th.design("TypeSM") }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.role; color: th.c("TextMuted"); font.pixelSize: th.design("TypeXS") }
            }
        }
        Arc.ArcIcon {
            anchors.right: parent.right; anchors.rightMargin: root._inset
            anchors.verticalCenter: parent.verticalCenter
            th: root.th; kind: "ChevronDown"
            width: root._chev; height: root._chev
            color: th.c("TextSecondary")
            rotation: root.open ? 180 : 0
        }
        MouseArea { id: _ma; anchors.fill: parent; hoverEnabled: true; onClicked: root.open = !root.open }
    }
    Arc.ArcMenuPanel {
        id: _panel
        visible: root.open
        y: root._trigH + root._panelGap
        x: root.width - width
        th: root.th; items: root.items; rowWidth: 210; accountStyle: true
        onActivated: function (i) { root.activated(i); root.open = false; }
    }
}
