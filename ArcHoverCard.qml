// arc:HoverCard —— Overlays/HoverCard + HoverCardProfile 真值移植。
// 触发物 hover 时卡片从 SideOffset 处淡入；PART_Head/Name/Role/Bio/Stats/Meta。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string name: "Ada Lovelace"
    property string role: "Product engineer"
    property string bio: "Writes the design system and the release notes."
    property var stats: []              // [{value, label}]
    property string triggerText: "Hover over me"
    property bool previewOpen: false
    default property alias trigger: _custom.data

    readonly property real _cardW: th.ct("HoverCard", "CardWidth")
    readonly property real _pad: th.pad(th.ct("HoverCard", "CardPadding"))
    readonly property real _off: th.ct("HoverCard", "SideOffset")
    readonly property real _headGap: th.ct("HoverCardProfile", "HeadGap")
    readonly property real _rowGap: th.ct("HoverCardProfile", "RowGap")
    readonly property real _statGap: th.ct("HoverCardProfile", "StatColumnGap")
    readonly property real _statsPad: th.t4(th.ct("HoverCardProfile", "StatsPadding"), 1)
    implicitWidth: 300; implicitHeight: 210
    width: implicitWidth; height: implicitHeight

    Item {
        id: _triggerHost
        width: root.width; height: 44
        Item { id: _custom; anchors.fill: parent }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: !_custom.children.length
            anchors.verticalCenter: parent.verticalCenter
            text: root.triggerText
            color: th.c("AccentStrong")
            font.pixelSize: th.design("TypeSM")
            font.underline: true
        }
        MouseArea { id: _ma; anchors.fill: parent; hoverEnabled: true }
    }
    Rectangle {
        id: _card
        x: Math.min(root._off, root.width - root._cardW)
        y: 50
        width: root._cardW
        height: _col.implicitHeight + 2 * root._pad
        visible: root.previewOpen || _ma.containsMouse
        radius: th.t4(th.design("RadiusPanel"), 0)
        color: th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Column {
            id: _col
            x: root._pad; y: root._pad
            width: parent.width - 2 * root._pad
            spacing: root._headGap
            Arc.ArcAvatar { th: root.th; name: root.name; size: "lg" }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.name; color: th.c("Foreground"); font.pixelSize: th.design("TypeBase"); font.weight: th.design("WeightMedium") }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.role; color: th.c("TextSecondary"); font.pixelSize: th.design("TypeSM") }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.bio; width: parent.width; wrapMode: Text.WordWrap; color: th.c("TextMuted"); font.pixelSize: th.design("TypeXS") }
            Row {
                spacing: root._statGap
                topPadding: root._statsPad
                Repeater {
                    model: root.stats
                    delegate: Column {
                        required property var modelData
                        spacing: root._rowGap
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.value; color: th.c("Foreground"); font.pixelSize: th.design("TypeBase"); font.weight: th.design("WeightMedium") }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.label; color: th.c("TextMuted"); font.pixelSize: th.design("TypeXS") }
                    }
                }
            }
        }
    }
}
