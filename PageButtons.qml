// 陈列页 · Buttons（官方组件目录 Buttons）：10 个按钮控件。
import QtQuick 2.15
import "." as Arc

Flickable {
    id: root
    property var th: null
    property bool _swDarkA: false
    property bool _swDarkB: true
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
            title: "Buttons"
            subtitle: "Buttons / TKCode.Arc — ActionButton, ActionSwap, ButtonGroup, ConfirmMorph, CopyButton, ExpandingButtonGroup, FloatingButtonGroup, IconMorph, SplitButton, ThemeSwitcher."
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "ActionButton & ActionSwap"
            description: "idle / pending / success / failed states; SwapState success/warning/danger."
            Row {
                width: parent.width; spacing: 14
                Arc.ArcActionButton { th: root.th; text: "Run action"; icon: "Play"; stateName: "idle" }
                Arc.ArcActionButton { th: root.th; text: "Running"; icon: "LoaderCircle"; stateName: "pending" }
                Arc.ArcActionButton { th: root.th; text: "Done"; icon: "Check"; stateName: "success" }
                Arc.ArcActionButton { th: root.th; text: "Failed"; icon: "CircleX"; stateName: "failed" }
                Arc.ArcActionSwap { th: root.th; tone: "success"; label: "Saved" }
                Arc.ArcActionSwap { th: root.th; tone: "danger"; label: "Delete"; sizeName: "sm" }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "ButtonGroup"
            description: "outline / solid variants + horizontal & vertical layouts with gliding highlight."
            Column {
                width: parent.width; spacing: 14
                Arc.ArcButtonGroup {
                    th: root.th; value: "grid"; variant: "outline"
                    options: [{value:"list",label:"L",icon:"Menu"},{value:"grid",label:"G",icon:"Grid2X2"},{value:"chart",label:"C",icon:"TrendingUp"}]
                }
                Arc.ArcButtonGroup {
                    th: root.th; value: "day"; variant: "solid"
                    options: [{value:"day",label:"Day"},{value:"week",label:"Week"},{value:"month",label:"Month"}]
                }
                Arc.ArcButtonGroup {
                    th: root.th; value: "a"; variant: "outline"; vertical: true
                    options: [{value:"a",label:"Alpha"},{value:"b",label:"Beta"},{value:"c",label:"Stable"}]
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "ConfirmMorph & CopyButton"
            description: "Morphing delete confirmation; copy with idle/copied/error feedback."
            Row {
                spacing: 14
                Arc.ArcConfirmMorph { th: root.th; label: "Delete project"; face: "idle" }
                Arc.ArcConfirmMorph { th: root.th; label: "Are you sure?"; face: "confirm" }
                Arc.ArcCopyButton { th: root.th; label: "Copy"; copyState: "idle" }
                Arc.ArcCopyButton { th: root.th; label: "Copied"; copyState: "copied"; iconOnly: true }
                Arc.ArcCopyButton { th: root.th; label: "Retry"; copyState: "error" }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "ExpandingButtonGroup & FloatingButtonGroup"
            description: "Expanding action pills + floating tray with gliding highlight."
            Column {
                width: parent.width; spacing: 14
                Arc.ArcExpandingButtonGroup {
                    th: root.th; expandedIndex: 1
                    items: [{value:"edit",label:"Edit",icon:"FileText"},{value:"share",label:"Share",icon:"Download"},
                            {value:"del",label:"Delete",icon:"Trash2",tone:"danger"}]
                }
                Arc.ArcFloatingButtonGroup {
                    th: root.th; value: "b"
                    items: [{value:"a",icon:"Menu"},{value:"b",icon:"Zap"},{value:"c",icon:"Gauge"},{value:"d",icon:"Settings"}]
                }
                Arc.ArcFloatingButtonGroup { th: root.th; value: "a"; vertical: true; items: [{value:"a",icon:"Plus"},{value:"b",icon:"Bell"}] }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th; z: 10
            title: "SplitButton & IconMorph & ThemeSwitcher"
            description: "Primary action + chevron menu; icon cross-fade; light/dark switch."
            Row {
                width: parent.width; spacing: 14
                Arc.ArcSplitButton {
                    th: root.th; label: "Export"; icon: "Download"; open: true
                    menuItems: [{label:"PDF"},{label:"CSV"},{label:"XLSX"}]
                }
                Arc.ArcIconMorph { th: root.th; kindFrom: "Menu"; kindTo: "X"; progress: 0.45; extent: 40 }
                Arc.ArcThemeSwitcher { th: root.th; dark: root._swDarkA; iconOnly: false; onChangeRequested: function (v) { root._swDarkA = v; } }
                Arc.ArcThemeSwitcher { th: root.th; dark: root._swDarkB; iconOnly: true; onChangeRequested: function (v) { root._swDarkB = v; } }
            }
        }
    }
}
