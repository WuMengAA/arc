// 陈列页 · Overlays & Tables（官方目录 Overlays / Navigation / Avatars / Tables / Pickers）。
// 与 PageControls.qml 同形态（Flickable + Column + ArcCard 分区），供真机预览逐项核对。
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
            title: "Overlays & Tables"
            subtitle: "Dialog, Tabs, Tooltip, Toast, DatePicker, Avatar, Badge, Table — Overlays / Navigation / Avatars / Tables / Pickers."
        }

        // ── Dialog：遮罩 + 居中面板 + 头/描述/操作区 ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Dialog"
            description: "Overlays/Dialog — ScrimColor, RadiusSurface panel 360/440/560, 32px close button."
            Item {
                width: parent.width; height: 250
                clip: true
                Rectangle { anchors.fill: parent; color: root.th.c("Background") }
                Arc.ArcDialog {
                    anchors.fill: parent
                    th: root.th
                    open: true; size: "sm"
                    title: "Invite a teammate"
                    description: "They will receive an email with a link to join this workspace."
                }
            }
        }

        // ── Tabs：轨道 + 滑动选中块 + 内容宿主 ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Tabs"
            description: "Navigation/Tabs — SurfaceMuted shell, gliding Surface pill, 88px min trigger."
            Column {
                width: parent.width; spacing: 12
                Arc.ArcTabs {
                    width: 420
                    th: root.th
                    value: "overview"
                    options: [{value:"overview",label:"Overview"},{value:"activity",label:"Activity"},
                              {value:"locked",label:"Locked",disabled:true}]
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        width: parent.width
                        text: "Overview content — selection pill glides to the active tab."
                        color: root.th.c("TextSecondary")
                        font.pixelSize: root.th.design("TypeSM")
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        // ── Tooltip：深底白字 + 小尖角 ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Tooltip"
            description: "Overlays/Tooltip — Foreground bubble, Oklch 14% hairline, 240px max width."
            Item {
                width: parent.width; height: 92
                Rectangle {
                    width: 132; height: 36; radius: 10
                    color: root.th.c("SurfaceMuted")
                    border.width: 1; border.color: root.th.c("Border")
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: "Hover target"; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
                }
                Arc.ArcTooltip {
                    x: 148; y: 0
                    th: root.th
                    text: "Copy a link to this workspace"
                }
            }
        }

        // ── Toast：状态圆盘 + 标题/描述 + 关闭 ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Toast"
            description: "Messages/Toast — 30px icon disc with true Check glyph, 416px max, RadiusPanel."
            Column {
                width: parent.width; spacing: 12
                Arc.ArcToast { th: root.th; title: "Changes saved"; description: "Your workspace settings are up to date."; tone: "success" }
                Arc.ArcToast { th: root.th; title: "Connection lost"; description: "Reconnecting in a moment."; tone: "danger" }
            }
        }

        // ── DatePicker：字段 + 弹出月历 + 页脚 ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "DatePicker"
            description: "Pickers/DatePicker — 320px popup, MonthCalendar grid, footer Clear / Today."
            Column {
                width: parent.width; spacing: 14
                Arc.ArcDatePicker { th: root.th; label: "Launch date"; value: "2026-11-14" }
                Item {
                    width: parent.width; height: 430
                    clip: true
                    Rectangle { anchors.fill: parent; color: root.th.c("Background") }
                    Arc.ArcDatePicker { th: root.th; label: "Open panel"; value: "2026-11-14"; isOpen: true }
                }
            }
        }

        // ── Avatar：五档尺寸 + 状态点 + 真源码 monochrome ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Avatar"
            description: "Avatars/Avatar — 28/36/48/64/88, status dots (online / busy), SurfaceMuted variant."
            Row {
                width: parent.width; spacing: 16
                Arc.ArcAvatar { th: root.th; name: "Ada Lind"; size: "sm"; seed: 1; status: "online" }
                Arc.ArcAvatar { th: root.th; name: "Ada Lind"; size: "md"; seed: 2; status: "busy" }
                Arc.ArcAvatar { th: root.th; name: "Ada Lind"; size: "lg"; seed: 3 }
                Arc.ArcAvatar { th: root.th; name: "Ada Lind"; size: "lgPlus"; seed: 4 }
                Arc.ArcAvatar { th: root.th; name: "Ada Lind"; size: "xl"; monochrome: true }
            }
        }

        // ── Badge：五 tone + small + icon + hover ──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Badge"
            description: "Avatars/Badge — ct() tone fills, 26/22 heights, icon slot and hover wash."
            Flow {
                width: parent.width; spacing: 10
                Arc.ArcBadge { th: root.th; text: "Neutral" }
                Arc.ArcBadge { th: root.th; text: "Success"; tone: "success"; icon: "Check" }
                Arc.ArcBadge { th: root.th; text: "Info"; tone: "info" }
                Arc.ArcBadge { th: root.th; text: "Warning"; tone: "warning" }
                Arc.ArcBadge { th: root.th; text: "Danger"; tone: "danger" }
                Arc.ArcBadge { th: root.th; text: "Small"; tone: "success"; small: true }
            }
        }

        // ── Table：紧凑断点 + 列对齐 + 斑马纹（ct 真值）──
        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Table"
            description: "Tables/Table — 44/52 rows, 16px cell inset, StripeBackground, right-aligned numeric column."
            Arc.ArcTable {
                width: parent.width; height: 210
                th: root.th
                caption: "Invoices"
                columns: [{key:"id",title:"Invoice",width:180},{key:"status",title:"Status",width:160},{key:"amount",title:"Amount",align:"right"}]
                rows: [{id:"INV-2026-011",status:"Paid",amount:"$1,240.00"},
                       {id:"INV-2026-012",status:"Pending",amount:"$860.00"},
                       {id:"INV-2026-013",status:"Paid",amount:"$2,110.00"}]
            }
        }
    }
}

