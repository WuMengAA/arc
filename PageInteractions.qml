// 陈列页 · Gestures & Toggles（官方目录 Gestures / Toggles / SpecialInputs）。
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
            title: "Gestures & Toggles"
            subtitle: "HoldToConfirm, Reactions, SwipeActions, BillingToggle, EnumSelector, RadioCards, SegmentedControl, ToggleGroup — Gestures / Toggles / SpecialInputs."
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "HoldToConfirm"
            description: "Gestures/HoldToConfirm — press and hold ~900ms; danger / neutral fills."
            Row {
                spacing: 16
                Arc.ArcHoldToConfirm { th: root.th; label: "Hold to delete"; tone: "danger" }
                Arc.ArcHoldToConfirm { th: root.th; label: "Hold to publish"; tone: "neutral" }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th; z: 12
            title: "Reactions"
            description: "Gestures/Reactions — pill counts + emoji picker (PickerPadding/OptionExtent)."
            Arc.ArcReactions {
                width: 420; height: 84; th: root.th; pickerOpen: false
                reactions: [{emoji:"👍",count:12,reacted:true},{emoji:"❤️",count:8,reacted:false},{emoji:"🎉",count:4,reacted:false}]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "SwipeActions"
            description: "Gestures/SwipeActions — drag the row left to reveal Archive / Delete."
            Column {
                width: parent.width; spacing: 10
                Arc.ArcSwipeActions {
                    width: 460; th: root.th; reveal: 1
                    title: "Invoice #1042"; subtitle: "Due Nov 30"
                    actions: [{label:"Archive",icon:"Download",tone:"neutral"},{label:"Delete",icon:"Trash2",tone:"danger"}]
                }
                Arc.ArcSwipeActions {
                    width: 460; th: root.th; reveal: 0
                    title: "Invoice #1043"; subtitle: "Paid Nov 12"
                    actions: [{label:"Archive",icon:"Download",tone:"neutral"},{label:"Delete",icon:"Trash2",tone:"danger"}]
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "BillingToggle & EnumSelector"
            description: "Toggles/BillingToggle (Save 20% badge) + EnumSelector radio/check rows."
            Row {
                width: parent.width; spacing: 24
                Arc.ArcBillingToggle { th: root.th; period: "year"; monthly: 24; yearly: 19 }
                Arc.ArcEnumSelector {
                    th: root.th; legend: "Visibility"; mode: "radio"; value: ["public"]
                    options: [{value:"public",label:"Public"},{value:"team",label:"Team only"},{value:"private",label:"Private"}]
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "RadioCards"
            description: "Toggles/RadioCards — grid / list layouts, gliding ring, CardInsetGrid/List."
            Column {
                width: parent.width; spacing: 14
                Arc.ArcRadioCards {
                    width: 520; th: root.th; value: "studio"; layout: "grid"
                    options: [{value:"studio",label:"Studio",description:"For small teams shipping every week.",icon:"Sparkles"},
                              {value:"business",label:"Business",description:"Advanced controls and audit log.",icon:"Shield"},
                              {value:"scale",label:"Scale",description:"Dedicated support and SLA.",icon:"TrendingUp"},
                              {value:"solo",label:"Solo",description:"Just me, one workspace.",icon:"CircleDot"}]
                }
                Arc.ArcRadioCards {
                    width: 520; th: root.th; value: "b"; layout: "list"
                    options: [{value:"a",label:"Monthly billing",description:"Pay as you go.",icon:"Calendar"},
                              {value:"b",label:"Yearly billing",description:"Save 20% annually.",icon:"CreditCard"}]
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "SegmentedControl & ToggleGroup"
            description: "SegmentedControl (accessory labels) + ToggleGroup single/multiple."
            Column {
                width: parent.width; spacing: 14
                Arc.ArcSegmentedControl {
                    th: root.th; value: "overview"
                    options: [{value:"overview",label:"Overview"},{value:"revenue",label:"Revenue",accessory:"$2.2M"},
                              {value:"usage",label:"Usage",accessory:"26M"},{value:"locked",label:"Locked",disabled:true}]
                }
                Arc.ArcToggleGroup {
                    th: root.th; value: ["bold"]; multiple: true
                    options: [{value:"bold",label:"B",icon:"Menu"},{value:"italic",label:"I",icon:"FileText"},{value:"under",label:"U",icon:"Download"}]
                }
                Arc.ArcToggleGroup { th: root.th; value: ["sm"]; multiple: false; small: true; options: [{value:"sm",label:"S",icon:"Gauge"},{value:"md",label:"M",icon:"Circle"}] }
            }
        }
    }
}
