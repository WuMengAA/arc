// arc:Select —— Selects/Select/SelectTheme.axaml + SelectToken.cs 真值移植。
// Trigger(44/36/50) + Chevron(open 转 180) + Popup 菜单（Option 36 / 圆角 14 / IndicatorInset 10）。
import QtQuick 2.15

Item {
    id: root

    property var th: null
    property string label: ""
    property string description: ""
    property string placeholder: "Select…"
    property var options: []           // [{value,label,disabled?}]
    property var value: null
    property string size: "md"        // ControlSize sm/md/lg
    property bool isOpen: false
    signal activated(var value)

    readonly property real _h: size === "sm" ? th.design("ControlSizeSM") : (size === "lg" ? th.design("ControlSizeLG") : th.design("ControlSizeMD"))
    readonly property real _padL: th.t4(th.ct("Select", "TriggerPadding"), 0)
    readonly property real _padR: th.t4(th.ct("Select", "TriggerPadding"), 2)
    readonly property string _valueText: {
        for (var i = 0; i < options.length; i++)
            if (options[i].value === value) return options[i].label;
        return "";
    }
    readonly property color _bd: !enabled ? th.c("Border")
        : (isOpen || _ma.pressed || _ma.containsMouse ? th.c("BorderStrong") : th.c("Border"))
    readonly property color _bg: (isOpen || _ma.pressed || _ma.containsMouse) ? th.c("SurfaceMuted") : th.c("Surface")

    width: implicitWidth
    height: implicitHeight
    implicitWidth: Math.max(180, _col.implicitWidth)
    implicitHeight: _col.implicitHeight
    opacity: enabled ? 1 : th.ct("Select", "DisabledOpacity")
    z: isOpen ? 10 : 0

    Column {
        id: _col
        width: root.width
        spacing: th.design("Space2")

        // PART_Label
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.label !== ""
            width: parent.width
            text: root.label
            color: root.th.c("Foreground")
            font.pixelSize: root.th.design("TypeSM")
            font.weight: root.th.design("WeightMedium")
        }

        // PART_Trigger
        Item {
            id: _triggerHost
            width: parent.width
            height: root._h

            Rectangle {
                id: _trigger
                anchors.fill: parent
                radius: th.t4(root.th.design("RadiusControl"), 0)
                color: root._bg
                border.width: th.t4(root.th.design("EdgeThickness"), 0)
                border.color: root._bd
                Behavior on color { ColorAnimation { duration: th.dur("Instant") } }
                Behavior on border.color { ColorAnimation { duration: th.dur("Instant") } }

                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    x: root._padL
                    width: parent.width - root._padL - root._padR - 22
                    anchors.verticalCenter: parent.verticalCenter
                    text: root._valueText !== "" ? root._valueText : root.placeholder
                    color: root._valueText !== "" ? root.th.c("Foreground") : root.th.c("TextMuted")
                    font.pixelSize: root.th.design("TypeSM")
                    elide: Text.ElideRight
                    clip: true
                }

                ArcIcon {
                    anchors.right: parent.right
                    anchors.rightMargin: root._padR
                    anchors.verticalCenter: parent.verticalCenter
                    th: root.th
                    kind: "ChevronDown"
                    width: 16; height: 16
                    color: root.th.c("TextMuted")
                    rotation: root.isOpen ? 180 : 0
                    Behavior on rotation { NumberAnimation { duration: th.dur("Exit"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }
                }
            }

            MouseArea {
                id: _ma
                anchors.fill: parent
                hoverEnabled: true
                enabled: root.enabled
                cursorShape: Qt.PointingHandCursor
                onClicked: root.isOpen = !root.isOpen
            }
        }

        // PART_Description
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.description !== ""
            width: parent.width
            text: root.description
            color: root.th.c("TextMuted")
            font.pixelSize: root.th.design("TypeXS")
            wrapMode: Text.Wrap
        }
    }

    // PART_Popup：菜单浮层（MenuCornerRadius 20 / MenuPadding 6 / ViewportPadding [0,2,0,2]）
    Rectangle {
        id: _menu
        visible: root.isOpen
        y: _triggerHost.y + root._h + 4
        width: root.width
        height: Math.min(_opts.implicitHeight + th.t4(root.th.ct("Select", "MenuPadding"), 1) * 2 + th.t4(root.th.ct("Select", "ViewportPadding"), 1) * 2, 240)
        radius: th.t4(root.th.ct("Select", "MenuCornerRadius"), 0)
        color: root.th.c("Surface")
        border.width: th.t4(root.th.design("EdgeThickness"), 0)
        border.color: root.th.c("Border")
        clip: true
        Column {
            id: _opts
            x: th.t4(root.th.ct("Select", "MenuPadding"), 0)
            y: th.t4(root.th.ct("Select", "MenuPadding"), 1)
            width: parent.width - th.t4(root.th.ct("Select", "MenuPadding"), 0) * 2
            spacing: 0
            Repeater {
                model: root.options
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    readonly property bool _on: modelData.value === root.value
                    readonly property bool _off: modelData.disabled === true
                    width: _opts.width
                    height: th.ct("Select", "OptionHeight")
                    radius: th.t4(root.th.ct("Select", "OptionCornerRadius"), 0)
                    color: _on ? root.th.c("SurfaceMuted") : "transparent"
                    opacity: _off ? th.ct("Select", "OptionDisabledOpacity") : 1
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        x: th.t4(root.th.ct("Select", "OptionPadding"), 0)
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label
                        color: root.th.c("Foreground")
                        font.pixelSize: root.th.design("TypeSM")
                    }
                    ArcIcon {
                        visible: _on
                        anchors.right: parent.right
                        anchors.rightMargin: th.ct("Select", "IndicatorInset")
                        anchors.verticalCenter: parent.verticalCenter
                        th: root.th
                        kind: "Check"
                        width: 16; height: 16
                        color: root.th.a("accent")
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: !_off
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.value = modelData.value;
                            root.isOpen = false;
                            root.activated(modelData.value);
                        }
                    }
                }
            }
        }
    }
}
