// arc:KanbanBoard PART_Drawer —— 详情抽屉（移动下一列 / 删除 / 关闭）。
import QtQuick 2.15
import "." as Arc

Rectangle {
    id: root
    property var th: null
    property string cardKey: ""
    property string cardTitle: ""
    property int points: 0
    property string due: ""
    signal moveNext()
    signal remove()
    signal closed()
    anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom
    width: Math.min(root.th.ct("KanbanBoard", "DrawerMaxWidth"), parent.width * 0.42)
    color: root.th.c("SurfaceRaised"); border.width: 1; border.color: root.th.c("Border")
    Column {
        x: 20; y: 20; width: parent.width - 40; spacing: 12
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Card details"; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeLG"); font.weight: root.th.design("WeightMedium") }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.cardKey; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.cardTitle; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); width: parent.width; wrapMode: Text.WordWrap }
        Arc.ArcBadge { th: root.th; text: "In progress"; tone: "info" }
        Item { width: 1; height: 8 }
        Row { spacing: 10; Arc.ArcAvatar { th: root.th; name: "Ada Lovelace"; size: "md"; seed: 2 } Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: String(root.points) + " pt · " + (root.due || "no due date"); color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); anchors.verticalCenter: parent.verticalCenter } }
        Item { width: 1; height: 12 }
        Row {
            spacing: 8
            Arc.ArcButton { th: root.th; text: "Move next"; variant: "secondary"; size: "sm"; onClicked: root.moveNext() }
            Arc.ArcButton { th: root.th; text: "Delete"; variant: "secondary"; size: "sm"; onClicked: root.remove() }
            Arc.ArcButton { th: root.th; text: "Close"; variant: "secondary"; size: "sm"; onClicked: root.closed() }
        }
    }
}
