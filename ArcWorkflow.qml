// arc:WorkflowCanvas —— 官方 WorkflowCanvas 的可交互移植（run / arrange 两帧）。
// 官方方法对照（真源码 src/TKCode.Arc.Workflow，逐字核对）：
//   ArrangeNodes(bool animate = true)         WorkflowCanvas.Layout.cs:39  → arrangeNodes()
//   DeleteSelection()                        WorkflowCanvas.Editing.cs:119 → deleteSelection()
//   Select(IEnumerable<WorkflowNode> nodes)  WorkflowCanvas.Editing.cs:105 → selectNode(i)
//   ClearSelection()                         WorkflowCanvas.Editing.cs:113 → clearSelection()
//   SelectedNodes / SelectedEdges（复数）     WorkflowCanvas.Editing.cs:96  → selectedNodes
//   ResetRun()                               WorkflowGraph.cs:156          → resetRun()
//   Undo() / Redo()                          WorkflowCanvas.Connecting.cs:71/74 → undo() / redo()
//   ScrollIntoView(WorkflowNode, bool)       WorkflowCanvas.View.cs:83     → scrollIntoView(i)
//   BeginMove / UpdateDrag / CommitMove      WorkflowCanvas.Editing.cs     → 拖动三段（直接跟随）
//   ZoomIn() / ZoomOut() / ZoomTo(z)         WorkflowCanvas.View.cs:74-77 → zoomIn/zoomOut/zoomTo
//   FitToContent(bool animate = true)        WorkflowCanvas.View.cs:53     → fitToContent()
// ⚠️ QML 属性/方法名不能以大写字母开头（"Property names cannot begin with an upper case letter"），
//    故对外函数一律 camelCase；官方 PascalCase 真名保留在上方逐字对照。
// 官方不存在：AutoArrange / ResetLayout / RunTestEvent / SelectedNode（全库 0 命中）。
// loadLayout() 借用 DockLayout.LoadLayout(json) 语义；startRun() 是模板 ArcWorkflowApp 的 Run 命令。
import QtQuick 2.15
import "." as Arc
import "ArcShowcaseData.js" as Showcase

