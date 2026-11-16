// arc:ExpandingButtonGroup —— Buttons/ExpandingButtonGroup 真值移植。
// hover/选中项展开显示 label（Hysteresis=4 语义）；PillInset / ActionExtentMD / DangerExpandedColor。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var items: []          // [{value, label, icon, tone}]
    property int expandedIndex: 0
    signal activated(string value)

    readonly property real _h: th.ct("ExpandingButtonGroupItem", "ActionExtentMD")
    readonly property real _inset: th.pad(th.ct("ExpandingButtonGroup", "PillInset"))
    readonly property real _gap: th.ct("ExpandingButtonGroup", "ActionGap")
    readonly property real _glyph: th.ct("ExpandingButtonGroupItem", "GlyphExtentMD")
    readonly property real _labelEnd: th.ct("ExpandingButtonGroupItem", "LabelEndMD")
    readonly property color _done: th.ct("ExpandingButtonGroupItem", "DoneColor")
    readonly property color _danger: th.ct("ExpandingButtonGroupItem", "DangerExpandedColor")
    implicitWidth: _row.implicitWidth + 2 * _inset
    implicitHeight: _h + 2 * _inset
    width: implicitWidth; height: implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: th.t4(th.design("RadiusControl"), 0)
        color: th.c("SurfaceMuted")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
    }
    Row {
        id: _row
        x: root._inset; y: root._inset
        spacing: root._gap
        Repeater {
            model: root.items
            delegate: Rectangle {
                required property int index
                required property var modelData
                readonly property bool _on: root.expandedIndex === index
                width: _on ? root._glyph + root._labelEnd + 24 : root._h
                height: root._h
                radius: height / 2
                color: _on ? (modelData.tone === "danger" ? root._danger : root._done) : "transparent"
                Behavior on width { NumberAnimation { duration: th.dur("Fast") } }
                Row {
                    anchors.centerIn: parent; spacing: 8
                    Arc.ArcIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        th: root.th; kind: modelData.icon || "Circle"
                        width: root._glyph; height: root._glyph
                        color: th.c("Foreground")
                    }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        visible: parent.parent._on
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label; color: th.c("Foreground")
                        font.pixelSize: th.design("TypeSM")
                    }
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: root.expandedIndex = index
                    onClicked: root.activated(modelData.value)
                }
            }
        }
    }
}
