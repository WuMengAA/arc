import QtQuick 2.15
import "." as Arc
Item {
    id: root
    property var th: null
    property string label: ""
    property string description: ""
    property string placeholder: "Search…"
    property var options: []            // [{value,label,disabled?}]
    property var value: null
    property string size: "md"          // sm | md | lg
    property bool isOpen: false
    property string query: ""
    signal activated(var value)
    implicitWidth: 260
    implicitHeight: _col.implicitHeight
    readonly property real _h: size === "sm" ? th.design("ControlSizeSM")
                             : (size === "lg" ? th.design("ControlSizeLG") : th.design("ControlSizeMD"))
    readonly property real _padL: th.t4(th.ct("Combobox", "FieldPadding"), 0)
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _optH: th.ct("Combobox", "OptionHeight")
    readonly property real _gap: th.design("Space2")
    readonly property string _valueText: {
        for (var i = 0; i < options.length; i++)
            if (options[i].value === value) return options[i].label;
        return "";
    }
    readonly property var _filtered: {
        var out = [], q = query.toLowerCase();
        for (var j = 0; j < options.length; j++) {
            var o = options[j];
            if (q === "" || String(o.label).toLowerCase().indexOf(q) >= 0) out.push(o);
        }
        return out;
    }
    function pick(o) {
        if (o.disabled === true) return;
        value = o.value; query = ""; isOpen = false; activated(o.value);
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
            height: root._h
            z: root.isOpen ? 100 : 0
            Rectangle {
                id: _frame
                width: root.width
                height: root._h
                radius: root.th.t4(root.th.design("RadiusControl"), 0)
                color: (root.isOpen || _ma.containsMouse) ? root.th.c("SurfaceMuted") : root.th.c("Surface")
                border.width: root._edge
                border.color: root.isOpen ? root.th.c("BorderStrong") : root.th.c("Border")
                MouseArea {
                    id: _ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: { root.isOpen = !root.isOpen; if (root.isOpen) _inp.forceActiveFocus(); }
                }
                Row {
                    anchors.left: parent.left; anchors.leftMargin: root._padL
                    anchors.right: parent.right; anchors.rightMargin: root._padL
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    Arc.ArcIcon {
                        th: root.th; kind: "Search"; width: 16; height: 16
                        color: root.th.c("TextMuted")
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item {
                        width: Math.max(24, parent.width - 16 - 8 - _tail.width - 8)
                        height: root._h
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                            visible: root.isOpen && root.query === ""
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: root.placeholder
                            color: root.th.c("TextMuted")
                            font.pixelSize: root.th.design("TypeSM")
                        }
                        TextInput { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                            id: _inp
                            anchors.fill: parent
                            visible: root.isOpen
                            verticalAlignment: TextInput.AlignVCenter
                            text: root.query
                            color: root.th.c("Foreground")
                            font.pixelSize: root.th.design("TypeSM")
                            selectionColor: root.th.a("subtle")
                            onTextEdited: root.query = text
                        }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                            anchors.fill: parent
                            visible: !root.isOpen
                            verticalAlignment: Text.AlignVCenter
                            text: root._valueText !== "" ? root._valueText : root.placeholder
                            color: root._valueText !== "" ? root.th.c("Foreground") : root.th.c("TextMuted")
                            font.pixelSize: root.th.design("TypeSM")
                            elide: Text.ElideRight
                        }
                    }
                    Row {
                        id: _tail
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        Arc.ArcIcon {
                            visible: root.value !== null
                            th: root.th; kind: "X"; width: 14; height: 14
                            color: root.th.c("TextMuted")
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea { anchors.fill: parent; onClicked: { root.value = null; root.query = ""; } }
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
                y: root._h + root.th.ct("Combobox", "PopoverOffset")
                width: root.width
                height: Math.max(1, root._filtered.length) * root._optH
                        + 2 * root.th.pad(root.th.ct("Combobox", "PopoverPadding"))
                radius: root.th.t4(root.th.ct("Combobox", "OptionCornerRadius"), 0)
                color: root.th.c("SurfaceRaised")
                border.width: root._edge
                border.color: root.th.c("Border")
                Column {
                    x: root.th.pad(root.th.ct("Combobox", "PopoverPadding"))
                    y: x
                    width: parent.width - 2 * x
                    spacing: 2
                    Repeater {
                        model: root._filtered
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: parent.width
                            height: root._optH
                            radius: root.th.t4(root.th.ct("Combobox", "OptionCornerRadius"), 0)
                            color: _optMa.containsMouse ? root.th.c("SurfaceMuted") : "transparent"
                            opacity: modelData.disabled === true
                                     ? root.th.ct("Combobox", "OptionDisabledOpacity") : 1
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                                anchors.left: parent.left
                                anchors.leftMargin: root.th.t4(root.th.ct("Combobox", "OptionPadding"), 0)
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                color: root.th.c("Foreground")
                                font.pixelSize: root.th.design("TypeSM")
                            }
                            Arc.ArcIcon {
                                visible: modelData.value === root.value
                                anchors.right: parent.right; anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                th: root.th; kind: "Check"; width: 16; height: 16
                                color: root.th.a("accent")
                            }
                            MouseArea {
                                id: _optMa
                                anchors.fill: parent; hoverEnabled: true
                                onClicked: root.pick(modelData)
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
