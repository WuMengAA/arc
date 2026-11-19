// arc:TreeView —— Tables/TreeView 真源码移植（TreeView.cs + TreeViewToken.cs + TreeViewRow/TreeViewItem）。
// 文件树：行槽 RowSlotHeight(38)、缩进 IndentWidth(18)、行圆角 RowRadius(10)、行内边距 RowInlinePadding(10)、
// 行距 RowGap(2)；外壳 TreeCornerRadius16 / TreePadding[8,6,8,8]。
// 图标按扩展名取色（TypeScript/Markdown/Stylesheet/Json 四种 tint），展开箭头 ChevronSize16 随开合旋转。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var nodes: []           // [{name, children?:[], kind?}]
    property real rowHeight: 0
    property bool showIndentGuides: true
    property bool showIcons: true
    property var selectedItem: null
    property string indentMode: "auto"

    readonly property real _slot: root.rowHeight > 0 ? root.rowHeight : root.th.ct("TreeView", "RowSlotHeight")
    readonly property real _indent: root.th.ct("TreeView", "IndentWidth")
    readonly property real _rowGap: root.th.ct("TreeView", "RowGap")
    readonly property real _padIn: root.th.ct("TreeView", "RowInlinePadding")
    readonly property real _rad: root.th.pad(root.th.ct("TreeView", "TreeCornerRadius"))
    readonly property real _pad: root.th.pad(root.th.ct("TreeView", "TreePadding"))
    // 展平：{node, depth, path, expanded, hasChildren}
    property var expanded: ({})
    readonly property var _flat: root._flatten(root.nodes, 0, "")
    function _flatten(list, depth, prefix) {
        var out = [];
        for (var i = 0; i < (list ? list.length : 0); i++) {
            var n = list[i];
            var path = prefix + "/" + (n.name || i);
            var kids = n.children || [];
            out.push({ node: n, depth: depth, path: path, hasChildren: kids.length > 0, expanded: !!root.expanded[path] });
            if (kids.length > 0 && root.expanded[path]) {
                var sub = root._flatten(kids, depth + 1, path);
                for (var j = 0; j < sub.length; j++) out.push(sub[j]);
            }
        }
        return out;
    }
    function toggle(path) {
        var e = {};
        for (var k in root.expanded) e[k] = root.expanded[k];
        e[path] = !e[path];
        root.expanded = e;
    }
    // 扩展名 → tint
    function _tint(name) {
        var n = String(name || "");
        if (/\.tsx?$/.test(n)) return root.th ? root.th.ct("TreeView", "TypeScriptTint") : "#FF2A5E98";
        if (/\.md$/.test(n)) return root.th ? root.th.ct("TreeView", "MarkdownTint") : "#FF2E6550";
        if (/\.(css|scss|less)$/.test(n)) return root.th ? root.th.ct("TreeView", "StylesheetTint") : "#FF644E93";
        if (/\.json$/.test(n)) return root.th ? root.th.ct("TreeView", "JsonTint") : "#FF96682F";
        return root.th ? root.th.c("Border") : "#FFE0E0E0";
    }
    implicitWidth: 280
    implicitHeight: Math.min(root._flat.length * (root._slot + root._rowGap), 420) + 2 * root._pad

    Rectangle {
        anchors.fill: parent
        radius: root._rad
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
    }
    Flickable {
        x: root._pad; y: root._pad
        width: parent.width - 2 * root._pad
        height: parent.height - 2 * root._pad
        contentHeight: _rows.implicitHeight
        contentWidth: parent.width
        clip: true
        Column {
            id: _rows
            width: parent.width
            spacing: root._rowGap
            Repeater {
                model: root._flat
                delegate: Item {
                    required property var modelData
                    required property int index
                    readonly property bool sel: root.selectedItem !== null
                            && root.selectedItem && root.selectedItem.name === modelData.node.name
                    width: _rows.width
                    height: root._slot
                    Rectangle {
                        anchors.fill: parent
                        radius: root.th.ct("TreeView", "RowRadius")
                        color: sel ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0")
                              : (_ma.containsMouse ? (root.th ? root.th.fade(root.th.c("SurfaceMuted"), 0.6) : "#FFF6F6F6") : "transparent")
                        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                    }
                    // 缩进参考线
                    Repeater {
                        model: root.showIndentGuides ? modelData.depth : 0
                        delegate: Rectangle {
                            required property int index
                            x: root._padIn + index * root._indent + root._indent / 2
                            y: 0; width: 1; height: parent.height
                            color: root.th ? root.th.fade(root.th.c("Border"), 0.6) : "#33E0E0E0"
                        }
                    }
                    // 展开箭头
                    Arc.ArcIcon {
                        visible: modelData.hasChildren
                        x: root._padIn + modelData.depth * root._indent
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16; height: 16
                        th: root.th
                        kind: "ChevronRight"
                        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                        rotation: modelData.expanded ? 90 : 0
                        Behavior on rotation { NumberAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                    }
                    // 文件图标（按扩展名 tint）
                    Rectangle {
                        visible: root.showIcons && !modelData.hasChildren
                        x: root._padIn + modelData.depth * root._indent + (modelData.hasChildren ? 16 : 4)
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8; height: 8; radius: 2
                        color: root._tint(modelData.node.name)
                    }
                    Text {
                        x: root._padIn + modelData.depth * root._indent
                           + (modelData.hasChildren ? 18 : (root.showIcons ? 18 : 4))
                        width: parent.width - x - root._padIn
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideMiddle
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: modelData.node.name || ""
                        color: sel ? (root.th ? root.th.c("Foreground") : "#FF1D1D1D")
                                   : (root.th ? root.th.c("TextSecondary") : "#FF6D6D6D")
                        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
                        font.weight: sel ? (root.th ? root.th.weightMedium : 500) : (root.th ? root.th.weightRegular : 400)
                    }
                    MouseArea {
                        id: _ma
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (modelData.hasChildren) root.toggle(modelData.path);
                            root.selectedItem = modelData.node;
                        }
                    }
                }
            }
        }
    }
}
