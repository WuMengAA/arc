// arc:ThemeSwitcher —— Buttons/ThemeSwitcher 真值移植。
// PART_Button/IconWrap/Icon/Text/Frame；:dark 切 Sun/Moon，IconOnlyExtent / IconTextGap。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property bool dark: false
    property bool iconOnly: false
    property string label: "Theme"
    signal changeRequested(bool nextDark)
    // issue 3：受控组件 —— dark 由调用方绑定，组件只发请求，不改自身状态。
    // 旧实现 onClicked 里 root.dark = !root.dark 会在调用方未回填时从旧基准翻转。
    Accessible.role: Accessible.Button
    Accessible.name: root.iconOnly ? qsTr("Toggle theme") : (root.dark ? qsTr("Switch to light theme") : qsTr("Switch to dark theme"))
    Accessible.onPressAction: root.changeRequested(!root.dark)

    readonly property real _h: th.design("ControlSizeMD")
    readonly property real _ext: th.ct("ThemeSwitcher", "IconOnlyExtent")
    readonly property real _wrap: th.ct("ThemeSwitcher", "IconWrapExtent")
    readonly property real _gap: th.ct("ThemeSwitcher", "IconTextGap")
    readonly property real _rad: th.pad(th.ct("ThemeSwitcher", "IconOnlyRadius"))
    implicitWidth: iconOnly ? _ext : _row.implicitWidth + 24
    implicitHeight: _h
    width: implicitWidth; height: implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: iconOnly ? root._rad : th.t4(th.design("RadiusControl"), 0)
        color: _ma.containsMouse ? th.c("SurfaceMuted") : th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Row {
            id: _row
            anchors.centerIn: parent; spacing: root._gap
            Item {
                width: root._wrap; height: root._wrap
                anchors.verticalCenter: parent.verticalCenter
                Arc.ArcIcon {
                    anchors.centerIn: parent; th: root.th
                    kind: root.dark ? "Sun" : "Moon"
                    width: 18; height: 18; color: th.c("Foreground")
                    rotation: root.dark ? 0 : -25
                    Behavior on rotation { NumberAnimation { duration: th.dur("Standard") } }
                }
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                visible: !root.iconOnly
                anchors.verticalCenter: parent.verticalCenter
                text: root.dark ? "Light" : "Dark"
                color: th.c("Foreground"); font.pixelSize: th.design("TypeSM")
            }
        }
        MouseArea { id: _ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.changeRequested(!root.dark) }
    }
}
