// arc:Accordion —— Expand/Accordion 真源码移植：AccordionToken.cs + AccordionItemToken.cs +
// Accordion(Item)Theme.axaml。列表顶 1px 细线（ListBorderThickness）、每行底 1px 细线（RowBorderThickness）、
// Trigger 高 ControlSizeLG / 行高 TriggerLineHeight、ChevronDown 展开转 180°、答案区 AnswerPadding。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var items: []           // [{ header, answer }]
    property int expandedIndex: 0
    property bool large: false
    signal toggled(int index)

    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _trigPadV: th.t4(th.ct("AccordionItem", large ? "TriggerPaddingLG" : "TriggerPadding"), 1)
    readonly property real _trigH: Math.max(large ? th.ct("AccordionItem", "TriggerMinHeightLG") : th.design("ControlSizeLG"),
                                            _trigLH + 2 * _trigPadV)
    readonly property real _trigLH: th.ct("AccordionItem", large ? "TriggerLineHeightLG" : "TriggerLineHeight")
    readonly property real _chev: th.ct("AccordionItem", "ChevronSize")
    readonly property real _chevGap: th.t4(th.ct("AccordionItem", large ? "ChevronMarginLG" : "ChevronMargin"), 0)
    readonly property real _ansPadR: th.t4(th.ct("AccordionItem", large ? "AnswerPaddingLG" : "AnswerPadding"), 2)
    readonly property real _ansPadB: th.t4(th.ct("AccordionItem", large ? "AnswerPaddingLG" : "AnswerPadding"), 3)
    readonly property real _ansLH: th.ct("AccordionItem", large ? "AnswerLineHeightLG" : "AnswerLineHeight")
    readonly property real _ansMax: th.ct("AccordionItem", "AnswerMaxWidthLG")

    width: implicitWidth; height: implicitHeight
    implicitWidth: 560
    implicitHeight: _col.implicitHeight

    Column {
        id: _col
        width: root.width
        spacing: 0

        // 列表顶 1px 细线
        Rectangle {
            width: parent.width; height: root._edge
            color: root.th.c("Border")
        }

        Repeater {
            model: root.items
            delegate: Item {
                required property var modelData
                required property int index
                readonly property bool _open: root.expandedIndex === index
                readonly property real _ansW: Math.min(_ansTxt.implicitWidth + root._ansPadR,
                    root.large ? root._ansMax : root.width)
                readonly property real _ansH: _open ? _ansTxt.implicitHeight + root._ansPadB : 0
                width: root.width
                height: root._trigH + _ansH + root._edge

                // PART_Trigger
                Item {
                    width: parent.width; height: root._trigH
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - root._chev - root._chevGap
                        text: modelData.header
                        color: root.th.c("Foreground")
                        font.pixelSize: root.th.design(root.large ? "TypeLG" : "TypeSM")
                        font.weight: root.th.design("WeightMedium")
                        lineHeight: root._trigLH
                        lineHeightMode: Text.FixedHeight
                        wrapMode: Text.WordWrap
                    }
                    Arc.ArcIcon {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: root._chev; height: root._chev
                        th: root.th
                        kind: "ChevronDown"
                        strokeWidth: 2
                        color: root.th.c(_open ? "Foreground" : "TextMuted")
                        rotation: _open ? 180 : 0
                        Behavior on rotation { NumberAnimation { duration: th.dur("Exit"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.expandedIndex = _open ? -1 : index; root.toggled(index); }
                    }
                }

                // PART_Answer（展开时才占高，避免空答案撑出空白）
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    id: _ansTxt
                    visible: _open
                    x: 0; y: root._trigH
                    width: Math.min(parent.width - root._ansPadR, root.large ? root._ansMax : parent.width)
                    text: modelData.answer
                    color: root.th.c("TextSecondary")
                    font.pixelSize: root.th.design(root.large ? "TypeBase" : "TypeSM")
                    lineHeight: root._ansLH
                    lineHeightMode: Text.FixedHeight
                    wrapMode: Text.WordWrap
                }

                // 行底 1px 细线
                Rectangle {
                    y: parent.height - root._edge
                    width: parent.width; height: root._edge
                    color: root.th.c("Border")
                }
            }
        }
    }
}
