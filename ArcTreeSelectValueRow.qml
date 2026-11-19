// arc:TreeSelectValueRow —— Selects/TreeSelect/TreeSelectValueRow.cs 真源码移植。
// 收起态：已选 chip（ChipPadding[7,3,7,3] / ChipSpacing5 / ChipMaxWidth144）+ VALUE 占位 + 折角；ValueMinHeight26。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var selected: []
    property bool open: false
    property string placeholder: "Select items"
    signal toggled()

    readonly property real _valMinH: root.th.ct("TreeSelect", "ValueMinHeight")
    readonly property real _chipMax: root.th.ct("TreeSelect", "ChipMaxWidth")
    readonly property real _chipSp: root.th.ct("TreeSelect", "ChipSpacing")
    width: parent ? parent.width : 300
    height: root._valMinH + 4

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root.open ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
    }
    Row {
        x: 6
        anchors.verticalCenter: parent.verticalCenter
        spacing: root._chipSp
        Repeater {
            model: Math.min(2, root.selected.length)
            delegate: Rectangle {
                required property int index
                width: Math.min(root._chipMax, _ct.implicitWidth + 14)
                height: 22
                radius: 11
                color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
                Text {
                    id: _ct
                    x: 7
                    width: parent.width - 14
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: { var s = String(root.selected[index]).split(" / "); return s[s.length - 1]; }
                    color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
            }
        }
        Text {
            visible: root.selected.length === 0
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.placeholder
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
        Text {
            visible: root.selected.length > 2
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: "+" + (root.selected.length - 2)
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
    }
    Arc.ArcIcon {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 14; height: 14
        th: root.th; kind: "ChevronDown"
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        rotation: root.open ? 180 : 0
        Behavior on rotation { NumberAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
    }
    MouseArea { anchors.fill: parent; onClicked: root.toggled() }
}
