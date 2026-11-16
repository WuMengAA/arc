// 陈列页 · Messages & Expand（官方目录 Messages / Content / Navigation / Expand / Forms）。
// Accordion / Textarea / RadioGroup。同 PageControls/PageControls2 形态，供真机预览逐项核对。
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
            th: root.th
            title: "Messages & Expand"
            subtitle: "Alert, EmptyState, Breadcrumb, Pagination, Stepper, Accordion, Textarea, RadioGroup — Messages / Content / Navigation / Expand / Forms."
        }

        // ── Alert：四 tone 图标 + 标题/描述 + dismiss ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Alert"
            description: "Messages/Alert — tone icon + Surface panel, 18px glyph, 28px dismiss."
            Column {
                width: parent.width; spacing: 10
                Arc.ArcAlert { width: parent.width; th: root.th; tone: "info"; title: "A new version is available"; description: "Refresh to get the latest workspace features." }
                Arc.ArcAlert { width: parent.width; th: root.th; tone: "success"; title: "Payment received"; description: "Invoice INV-2026-011 has been settled." }
                Arc.ArcAlert { width: parent.width; th: root.th; tone: "warning"; title: "Storage almost full"; description: "You have used 92% of your plan quota."; dismissible: true }
                Arc.ArcAlert { width: parent.width; th: root.th; tone: "danger"; title: "Sync failed"; description: "Could not reach the relay. Retry in a moment." }
            }
        }

        // ── EmptyState：默认 + compact + 带动作 ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "EmptyState"
            description: "Cards/EmptyState — centered icon block 48/32, maxWidth 288 description."
            Row {
                width: parent.width; spacing: 12
                Arc.ArcEmptyState {
                    width: 320; th: root.th; icon: "Inbox"
                    title: "No messages yet"; description: "When your team mentions you, it will show up here."
                    actionText: "Refresh"
                }
                Arc.ArcEmptyState {
                    width: 260; th: root.th; icon: "Search"; small: true
                    title: "No results"; description: "Try a different keyword."
                }
            }
        }

        // ── Breadcrumb：普通 + 折叠 ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Breadcrumb"
            description: "Navigation/Breadcrumb — ChevronRight 16, current AccentStrong, hover underline."
            Column {
                width: parent.width; spacing: 16
                Arc.ArcBreadcrumb {
                    th: root.th
                    crumbs: [{label:"Workspace"},{label:"Projects"},{label:"Arc Admin",current:true}]
                }
                Arc.ArcBreadcrumb {
                    th: root.th; maxVisible: 3
                    crumbs: [{label:"Workspace"},{label:"Design"},{label:"Tokens"},{label:"Colors"},{label:"Accent",current:true}]
                }
            }
        }

        // ── Pagination：10 页，当前第 4 页（两侧省略号）──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Pagination"
            description: "Navigation/Pagination — 36px buttons, gliding Surface mark, boundary ellipses."
            Column {
                width: parent.width; spacing: 14
                Arc.ArcPagination { th: root.th; pageCount: 10; currentPage: 4 }
                Arc.ArcPagination { th: root.th; pageCount: 5; currentPage: 1 }
            }
        }

        // ── Stepper：4 步（complete / current / error / upcoming）+ caption ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Stepper"
            description: "Progress/Stepper — 28px disc + halo, Number/Check/Error glyph, connecting track."
            Arc.ArcStepper {
                width: parent.width; th: root.th
                currentIndex: 1
                captionVisible: true
                captionLabel: "Step 2 of 4 — Review details"
                captionDetail: "A verification step failed and needs your attention."
                steps: [{label:"Account",detail:"Created"},{label:"Details",detail:"In progress"},
                        {label:"Verify",detail:"Action needed",status:"error"},{label:"Done",detail:"Pending"}]
            }
        }

        // ── Accordion：md 三行（首行展开）+ lg 两行 ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Accordion"
            description: "Expand/Accordion — 1px row rules, ChevronDown flip, spring answer."
            Column {
                width: parent.width; spacing: 18
                Arc.ArcAccordion {
                    width: parent.width; th: root.th; expandedIndex: 0
                    items: [{header:"What is TKCode.Arc?",answer:"A 112-component Avalonia control library with 59 page blocks, MIT licensed."},
                            {header:"How are tokens sourced?",answer:"From tests/Baselines/tokens JSON plus each control's Token.cs."},
                            {header:"Can I change the theme?",answer:"Yes — dark mode and eight accent palettes are built in."}]
                }
                Arc.ArcAccordion {
                    width: parent.width; th: root.th; large: true; expandedIndex: 1
                    items: [{header:"Billing questions",answer:"Invoices are issued on the first of each month."},
                            {header:"Team management",answer:"Invite members from the Team page and assign roles."}]
                }
            }
        }

        // ── Textarea：多行 + invalid + disabled ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Textarea"
            description: "TextFields/Textarea — FrameMinHeight 110, FieldFrame tokens, resize grip."
            Row {
                width: parent.width; spacing: 16
                Arc.ArcTextarea {
                    width: 320; th: root.th; label: "Notes"
                    placeholder: "Write a short note…"
                    description: "Markdown is supported."
                    text: "Ported from the real Theme.axaml and TextareaToken.cs."
                }
                Arc.ArcTextarea {
                    width: 300; th: root.th; label: "Feedback"
                    error: "This field is required."; isInvalid: true
                }
            }
        }

        // ── RadioGroup：三档 + 描述 + 选中态 ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "RadioGroup"
            description: "Toggles/RadioGroup — 17px ring / 7px dot, ControlOn fill, 8px row gap."
            Arc.ArcRadioGroup {
                width: 480; th: root.th; legend: "Deployment target"
                value: "beta"
                options: [{value:"alpha",label:"Alpha",description:"Internal builds, updated hourly."},
                          {value:"beta",label:"Beta",description:"Invited testers, promoted after 5h."},
                          {value:"stable",label:"Stable",description:"Public channel, promoted after 24h."}]
            }
        }
    }
}
