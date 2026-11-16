// 陈列页 · Menus & Overlays（官方目录 Menus / Overlays）。
// 覆盖层组件 open 态会向下溢出自身边界 → 每卡给 z 且给足高度，避免被后续卡盖住。
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
            title: "Menus & Overlays"
            subtitle: "ContextMenu, DropdownMenu, RadialMenu, UserMenu, BottomSheet, Drawer, HoverCard, Popover — Menus / Overlays."
        }

        Arc.ArcCard {
            width: parent.width; th: root.th; z: 18
            title: "DropdownMenu"
            description: "Menus/DropdownMenu — trigger + MenuSurface/MenuEntry shared panel."
            Arc.ArcDropdownMenu {
                width: 300; height: 210; th: root.th; open: true; label: "Options"
                items: [
                    {label:"Edit", icon:"FileText", shortcut:"⌘E"},
                    {label:"Duplicate", icon:"Copy", shortcut:"⌘D"},
                    {label:"", separator:true},
                    {label:"Delete", icon:"Trash2", danger:true}
                ]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th; z: 17
            title: "ContextMenu"
            description: "Menus/ContextMenu — anchorX/anchorY + dotted separators + checked rows."
            Arc.ArcContextMenu {
                width: 340; height: 216; th: root.th; open: true; anchorX: 12; anchorY: 8
                items: [
                    {label:"Open", icon:"Play"},
                    {label:"Rename", icon:"FileText", checked:true},
                    {label:"", separator:true},
                    {label:"Archive", icon:"Download", disabled:true}
                ]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th; z: 16
            title: "RadialMenu"
            description: "Menus/RadialMenu — sectors via SVG data URI (InnerRadius/OuterRadius/SectorGap)."
            Arc.ArcRadialMenu {
                width: 220; height: 220; th: root.th; open: true; centerLabel: "Arc"
                items: [{label:"Home",icon:"LayoutDashboard"},{label:"Users",icon:"Users"},
                        {label:"Chart",icon:"TrendingUp"},{label:"Gear",icon:"Settings"},
                        {label:"Bell",icon:"Bell"},{label:"Exit",icon:"LogOut"}]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th; z: 15
            title: "UserMenu"
            description: "Menus/UserMenu — avatar + status dot + account menu panel."
            Arc.ArcUserMenu {
                width: 320; height: 230; th: root.th; open: true
                name: "Ada Lovelace"; role: "Workspace owner"; status: "online"
                items: [
                    {label:"Profile", icon:"UserCog"},
                    {label:"Settings", icon:"Settings"},
                    {label:"", separator:true},
                    {label:"Sign out", icon:"LogOut", danger:true}
                ]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th; z: 14
            title: "Popover"
            description: "Overlays/Popover — trigger + floating frame (PanelMinWidth/MaxWidth)."
            Arc.ArcPopover {
                width: 340; height: 190; th: root.th; open: true; triggerText: "Open popover"
                Column {
                    width: 260; spacing: 6
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Popover title"; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeBase"); font.weight: root.th.design("WeightMedium") }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Rich content, clicks and inputs live here."; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th; z: 13
            title: "HoverCard"
            description: "Overlays/HoverCard — profile card with stats (hover the link to reveal)."
            Arc.ArcHoverCard {
                width: 340; height: 300; th: root.th; previewOpen: true
                name: "Ada Lovelace"; role: "Product engineer"
                bio: "Writes the design system and the release notes."
                stats: [{value:"128",label:"Repos"},{value:"1.4k",label:"Commits"}]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th; z: 12
            title: "BottomSheet"
            description: "Overlays/BottomSheet — grabber, header, body, actions, scrim."
            Arc.ArcBottomSheet {
                width: 420; height: 300; th: root.th; open: true
                title: "Export report"; description: "Choose a format for the quarterly summary."
                Column {
                    width: 360; spacing: 8
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "• PDF — full tables and charts"; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "• CSV — raw rows only"; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
                }
                actions: Row {
                    spacing: 8
                    Arc.ArcButton { th: root.th; text: "Cancel"; variant: "secondary"; size: "sm" }
                    Arc.ArcButton { th: root.th; text: "Export"; variant: "primary"; size: "sm" }
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th; z: 11
            title: "Drawer"
            description: "Overlays/Drawer — right-side panel with radius tokens per side."
            Arc.ArcDrawer {
                width: 460; height: 280; th: root.th; open: true; side: "right"
                title: "Filters"; description: "Narrow the current view."
                Column {
                    width: 300; spacing: 8
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Status: all active"; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
                    Arc.ArcCheckbox { th: root.th; text: "Include archived"; checkState: 1 }
                }
            }
        }
    }
}
