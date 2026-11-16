// arc:ButtonGroup —— Buttons/ButtonGroup 真值移植。
// PART_Track/Highlight/Row/ItemsPresenter/Divider；variant outline|solid；滑条用 HighlightRadius。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var options: []          // [{value, label, icon}]
    property string value: ""
    property string variant: "outline"
    property bool vertical: false
    signal activated(string value)

    readonly property real _h: th.ct("ButtonGroup", "TriggerHeightMD")
    readonly property real _segW: th.ct("ButtonGroupItem", "SegmentExtentMD")
    readonly property real _rad: th.pad(th.ct("ButtonGroup", "HighlightRadius"))
    readonly property real _glyph: th.ct("ButtonGroup", "GlyphExtent")
    readonly property color _solid: th.ct("ButtonGroup", "SolidDividerColor")
    readonly property real _segGap: th.t4(th.ct("ButtonGroup", "DividerMarginVertical"), 0)
    implicitWidth: vertical ? _segW + 12 : _row.implicitWidth + 12
    implicitHeight: vertical ? root.options.length * (root._h + root._segGap) - root._segGap + 12 : _h + 12
    width: implicitWidth; height: implicitHeight

    function _idx() { for (var i = 0; i < root.options.length; i++) if (root.options[i].value === root.value) return i; return 0; }
    Rectangle {
        id: _track
        anchors.fill: parent
        radius: root._rad
        color: root.variant === "solid" ? th.c("ControlOn") : th.c("SurfaceMuted")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
    }
    Rectangle {
        id: _highlight
        x: 6 + (root.vertical ? 0 : root._idx() * root._segW)
        y: 6 + (root.vertical ? root._idx() * (root._h + root._segGap) : 0)
        width: root._segW; height: root._h
        radius: root._rad
        color: root.variant === "solid" ? th.ct("ButtonGroup", "SolidHighlightColor") : th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Behavior on x { NumberAnimation { duration: th.dur("Fast"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }
        Behavior on y { NumberAnimation { duration: th.dur("Fast"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }
    }
    Column {
        id: _col
        x: 6; y: 6
        spacing: root._segGap
        visible: root.vertical
        Repeater {
            model: root.options
            delegate: Item {
                required property int index
                required property var modelData
                width: root._segW; height: root._h
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    anchors.centerIn: parent
                    text: modelData.label
                    color: root.variant === "solid" ? th.c("ControlGlyph") : th.c("Foreground")
                    font.pixelSize: th.design("TypeSM")
                }
                MouseArea { anchors.fill: parent; onClicked: root.activated(modelData.value) }
            }
        }
    }
    Row {
        id: _row
        x: 6; y: 6
        spacing: 0
        visible: !root.vertical
        Repeater {
            model: root.options
            delegate: Item {
                required property int index
                required property var modelData
                width: root._segW; height: root._h
                Row {
                    anchors.centerIn: parent
                    spacing: th.ct("ButtonGroupItem", "LabelGapMD")
                    Arc.ArcIcon {
                        visible: (modelData.icon || "") !== ""
                        anchors.verticalCenter: parent.verticalCenter
                        th: root.th; kind: modelData.icon || "Circle"
                        width: root._glyph; height: root._glyph
                        color: root.variant === "solid" ? th.c("ControlGlyph") : th.c("Foreground")
                    }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label
                        color: root.variant === "solid" ? th.c("ControlGlyph") : th.c("Foreground")
                        font.pixelSize: th.design("TypeSM")
                    }
                }
                Rectangle {
                    visible: index < root.options.length - 1
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                    width: 1; height: root._h * 0.5
                    color: root.variant === "solid" ? root._solid : th.c("Border")
                }
                MouseArea { anchors.fill: parent; onClicked: root.activated(modelData.value) }
            }
        }
    }
}
