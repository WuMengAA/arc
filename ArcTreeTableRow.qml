// arc:TreeTableRow —— Tables/TreeTable/TreeTableRow.cs 真源码移植。
// 一行：RowHeight44；缩进 IndentWidth20 + 折角 ChevronExtent24；复选列 CheckColumnWidth44；
// 选中行用 SurfaceMuted、斑马纹用 StripeBackground。首列是树列（名称 + 折角），其余列按 columns 取值。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var node: null
    property int depth: 0
    property bool hasChildren: false
    property bool expanded: false
    property bool isChecked: false
    property bool isSelected: false
    property bool stripe: false
    property var columns: []
    property real totalWidth: 0
    property bool showCheckboxes: true
    property real totalDepth: 0
    signal toggleRequested()
    signal checkRequested()
    signal activated()

    readonly property real _row: root.th.ct("TreeTable", "RowHeight")
    readonly property real _indent: root.th.ct("TreeTable", "IndentWidth")
    readonly property real _chev: root.th.ct("TreeTable", "ChevronExtent")
    readonly property real _chkW: root.showCheckboxes ? root.th.ct("TreeTable", "CheckColumnWidth") : 0
    readonly property real _padIn: root.th.ct("TreeTable", "CellInlinePadding")
    function colW(i) {
        var c = root.columns[i];
        if (c && c.width > 0) return c.width;
        return Math.max(0, root.totalWidth - root._chkW) / Math.max(1, root.columns.length);
    }
    function colX(i) {
        var x = root._chkW;
        for (var j = 0; j < i; j++) x += root.colW(j);
        return x;
    }
    width: root.totalWidth
    height: root._row

    Rectangle {
        anchors.fill: parent
        color: root.isSelected ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0")
              : ((root.stripe && root.th) ? root.th.ct("TreeTable", "StripeBackground") : "transparent")
    }
    // 复选列
    Rectangle {
        visible: root.showCheckboxes
        x: 14
        anchors.verticalCenter: parent.verticalCenter
        width: 16; height: 16; radius: 4
        color: root.isChecked ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : "transparent"
        border.width: 1.5
        border.color: root.isChecked ? (root.th ? root.th.a("accent") : "#FF2FB8C6")
                                     : (root.th ? root.th.c("BorderStrong") : "#FFC0C0C0")
        MouseArea { anchors.fill: parent; onClicked: root.checkRequested() }
    }
    // 树列
    Item {
        x: root._chkW
        width: root.colW(0)
        height: parent.height
        Arc.ArcIcon {
            visible: root.hasChildren
            x: root._padIn + root.depth * root._indent
            anchors.verticalCenter: parent.verticalCenter
            width: 14; height: 14
            th: root.th
            kind: "ChevronRight"
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            rotation: root.expanded ? 90 : 0
            Behavior on rotation { NumberAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        }
        Text {
            x: root._padIn + root.depth * root._indent + (root.hasChildren ? root._chev : 0)
            width: parent.width - x - root._padIn
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.node ? (root.node.name || "") : ""
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            font.pixelSize: root.th ? root.th.design("TypeSM") : 13
            font.weight: root.hasChildren ? (root.th ? root.th.weightMedium : 500) : (root.th ? root.th.weightRegular : 400)
        }
    }
    // 其余列
    Repeater {
        model: Math.max(0, root.columns.length - 1)
        delegate: Text {
            required property int index
            readonly property int ci: index + 1
            x: root.colX(root.ci)
            width: root.colW(root.ci) - 2 * root._padIn
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: (root.columns[root.ci] && root.columns[root.ci].align === "right") ? Text.AlignRight : Text.AlignLeft
            elide: Text.ElideRight
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: (root.node && root.columns[root.ci] && root.node[root.columns[root.ci].key] !== undefined)
                  ? String(root.node[root.columns[root.ci].key]) : ""
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.activated()
    }
}
