// arc:ExpandableCard —— Expand/ExpandableCard 真值：TriggerMinHeight 64 / TriggerPadding [20,16] /
// ChevronSize 18 / DescriptionMargin [0,4,0,0] / DetailsDivider 顶 1px / DetailsPadding [20,16,20,20]。
// 点击展开/收起：details 高度弹簧 + chevron 旋转，全走 th.dur("Standard") + th.ease("Standard")。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property string title: ""
    property string description: ""
    property bool expanded: false
    default property alias details: _details.data
    readonly property real _padL: th.t4(th.ct("ExpandableCard", "TriggerPadding"), 0)
    readonly property real _padT: th.t4(th.ct("ExpandableCard", "TriggerPadding"), 1)
    readonly property real _minH: th.ct("ExpandableCard", "TriggerMinHeight")
    readonly property real _chev: th.ct("ExpandableCard", "ChevronSize")
    readonly property real _descM: th.t4(th.ct("ExpandableCard", "DescriptionMargin"), 1)
    readonly property real _dPadL: th.t4(th.ct("ExpandableCard", "DetailsPadding"), 0)
    readonly property real _dPadT: th.t4(th.ct("ExpandableCard", "DetailsPadding"), 1)
    readonly property real _dPadB: th.t4(th.ct("ExpandableCard", "DetailsPadding"), 3)
    readonly property real _div: th.t4(th.ct("ExpandableCard", "DetailsDivider"), 1)
    width: 420; height: Math.max(root._minH, _card.implicitHeight)
    Rectangle {
        id: _card
        width: parent.width; height: _col.implicitHeight
        radius: th.t4(th.design("RadiusSurface"), 0)
        color: th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0); border.color: th.c("Border")
        clip: true
        Column {
            id: _col
            width: parent.width; spacing: 0
            Item {
                width: parent.width; height: Math.max(root._minH, _head.implicitHeight + 2 * root._padT)
                Column {
                    id: _head
                    x: root._padL; y: root._padT; width: parent.width - 2 * root._padL; spacing: 0
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.title; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  visible: root.description !== ""; y: root._descM; text: root.description; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS") }
                }
                ArcIcon {
                    anchors.right: parent.right; anchors.rightMargin: root._padL
                    anchors.verticalCenter: parent.verticalCenter
                    th: root.th; kind: "ChevronDown"; width: root._chev; height: root._chev
                    strokeWidth: 1.75; color: root.th.c("TextMuted")
                    rotation: root.expanded ? 180 : 0
                    Behavior on rotation { NumberAnimation { duration: root.th.dur("Standard"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.expanded = !root.expanded }
            }
            Item {
                id: _fold
                width: parent.width
                height: root.expanded ? _details.implicitHeight + root._dPadT + root._dPadB + root._div : 0
                clip: true
                Behavior on height { NumberAnimation { duration: root.th.dur("Standard"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
                Rectangle { width: parent.width; height: root._div; color: root.th.c("Border") }
                Column {
                    id: _details
                    x: root._dPadL; y: root._div + root._dPadT
                    width: parent.width - 2 * root._dPadL; spacing: 8
                }
            }
        }
    }
}
