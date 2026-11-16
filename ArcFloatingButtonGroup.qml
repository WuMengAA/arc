// arc:FloatingButtonGroup —— Buttons/FloatingButtonGroup 真值移植。
// Tray/Highlight/Item 三层；ItemExtentMD / HighlightRadiusMD / OnTintOpacity。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var items: []          // [{value, icon}]
    property string value: ""
    property bool vertical: false
    signal activated(string value)

    readonly property real _ext: th.ct("FloatingButtonGroupItem", "ItemExtentMD")
    readonly property real _gap: th.ct("FloatingButtonGroup", "ItemGapMD")
    readonly property real _inset: th.pad(th.ct("FloatingButtonGroup", "TrayInsetMD"))
    readonly property real _rad: th.pad(th.ct("FloatingButtonGroup", "TrayRadiusMD"))
    readonly property real _hlRad: th.pad(th.ct("FloatingButtonGroup", "HighlightRadiusMD"))
    readonly property color _tray: th.ct("FloatingButtonGroup", "TrayColor")
    readonly property color _hl: th.ct("FloatingButtonGroup", "HighlightColor")
    readonly property color _edge: th.ct("FloatingButtonGroup", "TrayEdgeColor")
    function _idx() { for (var i = 0; i < root.items.length; i++) if (root.items[i].value === root.value) return i; return 0; }
    readonly property real _unit: root._ext + root._gap
    implicitWidth: vertical ? _ext + 2 * _inset : root.items.length * _unit - root._gap + 2 * _inset
    implicitHeight: vertical ? root.items.length * _unit - root._gap + 2 * _inset : _ext + 2 * _inset
    width: implicitWidth; height: implicitHeight

    Rectangle {
        id: _tray
        anchors.fill: parent; radius: root._rad
        color: root._tray
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: root._edge
    }
    Rectangle {
        id: _highlight
        x: root._inset + (root.vertical ? 0 : root._idx() * root._unit)
        y: root._inset + (root.vertical ? root._idx() * root._unit : 0)
        width: root._ext; height: root._ext; radius: root._hlRad
        color: root._hl
        Behavior on x { NumberAnimation { duration: th.dur("Fast") } }
        Behavior on y { NumberAnimation { duration: th.dur("Fast") } }
    }
    Row {
        visible: !root.vertical
        x: root._inset; y: root._inset; spacing: root._gap
        Repeater {
            model: root.items
            delegate: Item {
                required property int index
                required property var modelData
                width: root._ext; height: root._ext
                Arc.ArcIcon {
                    anchors.centerIn: parent; th: root.th
                    kind: modelData.icon || "Circle"
                    width: 18; height: 18
                    color: root.value === modelData.value ? th.c("AccentStrong") : th.c("TextSecondary")
                }
                MouseArea { anchors.fill: parent; onClicked: root.activated(modelData.value) }
            }
        }
    }
    Column {
        visible: root.vertical
        x: root._inset; y: root._inset; spacing: root._gap
        Repeater {
            model: root.items
            delegate: Item {
                required property int index
                required property var modelData
                width: root._ext; height: root._ext
                Arc.ArcIcon {
                    anchors.centerIn: parent; th: root.th
                    kind: modelData.icon || "Circle"
                    width: 18; height: 18
                    color: root.value === modelData.value ? th.c("AccentStrong") : th.c("TextSecondary")
                }
                MouseArea { anchors.fill: parent; onClicked: root.activated(modelData.value) }
            }
        }
    }
}
