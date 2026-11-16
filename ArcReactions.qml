// arc:Reactions —— Gestures/Reactions 真值移植。
// PART_Bar/AddButton/Pill/Glyph/Count/Options；PickerPadding/PillHeight/KickStiffness 走令牌。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var reactions: []     // [{emoji, count, reacted}]
    property var options: ["👍", "❤️", "🎉", "🚀", "👀"]
    property bool pickerOpen: false
    signal reacted(int index)
    signal added(string emoji)

    readonly property real _pillH: th.ct("Reactions", "PillHeight")
    readonly property real _pad: th.pad(th.ct("Reactions", "PillPadding"))
    readonly property real _gap: th.ct("Reactions", "PillContentGap")
    readonly property real _font: th.ct("Reactions", "PillGlyphSize")
    readonly property real _pickerPad: th.pad(th.ct("Reactions", "PickerPadding"))
    readonly property real _optExtent: th.ct("Reactions", "OptionExtent")
    readonly property real _rowGap: th.ct("Reactions", "RowGap")
    readonly property real _colGap: th.ct("Reactions", "ColumnGap")
    readonly property real _addW: th.ct("Reactions", "AddButtonWidth")
    readonly property real _optGlyph: th.ct("Reactions", "OptionGlyphSize")
    implicitWidth: 420
    implicitHeight: _picker && root.pickerOpen ? _pillH + _picker.height + root._rowGap : _pillH
    width: implicitWidth; height: implicitHeight

    Row {
        id: _bar
        spacing: root._colGap
        Repeater {
            model: root.reactions
            delegate: Rectangle {
                required property int index
                required property var modelData
                width: _pillRow.implicitWidth + 2 * root._pad
                height: root._pillH
                radius: root._pillH / 2
                color: modelData.reacted ? th.fade(th.c("Accent"), th.ct("Reactions", "ReactedRingOpacity")) : th.c("SurfaceMuted")
                border.width: th.t4(th.design("EdgeThickness"), 0)
                border.color: modelData.reacted ? th.fade(th.c("Accent"), th.ct("Reactions", "ReactedHoverRingOpacity")) : th.c("Border")
                Row {
                    id: _pillRow
                    anchors.centerIn: parent; spacing: root._gap
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.emoji; font.pixelSize: root._font }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: String(modelData.count); color: th.c("TextSecondary"); font.pixelSize: th.design("TypeXS") }
                }
                MouseArea { anchors.fill: parent; onClicked: root.reacted(index) }
            }
        }
        Rectangle {
            width: root._addW; height: root._pillH
            radius: root._pillH / 2
            color: th.c("SurfaceMuted")
            border.width: th.t4(th.design("EdgeThickness"), 0)
            border.color: th.c("Border")
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: "+"; color: th.c("TextSecondary"); font.pixelSize: th.design("TypeBase") }
            MouseArea { anchors.fill: parent; onClicked: root.pickerOpen = !root.pickerOpen }
        }
    }
    Rectangle {
        id: _picker
        visible: root.pickerOpen
        y: root._pillH + root._rowGap
        width: _optRow.implicitWidth + 2 * root._pickerPad
        height: root._optExtent + 2 * root._pickerPad
        radius: th.t4(th.design("RadiusPanel"), 0)
        color: th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Row {
            id: _optRow
            x: root._pickerPad; y: root._pickerPad; spacing: root._colGap
            Repeater {
                model: root.options
                delegate: Rectangle {
                    required property var modelData
                    width: root._optExtent; height: root._optExtent
                    radius: width / 2
                    color: _m.containsMouse ? th.c("SurfaceMuted") : "transparent"
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: modelData; font.pixelSize: root._optGlyph }
                    MouseArea { id: _m; anchors.fill: parent; hoverEnabled: true; onClicked: { root.added(modelData); root.pickerOpen = false; } }
                }
            }
        }
    }
}
