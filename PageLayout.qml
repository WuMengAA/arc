// 排版专页：Layout 域真算法 —— WaterfallPanel 最短列优先、TilePanel 等格、CyclicPanel 环绕、
// ResizablePanels 可拖拽分隔、ScrollArea + BackToTop 阈值浮出、Sticky render translation。
import QtQuick 2.15
import "." as Arc

Flickable {
    id: root
    property var th: null
    contentWidth: width
    contentHeight: _col.implicitHeight + 52
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: _col
        x: 28; y: 24
        width: root.width - 56
        spacing: 20

        Arc.ArcPageHeader {
            th: root.th; width: parent.width
            title: "Layout"
            subtitle: "Layout panels from TKCode.Arc/Layout — masonry shortest-lane packing, tile grid, cyclic wheel, resizable panels and scroll areas."
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Waterfall · shortest-lane masonry"
            description: "WaterfallPanel.cs MeasureOverride: each child goes to the lane whose ends[l] is currently shortest; ties take the first lane; start = used[lane] ? ends[lane] + Spacing : 0."
            Row {
                width: parent.width; height: 730; spacing: 16
                Column { width: (parent.width - 32) / 3; spacing: 6; Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Columns = 1 · single stack"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } Arc.ArcAutoLayout { th: root.th; width: parent.width; mode: "waterfall"; columns: 1; items: [{ label: "A", h: 80 }, { label: "B", h: 130 }, { label: "C", h: 70 }, { label: "D", h: 110 }, { label: "E", h: 90 }, { label: "F", h: 140 }] } }
                Column { width: (parent.width - 32) / 3; spacing: 6; Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Columns = 2 · shortest lane"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } Arc.ArcAutoLayout { th: root.th; width: parent.width; mode: "waterfall"; columns: 2; items: [{ label: "A", h: 80 }, { label: "B", h: 130 }, { label: "C", h: 70 }, { label: "D", h: 110 }, { label: "E", h: 90 }, { label: "F", h: 140 }] } }
                Column { width: (parent.width - 32) / 3; spacing: 6; Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Columns = 3 · shortest lane"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } Arc.ArcAutoLayout { th: root.th; width: parent.width; mode: "waterfall"; columns: 3; items: [{ label: "A", h: 80 }, { label: "B", h: 130 }, { label: "C", h: 70 }, { label: "D", h: 110 }, { label: "E", h: 90 }, { label: "F", h: 140 }] } }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Tile & cyclic"
            description: "TilePanel.cs first-fit equal cells (MinCellSize 96 / Spacing 8); CyclicPanel.cs offset wraps in item units (VisibleItemCount 5 / AnimationDuration 240ms)."
            Row {
                width: parent.width; height: 460; spacing: 20
                Column { width: (parent.width - 20) / 2; spacing: 6; Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Tile panel"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } Arc.ArcAutoLayout { th: root.th; width: parent.width; mode: "tile"; items: [{ label: "1" }, { label: "2" }, { label: "3" }, { label: "4" }, { label: "5" }, { label: "6" }, { label: "7" }, { label: "8" }] } }
                Column { width: (parent.width - 20) / 2; spacing: 6; Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Cyclic panel"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } Arc.ArcAutoLayout { th: root.th; width: parent.width; mode: "cyclic"; items: [{ icon: "Circle" }, { icon: "Star" }, { icon: "Layers" }, { icon: "Zap" }, { icon: "Target" }, { icon: "Sparkles" }] } }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Resizable panels"
            description: "Expand/ResizablePanels — DividerThickness 1, DefaultMinWidth 80; drag the divider, double-click to restore."
            Arc.ArcResizablePanels { th: root.th; width: parent.width; height: 240 }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Scroll area · back to top"
            description: "Navigation/ScrollArea TrackThickness 11 + BackToTop Threshold 200 / Inset 16 / HiddenScale 0.86; scroll past 200 to reveal the round button (preview forced on here)."
            Arc.ArcScrollArea {
                th: root.th; width: 420; height: 320; previewShown: true
                rows: ["Overview", "Tokens", "Palette", "Typography", "Spacing", "Radius", "Motion", "Elevation", "Icons", "Components", "Blocks", "Presets"]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Sticky group headers"
            description: "Layout/Sticky.cs — render translation only: header y follows the viewport top, then is pushed out by the next group; content height never changes."
            Arc.ArcStickyList {
                th: root.th; width: 420; height: 300
                groups: [
                    { name: "A · Atoms", items: ["Button", "Badge", "Avatar", "Checkbox", "Input"] },
                    { name: "B · Molecules", items: ["Dialog", "Tabs", "Tooltip", "Toast", "Select"] },
                    { name: "C · Surfaces", items: ["Settings", "Kanban", "Spreadsheet", "Workflow", "Dock"] }
                ]
            }
        }
    }
}
