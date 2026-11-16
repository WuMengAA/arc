// arc:SettingsPage —— Blocks/Settings 真值：NavWidth 248 / NavBackground / NavPillRadius [12..] /
// TitleInset [24,24,24,14] / ContentInset [36,30,36,36] / SaveBarRoom 72 / NavItemGap 2。
// 左侧导航 gliding pill（th.dur("Fast")），右侧分组（SettingsGroup/SettingsRow 令牌）+ 未保存时浮起的 SaveBar。
import QtQuick 2.15

Rectangle {
    id: root
    property var th: null
    property string title: "Settings"
    property var groups: []       // [{ name, rows:[{label,details,value}] }]
    property string active: ""
    property bool dirty: false
    signal saved()
    readonly property real _navW: th.ct("SettingsPage", "NavWidth")
    readonly property real _pillR: th.pad(th.ct("SettingsPage", "NavPillRadius"))
    readonly property real _titleT: th.t4(th.ct("SettingsPage", "TitleInset"), 1)
    readonly property real _contentL: th.t4(th.ct("SettingsPage", "ContentInset"), 0)
    readonly property real _contentT: th.t4(th.ct("SettingsPage", "ContentInset"), 1)
    readonly property real _rowIn: th.t4(th.ct("SettingsRow", "RowInset"), 1)
    readonly property real _tile: th.ct("SettingsRow", "IconTile")
    readonly property real _gap: th.ct("SettingsPage", "NavItemGap")
    width: 760; height: 460
    radius: th.t4(th.design("RadiusPanel"), 0)
    color: th.c("Surface")
    border.width: th.t4(th.design("EdgeThickness"), 0); border.color: th.c("Border")
    clip: true
    Rectangle {
        width: root._navW; height: parent.height
        color: th.ct("SettingsPage", "NavBackground")
        Column {
            x: 12; y: root._titleT; width: parent.width - 24; spacing: 8
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.title; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeLG"); font.weight: root.th.design("WeightMedium") }
            Item { width: 1; height: 8 }
            Item {
                id: _navHost
                width: parent.width; height: _navCol.implicitHeight
                Rectangle {
                    id: _pill
                    width: parent.width - 8; height: 34; radius: root._pillR
                    color: root.th.c("SurfaceRaised")
                    border.width: 1; border.color: root.th.c("BorderSubtle")
                    y: root._gap
                    Behavior on y { NumberAnimation { duration: root.th.dur("Fast"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
                }
                Column {
                    id: _navCol
                    width: parent.width; spacing: root._gap
                    Repeater {
                        model: root.groups
                        delegate: Item {
                            id: _ni
                            required property var modelData; required property int index
                            width: _navCol.width; height: 34
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.verticalCenter: parent.verticalCenter; x: 14; text: modelData.name; color: root.active === modelData.name ? root.th.c("Foreground") : root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.active === modelData.name ? root.th.design("WeightMedium") : root.th.design("WeightRegular") }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.active = modelData.name; _pill.y = _ni.y; root.dirty = true; } }
                        }
                    }
                }
            }
        }
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.th.c("BorderSubtle") }
    }
    Item {
        x: root._navW; width: parent.width - root._navW; height: parent.height
        Flickable {
            id: _flick
            anchors.fill: parent; contentWidth: width; contentHeight: _body.implicitHeight + 100; clip: true
            boundsBehavior: Flickable.StopAtBounds
            Column {
                id: _body
                x: root._contentL; y: root._contentT; width: _flick.width - 2 * root._contentL; spacing: 20
                Repeater {
                    model: root.groups
                    delegate: Column {
                        required property var modelData
                        visible: modelData.name === root.active || root.active === ""
                        width: _body.width; spacing: 0
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.name; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeBase"); font.weight: root.th.design("WeightMedium") }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Manage your " + modelData.name.toLowerCase() + " preferences."; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
                        Item { width: 1; height: 8 }
                        Repeater {
                            model: modelData.rows || []
                            delegate: Rectangle {
                                required property var modelData; required property int index
                                width: _body.width; height: 56
                                color: index % 2 ? root.th.c("SurfaceMuted") : "transparent"
                                Row {
                                    anchors.verticalCenter: parent.verticalCenter; x: root._rowIn; spacing: 14
                                    Rectangle { width: root._tile; height: root._tile; radius: root.th.pad(root.th.ct("SettingsRow", "IconTileRadius")); color: root.th.c("SurfaceMuted"); ArcIcon { anchors.centerIn: parent; th: root.th; kind: "Settings2"; width: 17; height: 17; color: root.th.c("TextSecondary") } }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.label; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM") }
                                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.details || ""; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
                                    }
                                    Item { width: _body.width - 210; height: 1 }
                                    ArcBadge { th: root.th; text: modelData.value || "On"; tone: "neutral"; small: true; anchors.verticalCenter: parent.verticalCenter }
                                }
                            }
                        }
                    }
                }
            }
        }
        Rectangle {
            visible: root.dirty
            anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 14
            width: Math.min(parent.width - 40, 420); height: 48
            radius: root.th.t4(root.th.design("RadiusPill"), 0)
            color: root.th.c("SurfaceRaised")
            border.width: 1; border.color: root.th.c("Border")
            Row {
                anchors.centerIn: parent; spacing: 8
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "You have unsaved changes"; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS"); anchors.verticalCenter: parent.verticalCenter }
                ArcButton { th: root.th; text: "Discard"; variant: "text"; size: "sm"; onClicked: root.dirty = false }
                ArcButton { th: root.th; text: "Save"; size: "sm"; onClicked: { root.dirty = false; root.saved(); } }
            }
            Behavior on opacity { NumberAnimation { duration: root.th.dur("Fast") } }
        }
    }
}
