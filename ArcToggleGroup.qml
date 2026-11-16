// arc:ToggleGroup —— Toggles/ToggleGroup 真值移植。
// enum ToggleGroupMode Single/Multiple；PART_Selection 滑条、GroupPadding/ItemSizeMD/FillMix。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var options: []       // [{value,label,icon}]
    property var value: []
    property bool small: false
    property bool multiple: true
    signal activated(string value)

    readonly property real _size: th.ct("ToggleGroup", small ? "ItemSizeSM" : "ItemSizeMD")
    readonly property real _gap: th.ct("ToggleGroup", "ItemGap")
    readonly property real _pad: th.pad(th.ct("ToggleGroup", "GroupPadding"))
    readonly property real _icon: th.ct("ToggleGroup", small ? "IconSizeSM" : "IconSizeMD")
    readonly property real _iconGap: th.ct("ToggleGroup", "IconGap")
    readonly property real _unit: root._size + root._gap
    readonly property real _rad: th.t4(th.design("RadiusControl"), 0)
    implicitWidth: root.options.length * _unit - root._gap + 2 * root._pad
    implicitHeight: root._size + 2 * root._pad
    width: implicitWidth; height: implicitHeight

    function _has(v) { for (var i = 0; i < root.value.length; i++) if (root.value[i] === v) return true; return false; }
    Rectangle {
        anchors.fill: parent; radius: root._rad
        color: th.c("SurfaceMuted")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
    }
    Row {
        x: root._pad; y: root._pad; spacing: root._gap
        Repeater {
            model: root.options
            delegate: Rectangle {
                id: _tile
                required property var modelData
                readonly property bool _on: root._has(modelData.value)
                width: root._size; height: root._size
                radius: root._rad - 3
                color: _on ? th.fade(th.c("Accent"), th.ct("ToggleGroup", "FillMix")) : "transparent"
                Behavior on color { ColorAnimation { duration: th.dur("Instant") } }
                Column {
                    anchors.centerIn: parent; spacing: 2
                    Arc.ArcIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        th: root.th; kind: modelData.icon || "Circle"
                        width: root._icon; height: root._icon
                        color: _tile._on ? th.c("AccentStrong") : th.c("TextSecondary")
                    }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  visible: (modelData.label || "") !== ""; text: modelData.label; color: th.c("Foreground"); font.pixelSize: th.design("TypeXS") }
                }
                MouseArea { anchors.fill: parent; onClicked: root.activated(modelData.value) }
            }
        }
    }
}
