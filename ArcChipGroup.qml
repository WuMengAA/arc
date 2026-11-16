// Selects/ChipGroup —— ChipGroupToken: ChipGap 8 / ChipInlinePadding 14 /
// ChipHeight ControlSizeSM(36)。PART_Panel(ChipGroupPanel) 用 Flow 排布，选中 ControlOn 底。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var options: []      // [{value,label}]
    property string value: ""     // 单选
    property var selected: []     // 多选（multi:true 时）
    property bool multi: false
    signal activated(string value)

    implicitWidth: 360
    implicitHeight: _flow.implicitHeight

    readonly property real _h: th.design("ControlSizeSM")
    readonly property real _px: th.ct("ChipGroup", "ChipInlinePadding")
    readonly property real _gap: th.ct("ChipGroup", "ChipGap")
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)

    function _on(o) { return multi ? selected.indexOf(o.value) >= 0 : value === o.value; }
    function pick(o) {
        if (multi) {
            var t = selected.slice(), k = t.indexOf(o.value);
            if (k >= 0) t.splice(k, 1); else t.push(o.value);
            selected = t;
        } else value = o.value;
        activated(o.value);
    }

    Flow {
        id: _flow
        width: root.width
        height: root._h
        spacing: root._gap
        Repeater {
            model: root.options
            delegate: Rectangle {
                required property var modelData
                required property int index
                width: _ct.implicitWidth + 2 * root._px
                height: root._h
                radius: height / 2
                color: root._on(modelData) ? root.th.c("ControlOn")
                       : (_cMa.containsMouse ? root.th.c("SurfaceMuted") : root.th.c("Surface"))
                border.width: root._on(modelData) ? 0 : root._edge
                border.color: root.th.c("Border")
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    id: _ct
                    anchors.centerIn: parent
                    text: modelData.label
                    color: root._on(modelData) ? root.th.c("ControlGlyph") : root.th.c("Foreground")
                    font.pixelSize: root.th.design("TypeSM")
                    font.weight: root.th.weightMedium
                }
                MouseArea {
                    id: _cMa
                    anchors.fill: parent; hoverEnabled: true
                    onClicked: root.pick(modelData)
                }
            }
        }
    }
}
