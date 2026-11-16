// arc:SidebarSection —— Sidebar.cs 真值：分组标题点击折叠、项带 children 时点击展开嵌套行。
// 令牌：SectionHeaderHeight 28 / NestedRowHeight 30 / ChildrenMargin [26,0,0,0] / ChevronSize 14 / ChevronStroke 2。
// 动效：height 与 rotation 都走 th.dur("Standard") + th.ease("Standard")，非硬编码 180ms。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property var section: null          // { header, items:[{key,label,icon,children?}] }
    property string currentKey: ""
    property bool collapsed: false
    signal navigate(string key)
    property bool expanded: true
    property var openKeys: []
    readonly property real _rowH: th.n("sidebar", "RowHeight")
    readonly property real _nestH: th.n("sidebar", "NestedRowHeight")
    readonly property real _indent: th.t4(th.n("sidebar", "ChildrenMargin"), 0)
    readonly property real _chev: th.ct("Sidebar", "ChevronSize")
    readonly property real _gap: th.n("sidebar", "RowGap")
    readonly property real _secH: th.n("sidebar", "SectionHeaderHeight")
    width: 240; height: _col.implicitHeight
    function isOpen(k) { for (var i = 0; i < openKeys.length; i++) if (openKeys[i] === k) return true; return false; }
    function toggleOpen(k) {
        var a = []; for (var i = 0; i < openKeys.length; i++) if (openKeys[i] !== k) a.push(openKeys[i]);
        if (!root.isOpen(k)) a.push(k);
        root.openKeys = a;
    }
    Column {
        id: _col
        width: parent.width
        spacing: 0
        Item {
            width: parent.width
            height: (root.section && root.section.header) ? root._secH : 0
            visible: height > 0
            Row {
                anchors.verticalCenter: parent.verticalCenter
                x: 6; spacing: 6
                ArcIcon {
                    th: root.th; kind: "ChevronRight"; width: root.th.ct("Sidebar", "ChevronSize"); height: root.th.ct("Sidebar", "ChevronSize")
                    color: root.th.c("TextMuted"); strokeWidth: root.th.ct("Sidebar", "ChevronStroke")
                    rotation: root.expanded ? 90 : 0
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on rotation { NumberAnimation { duration: root.th.dur("Standard"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
                }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    visible: !root.collapsed; anchors.verticalCenter: parent.verticalCenter
                    text: (root.section && root.section.header) || ""
                    color: root.th.c("TextMuted"); font.pixelSize: 14
                    font.weight: root.th.design("WeightMedium"); font.letterSpacing: 0.4
                }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.expanded = !root.expanded }
        }
        Item {
            id: _host
            width: parent.width
            height: root.expanded ? _items.implicitHeight : 0
            clip: true
            Behavior on height { NumberAnimation { duration: root.th.dur("Standard"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
            Column {
                id: _items
                width: parent.width
                spacing: root._gap
                Repeater {
                    model: (root.section && root.section.items) || []
                    delegate: Column {
                        id: _grp
                        required property var modelData
                        readonly property bool _hasKids: (modelData.children || []).length > 0
                        readonly property bool _open: root.isOpen(modelData.key)
                        width: _items.width; spacing: root._gap
                        Rectangle {
                            id: _row
                            width: parent.width; height: root._rowH
                            radius: root.th.n("sidebar", "RowRadius")
                            color: root.currentKey === modelData.key ? root.th.sidebar("RowSelectedFill")
                                 : _ma.containsMouse ? root.th.sidebar("RowHoverFill") : "transparent"
                            Behavior on color { ColorAnimation { duration: root.th.dur("Instant") } }
                            Row {
                                anchors.verticalCenter: parent.verticalCenter; x: 12; spacing: 10
                                ArcIcon {
                                    th: root.th; kind: modelData.icon || "Circle"
                                    width: 16; height: 16; strokeWidth: root.th.n("sidebar", "RowGlyphStroke")
                                    color: root.currentKey === modelData.key ? root.th.c("Foreground") : root.th.c("TextSecondary")
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                                    visible: !root.collapsed; anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.label; color: root.currentKey === modelData.key ? root.th.c("Foreground") : root.th.c("TextSecondary")
                                    font.pixelSize: root.th.n("sidebar", "RowFontSize")
                                    font.weight: root.currentKey === modelData.key ? root.th.design("WeightMedium") : root.th.design("WeightRegular")
                                }
                                ArcIcon {
                                    visible: _grp._hasKids && !root.collapsed
                                    th: root.th; kind: "ChevronRight"; width: root._chev; height: root._chev
                                    strokeWidth: root.th.ct("Sidebar", "ChevronStroke"); color: root.th.c("TextMuted")
                                    rotation: _grp._open ? 90 : 0
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on rotation { NumberAnimation { duration: root.th.dur("Standard"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
                                }
                            }
                            MouseArea {
                                id: _ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: { if (_grp._hasKids) root.toggleOpen(modelData.key); root.navigate(modelData.key); }
                            }
                        }
                        Item {
                            width: parent.width; height: _grp._open ? _kids.implicitHeight : 0; clip: true
                            Behavior on height { NumberAnimation { duration: root.th.dur("Standard"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
                            Column {
                                id: _kids; x: root._indent; width: parent.width - root._indent; spacing: root._gap
                                Repeater {
                                    model: modelData.children || []
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: _kids.width; height: root._nestH
                                        radius: root.th.n("sidebar", "RowRadius")
                                        color: root.currentKey === modelData.key ? root.th.sidebar("RowSelectedFill")
                                             : _nma.containsMouse ? root.th.sidebar("RowHoverFill") : "transparent"
                                        Row {
                                            anchors.verticalCenter: parent.verticalCenter; x: 8; spacing: 8
                                            ArcIcon { th: root.th; kind: modelData.icon || "Circle"; width: 14; height: 14; color: root.th.c("TextMuted"); anchors.verticalCenter: parent.verticalCenter }
                                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  visible: !root.collapsed; anchors.verticalCenter: parent.verticalCenter; text: modelData.label; color: root.th.c("TextSecondary"); font.pixelSize: 15 }
                                        }
                                        MouseArea { id: _nma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.navigate(modelData.key) }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        Item { width: 1; height: root.th.n("sidebar", "SectionGap") }
    }
}
