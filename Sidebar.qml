// arc:Sidebar —— SidebarTheme 真值：展开 240 / 轨道 64、行高 32、行圆角 10、行内边距 12、
// 行字号 13、图标 16、区块间距 16、页脚边距 12,10。Header 是 28x28 圆角 8 的 Foreground 底 + 图标 + 名称。
import QtQuick 2.15

Rectangle {
    id: root

    property var th: null
    property bool collapsed: false
    property var sections: []       // [{ header: "", items: [{key,label,icon}] }]
    property string currentKey: ""
    property string workspaceName: ""
    property string accountName: ""
    property string accountRole: ""
    signal navigate(string key)
    signal toggleCollapse()
    signal signOut()

    readonly property real _w: collapsed ? th.n("sidebar","RailWidth") : th.n("sidebar","ExpandedWidth")
    readonly property real _rowH: th.n("sidebar","RowHeight")
    readonly property real _pad: 12

    implicitWidth: _w
    color: th.sidebar("PaneFill")
    Behavior on implicitWidth { NumberAnimation { duration: th.dur("Exit"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }

    Column {
        id: _col
        x: root._pad
        width: root.width - 2 * root._pad
        y: root.th.t4(root.th.n("sidebar","HeaderMargin"), 1)
        spacing: 0

        // ── Header：28x28 圆角 8 的 Foreground 底 + LayoutDashboard + 工作区名 ──
        Item {
            width: parent.width
            height: 32
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Rectangle {
                    width: 28; height: 28; radius: 8
                    color: root.th.c("Foreground")
                    ArcIcon {
                        anchors.centerIn: parent
                        th: root.th
                        kind: "LayoutDashboard"
                        color: root.th.c("Background")
                        width: 14; height: 14
                        strokeWidth: 1.8
                    }
                }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    visible: !root.collapsed
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.workspaceName
                    color: root.th.c("Foreground")
                    font.pixelSize: root.th.design("TypeSM")
                    font.weight: root.th.design("WeightMedium")
                }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.toggleCollapse() }
        }

        Item { width: 1; height: root.th.n("sidebar","SectionGap") }

        // ── Sections ──
        Repeater {
            model: root.sections
            delegate: Column {
                id: _sec
                required property var modelData
                width: _col.width
                spacing: 0

                Item {
                    visible: _sec.modelData.header !== undefined && _sec.modelData.header !== ""
                    width: parent.width
                    height: visible ? root.th.n("sidebar","SectionHeaderHeight") : 0
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        anchors.verticalCenter: parent.verticalCenter
                        x: 6
                        visible: !root.collapsed
                        text: _sec.modelData.header || ""
                        color: root.th.c("TextMuted")
                        font.pixelSize: 14
                        font.weight: root.th.design("WeightMedium")
                        font.letterSpacing: 0.4
                    }
                }

                Repeater {
                    model: _sec.modelData.items
                    delegate: Rectangle {
                        id: _row
                        required property var modelData
                        readonly property bool _on: root.currentKey === modelData.key
                        readonly property bool _hover: _ma.containsMouse
                        width: _col.width
                        height: root._rowH
                        radius: root.th.n("sidebar","RowRadius")
                        color: _on ? root.th.sidebar("RowSelectedFill")
                             : (_hover ? root.th.sidebar("RowHoverFill") : "transparent")
                        Behavior on color { ColorAnimation { duration: th.dur("Instant") } }

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 12
                            spacing: 10
                            ArcIcon {
                                th: root.th
                                kind: modelData.icon
                                width: 16; height: 16
                                color: _row._on ? root.th.c("Foreground") : root.th.c("TextSecondary")
                                strokeWidth: 1.6
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                                visible: !root.collapsed
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                color: _row._on ? root.th.c("Foreground") : root.th.c("TextSecondary")
                                font.pixelSize: root.th.n("sidebar","RowFontSize")
                                font.weight: _row._on ? root.th.design("WeightMedium") : root.th.design("WeightRegular")
                            }
                        }

                        MouseArea {
                            id: _ma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.navigate(modelData.key)
                            Accessible.role: Accessible.Button; Accessible.name: modelData.label
                        }
                    }
                }

                Item { width: 1; height: root.th.n("sidebar","SectionGap") }
            }
        }
    }

    // ── Footer：头像 + 姓名/角色 + 登出 ──
    Rectangle {
        id: _footer
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.th.t4(root.th.n("sidebar","FooterMargin"), 3)
        x: root._pad
        width: root.width - 2 * root._pad
        height: 44
        radius: 10
        color: _fma.containsMouse ? root.th.sidebar("RowHoverFill") : "transparent"

        Row {
            anchors.verticalCenter: parent.verticalCenter
            x: 6
            spacing: 10
            ArcAvatar { th: root.th; name: root.accountName; size: "sm"; seed: 1; anchors.verticalCenter: parent.verticalCenter }
            Column {
                visible: !root.collapsed
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    text: root.accountName
                    color: root.th.c("Foreground")
                    font.pixelSize: root.th.design("TypeSM")
                    font.weight: root.th.design("WeightMedium")
                }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    text: root.accountRole
                    color: root.th.c("TextMuted")
                    font.pixelSize: 14
                }
            }
        }

        ArcIcon {
            visible: !root.collapsed && _fma.containsMouse
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            th: root.th
            kind: "LogOut"
            width: 14; height: 14
            color: root.th.c("TextSecondary")
        }

        MouseArea { id: _fma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.signOut() }
    }
}