Item {
    id: root
    property var th: null
    property string variant: "run"
    property var showcase: ({})
    property var labels: ({})          // issue 9：宿主数据桥可覆盖工具条/状态行字面量
    property int selected: -1
    property real zoom: 1
    property int _rev: 0
    property int runIdx: 1
    property real viewX: 0; property real viewY: 0
    property var _undoStack: []; property var _redoStack: []
    property var _nodes: []; property var _edges: []
    readonly property var _d: root.showcase && root.showcase.nodes ? root.showcase : (root.variant === "arrange" ? Showcase.ArcShowcase.workflowArrange : Showcase.ArcShowcase.workflowRun)
    readonly property real _grid: th.ct("WorkflowCanvas", "GridSpacing")
    readonly property real _dot: th.ct("WorkflowCanvas", "GridDotRadius")
    readonly property real _wire: th.ct("WorkflowCanvas", "WireThickness")
    readonly property real _nodeW: th.ct("WorkflowNodeCard", "StandardWidth")
    readonly property real _nodeH: th.ct("WorkflowNodeCard", "StandardHeight")
    readonly property real _toolH: 56
    width: 800; height: root.variant === "arrange" ? 560 : 460
    function _touch() { root._rev = root._rev + 1; }
    function _oxFor(w) { return Math.max(0, (Math.max(780, w || 0) - 780) / 2); }
    readonly property var selectedNodes: root.selected >= 0 && root._nodes[root.selected] ? [root._nodes[root.selected]] : []
    function selectNode(i) { root.selected = i; root._touch(); }
    function clearSelection() { root.selected = -1; root._touch(); }
    // issue 6：官方 Undo()/Redo() 历史栈 —— 快照节点/边/选中；beginMove / deleteSelection / arrangeNodes 入栈。
    function _snapshot() { var n = [], e = []; for (var i = 0; i < root._nodes.length; i++) { var o = {}; for (var k in root._nodes[i]) o[k] = root._nodes[i][k]; n.push(o); } for (var j = 0; j < root._edges.length; j++) e.push({ from: root._edges[j].from, to: root._edges[j].to }); return { nodes: n, edges: e, selected: root.selected }; }
    function _pushUndo() { var u = root._undoStack.slice(); u.push(root._snapshot()); root._undoStack = u; root._redoStack = []; }
    function _restore(s) { root._nodes = s.nodes; root._edges = s.edges; root.selected = s.selected; root._touch(); }
    function undo() { var u = root._undoStack.slice(); if (!u.length) return false; var s = u.pop(), r = root._redoStack.slice(); r.push(root._snapshot()); root._undoStack = u; root._redoStack = r; root._restore(s); return true; }
    function redo() { var r = root._redoStack.slice(); if (!r.length) return false; var s = r.pop(), u = root._undoStack.slice(); u.push(root._snapshot()); root._redoStack = r; root._undoStack = u; root._restore(s); return true; }
    // issue 6：官方 ScrollIntoView —— 选中节点并把画布平移到可见中心（animate 参数保留签名，当前即时生效）。
    function scrollIntoView(i, animate) { var n = root._nodes[i]; if (!n) return; root.selected = i; root.viewX = Math.max(0, (n.x || 0) + root._nodeW / 2 - _plot.width / 2); root.viewY = Math.max(0, (n.y || 0) + root._nodeH / 2 - _plot.height / 2); root._touch(); }
    function beginMove(i) { root._pushUndo(); root.selectNode(i); }
    // 直接跟随：原地改同一对象、绝不换 _nodes 引用（换引用会让 Repeater 重建，MouseArea 被销毁 → 断续）。
    // dx/dy 是 ArcWorkflowNode 用 mapToGlobal 算出的「全局光标帧间增量」，已是父坐标系像素，
    // 直接累加即 1:1 跟手；不能再除 zoom（除 zoom 会让缩放时拖动变慢）。
    function updateDrag(i, dx, dy) { if (!root._nodes[i]) return; var n = root._nodes[i]; n.x = (n.x || 0) + dx; n.y = (n.y || 0) + dy; root._touch(); }
    function commitMove() { root._touch(); }
    function deleteSelection() { if (root.selected < 0) return; root._pushUndo(); var k = root.selected, ns = [], map = {}; for (var i = 0; i < root._nodes.length; i++) { if (i === k) continue; map[i] = ns.length; ns.push(root._nodes[i]); } var es = []; for (var j = 0; j < root._edges.length; j++) { var e = root._edges[j]; if (e.from === k || e.to === k) continue; es.push({ from: map[e.from], to: map[e.to] }); } root._nodes = ns; root._edges = es; root.selected = -1; root._touch(); }
    function arrangeNodes() { root._pushUndo(); var n = root._nodes, e = root._edges, layers = []; for (var i = 0; i < n.length; i++) layers.push(0); for (var pass = 0; pass < n.length; pass++) for (var j = 0; j < e.length; j++) { var a = e[j].from, b = e[j].to; if (layers[b] < layers[a] + 1) layers[b] = layers[a] + 1; } var counts = [], maxL = 0; for (var q = 0; q < layers.length; q++) { counts[layers[q]] = (counts[layers[q]] || 0) + 1; if (layers[q] > maxL) maxL = layers[q]; } var cursor = [], w = Math.max(780, root.width || 780); for (var i2 = 0; i2 < n.length; i2++) { var L = layers[i2], c = counts[L], idx = cursor[L] || 0; cursor[L] = idx + 1; var gap = c > 1 ? Math.min(250, (w - 40 - root._nodeW) / (c - 1)) : 0; n[i2].x = Math.round((w - root._nodeW) / 2 + (idx - (c - 1) / 2) * gap); n[i2].y = 10 + L * 90; } root._nodes = n.slice(); root._touch(); }
    function resetRun() { var n = root._nodes; for (var i = 0; i < n.length; i++) n[i].state = i === 0 ? "running" : (n[i].state === "locked" ? "locked" : "idle"); root.runIdx = 1; _runTimer.running = false; root._touch(); }
    function loadLayout() { var src = root._d.nodes || [], out = []; for (var i = 0; i < src.length; i++) { var o = {}; for (var k in src[i]) o[k] = src[i][k]; out.push(o); } root._nodes = out; var es = root._d.edges || [], eo = []; for (var j = 0; j < es.length; j++) eo.push({ from: es[j].from, to: es[j].to }); root._edges = eo; root.selected = -1; root.runIdx = 1; root.zoom = 1; root.viewX = 0; root.viewY = 0; root._undoStack = []; root._redoStack = []; _runTimer.running = false; root._touch(); }
    function startRun() { root.runIdx = 0; _runTimer.running = true; }
    function _runStep() { var n = []; for (var i = 0; i < root._nodes.length; i++) { var o = {}; for (var k in root._nodes[i]) o[k] = root._nodes[i][k]; o.state = i < root.runIdx ? "done" : (i === root.runIdx ? "running" : o.state === "locked" ? "locked" : "idle"); n.push(o); } root._nodes = n; root.runIdx = root.runIdx + 1; root._touch(); if (root.runIdx > root._nodes.length) _runTimer.running = false; }
    function zoomIn() { root.zoom = Math.min(1.4, root.zoom + 0.1); }
    function zoomOut() { root.zoom = Math.max(0.6, root.zoom - 0.1); }
    function zoomTo(z) { root.zoom = z; }
    function fitToContent() { root.zoomTo(1); root.viewX = 0; root.viewY = 0; root._touch(); }
    Timer { id: _runTimer; interval: 620; repeat: true; running: false; onTriggered: root._runStep() }
    Component.onCompleted: root.loadLayout()
    readonly property string _dotSvg: "data:image/svg+xml;utf8," + encodeURIComponent(
        '<svg xmlns="http://www.w3.org/2000/svg" width="' + root._grid + '" height="' + root._grid + '">' +
        '<circle cx="' + (root._grid / 2) + '" cy="' + (root._grid / 2) + '" r="' + root._dot + '" fill="' + root.th.c("Border") + '"/></svg>')
    Rectangle {
        anchors.fill: parent; color: root.th.c("Background")
        border.width: 1; border.color: root.th.c("Border"); radius: root.th.t4(root.th.design("RadiusPanel"), 0); clip: true
        Rectangle {
            width: parent.width; height: root._toolH; color: root.th.c("Surface")
            Row {
                x: 20; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                Rectangle { visible: root.variant === "run"; width: 8; height: 8; radius: 4; color: _runTimer.running ? root.th.c("Success") : root.th.c("TextMuted"); anchors.verticalCenter: parent.verticalCenter }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.variant === "run" ? (root._d.file || "") : (root.selected >= 0 ? (root.labels.selectedText || qsTr("1 selected · drag to move")) : (root._d.selection || qsTr("Nothing selected"))); color: root.variant === "run" ? root.th.c("TextSecondary") : root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM"); anchors.verticalCenter: parent.verticalCenter }
            }
            Row {
                anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                Rectangle { objectName: "hit:wfUndo"; visible: root.variant === "arrange"; width: 68; height: 34; radius: 17; color: root._undoStack.length ? root.th.c("Surface") : root.th.c("SurfaceMuted"); border.width: 1; border.color: root.th.c("Border"); Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: qsTr("Undo"); color: root._undoStack.length ? root.th.c("Foreground") : root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM") } MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.undo() } }
                Rectangle { objectName: "hit:wfRedo"; visible: root.variant === "arrange"; width: 68; height: 34; radius: 17; color: root._redoStack.length ? root.th.c("Surface") : root.th.c("SurfaceMuted"); border.width: 1; border.color: root.th.c("Border"); Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: qsTr("Redo"); color: root._redoStack.length ? root.th.c("Foreground") : root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM") } MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.redo() } }
                Rectangle { objectName: "hit:wfDelete"; visible: root.variant === "arrange"; width: 120; height: 34; radius: 17; color: root.selected >= 0 ? root.th.fade(root.th.c("Danger"), 0.10) : root.th.c("SurfaceMuted"); border.width: 1; border.color: root.th.c("Border"); Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: qsTr("Delete selected"); color: root.selected >= 0 ? root.th.c("Danger") : root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM") } MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.deleteSelection() } }
                Rectangle { objectName: root.variant === "run" ? "hit:wfRun" : "hit:wfArrange"; width: root.variant === "run" ? 132 : 90; height: 34; radius: 17; color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("BorderStrong"); Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: root.variant === "run" ? (_runTimer.running ? qsTr("Running…") : qsTr("Send test event")) : qsTr("Arrange"); color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") } MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.variant === "run" ? root.startRun() : root.arrangeNodes() } }
                Rectangle { visible: root.variant === "arrange"; width: 68; height: 34; radius: 17; color: root.th.c("SurfaceMuted"); Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: qsTr("Reset"); color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") } MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.loadLayout() } }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.th.c("Border") }
        }
        Item {
            id: _plot; y: root._toolH; width: parent.width; height: parent.height - root._toolH; clip: true
            Item {
                anchors.fill: parent
                transform: Translate { x: -root.viewX; y: -root.viewY }
                Image { anchors.fill: parent; source: root._dotSvg; fillMode: Image.Tile; opacity: 0.9 }
                Image { anchors.fill: parent; source: "data:image/svg+xml;utf8," + encodeURIComponent(root._rev >= 0 ? root._wires() : "<svg/>"); fillMode: Image.PreserveAspectFit }
                Repeater {
                    model: root._nodes
                    delegate: Arc.ArcWorkflowNode {
                        objectName: "hit:wfNode" + index
                        required property var modelData; required property int index
                        property int ni: index
                        th: root.th; node: modelData; selected: root.selected === ni
                        // x/y 显式依赖 _rev：updateDrag 原地改坐标也能即时重算，model 引用不变 → delegate 不重建
                        x: root._oxFor(_plot.width) + (root._rev >= 0 && root._nodes[ni] ? (root._nodes[ni].x || 0) : 0)
                        y: (root._rev >= 0 && root._nodes[ni] ? (root._nodes[ni].y || 0) : 0)
                        scale: root.zoom
                        onInvoked: root.selected === ni ? root.clearSelection() : root.selectNode(ni)
                        onDragBegun: root.beginMove(ni)
                        onDragMoved: function (dx, dy) { root.updateDrag(ni, dx, dy); }
                        onDragEnded: root.commitMove()
                    }
                }
            }
        }
        Rectangle {
            visible: root.variant === "run"; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 10
            width: 116; height: 30; radius: 15; color: root.th.c("SurfaceRaised"); border.width: 1; border.color: root.th.c("Border")
            Row {
                anchors.centerIn: parent; spacing: 6
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "−"; color: root.th.c("TextSecondary"); font.pixelSize: 19; MouseArea { anchors.fill: parent; onClicked: root.zoomOut() } }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: Math.round(root.zoom * 100) + "%"; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS"); MouseArea { anchors.fill: parent; onClicked: root.fitToContent() } }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "+"; color: root.th.c("TextSecondary"); font.pixelSize: 19; MouseArea { anchors.fill: parent; onClicked: root.zoomIn() } }
            }
        }
    }
    function _hex(c) { var s = String(c); if (s.charAt(0) !== "#") return "#808080"; return s.length === 9 ? "#" + s.substring(3) : s; }
    function _alpha(c) { var s = String(c); if (s.charAt(0) !== "#" || s.length !== 9) return 1; return parseInt(s.substring(1, 3), 16) / 255; }
    function _wires() {
        var w = Math.max(780, Math.round(root._plot ? root._plot.width : root.width) || 780);
        var h = Math.max(300, Math.round(root._plot ? root._plot.height : (root.height - root._toolH)) || 404);
        var ox = root._oxFor(w), p = "", col = root.th.ct("WorkflowCanvas", "WireColor");
        for (var i = 0; i < root._edges.length; i++) {
            var a = root._nodes[root._edges[i].from], b = root._nodes[root._edges[i].to];
            if (!a || !b) continue;
            var x0 = ox + (a.x || 0) + root._nodeW / 2, y0 = (a.y || 0) + root._nodeH;
            var x1 = ox + (b.x || 0) + root._nodeW / 2, y1 = (b.y || 0), m = (y0 + y1) / 2;
            p += '<path d="M' + x0 + ' ' + y0 + ' C' + x0 + ' ' + m + ' ' + x1 + ' ' + m + ' ' + x1 + ' ' + y1 +
                 '" fill="none" stroke="' + root._hex(col) + '" stroke-opacity="' + root._alpha(col).toFixed(3) + '" stroke-width="' + root._wire + '"/>';
        }
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + w + ' ' + h + '">' + p + '</svg>';
    }
}
