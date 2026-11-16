// arc:EnumSelector —— Toggles/EnumSelector 真值移植。
// EnumMetadataAttribute 语义：options [{value,label,bits}]；CheckRowSpacing / RadioRowSpacing / LegendMargin。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property string legend: "Select values"
    property var options: []       // [{value,label,bits}]
    property var value: []
    property string mode: "radio"  // radio | check
    signal activated(string value)

    readonly property real _legendM: th.t4(th.ct("EnumSelector", "LegendMargin"), 3)
    readonly property real _radioGap: th.ct("EnumSelector", "RadioRowSpacing")
    readonly property real _checkGap: th.ct("EnumSelector", "CheckRowSpacing")
    readonly property real _colGap: th.ct("EnumSelector", "ColumnSpacing")
    readonly property real _rowH: th.design("ControlSizeSM")
    implicitWidth: 320
    implicitHeight: _col.implicitHeight
    width: implicitWidth; height: implicitHeight

    function _has(v) { for (var i = 0; i < root.value.length; i++) if (root.value[i] === v) return true; return false; }
    Column {
        id: _col
        width: parent.width
        spacing: root._legendM
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.legend; color: th.c("TextSecondary"); font.pixelSize: th.design("TypeSM") }
        Column {
            width: parent.width
            spacing: root.mode === "check" ? root._checkGap : root._radioGap
            Repeater {
                model: root.options
                delegate: Rectangle {
                    required property var modelData
                    readonly property bool _on: root._has(modelData.value)
                    width: root.width; height: root._rowH
                    radius: th.t4(th.design("RadiusControl"), 0)
                    color: _on ? th.c("SurfaceMuted") : "transparent"
                    Row {
                        x: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                        Rectangle {
                            width: 16; height: 16
                            radius: root.mode === "radio" ? 8 : 4
                            border.width: 1.5; border.color: _on ? th.c("Accent") : th.c("BorderStrong")
                            color: "transparent"
                            Rectangle {
                                visible: parent.parent._on === true
                                anchors.centerIn: parent
                                width: root.mode === "radio" ? 8 : 10; height: root.mode === "radio" ? 8 : 10
                                radius: root.mode === "radio" ? 4 : 2
                                color: th.c("Accent")
                            }
                        }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.label; color: th.c("Foreground"); font.pixelSize: th.design("TypeSM") }
                    }
                    MouseArea { anchors.fill: parent; onClicked: root.activated(modelData.value) }
                }
            }
        }
    }
}
