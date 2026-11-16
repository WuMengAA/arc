// 陈列页 · Charts & Selects（官方目录 Selects / Charts / Activity）。
// DonutChart / BarChart / Skeleton / AnnouncementBar。真机预览逐项核对。
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
            title: "Charts & Selects"
            subtitle: "Combobox, MultiSelect, ChipGroup, Rating, DonutChart, BarChart, Skeleton, AnnouncementBar — Selects / Charts / Activity."
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "AnnouncementBar"
            description: "Messages/AnnouncementBar — 32px icon, rotating messages, Previous/Next/Dismiss, inverted variant."
            Column {
                width: parent.width; spacing: 12
                Arc.ArcAnnouncementBar {
                    width: parent.width; th: root.th
                    messages: [{text:"A new version of TKCode.Arc is available. Refresh to get the latest workspace features."},
                               {text:"Scheduled maintenance on Sunday, 02:00–04:00 UTC."}]
                }
                Arc.ArcAnnouncementBar {
                    width: parent.width; th: root.th; inverted: true; navigable: false
                    messages: [{text:"Inverted surface uses Foreground background with Background text."}]
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th; z: 10
            title: "Combobox"
            description: "Selects/Combobox — searchable input, 36px options, clear + chevron, open state."
            Row {
                width: parent.width; spacing: 24
                Arc.ArcCombobox {
                    width: 260; th: root.th
                    label: "Framework"; description: "Search and pick one."
                    options: [{value:"a",label:"Avalonia"},{value:"q",label:"Qt Quick"},
                              {value:"w",label:"WPF"},{value:"f",label:"Flutter",disabled:true}]
                    value: "q"
                }
                Arc.ArcCombobox {
                    width: 260; th: root.th; isOpen: true
                    label: "Open preset"
                    options: [{value:"a",label:"Avalonia"},{value:"q",label:"Qt Quick"},{value:"w",label:"WPF"}]
                    value: "a"
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "MultiSelect"
            description: "Selects/MultiSelect — chips with remove, 38px options, clear-all, open state."
            Arc.ArcMultiSelect {
                width: 360; th: root.th
                label: "Tags"; description: "Pick several."
                options: [{value:"ui",label:"UI"},{value:"qml",label:"QML"},
                          {value:"charts",label:"Charts"},{value:"motion",label:"Motion",disabled:true}]
                selected: ["qml", "charts"]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "ChipGroup"
            description: "Selects/ChipGroup — 36px pill chips, ChipGap 8, single / multi select."
            Column {
                width: parent.width; spacing: 12
                Arc.ArcChipGroup {
                    width: parent.width; th: root.th; value: "week"
                    options: [{value:"day",label:"Day"},{value:"week",label:"Week"},
                              {value:"month",label:"Month"},{value:"year",label:"Year"}]
                }
                Arc.ArcChipGroup {
                    width: parent.width; th: root.th; multi: true; selected: ["ui","qml"]
                    options: [{value:"ui",label:"UI"},{value:"qml",label:"QML"},
                              {value:"charts",label:"Charts"},{value:"motion",label:"Motion"}]
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Rating"
            description: "Toggles/Rating — partial fill from RatingStars.cs Portion(value,index), Warning fill."
            Column {
                width: parent.width; spacing: 12
                Arc.ArcRating { th: root.th; label: "Average"; value: 3.5; description: "Based on 128 reviews." }
                Arc.ArcRating { th: root.th; label: "Your rating"; value: 0; size: "lg" }
                Arc.ArcRating { th: root.th; label: "Small"; value: 4; size: "sm"; showValue: false }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "DonutChart"
            description: "Charts/DonutChart — RingThickness 24, dashed segments, center readout, legend."
            Arc.ArcDonutChart {
                th: root.th; diameter: 170; centerValue: "$48.2k"; totalLabel: "Revenue"
                segments: [{label:"Subscriptions",value:28.4},{label:"Services",value:12.1},
                           {label:"Licenses",value:7.7}]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "BarChart"
            description: "Charts/BarChart — GutterWidth 52, MaxBarWidth 28, 4 grid lines, axis labels."
            Arc.ArcBarChart {
                th: root.th; width: parent.width
                kind: "Revenue"; unit: "$"
                values: [18,24,19,31,27,36,29,42]
                labels: ["W1","W2","W3","W4","W5","W6","W7","W8"]
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Skeleton"
            description: "Progress/Skeleton — BlockColor #FFE8E8E8, BlockRadius 18, pulsing lines + avatar."
            Column {
                width: parent.width; spacing: 12
                Arc.ArcSkeleton { th: root.th; width: 420; lines: 3; avatar: true }
                Arc.ArcSkeleton { th: root.th; width: 420; lines: 2 }
            }
        }
    }
}
