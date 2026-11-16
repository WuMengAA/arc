// arc:DataGrid PART_Toolbar —— 搜索 / 撤销重做 / 筛选 / 列显隐 / 密度 / 导出 / 归档。
// 通过 grid 引用宿主表格（真行为全在 ArcSpreadsheet.qml 的状态函数里，无网络无 JSON）。
import QtQuick 2.15
import "." as Arc

Rectangle {
    id: root
    property var th: null
    property var grid: null
    width: parent.width; height: root.grid._toolH; color: root.th.c("Surface")
    Row {
        x: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 10
        Rectangle {
            width: 210; height: 34; radius: 17; color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("Border")
            Row {
                x: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 8
                Arc.ArcIcon { th: root.th; kind: "Search"; width: 14; height: 14; color: root.th.c("TextMuted"); anchors.verticalCenter: parent.verticalCenter }
                TextInput { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  width: 160; anchors.verticalCenter: parent.verticalCenter; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); selectByMouse: true
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  visible: parent.text === ""; text: "Search"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM") }
                    onTextChanged: { root.grid.query = text; root.grid._touch(); } }
            }
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: String(root.grid._visibleRows().length) + " rows"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM"); anchors.verticalCenter: parent.verticalCenter }
        Item { width: Math.max(8, parent.parent.width - 700); height: 1 }
        Repeater {
            model: ["Undo2", "Redo2", "Filter", "Columns2", "Rows3", "Download"]
            delegate: Rectangle {
                required property var modelData
                width: 32; height: 32; radius: 8
                color: root.grid._toolActive(modelData) ? root.th.c("SurfaceMuted") : "transparent"
                Arc.ArcIcon { anchors.centerIn: parent; th: root.th; kind: modelData; width: 16; height: 16; color: root.grid._toolActive(modelData) ? root.th.a("accent") : root.th.c("TextSecondary") }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.grid._tool(modelData) }
            }
        }
        Arc.ArcButton { th: root.th; text: root.grid._checked.length ? "Archive " + root.grid._checked.length : "Export"; size: "sm"; onClicked: root.grid._checked.length ? root.grid._archive() : root.grid._export() }
    }
    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.th.c("Border") }
}
