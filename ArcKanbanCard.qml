// arc:KanbanBoard PART_Card —— 官方展示帧真值：编号 FLD-xxx / label 点 / 粗体标题 /
// 日历 Mar 14 + checklist 2/4 + 5 pt + 负责人头像。数据模板 SampleBoard.cs。
// 交互：单击 invoked()；按住超过 4px 触发 dragBegun/dragMoved/dragEnded（board 用浮层代理搬运）。
import QtQuick 2.15
import "." as Arc

Rectangle {
    id: root
    property var th: null
    property var card: ({})
    property var people: ({})
    property var labels: ({})
    property bool dragging: false
    property bool dragEnabled: false
    property bool dimmed: false
    signal invoked()
    signal dragBegun()
    signal dragMoved(real dx, real dy)
    signal dragEnded()
    readonly property var _label: root.labels[root.card.label || ""] || { name: root.card.tag || "Task", tone: "neutral" }
    readonly property var _person: root.people[root.card.owner || ""] || { initials: (root.card.who || "??").slice(0, 2).toUpperCase() }
    readonly property real _pad: root.th.pad(root.th.ct("KanbanBoard", "CardInset"))
    readonly property real _metaH: root.th.ct("KanbanBoard", "CardMetaHeight")
    width: 300; height: 132
    radius: root.th.pad(root.th.ct("KanbanBoard", "CardRadius"))
    color: root.th.c("Surface")
    border.width: root.th.t4(root.th.design("EdgeThickness"), 0)
    border.color: root.dragging ? root.th.a("accent") : root.th.c("Border")
    opacity: root.dimmed ? 0.35 : 1
    Behavior on opacity { NumberAnimation { duration: root.th.dur("Fast") } }

    Column {
        x: root._pad; y: root._pad; width: parent.width - 2 * root._pad; spacing: 7
        Row {
            width: parent.width
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.card.key || ""; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS"); anchors.verticalCenter: parent.verticalCenter }
            Item { width: 1; height: 1 }
            Item { width: Math.max(0, parent.width - 140); height: 1 }
            Rectangle {
                width: _lbl.implicitWidth + 14; height: 20; radius: 10
                color: root.th.fade(root.th.a("accent"), 0.08)
                Row {
                    anchors.centerIn: parent; spacing: 5
                    Rectangle { width: 6; height: 6; radius: 3; color: root._label.tone === "warning" ? root.th.c("Warning") : root._label.tone === "success" ? root.th.c("Success") : root.th.c("AccentStrong"); anchors.verticalCenter: parent.verticalCenter }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  id: _lbl; text: root._label.name; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS"); anchors.verticalCenter: parent.verticalCenter }
                }
            }
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            width: parent.width; text: root.card.title || ""
            color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium")
            wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight
        }
        Row {
            width: parent.width; height: root._metaH; spacing: 10
            Row {
                visible: (root.card.due || "") !== ""; spacing: 4; anchors.verticalCenter: parent.verticalCenter
                Arc.ArcIcon { th: root.th; kind: "Calendar"; width: 12; height: 12; color: root.th.c("TextMuted"); anchors.verticalCenter: parent.verticalCenter }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.card.due || ""; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS"); anchors.verticalCenter: parent.verticalCenter }
            }
            Row {
                visible: (root.card.steps || "") !== ""; spacing: 4; anchors.verticalCenter: parent.verticalCenter
                Arc.ArcIcon { th: root.th; kind: "ListChecks"; width: 12; height: 12; color: root.th.c("TextMuted"); anchors.verticalCenter: parent.verticalCenter }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.card.steps || ""; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS"); anchors.verticalCenter: parent.verticalCenter }
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: (root.card.points || 0) + " pt"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS"); anchors.verticalCenter: parent.verticalCenter }
            Item { width: Math.max(0, parent.width - 170); height: 1 }
            Rectangle {
                width: 24; height: 24; radius: 12; anchors.verticalCenter: parent.verticalCenter
                color: root.th.fade(root.th.series(root.card.seed === undefined ? 3 : root.card.seed), 0.22)
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: root._person.initials; color: root.th.series(root.card.seed === undefined ? 3 : root.card.seed); font.pixelSize: root.th.design("TypeXS"); font.weight: root.th.design("WeightMedium") }
            }
        }
    }
    Rectangle {
        visible: root.dragging; anchors.fill: parent; radius: root.radius
        color: "transparent"; border.width: 2; border.color: root.th.a("accent")
        Rectangle { anchors.right: parent.right; anchors.bottom: parent.bottom; width: 8; height: 8; color: root.th.a("accent") }
    }
    MouseArea {
        id: _ma
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.dragging
        cursorShape: root.dragEnabled ? Qt.OpenHandCursor : Qt.PointingHandCursor
        preventStealing: true   // 拖卡片时父级 Flickable 不许抢 grab
        property real _sx: 0
        property real _sy: 0
        property bool _moved: false
        onPressed: { _sx = mouseX; _sy = mouseY; _moved = false; }
        onPositionChanged: {
            if (!_ma.pressed || !root.dragEnabled) return;
            var dx = mouseX - _sx, dy = mouseY - _sy;
            if (Math.abs(dx) > 4 || Math.abs(dy) > 4) {
                if (!_moved) { _moved = true; root.dragBegun(); }
                root.dragMoved(dx, dy);
            }
        }
        onReleased: if (_moved) root.dragEnded();
        onClicked: if (!_moved) root.invoked();
    }
}
