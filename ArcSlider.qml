// arc:Slider —— Sliders/Slider/SliderTheme.axaml + SliderToken.cs 真值移植。
// Header(Label+Readout) + Rail(Track/Fill/Tick/Thumb/Bubble/Marks)，几何全走 th.ct("Slider",...)。
import QtQuick 2.15

Item {
    id: root

    property var th: null
    property string label: ""
    property real value: 50
    property real min: 0
    property real max: 100
    property bool isValueVisible: true
    property var marks: []           // [{value,label}] 可选刻度标签
    signal valueChangedByUser(real value)

    readonly property real _thumb: th.ct("Slider", "ThumbDiameter")
    readonly property real _thick: th.ct("Slider", "TrackThickness")
    readonly property real _tick: th.ct("Slider", "TickDiameter")
    readonly property real _railH: Math.max(th.ct("Slider", "RailMinHeight"), th.design("ControlSizeMD"))
    readonly property real _half: _thumb / 2
    readonly property real _frac: max > min ? Math.max(0, Math.min(1, (value - min) / (max - min))) : 0
    readonly property real _bubbleGap: th.ct("Slider", "BubbleGap")
    readonly property real _bubbleMinH: th.ct("Slider", "BubbleMinHeight")
    readonly property bool _headerVisible: label !== "" || isValueVisible

    width: implicitWidth
    height: implicitHeight
    implicitWidth: 260
    implicitHeight: _col.implicitHeight
    opacity: enabled ? 1 : th.ct("Slider", "DisabledOpacity")

    Column {
        id: _col
        width: root.width
        spacing: 0

        // PART_Header：Label(WeightMedium) 左 + Readout(TextSecondary) 右
        Item {
            visible: root._headerVisible
            width: parent.width
            height: visible ? th.ct("Slider", "LabelLineHeight") : 0
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.label
                color: root.th.c("Foreground")
                font.pixelSize: root.th.design("TypeSM")
                font.weight: root.th.design("WeightMedium")
                lineHeight: root.th.ct("Slider", "LabelLineHeight")
                lineHeightMode: Text.FixedHeight
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                visible: root.isValueVisible
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(root.value).toString()
                color: root.th.c("TextSecondary")
                font.pixelSize: root.th.design("TypeSM")
            }
        }

        // PART_Rail 行：Start / Rail / End（此处省略外部内容，仅 Rail）
        Item {
            width: parent.width
            height: root._railH

            // Track + Fill + Ticks
            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: root._half
                anchors.rightMargin: root._half
                anchors.verticalCenter: parent.verticalCenter
                height: root._thick

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: root.th.c("ControlTrack")
                }
                Rectangle {
                    width: parent.width * root._frac
                    height: parent.height
                    radius: height / 2
                    color: root.th.c("ControlFill")
                }
                Repeater {
                    model: root.marks
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        x: parent.width * (root.max > root.min ? (modelData.value - root.min) / (root.max - root.min) : 0) - width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        width: root._tick; height: root._tick
                        radius: root._tick / 2
                        color: root.th.ct("Slider", "TickColor")
                    }
                }
            }

            // PART_Thumb：22 圆，ControlThumb 底 + FocusRing 描边（拖动放大）
            Rectangle {
                id: _knob
                x: root._half + (root.width - root._thumb) * root._frac
                anchors.verticalCenter: parent.verticalCenter
                width: root._thumb; height: root._thumb
                radius: root._thumb / 2
                color: root.th.c("ControlThumb")
                border.width: dragArea.pressed ? 2 : 1
                border.color: root.th.c("FocusRing")
                scale: dragArea.pressed ? 1.16 : 1
                Behavior on scale { NumberAnimation { duration: th.dur("Fast") } }

                // Bubble：拖动时在拇指上方显示数值（底 Foreground / 字 Background）
                Rectangle {
                    visible: dragArea.pressed
                    anchors.bottom: parent.top
                    anchors.bottomMargin: root._bubbleGap
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.max(_bt.implicitWidth + th.t4(root.th.ct("Slider", "BubbleInset"), 0) * 2, _bubbleMinH)
                    height: root._bubbleMinH
                    radius: root.th.t4(root.th.design("RadiusControl"), 0) - 4
                    color: root.th.c("Foreground")
                    border.width: th.t4(root.th.ct("Slider", "BubbleBorder"), 0)
                    border.color: root.th.ct("Slider", "BubbleBorderColor")
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        id: _bt
                        anchors.centerIn: parent
                        text: Math.round(root.value).toString()
                        color: root.th.c("Background")
                        font.pixelSize: root.th.design("TypeXS")
                        font.weight: root.th.design("WeightMedium")
                    }
                }
            }

            // 整行接管按压；按 x 反算 value
            MouseArea {
                id: dragArea
                anchors.fill: parent
                enabled: root.enabled
                cursorShape: Qt.PointingHandCursor
                preventStealing: true   // 拖滑块不滚页面
                function setFromX(mx) {
                    var f = Math.max(0, Math.min(1, (mx - root._half) / (root.width - root._thumb)));
                    var v = root.min + f * (root.max - root.min);
                    root.value = v;
                    root.valueChangedByUser(v);
                }
                onPressed: setFromX(mouseX)
                onPositionChanged: if (pressed) setFromX(mouseX)
            }
        }

        // PART_Marks：刻度文字（TextMuted，MarksHeight 20 / MarksMargin [0,-4,0,0]）
        Item {
            visible: root.marks.length > 0
            width: parent.width
            height: visible ? th.ct("Slider", "MarksHeight") : 0
            Repeater {
                model: root.marks
                delegate: Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    required property var modelData
                    required property int index
                    x: root._half + (root.width - root._thumb) * (root.max > root.min ? (modelData.value - root.min) / (root.max - root.min) : 0) - implicitWidth / 2
                    y: th.t4(root.th.ct("Slider", "MarksMargin"), 1)
                    text: modelData.label
                    color: root.th.c("TextMuted")
                    font.pixelSize: root.th.design("TypeXS")
                }
            }
        }
    }
}
