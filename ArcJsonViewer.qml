// arc:JsonViewer —— Tables/JsonViewer 真源码移植（JsonViewer.cs + JsonViewerToken.cs + JsonViewerRow/Model）。
// JSON 树：缩进 IndentWidth16（compact 12），行槽 RowSlotHeight30，树字号 TreeFontSize13，最大高 TreeMaxHeight420。
// 类型着色：字符串/数字/布尔各一色（StringBrush/NumberBrush/BooleanBrush 走设计令牌的 Success/Warning/Accent 语义）。
// 路径条 PathBarPadding[14,6,6,6]；工具条 ToolSize34 / 复制 PathCopySize30；搜索 SearchRadius14。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var json: null
    property string rootName: ""
    property int expandDepth: 2
    property bool isSearchable: true
    property string query: ""
    property bool isCopyable: true
    property bool isPathVisible: true
    property real maxTreeHeight: 0
    property bool compact: false

    readonly property real _indent: root.compact ? root.th.ct("JsonViewer", "IndentWidthCompact") : root.th.ct("JsonViewer", "IndentWidth")
    readonly property real _slot: root.th.ct("JsonViewer", "RowSlotHeight")
    readonly property real _treeFs: root.th.ct("JsonViewer", "TreeFontSize")
    readonly property real _maxH: root.maxTreeHeight > 0 ? root.maxTreeHeight : root.th.ct("JsonViewer", "TreeMaxHeight")
    readonly property real _pad: root.th.pad(root.th.ct("JsonViewer", "TreePadding"))
    readonly property real _barPad: root.th.pad(root.th.ct("JsonViewer", "PathBarPadding"))
    // 展平：{path, key, value, kind, depth, isLeaf, open}
    property var open: ({})
    readonly property var _rows: root._flatten(root.json, "", "", 0)
    function _kindOf(v) {
        if (v === null) return "null";
        if (typeof v === "object") return Array.isArray(v) ? "array" : "object";
        return typeof v;
    }
    function _colorOf(kind) {
        if (kind === "string") return root.th ? root.th.ct("JsonViewer", "StringBrush") : "#FF006B2D";
        if (kind === "number") return root.th ? root.th.ct("JsonViewer", "NumberBrush") : "#FF9D4700";
        if (kind === "boolean") return root.th ? root.th.c("Accent") : "#FF2FB8C6";
        return root.th ? root.th.c("TextMuted") : "#FF9A9A9A";
    }
    function _flatten(v, path, key, depth) {
        var out = [], kind = root._kindOf(v), isLeaf = (kind !== "object" && kind !== "array");
        var p = path === "" ? (key === "" ? (root.rootName || "$") : key) : path + "." + key;
        out.push({ path: p, key: key, value: v, kind: kind, depth: depth, isLeaf: isLeaf, open: !!root.open[p] });
        if (!isLeaf && root.open[p]) {
            var keys = kind === "array" ? v.map(function (_, i) { return String(i); }) : Object.keys(v);
            for (var i = 0; i < keys.length; i++) {
                var sub = root._flatten(kind === "array" ? v[Number(keys[i])] : v[keys[i]], p,
                                        kind === "array" ? "[" + keys[i] + "]" : keys[i], depth + 1);
                for (var j = 0; j < sub.length; j++) out.push(sub[j]);
            }
        }
        return out;
    }
    function _toggle(path) {
        var o = {};
        for (var k in root.open) o[k] = root.open[k];
        o[path] = !o[path];
        root.open = o;
    }
    function _preview(v, kind) {
        if (kind === "array") return v.length + " items";
        if (kind === "object") return Object.keys(v).length + " keys";
        if (kind === "string") return '"' + String(v).replace(/"/g, '\\"') + '"';
        return String(v);
    }
    implicitWidth: 420
    implicitHeight: root._barPad * 2 + 30 + Math.min(root._rows.length * root._slot, root._maxH) + 2 * root._pad

    Rectangle {
        anchors.fill: parent
        radius: root.th.pad(root.th.ct("JsonViewer", "ToolRadius"))
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
    }
    // PART_PathBar：当前路径 + 复制
    Row {
        x: root._barPad
        y: root._barPad
        width: parent.width - 2 * root._barPad
        height: 30
        visible: root.isPathVisible
        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - (root.isCopyable ? 34 : 0)
            elide: Text.ElideMiddle
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.monoFamily : "Consolas"
            text: root.rootName !== "" ? root.rootName : "$"
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th.design("TypeXS")
        }
        Rectangle {
            visible: root.isCopyable
            width: root.th.ct("JsonViewer", "PathCopySize"); height: width
            radius: root.th.pad(root.th.ct("JsonViewer", "PathCopyRadius"))
            color: _cm.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
            Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
            Arc.ArcIcon {
                anchors.centerIn: parent
                width: 14; height: 14
                th: root.th; kind: "Copy"
                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            }
            MouseArea { id: _cm; anchors.fill: parent; hoverEnabled: true }
        }
    }
    Flickable {
        x: root._pad
        y: root._barPad * 2 + 30 + root._pad
        width: parent.width - 2 * root._pad
        height: parent.height - y - root._pad
        contentHeight: _tree.implicitHeight
        clip: true
        Column {
            id: _tree
            width: parent.width
            spacing: 0
            Repeater {
                model: root._rows
                delegate: Item {
                    required property var modelData
                    width: _tree.width
                    height: root._slot
                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: _rm.containsMouse ? (root.th ? root.th.ct("JsonViewer", "RowHoverFill") : "#FFF5F5F5") : "transparent"
                    }
                    // 折角
                    Arc.ArcIcon {
                        visible: !modelData.isLeaf
                        x: modelData.depth * root._indent
                        anchors.verticalCenter: parent.verticalCenter
                        width: 12; height: 12
                        th: root.th; kind: "ChevronRight"
                        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                        rotation: modelData.open ? 90 : 0
                    }
                    // 键
                    Text {
                        x: modelData.depth * root._indent + (modelData.isLeaf ? 14 : 16)
                        anchors.verticalCenter: parent.verticalCenter
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.monoFamily : "Consolas"
                        text: modelData.key
                        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                        font.pixelSize: root._treeFs
                    }
                    // 值
                    Text {
                        x: modelData.depth * root._indent + (modelData.isLeaf ? 14 : 16) + _key.implicitWidth + 6
                        anchors.verticalCenter: parent.verticalCenter
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.monoFamily : "Consolas"
                        text: root._preview(modelData.value, modelData.kind)
                        color: root._colorOf(modelData.kind)
                        font.pixelSize: root._treeFs
                        elide: Text.ElideRight
                        width: parent.width - x - 8
                    }
                    Text {
                        id: _key
                        visible: false
                        font.family: root.th ? root.th.monoFamily : "Consolas"
                        font.pixelSize: root._treeFs
                        text: modelData.key
                    }
                    MouseArea {
                        id: _rm
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: if (!modelData.isLeaf) root._toggle(modelData.path)
                    }
                }
            }
        }
    }
}
