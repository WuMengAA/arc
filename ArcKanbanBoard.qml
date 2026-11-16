// arc:KanbanBoard —— 官方帧 "Field app 4.2 · 13 cards" 的可交互移植。
// 数据 SampleBoard.cs（4 列 / 4 人 / 4 标签 / 13 卡）。真行为：卡片跨列拖拽、Status/By person
// 重组、点击开详情抽屉、加卡/移动/删除，全部改内存模型并经 _rev 触发重绘（无网络无 JSON）。
import QtQuick 2.15
import "." as Arc
import "ArcShowcaseData.js" as Showcase
Rectangle {
    id: root
    property var th: null
    property var showcase: Showcase.ArcShowcase.board
    property string openedKey: ""
    signal cardInvoked(string key)
    readonly property real _toolT: th.t4(th.ct("KanbanBoard", "ToolbarPadding"), 1)
    readonly property real _toolL: th.t4(th.ct("KanbanBoard", "ToolbarPadding"), 0)
    readonly property real _colW: Math.max(160, (root.width - 2 * root._toolL - 3 * root._gap - 8) / 4)
    readonly property real _gap: th.ct("KanbanBoard", "CardRowGap")
    property string _view: "status"
    property int _rev: 0
    property bool _dragActive: false
    property string _dragKey: ""
    property real _dragX: 0
    property real _dragY: 0
    property real _dragSX: 0
    property real _dragSY: 0
    property var _cards: {
        var out = [];
        var cs = root.showcase && root.showcase.columns ? root.showcase.columns : [];
        for (var i = 0; i < cs.length; i++) {
            var list = cs[i].cards || [];
            for (var j = 0; j < list.length; j++) {
                var c = list[j];
                out.push({ key: c.key, label: c.label, title: c.title, owner: c.owner, points: c.points, due: c.due, steps: c.steps, seed: c.seed === undefined ? i : c.seed, lane: cs[i].key });
            }
        }
        return out;
    }
    width: 1100; height: 640; radius: th.t4(th.design("RadiusPanel"), 0); color: th.c("Surface"); clip: true
    border.width: th.t4(th.design("EdgeThickness"), 0); border.color: th.c("Border")
    function _touch() { root._rev = root._rev + 1; }
    function _columnsFor() {
        var defs = [];
        if (root._view === "person") {
            var p = root.showcase && root.showcase.people ? root.showcase.people : {};
            for (var k in p) defs.push({ key: k, name: String(p[k].name || k).split(" ")[0] });
        } else {
            var cs = root.showcase && root.showcase.columns ? root.showcase.columns : [];
            for (var i = 0; i < cs.length; i++) defs.push({ key: cs[i].key, name: cs[i].name, limit: cs[i].limit || 0 });
        }
        var out = [];
        for (var d = 0; d < defs.length; d++) {
            var cards = [];
            for (var j = 0; j < root._cards.length; j++) {
                var c = root._cards[j];
                if (root._view === "person" ? c.owner === defs[d].key : c.lane === defs[d].key) cards.push(c);
            }
            out.push({ key: defs[d].key, name: defs[d].name, limit: defs[d].limit || 0, cards: cards });
        }
        return out;
    }
    function _cardByKey(k) {
        for (var i = 0; i < root._cards.length; i++) if (root._cards[i].key === k) return root._cards[i];
        return ({});
    }
    function _beginDrag(key, gx, gy) {
        root._dragKey = key; root._dragSX = gx; root._dragSY = gy; root._dragX = gx; root._dragY = gy; root._dragActive = true;
    }
    function _moveDrag(dx, dy) { root._dragX = root._dragSX + dx; root._dragY = root._dragSY + dy; }
    function _endDrag() {
        if (!root._dragActive) return;
        var cols = root._columnsFor();
        var idx = Math.floor((root._dragX + root._colW / 2 - root._toolL) / (root._colW + root._gap));
        idx = Math.max(0, Math.min(cols.length - 1, idx));
        var key = cols[idx].key;
        for (var i = 0; i < root._cards.length; i++) {
            if (root._cards[i].key !== root._dragKey) continue;
            if (root._view === "person") root._cards[i].owner = key; else root._cards[i].lane = key;
        }
        root._dragActive = false; root._touch();
    }
    function _addCard(colKey) {
        var n = root._cards.length + 1;
        root._cards.push({ key: "FLD-" + (300 + n), label: "sync", title: "New task — click to open", owner: root._view === "person" ? colKey : "amara", lane: root._view === "person" ? "queued" : colKey, points: 1, due: "", steps: "", seed: n });
        root._touch();
    }
    function _removeCard(k) {
        for (var i = 0; i < root._cards.length; i++) if (root._cards[i].key === k) { root._cards.splice(i, 1); break; }
        root.openedKey = ""; root._touch();
    }
    function _moveNext(k) {
        var cols = root._columnsFor();
        for (var i = 0; i < root._cards.length; i++) {
            var c = root._cards[i];
            if (c.key !== k) continue;
            var field = root._view === "person" ? "owner" : "lane";
            for (var d = 0; d < cols.length; d++) if (cols[d].key === c[field]) {
                c[field] = cols[(d + 1) % cols.length].key; break;
            }
            break;
        }
        root._touch();
    }
    Row {
        x: root._toolL; y: root._toolT; spacing: 12
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: (root.showcase && root.showcase.title) || "Project board"; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeLG"); font.weight: root.th.design("WeightMedium"); anchors.verticalCenter: parent.verticalCenter }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: String(root._cards.length) + " cards"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM"); anchors.verticalCenter: parent.verticalCenter }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Drag cards between lanes · click to open"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS"); anchors.verticalCenter: parent.verticalCenter }
        Item { width: Math.max(8, parent.parent.width - 560); height: 1 }
        Arc.ArcSegmented {
            objectName: "hit:kbView"
            th: root.th; value: root._view
            options: [{ value: "status", label: "Status" }, { value: "person", label: "By person" }]
            onActivated: function (v) { root._view = v; root.openedKey = ""; root._touch(); }
        }
    }
    Flickable {
        id: _scroll
        x: root._toolL; y: 64; width: parent.width - 2 * root._toolL; height: parent.height - 76
        contentWidth: _lanes.implicitWidth; contentHeight: height; clip: true
        boundsBehavior: Flickable.StopAtBounds
        Row {
            id: _lanes; spacing: root._gap
            Repeater {
                model: root._rev >= 0 ? root._columnsFor() : []
                delegate: Rectangle {
                    id: _lane
                    required property var modelData; required property int index
                    property string laneKey: modelData.key
                    width: root._colW; height: _scroll.height - 8
                    radius: root.th.pad(root.th.ct("KanbanBoard", "CellRadius"))
                    color: root.th.c("SurfaceMuted")
                    Column {
                        width: parent.width; spacing: 10
                        Row {
                            x: 12; y: 10; spacing: 8
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.name; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium"); anchors.verticalCenter: parent.verticalCenter }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: String((modelData.cards || []).length) + (modelData.limit ? "/" + modelData.limit : ""); color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM"); anchors.verticalCenter: parent.verticalCenter }
                            Arc.ArcBadge {
                                visible: !!modelData.limit && (modelData.cards || []).length > modelData.limit
                                th: root.th; text: "Above limit"; tone: "warning"; small: true; anchors.verticalCenter: parent.verticalCenter
                            }
                            Item { width: 8; height: 1 }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "+"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeLG"); anchors.verticalCenter: parent.verticalCenter }
                            MouseArea { width: 18; height: 24; cursorShape: Qt.PointingHandCursor; onClicked: root._addCard(_lane.laneKey) }
                        }
                        Rectangle {
                            visible: _lane.laneKey === (root.showcase.columns ? root.showcase.columns[0].key : "");
                            x: 10; width: root._colW - 20; height: 96
                            radius: root.th.pad(root.th.ct("KanbanBoard", "SlotRadius"))
                            color: root.th.fade(root.th.c("Foreground"), 0.04)
                            border.width: 1; border.color: root.th.c("BorderStrong")
                        }
                        Repeater {
                            model: modelData.cards || []
                            delegate: Arc.ArcKanbanCard {
                                id: _card
                                objectName: "hit:kbCard" + modelData.key
                                required property var modelData
                                th: root.th; card: modelData; dragEnabled: true
                                people: (root.showcase && root.showcase.people) || ({}); labels: (root.showcase && root.showcase.labels) || ({})
                                dimmed: root._dragActive && root._dragKey === modelData.key
                                width: root._colW - 20; x: 10
                                onInvoked: { root.openedKey = modelData.key; root.cardInvoked(modelData.key); }
                                onDragBegun: { var p = _card.mapToItem(root, 0, 0); root._beginDrag(modelData.key, p.x, p.y); }
                                onDragMoved: function (dx, dy) { root._moveDrag(dx, dy); }
                                onDragEnded: root._endDrag()
                            }
                        }
                        Row {
                            x: 16; spacing: 6
                            Arc.ArcIcon { th: root.th; kind: "Plus"; width: 13; height: 13; color: root.th.c("TextMuted"); anchors.verticalCenter: parent.verticalCenter }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Add card"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS"); anchors.verticalCenter: parent.verticalCenter }
                            MouseArea { width: 90; height: 20; cursorShape: Qt.PointingHandCursor; onClicked: root._addCard(_lane.laneKey) }
                        }
                    }
                }
            }
        }
    }
    Rectangle {
        visible: root._dragActive; x: root._dragX; y: root._dragY; z: 3
        width: root._colW - 20; height: 132
        radius: root.th.pad(root.th.ct("KanbanBoard", "CardRadius"))
        color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("Border")
        opacity: 0.98
        Arc.ArcKanbanCard {
            th: root.th; width: parent.width - 2; x: 1; y: 1
            card: root._cardByKey(root._dragKey); dragging: true
            people: (root.showcase && root.showcase.people) || ({}); labels: (root.showcase && root.showcase.labels) || ({})
        }
    }
    Arc.ArcKanbanDrawer {
        visible: root.openedKey !== ""; z: 4; th: root.th
        cardKey: root.openedKey; cardTitle: root._cardByKey(root.openedKey).title || ""
        points: root._cardByKey(root.openedKey).points || 0; due: root._cardByKey(root.openedKey).due || ""
        onMoveNext: root._moveNext(root.openedKey)
        onRemove: root._removeCard(root.openedKey)
        onClosed: root.openedKey = ""
    }
}
