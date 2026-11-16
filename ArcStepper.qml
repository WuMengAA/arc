// arc:Stepper —— Progress/Stepper 真源码移植：StepperToken.cs + StepperTheme.axaml + StepperMarker.cs。
// 28px 圆盘（DiscSize=28）+ 4px 光晕（Halo=4）；状态 Complete/Current/Error/Upcoming 决定
// 圆盘/描边/字形（Number 12 Medium / Check "M5.5 12.5l4.25 4.25L18.5 8" / Error 叹号）。
// 水平排布：StepGapHorizontal [0,0,16,0] + 项间连接轨；错误态用 Stepper.ErrorDisc/ErrorHalo。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var steps: []           // [{ label, detail, status?:"complete|current|error|upcoming" }]
    property int currentIndex: 0
    property string captionLabel: ""
    property string captionDetail: ""
    property bool captionVisible: false
    signal stepActivated(int index)

    readonly property real _disc: 28
    readonly property real _halo: 4
    readonly property real _stepGap: th.t4(th.ct("Stepper", "StepGapHorizontal"), 2)
    readonly property real _markerGap: th.t4(th.ct("Stepper", "MarkerGapHorizontal"), 3)
    readonly property real _labelLH: th.ct("Stepper", "LabelLineHeight")
    readonly property real _detailLH: th.ct("Stepper", "DetailLineHeight")
    readonly property real _detailTop: th.t4(th.ct("Stepper", "DetailMargin"), 1)
    readonly property real _captionTop: th.t4(th.ct("Stepper", "CaptionMargin"), 1)
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)

    function _status(i, s) {
        if (s && s.status) return s.status;
        return i < currentIndex ? "complete" : (i === currentIndex ? "current" : "upcoming");
    }

    width: implicitWidth; height: implicitHeight
    implicitWidth: 560
    implicitHeight: _col.implicitHeight

    Column {
        id: _col
        width: root.width
        spacing: 0

        Row {
            width: parent.width
            spacing: root._stepGap
            Repeater {
                model: root.steps
                delegate: Item {
                    required property var modelData
                    required property int index
                    readonly property string _st: root._status(index, modelData)
                    readonly property bool _last: index === root.steps.length - 1
                    readonly property color _rim: _st === "complete" ? root.th.c("Accent")
                        : _st === "current" ? root.th.c("Accent")
                        : _st === "error" ? root.th.ct("Stepper", "ErrorDiscHover")
                        : root.th.c("BorderStrong")
                    readonly property color _fill: _st === "complete" ? root.th.c("Accent")
                        : _st === "error" ? root.th.ct("Stepper", "ErrorDisc")
                        : root.th.c("Surface")
                    readonly property color _glyph: _st === "complete" ? root.th.c("AccentForeground")
                        : _st === "error" ? root.th.c("Danger")
                        : _st === "current" ? root.th.c("Foreground")
                        : root.th.c("TextMuted")
                    width: Math.max(88, (root.width - (root.steps.length - 1) * root._stepGap) / root.steps.length)
                    height: _cell.implicitHeight

                    // 连接轨（从本圆盘右缘到下个圆盘左缘）
                    Rectangle {
                        visible: !_last
                        x: root._disc + 2
                        y: root._halo + root._disc / 2 - root._edge / 2
                        width: parent.width - root._disc - 4 + root._stepGap
                        height: root._edge
                        color: root.th.c("Border")
                    }

                    Column {
                        id: _cell
                        width: parent.width
                        spacing: root._markerGap

                        // PART_Marker：光晕 + 圆盘 + 字形
                        Item {
                            width: root._disc + 2 * root._halo
                            height: root._disc + 2 * root._halo
                            Rectangle {
                                anchors.centerIn: parent
                                width: root._disc + 2 * root._halo; height: root._disc + 2 * root._halo
                                radius: width / 2
                                color: _st === "error" ? root.th.ct("Stepper", "ErrorHalo")
                                    : (_st === "current" || _st === "complete") ? root.th.c("AccentSubtle")
                                    : "transparent"
                                opacity: _st === "upcoming" ? 0 : 1
                            }
                            Rectangle {
                                anchors.centerIn: parent
                                width: root._disc; height: root._disc
                                radius: root._disc / 2
                                color: _fill
                                border.width: _st === "current" ? 1.5 : root._edge
                                border.color: _rim
                            }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                                visible: _st === "upcoming" || _st === "current"
                                anchors.centerIn: parent
                                text: index + 1
                                color: _glyph
                                font.pixelSize: 15
                                font.weight: root.th.design("WeightMedium")
                            }
                            Image {
                                visible: _st === "complete"
                                anchors.centerIn: parent
                                width: 16; height: 16
                                sourceSize.width: 32; sourceSize.height: 32
                                source: "data:image/svg+xml;utf8," + encodeURIComponent(
                                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="' +
                                    _glyph + '" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">' +
                                    '<path d="M5.5 12.5l4.25 4.25L18.5 8"/></svg>')
                            }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                                visible: _st === "error"
                                anchors.centerIn: parent
                                text: "!"
                                color: _glyph
                                font.pixelSize: 18
                                font.weight: root.th.design("WeightMedium")
                            }
                        }

                        // PART_Label + PART_Detail
                        Column {
                            width: parent.width
                            spacing: root._detailTop
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                                width: parent.width
                                text: modelData.label
                                color: _st === "upcoming" ? root.th.c("TextMuted") : root.th.c("Foreground")
                                font.pixelSize: root.th.design("TypeSM")
                                font.weight: root.th.design("WeightMedium")
                                lineHeight: root._labelLH
                                lineHeightMode: Text.FixedHeight
                                wrapMode: Text.WordWrap
                            }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                                visible: modelData.detail !== undefined
                                width: parent.width
                                text: modelData.detail || ""
                                color: root.th.c("TextMuted")
                                font.pixelSize: root.th.design("TypeXS")
                                lineHeight: root._detailLH
                                lineHeightMode: Text.FixedHeight
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.stepActivated(index)
                    }
                }
            }
        }

        // PART_Caption
        Column {
            visible: root.captionVisible
            width: parent.width
            topPadding: root._captionTop
            spacing: root._detailTop
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                width: parent.width
                text: root.captionLabel
                color: root.th.c("Foreground")
                font.pixelSize: root.th.design("TypeSM")
                font.weight: root.th.design("WeightMedium")
                lineHeight: root._labelLH
                lineHeightMode: Text.FixedHeight
                wrapMode: Text.WordWrap
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                width: parent.width
                text: root.captionDetail
                color: root.th.c("TextMuted")
                font.pixelSize: root.th.design("TypeXS")
                lineHeight: root._detailLH
                lineHeightMode: Text.FixedHeight
                wrapMode: Text.WordWrap
            }
        }
    }
}
