// 顶栏 —— MainView.axaml：高 52、左右内边距 14、下边 1px BorderSubtle、
// 内含 sidebar 切换按钮 / 页面标题 / 搜索按钮 / 通知中心 / 主题切换。
import QtQuick 2.15

Rectangle {
    id: root

    property var th: null
    property string title: ""
    property bool collapsed: false
    signal toggleSidebar()
    signal openSearch()
    signal cycleTheme()

    implicitHeight: 52
    color: th.c("Background")

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: th.design("EdgeThickness")
        color: th.c("BorderSubtle")
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        x: 14
        spacing: 8

        // sidebar 折叠
        Item {
            width: 28; height: 28
            ArcIcon {
                anchors.centerIn: parent
                th: root.th
                kind: "PanelLeft"
                width: 17; height: 17
                color: _m1.containsMouse ? root.th.c("Foreground") : root.th.c("TextSecondary")
            }
            MouseArea { id: _m1; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.toggleSidebar() }
        }

        // 页面标题
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            anchors.verticalCenter: parent.verticalCenter
            text: root.title
            color: root.th.c("Foreground")
            font.pixelSize: root.th.design("TypeSM")
            font.weight: root.th.design("WeightMedium")
        }
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 14
        spacing: 6

        // 搜索
        Rectangle {
            width: _sRow.implicitWidth + 24
            height: 30
            radius: root.th.t4(root.th.design("RadiusControl"), 0)
            color: _sm.containsMouse ? root.th.c("SurfaceMuted") : "transparent"
            border.width: root.th.design("EdgeThickness")
            border.color: _sm.containsMouse ? root.th.c("Border") : "transparent"
            Row {
                id: _sRow
                anchors.centerIn: parent
                spacing: 6
                ArcIcon { th: root.th; kind: "Search"; width: 14; height: 14; color: root.th.c("TextSecondary"); anchors.verticalCenter: parent.verticalCenter }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Search"; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM"); anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea { id: _sm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.openSearch() }
        }

        // 通知
        Item {
            width: 30; height: 30
            ArcIcon {
                anchors.centerIn: parent
                th: root.th
                kind: "Bell"
                width: 16; height: 16
                color: _nm.containsMouse ? root.th.c("Foreground") : root.th.c("TextSecondary")
            }
            Rectangle {
                width: 6; height: 6; radius: 3
                color: root.th.c("Danger")
                x: 19; y: 5
            }
            MouseArea { id: _nm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
        }

        // 主题切换
        Item {
            width: 30; height: 30
            ArcIcon {
                anchors.centerIn: parent
                th: root.th
                kind: root.th.dark ? "Moon" : "Sun"
                width: 16; height: 16
                color: _tm.containsMouse ? root.th.c("Foreground") : root.th.c("TextSecondary")
            }
            MouseArea { id: _tm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.cycleTheme() }
        }
    }
}
