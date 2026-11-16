// arc:RadioGroup —— Toggles/RadioGroup 真源码移植：RadioGroupToken.cs + RadioGroupItemToken.cs +
// RadioGroupTheme.axaml。17px 圆环 + 7px 圆点（选中 ControlOn 底 + ControlGlyph 点）、
// 行内缩 12、行距 8、MarkGap 12、选中描边 GlidingIndicator（HighlightRadius 17.5）。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property string legend: ""
    property var options: []          // [{ value, label, description? }]
    property var value: null
    signal activated(var value)

    readonly property real _legendGap: th.t4(th.ct("RadioGroup", "LegendMargin"), 3)
    readonly property real _rowGap: th.ct("RadioGroup", "RowGap")
    readonly property real _inset: th.t4(th.ct("RadioGroup", "RowInset"), 0)
    readonly property real _markGap: th.ct("RadioGroup", "MarkGap")
    readonly property real _ringD: th.ct("RadioGroup", "RingDiameter")
    readonly property real _ringR: th.t4(th.ct("RadioGroup", "RingRadius"), 0)
    readonly property real _dotD: th.ct("RadioGroup", "DotDiameter")
    readonly property real _dotR: th.t4(th.ct("RadioGroup", "DotRadius"), 0)
    readonly property real _highlightR: th.t4(th.ct("RadioGroup", "HighlightRadius"), 0)
    readonly property real _labelLH: th.ct("RadioGroup", "LabelLineHeight")
    readonly property real _descLH: th.ct("RadioGroup", "DescriptionLineHeight")
    readonly property real _descTop: th.t4(th.ct("RadioGroup", "DescriptionMargin"), 1)
    readonly property real _previewO: th.ct("RadioGroup", "PreviewOpacity")
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _r: th.t4(th.design("RadiusControl"), 0)
    readonly property real _rowH: Math.max(_ringD, _labelLH + (options.some(function(o){return o.description;}) ? _descLH + _descTop : 0)) + 2 * _inset

    width: implicitWidth; height: implicitHeight
    implicitWidth: 360
    implicitHeight: _col.implicitHeight
    opacity: enabled ? 1 : th.ct("RadioGroup", "DisabledOpacity")

    Column {
        id: _col
        width: root.width
        spacing: 0

        // PART_HeaderPresenter
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.legend !== ""
            width: parent.width
            text: root.legend
            color: root.th.c("Foreground")
            font.pixelSize: root.th.design("TypeSM")
            font.weight: root.th.design("WeightMedium")
            bottomPadding: root._legendGap
        }

        Column {
        width: parent.width
        spacing: root._rowGap
        Repeater {
            id: _rep
            model: root.options
            delegate: Item {
                required property var modelData
                required property int index
                readonly property bool _on: modelData.value === root.value
                readonly property bool _hover: ma.containsMouse
                readonly property bool _down: ma.pressed
                width: root.width
                height: root._rowH

                // PART_Row
                Rectangle {
                    anchors.fill: parent
                    radius: root._r
                    color: _hover || _down ? root.th.c("SurfaceMuted") : "transparent"
                    border.width: root._edge
                    border.color: root.th.c("Border")
                }

                // PART_Mark：Ring + Preview + Dot
                Item {
                    id: _mark
                    x: root._inset
                    anchors.verticalCenter: parent.verticalCenter
                    width: root._ringD; height: root._ringD
                    scale: _down ? 0.88 : 1
                    Behavior on scale { NumberAnimation { duration: th.dur("Instant") } }
                    Rectangle {
                        anchors.fill: parent
                        radius: root._ringR
                        color: _on ? root.th.c("ControlOn") : "transparent"
                        border.width: root._edge
                        border.color: _on ? root.th.c("ControlOn") : root.th.c("BorderStrong")
                    }
                    Rectangle {   // pressed 未选中时的预览点
                        anchors.centerIn: parent
                        width: root._dotD; height: root._dotD
                        radius: root._dotR
                        color: root.th.c("Foreground")
                        opacity: _down && !_on ? root._previewO : 0
                    }
                    Rectangle {   // PART_Dot
                        anchors.centerIn: parent
                        width: root._dotD; height: root._dotD
                        radius: root._dotR
                        color: root.th.c("ControlGlyph")
                        opacity: _on ? 1 : 0
                        scale: _on ? 1 : 0.4
                        Behavior on opacity { NumberAnimation { duration: th.dur("Fast") } }
                        Behavior on scale { NumberAnimation { duration: th.dur("Fast"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }
                    }
                }

                // PART_Label + PART_Description
                Column {
                    x: root._inset + root._ringD + root._markGap
                    width: parent.width - x - root._inset
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root._descTop
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        width: parent.width
                        text: modelData.label
                        color: _on ? root.th.c("Foreground") : root.th.c("TextSecondary")
                        font.pixelSize: root.th.design("TypeSM")
                        font.weight: root.th.design("WeightMedium")
                        lineHeight: root._labelLH
                        lineHeightMode: Text.FixedHeight
                        wrapMode: Text.WordWrap
                    }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        visible: modelData.description !== undefined
                        width: parent.width
                        text: modelData.description || ""
                        color: root.th.c("TextMuted")
                        font.pixelSize: root.th.design("TypeXS")
                        lineHeight: root._descLH
                        lineHeightMode: Text.FixedHeight
                        wrapMode: Text.WordWrap
                    }
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: root.enabled
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.value = modelData.value; root.activated(modelData.value); }
                }
            }
        }
        }
    }
}
