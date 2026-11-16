// arc:WorkflowCanvas PART_Node —— 图标 + 标题 + 副标题 + 右侧状态圈。
// 交互：单击选中；按住拖动发「帧间增量」dx/dy（官方 BeginMove/UpdateDrag/CommitMove 三段）。
// 关键修复：全局坐标帧间增量（消除自反馈阻尼）；canvas 原地改坐标，Repeater 不重建。
import QtQuick 2.15
import "." as Arc

Rectangle {
    id: root
    property var th: null
    property var node: ({})
    property bool compact: false
    property bool selected: false
    signal invoked()
    signal dragBegun()
    signal dragMoved(real dx, real dy)
    signal dragEnded()
    readonly property real _h: root.th.ct("WorkflowNodeCard", "StandardHeight")
    readonly property real _r: root.th.pad(root.th.ct("WorkflowNodeCard", "CardRadius"))
    readonly property string _state: root.node.state || "idle"
    width: root.th.ct("WorkflowNodeCard", "StandardWidth"); height: root._h
    radius: root._r; color: root.selected ? root.th.fade(root.th.a("accent"), 0.08) : root.th.c("SurfaceRaised")
    border.width: root.selected ? 2 : (_state === "running" ? 2 : 1)
    border.color: root.selected ? root.th.a("accent") : _state === "failed" ? root.th.ct("WorkflowNodeCard", "FailedBorderColor") : _state === "running" ? root.th.a("accent") : root.th.c("Border")
    Row {
        x: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 10
        Rectangle {
            width: 30; height: 30; radius: 8
            color: root._state === "done" ? root.th.fade(root.th.c("Success"), 0.14) : root._state === "running" ? root.th.fade(root.th.a("accent"), 0.14) : root.th.c("SurfaceMuted")
            Arc.ArcIcon { anchors.centerIn: parent; th: root.th; kind: root.node.icon || "Circle"; width: 15; height: 15
                color: root._state === "done" ? root.th.c("Success") : root._state === "running" ? root.th.a("accent") : root.th.c("TextSecondary") }
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.node.title || ""; color: root.th.c("Foreground"); font.pixelSize: root.th.ct("WorkflowNodeCard", "TitleFontSize"); font.weight: root.th.design("WeightMedium") }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.node.sub || ""; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
        }
    }
    Rectangle {
        anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
        width: 14; height: 14; radius: 7; color: "transparent"; border.width: 1.5
        border.color: root._state === "done" ? root.th.c("Success") : root._state === "running" ? root.th.a("accent") : root.th.c("BorderStrong")
        Arc.ArcIcon { visible: root._state === "done"; anchors.centerIn: parent; th: root.th; kind: "Check"; width: 10; height: 10; color: root.th.c("Success") }
        Arc.ArcIcon { visible: root._state === "locked"; anchors.centerIn: parent; th: root.th; kind: "Lock"; width: 9; height: 9; color: root.th.c("TextMuted") }
    }
    MouseArea {
        id: _ma; anchors.fill: parent; cursorShape: Qt.OpenHandCursor
        preventStealing: true   // 阻止父级 Flickable 偷 grab（竖向拖节点不再连带滚页面）
        // 用「全局光标坐标」算帧间增量，不用 mouseX/mouseY 局部坐标：
        // 节点被拖动时会跟着光标一起走，局部 mouseX 会因节点自身位移被抵消，
        // 形成自反馈阻尼（真 GUI 实测每两步才走一步，150px 只挪 80px）。
        property real _gx: 0; property real _gy: 0
        property real _accX: 0; property real _accY: 0; property bool _moved: false
        onPressed: {
            var g = _ma.mapToGlobal(Qt.point(mouseX, mouseY));
            _gx = g.x; _gy = g.y; _accX = 0; _accY = 0; _moved = false;
        }
        onPositionChanged: {
            if (!_ma.pressed) return;
            var g = _ma.mapToGlobal(Qt.point(mouseX, mouseY));
            var dx = g.x - _gx, dy = g.y - _gy;
            _gx = g.x; _gy = g.y;                              // 每帧推进全局基准
            _accX += dx; _accY += dy;
            if (!_moved && (Math.abs(_accX) > 4 || Math.abs(_accY) > 4)) { _moved = true; root.dragBegun(); }
            if (_moved) root.dragMoved(dx, dy);
        }
        onReleased: if (_moved) root.dragEnded();
        onClicked: if (!_moved) root.invoked();
    }
}
