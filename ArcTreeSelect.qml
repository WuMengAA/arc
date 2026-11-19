// arc:TreeSelect —— Selects/TreeSelect 真源码移植（TreeSelect.cs 2094 行 + TreeSelectToken.cs）。
// 结构：TreeSelectValueRow（收起态 chip 行）+ 展开菜单（MenuPadding[6,6,6,6] / MenuCornerRadius20，
// 行用 TreeSelectRow：RowHeight36 / IndentWidth18 / RowRadius12 / 复选框 16）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var nodes: []
    property var selected: []
    property bool open: false
    property string placeholder: "Select items"
    property var expanded: ({})
    readonly property real _rowH: root.th.ct("TreeSelect", "RowHeight")
    readonly property real _menuPad: root.th.pad(root.th.ct("TreeSelect", "MenuPadding"))
    readonly property real _menuRad: root.th.pad(root.th.ct("TreeSelect", "MenuCornerRadius"))
    readonly property var _flat: {
        var out = [];
        var walk = function (list, depth, prefix) {
            for (var i = 0; i < (list ? list.length : 0); i++) {
                var n = list[i], path = prefix === "" ? n.label : prefix + " / " + n.label;
                var kids = n.children || [];
                out.push({ node: n, path: path, depth: depth, has: kids.length > 0, open: !!root.expanded[path] });
                if (kids.length > 0 && root.expanded[path]) walk(kids, depth + 1, path);
            }
        };
        walk(root.nodes, 0, "");
        return out;
    }
    function flip(map, key) {
        var o = {};
        for (var k in map) o[k] = map[k];
        o[key] = !o[key];
        return o;
    }
    function toggleSelect(path) {
        var arr = root.selected.slice(), i = arr.indexOf(path);
        if (i >= 0) arr.splice(i, 1); else arr.push(path);
        root.selected = arr;
    }
    implicitWidth: 300
    implicitHeight: _trigger.height + (root.open ? 8 + root._menuPad * 2 + Math.min(7, root._flat.length) * root._rowH : 0)

    Arc.ArcTreeSelectValueRow {
        id: _trigger
        th: root.th
        width: parent.width
        selected: root.selected
        open: root.open
        placeholder: root.placeholder
        onToggled: root.open = !root.open
    }
    Rectangle {
        visible: root.open
        y: _trigger.height + 8
        width: parent.width
        height: root._menuPad * 2 + Math.min(7, root._flat.length) * root._rowH
        radius: root._menuRad
        color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
        border.width: 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        Column {
            x: root._menuPad
            y: root._menuPad
            width: parent.width - 2 * root._menuPad
            spacing: 0
            Repeater {
                model: Math.min(7, root._flat.length)
                delegate: Arc.ArcTreeSelectRow {
                    required property int index
                    th: root.th
                    width: parent.width
                    node: root._flat[index].node
                    path: root._flat[index].path
                    depth: root._flat[index].depth
                    hasChildren: root._flat[index].has
                    expanded: root._flat[index].open
                    checked: root.selected.indexOf(root._flat[index].path) >= 0
                    onToggleOpen: root.expanded = root.flip(root.expanded, root._flat[index].path)
                    onToggleCheck: root.toggleSelect(root._flat[index].path)
                }
            }
        }
    }
}
