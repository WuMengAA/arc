// arc:SegmentedControl —— Toggles/SegmentedControl 真值移植（与既有 ArcSegmented 不同源，勿混）。
// PART_Track/Selection/Segment/Label/Accessory；TrackInset/SelectionRadius/SegmentGap/AccessoryGap。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var options: []       // [{value,label,accessory,disabled}]
    property string value: ""
    signal activated(string value)

    readonly property real _h: th.design("ControlSizeSM")
    readonly property real _inset: th.pad(th.ct("SegmentedControl", "TrackInset"))
    readonly property real _segGap: th.ct("SegmentedControl", "SegmentGap")
    readonly property real _segIn: th.t4(th.ct("SegmentedControl", "SegmentInset"), 0)
    readonly property real _selRad: th.pad(th.ct("SegmentedControl", "SelectionRadius"))
    readonly property real _segRad: th.pad(th.ct("SegmentedControl", "SegmentRadius"))
    readonly property real _accGap: th.ct("SegmentedControl", "AccessoryGap")
    readonly property real _segW: 92
    readonly property real _unit: _segW + root._segGap
    function _idx() { for (var i = 0; i < root.options.length; i++) if (root.options[i].value === root.value) return i; return 0; }
    implicitWidth: root.options.length * _unit - root._segGap + 2 * root._inset
    implicitHeight: root._h + 2 * root._inset
    width: implicitWidth; height: implicitHeight

    Rectangle {
        anchors.fill: parent; radius: root._selRad + root._inset
        color: th.c("SurfaceMuted")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
    }
    Rectangle {
        id: _sel
        x: root._inset + root._idx() * root._unit
        y: root._inset; width: root._segW; height: root._h
        radius: root._selRad
        color: th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Behavior on x { NumberAnimation { duration: th.dur("Fast"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }
    }
    Row {
        x: root._inset; y: root._inset; spacing: root._segGap
        Repeater {
            model: root.options
            delegate: Item {
                required property var modelData
                width: root._segW; height: root._h
                opacity: modelData.disabled ? th.ct("SegmentedControl", "DisabledOpacity") : 1
                Row {
                    anchors.centerIn: parent; spacing: root._accGap
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.label; color: th.c("Foreground"); font.pixelSize: th.design("TypeSM") }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  visible: (modelData.accessory || "") !== ""; text: modelData.accessory || ""; color: th.c("TextMuted"); font.pixelSize: th.design("TypeXS") }
                }
                MouseArea { anchors.fill: parent; enabled: !modelData.disabled; onClicked: root.activated(modelData.value) }
            }
        }
    }
}
