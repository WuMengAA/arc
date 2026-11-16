import QtQuick 2.15
import "." as Arc
Item {
    id: root
    property var th: null
    property string label: ""
    property string description: ""
    property string placeholder: "Select tags…"
    property var options: []             // [{value,label,disabled?}]
    property var selected: []            // [value, ...]
    property bool isOpen: false
    signal changed()
    implicitWidth: 300
    implicitHeight: _col.implicitHeight
    readonly property real _h: th.design("ControlSizeMD")
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _optH: th.ct("MultiSelect", "OptionHeight")
    readonly property real _gap: th.design("Space2")
    readonly property real _chipH: th.ct("MultiSelect", "ValueMinHeight")
    readonly property var _chosen: {
        var out = [];
        for (var i = 0; i < options.length; i++)
            if (selected.indexOf(options[i].value) >= 0) out.push(options[i]);
        return out;
    }
    function toggle(v) {
        var t = selected.slice(), k = t.indexOf(v);
        if (k >= 0) t.splice(k, 1); else t.push(v);
        selected = t; changed();
    }
    Column {
        id: _col
        width: root.width
        spacing: root._gap
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.label !== ""
            text: root.label
            color: root.th.c("Foreground")
            font.pixelSize: root.th.design("TypeSM")
            font.weight: root.th.weightMedium
        }
        Item {
            width: root.width
            height: Math.max(root._h, _chips.height + 10)
            z: root.isOpen ? 100 : 0
            Rectangle {
                id: _trig
                width: root.width
                height: parent.height
                radius: root.th.t4(root.th.design("RadiusControl"), 0)
                color: (root.isOpen || _ma.containsMouse) ? root.th.c("SurfaceMuted") : root.th.c("Surface")
                border.width: root._edge
                border.color: root.isOpen ? root.th.c("BorderStrong") : root.th.c("Border")
                MouseArea {
                    id: _ma
                    anchors.fill: parent; hoverEnabled: true
                    onClicked: root.isOpen = !root.isOpen
                }
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: root.th.t4(root.th.ct("MultiSelect", "TriggerPadding"), 0)
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    Flow {
                        id: _chips
                        width: parent.width - _tail.width - 8
                        spacing: root.th.ct("MultiSelect", "ChipSpacing")
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                            visible: root._chosen.length === 0
                            height: root._chipH
                            verticalAlignment: Text.AlignVCenter
                            text: root.placeholder
                            color: root.th.c("TextMuted")
                            font.pixelSize: root.th.design("TypeSM")
                        }
                        Repeater {
                            model: root._chosen
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                width: Math.min(root.th.ct("MultiSelect", "ChipMaxWidth"), _lbl.implicitWidth + 30)
                                height: root._chipH
                                radius: root.th.t4(root.th.ct("MultiSelect", "ClearGlyphRadius"), 0)
                                color: root.th.c("SurfaceRaised")
                                border.width: root._edge
                                border.color: root.th.c("Border")
                                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                                    id: _lbl
                                    anchors.left: parent.left; anchors.leftMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.label
                                    color: root.th.c("Foreground")
                                    font.pixelSize: root.th.design("TypeXS")
                                    elide: Text.ElideRight
                                }
                                Arc.ArcIcon {
                                    anchors.right: parent.right; anchors.rightMargin: 5
                                    anchors.verticalCenter: parent.verticalCenter
                                    th: root.th; kind: "X"; width: 12; height: 12
                                    color: root.th.c("TextMuted")
                                    MouseArea { anchors.fill: parent; onClicked: root.toggle(modelData.value) }
                                }
                            }
                        }
                    }
                    Row {
                        id: _tail
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        Arc.ArcIcon {
                            visible: root.selected.length > 0
                            th: root.th; kind: "X"; width: 14; height: 14
                            color: root.th.c("TextMuted")
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea { anchors.fill: parent; onClicked: { root.selected = []; root.changed(); } }
                        }
                        Arc.ArcIcon {
                            th: root.th; kind: "ChevronDown"; width: 16; height: 16
                            color: root.th.c("TextMuted")
                            rotation: root.isOpen ? 180 : 0
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
            Rectangle {
                visible: root.isOpen
                y: parent.height + root.th.ct("MultiSelect", "MenuOffset")
                width: root.width
                height: root.options.length * root._optH
                        + 2 * root.th.pad(root.th.ct("MultiSelect", "MenuPadding"))
                radius: root.th.t4(root.th.ct("MultiSelect", "OptionCornerRadius"), 0)
                color: root.th.c("SurfaceRaised")
                border.width: root._edge
                border.color: root.th.c("Border")
                Column {
                    x: root.th.pad(root.th.ct("MultiSelect", "MenuPadding")); y: x
                    width: parent.width - 2 * x
                    spacing: 2
                    Repeater {
                        model: root.options
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: parent.width; height: root._optH
                            radius: root.th.t4(root.th.ct("MultiSelect", "OptionCornerRadius"), 0)
                            color: _oMa.containsMouse ? root.th.c("SurfaceMuted") : "transparent"
                            opacity: modelData.disabled === true
                                     ? root.th.ct("MultiSelect", "OptionDisabledOpacity") : 1
                            Rectangle {
                                width: 16; height: 16; radius: 4
                                anchors.left: parent.left
                                anchors.leftMargin: root.th.t4(root.th.ct("MultiSelect", "OptionPadding"), 0)
                                anchors.verticalCenter: parent.verticalCenter
                                color: root.selected.indexOf(modelData.value) >= 0
                                       ? root.th.c("ControlOn") : "transparent"
                                border.width: 1
                                border.color: root.th.c("BorderStrong")
                                Arc.ArcIcon {
                                    visible: root.selected.indexOf(modelData.value) >= 0
                                    anchors.centerIn: parent
                                    th: root.th; kind: "Check"; width: 12; height: 12
                                    color: root.th.c("ControlGlyph")
                                }
                            }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                                anchors.left: parent.left; anchors.leftMargin: 38
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                color: root.th.c("Foreground")
                                font.pixelSize: root.th.design("TypeSM")
                            }
                            MouseArea {
                                id: _oMa
                                anchors.fill: parent; hoverEnabled: true
                                onClicked: if (modelData.disabled !== true) root.toggle(modelData.value)
                            }
                        }
                    }
                }
            }
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.description !== ""
            text: root.description
            color: root.th.c("TextMuted")
            font.pixelSize: root.th.design("TypeXS")
        }
    }
}
