// 陈列页 · TextFields & Forms（官方目录 TextFields / Forms / Selects / Progress）。
// 全部按 Theme.axaml + Token.cs 真值，用 ArcCard 分区呈现，供真机预览逐项核对。
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
            title: "TextFields & Forms"
            subtitle: "TextFields / Forms / Selects / Progress — Checkbox, Input, Progress, Slider, Select."
        }

        // ── Checkbox：三态 + invalid + disabled ──
        Arc.ArcCard {
            width: parent.width
            th: root.th
            title: "Checkbox"
            description: "Toggles/Checkbox — 18px square, 3-point check morphs to a dash."
            Column {
                width: parent.width
                spacing: 14
                Arc.ArcCheckbox { th: root.th; text: "Checked"; description: "With a helper line."; checkState: 1 }
                Arc.ArcCheckbox { th: root.th; text: "Indeterminate"; checkState: 2 }
                Arc.ArcCheckbox { th: root.th; text: "Unchecked" }
                Arc.ArcCheckbox { th: root.th; text: "Invalid"; isInvalid: true }
                Arc.ArcCheckbox { th: root.th; text: "Disabled"; enabled: false; checkState: 1 }
            }
        }

        // ── Input：label/placeholder/description、invalid、password ──
        Arc.ArcCard {
            width: parent.width
            th: root.th
            title: "Input"
            description: "TextFields/Input — inline FieldFrame/FieldMessage, hover/focus/invalid states."
            Column {
                width: parent.width
                spacing: 14
                Arc.ArcInput { th: root.th; width: 360; label: "Email"; placeholder: "you@example.com"; description: "We never share it." }
                Arc.ArcInput { th: root.th; width: 360; label: "Password"; password: true; error: "Use at least 8 characters." }
                Arc.ArcInput { th: root.th; width: 360; label: "Disabled"; enabled: false; text: "read only value" }
            }
        }

        // ── Progress：进行中 / 完成 ──
        Arc.ArcCard {
            width: parent.width
            th: root.th
            title: "Progress"
            description: "Progress/Progress — 7px track, Accent fill turns Success at 100%."
            Column {
                width: parent.width
                spacing: 16
                Arc.ArcProgress { th: root.th; width: 420; label: "Uploading assets"; percentage: 64 }
                Arc.ArcProgress { th: root.th; width: 420; label: "Backup"; percentage: 100 }
                Arc.ArcProgress { th: root.th; width: 420; label: "Queued"; percentage: 12; isValueVisible: false }
            }
        }

        // ── Slider：刻度 + 数值气泡 ──
        Arc.ArcCard {
            width: parent.width
            th: root.th
            title: "Slider"
            description: "Sliders/Slider — 22px thumb, 6px rail, ticks, drag bubble."
            Column {
                width: parent.width
                spacing: 20
                Arc.ArcSlider { th: root.th; width: 460; label: "Volume"; value: 42;
                    marks: [{value:0,label:"0"},{value:50,label:"50"},{value:100,label:"100"}] }
                Arc.ArcSlider { th: root.th; width: 460; label: "Disabled"; value: 70; enabled: false }
            }
        }

        // ── Select：下拉菜单 ──
        Arc.ArcCard {
            width: parent.width
            th: root.th
            title: "Select"
            description: "Selects/Select — trigger + popup menu, chevron rotates on open."
            Column {
                width: parent.width
                spacing: 14
                Arc.ArcSelect { th: root.th; width: 300; label: "Plan"; value: "pro";
                    options: [{value:"free",label:"Free"},{value:"pro",label:"Pro"},
                              {value:"ent",label:"Enterprise"},{value:"ent+",label:"Enterprise+",disabled:true}] }
                Arc.ArcSelect { th: root.th; width: 300; label: "Disabled"; value: "a"; enabled: false;
                    options: [{value:"a",label:"Alpha"},{value:"b",label:"Beta"}] }
            }
        }

        Item { width: 1; height: 8 }
    }
}
