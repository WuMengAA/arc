// arc:TreeTable —— Tables/TreeTable 真源码移植（TreeTable.cs + TreeTableToken.cs + TreeTableRowsHost/Column/Palette）。
// 树形表格外壳：圆角 TableCornerRadius26，表头 TreeTableHeader + 滚动行区（TreeTableRow）；
// 行高 44 / 表头 40 / 缩进 20 / 折角 24 / 复选列 44 / 斑马纹；可排序（SortKey + SortDirection）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var nodes: []
    property var columns: []
    property string caption: ""
    property string emptyMessage: "No data"
    property bool isSelectable: true
    property bool isStriped: true
    property string sortKey: ""
    property int sortDirection: 1
    property real rowHeight: 0
    property bool showCheckboxes: true

    readonly property real _hdr: root.th.ct("TreeTable", "HeaderHeight")
    readonly property real _row: root.rowHeight > 0 ? root.rowHeight : root.th.ct("TreeTable", "RowHeight")
    readonly property real _rad: root.th.pad(root.th.ct("TreeTable", "TableCornerRadius"))
    property var expanded: ({})
    property var checked: ({})
    property string selectedPath: ""
    readonly property var _flat: root._flatten(root.nodes, 0, "")
    function _flatten(list, depth, prefix) {
        var out = [];
        for (var i = 0; i < (list ? list.length : 0); i++) {
            var n = list[i], path = prefix + "/" + (n.name || i), kids = n.children || [];
            out.push({ node: n, depth: depth, path: path, has: kids.length > 0,
                       open: !!root.expanded[path], stripe: out.length % 2 === 1 });
            if (kids.length > 0 && root.expanded[path]) {
                var sub = root._flatten(kids, depth + 1, path);
                for (var j = 0; j < sub.length; j++) out.push(sub[j]);
            }
        }
        return out;
    }
    function _flip(map, key) {
        var o = {};
        for (var k in map) o[k] = map[k];
        o[key] = !o[key];
        return o;
    }
    implicitWidth: 520
    implicitHeight: root._hdr + Math.min(root._flat.length * root._row, 460) + 2
    clip: true

    Rectangle {
        anchors.fill: parent
        radius: root._rad
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
    }
    Arc.ArcTreeTableHeader {
        id: _header
        th: root.th
        columns: root.columns
        showCheckboxes: root.showCheckboxes
        totalWidth: root.width
        sortKey: root.sortKey
        sortDirection: root.sortDirection
        onSortRequested: function (key) {
            if (root.sortKey === key) root.sortDirection = -root.sortDirection;
            else { root.sortKey = key; root.sortDirection = 1; }
        }
    }
    Flickable {
        y: root._hdr
        width: parent.width
        height: parent.height - root._hdr
        contentHeight: _rows.implicitHeight
        clip: true
        Column {
            id: _rows
            width: parent.width
            Repeater {
                model: root._flat
                delegate: Arc.ArcTreeTableRow {
                    required property var modelData
                    th: root.th
                    node: modelData.node
                    depth: modelData.depth
                    hasChildren: modelData.has
                    expanded: modelData.open
                    isChecked: !!root.checked[modelData.path]
                    isSelected: root.selectedPath === modelData.path
                    stripe: root.isStriped && modelData.stripe
                    columns: root.columns
                    totalWidth: _rows.width
                    showCheckboxes: root.showCheckboxes
                    onToggleRequested: root.expanded = root._flip(root.expanded, modelData.path)
                    onCheckRequested: root.checked = root._flip(root.checked, modelData.path)
                    onActivated: {
                        if (!root.isSelectable) return;
                        root.selectedPath = modelData.path;
                        if (modelData.has) root.expanded = root._flip(root.expanded, modelData.path);
                    }
                }
            }
        }
    }
    Text {
        visible: root._flat.length === 0
        anchors.centerIn: parent
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.emptyMessage
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
    }
}
