// 陈列页 · Blocks & screens / Surfaces：组件动效、设置界面、看板、导入向导、
// 电子表格与行内编辑、工作流、自动排版、停靠布局、PDF/图片查看器、控制中心、抽屉堆叠。
// 形态照 PageDashboard.qml：Flickable + Column(x28,y24,spacing20) + ArcPageHeader + N 个 ArcCard。
import QtQuick 2.15
import "." as Arc

Flickable {
    id: root
    property var th: null
    contentWidth: width
    contentHeight: _col.implicitHeight + 52
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    WheelHandler { acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad; onWheel: function (ev) { root.contentY = Math.max(0, Math.min(root.contentHeight - root.height, root.contentY - ev.angleDelta.y)); } }

    Column {
        id: _col
        x: 28; y: 24
        width: root.width - 56
        spacing: 20

        Arc.ArcPageHeader {
            th: root.th; width: parent.width
            title: "Surfaces"
            subtitle: "Blocks / Screens — collapsible sidebar, settings, kanban, import wizard, spreadsheet, workflow, auto layout, dock, viewers, control center, sheet stack."
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Component motion · sidebar expand & collapse"
            description: "Block/AppShell/Sidebar + Expand/ExpandableCard — height + chevron rotation on th.dur(Standard)."
            Row {
                width: parent.width; height: 340; spacing: 20
                Arc.ArcSidebarTree {
                    th: root.th; width: 240; height: 340
                    sections: [
                        { header: "Workspace", items: [
                            { key: "home", label: "Home", icon: "LayoutDashboard", children: [{ key: "recent", label: "Recent", icon: "Clock" }, { key: "starred", label: "Starred", icon: "Star" }] },
                            { key: "projects", label: "Projects", icon: "Folder", children: [{ key: "arc", label: "Arc port", icon: "Layers" }] },
                            { key: "team", label: "Team", icon: "Users" }
                        ] },
                        { header: "System", items: [{ key: "settings", label: "Settings", icon: "Settings" }] }
                    ]
                }
                Column {
                    width: parent.width - 260; spacing: 14
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Click a group header or a row with children to expand / collapse."; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM"); width: parent.width; wrapMode: Text.WordWrap }
                    Arc.ArcExpandableCard {
                        th: root.th; width: parent.width
                        title: "Motion tokens"; description: "Standard 240ms · EaseStandard cubic-bezier(0.22,1,0.36,1)"
                        expanded: true
                        Column { width: parent.width; spacing: 6; Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Instant 120ms / Fast 160ms / Exit 180ms / Standard 240ms"; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS") } Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Spring settle 716.7ms (Smooth) · 466.7ms (Snappy)"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } }
                    }
                    Arc.ArcExpandableCard {
                        th: root.th; width: parent.width
                        title: "Nested rows"; description: "ChildrenMargin 26 · NestedRowHeight 30"
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Nested items animate their own height with the same easing curve."; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS"); width: parent.width; wrapMode: Text.WordWrap }
                    }
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Settings interface"
            description: "Blocks/Settings/SettingsPage — NavWidth 248, gliding pill, settings rows, unsaved SaveBar."
            Arc.ArcSettingsPage {
                th: root.th; width: parent.width; height: 460
                groups: [
                    { name: "General", rows: [{ label: "Language", details: "Auto-detect from system", value: "EN" }, { label: "Start at login", details: "Launch the app when you sign in", value: "On" }, { label: "Updates", details: "Stable channel", value: "Auto" }] },
                    { name: "Appearance", rows: [{ label: "Theme", details: "Follow system appearance", value: "Light" }, { label: "Accent", details: "Violet by default", value: "Violet" }] },
                    { name: "Privacy", rows: [{ label: "Telemetry", details: "Anonymous usage data", value: "Off" }] }
                ]
                active: "General"
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Kanban board"
            description: "Field app 4.2 · real SampleBoard.cs data. Drag cards between lanes, switch Status/By person, click + to add, open a card to move/delete."
            Arc.ArcKanbanBoard { th: root.th; width: parent.width; height: 640 }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Import wizard"
            description: "customers-q3.csv real 22 rows. Click a target dropdown to re-map (counter updates), step through Upload/Match/Review/Import."
            Arc.ArcImportWizard { th: root.th; width: Math.min(parent.width, 760); height: 640 }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Spreadsheet & inline editing"
            description: "DataGrid — click any cell to edit (Enter saves / Esc cancels), Undo/Redo, Search, sort by column, Filter, hide column, density, check & archive, Export."
            Column {
                width: parent.width; spacing: 16
                Arc.ArcSpreadsheet { th: root.th; width: parent.width; height: 400; variant: "inline" }
                Arc.ArcSpreadsheet { th: root.th; width: parent.width; height: 400; variant: "ledger" }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Workflow canvas"
            description: "Send test event animates node states; Arrange/Reset re-layouts; click a node to select, drag to move, Delete selected removes it; zoom −/+."
            Column {
                width: parent.width; spacing: 16
                Arc.ArcWorkflow { th: root.th; width: parent.width; height: 460; variant: "run" }
                Arc.ArcWorkflow { th: root.th; width: parent.width; height: 560; variant: "arrange" }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Automatic layout"
            description: "Layout/WaterfallPanel + TilePanel + CyclicPanel — three token-driven arrangements."
            Row {
                width: parent.width; height: 480; spacing: 16
                Column { width: (parent.width - 32) / 3; spacing: 6; Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Waterfall"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } Arc.ArcAutoLayout { th: root.th; width: parent.width; mode: "waterfall"; items: [{ label: "A", h: 80 }, { label: "B", h: 120 }, { label: "C", h: 70 }, { label: "D", h: 110 }, { label: "E", h: 90 }, { label: "F", h: 130 }] } }
                Column { width: (parent.width - 32) / 3; spacing: 6; Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Tile"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } Arc.ArcAutoLayout { th: root.th; width: parent.width; mode: "tile"; items: [{ label: "1" }, { label: "2" }, { label: "3" }, { label: "4" }, { label: "5" }, { label: "6" }] } }
                Column { width: (parent.width - 32) / 3; spacing: 6; Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Cyclic"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } Arc.ArcAutoLayout { th: root.th; width: parent.width; mode: "cyclic"; items: [{ icon: "Circle" }, { icon: "Star" }, { icon: "Layers" }, { icon: "Zap" }, { icon: "Target" }] } }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Docked layout"
            description: "DockSamples.cs IDE layout — switch Explorer/Search, click document tabs, drag the split to resize, click Outline to expand, drag the floating card."
            Arc.ArcDockLayout { th: root.th; width: parent.width; height: 430 }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "PDF & image viewers"
            description: "TKCode.Arc.Pdf/PageViewer + Media/ImageCompare/Carousel — sidebar thumbnails, search, drag-to-compare."
            Column {
                width: parent.width; spacing: 14
                Arc.ArcPdfViewer { th: root.th; width: parent.width; height: 430 }
                Arc.ArcImageViewer { th: root.th; width: parent.width; height: 360 }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Control center & sheet stack"
            description: "Special/Surfaces — dial ticks, quick tiles, detail scrim; layered sheets with depth scale and peek."
            Row {
                width: parent.width; height: 400; spacing: 20
                Arc.ArcControlCenter { th: root.th; width: 420; height: 400 }
                Arc.ArcSheetStack { th: root.th; width: parent.width - 440; height: 400 }
            }
        }
    }
}
