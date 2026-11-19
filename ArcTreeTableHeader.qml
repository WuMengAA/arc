// arc:TreeTableHeader —— Tables/TreeTable/TreeTableHeader.cs 真源码移植。
// 表头：HeaderHeight40，列宽按 columns[i].width 或均分；点击列头切排序（同列反向、异列正向）；
// 排序指示用 ChevronUp / ChevronDown。CheckColumnWidth44 的复选列在左。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var columns: []
    property bool showCheckboxes: true
    property real totalWidth: 0
    property string sortKey: ""
    property int sortDirection: 1
    signal sortRequested(string key)

    readonly property real _h: root.th.ct("TreeTable", "HeaderHeight")
    readonly property real _chkW: root.showCheckboxes ? root.th.ct("TreeTable", "CheckColumnWidth") : 0
    readonly property real _padIn: root.th.ct("TreeTable", "CellInlinePadding")
    function colW(i) {
        var c = root.columns[i];
        if (c && c.width > 0) return c.width;
        return Math.max(0, root.totalWidth - root._chkW) / Math.max(1, root.columns.length);
    }
    width: root.totalWidth
    height: root._h

    Row {
        x: root._chkW
        spacing: 0
        Repeater {
            model: root.columns.length
            delegate: Item {
                required property int index
                width: root.colW(index)
                height: root._h
                Text {
                    x: root._padIn
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root.columns[index].title || root.columns[index].key || ""
                    color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    font.weight: root.th ? root.th.weightMedium : 500
                }
                Arc.ArcIcon {
                    visible: root.sortKey === root.columns[index].key
                    x: parent.width - 20
                    anchors.verticalCenter: parent.verticalCenter
                    width: 12; height: 12
                    th: root.th
                    kind: root.sortDirection > 0 ? "ChevronUp" : "ChevronDown"
                    color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.sortRequested(root.columns[index].key)
                }
            }
        }
    }
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: root.th ? root.th.c("Border") : "#FFE0E0E0"
    }
}
