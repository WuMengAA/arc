// 陈列页 · Activity & TextEffects（官方目录 Activity / TextEffects）：加载、过渡、缓动、存在性、数字轮与 128 lucide 图标。
import QtQuick 2.15
import "." as Arc
import "Icons.js" as Ic
Flickable {
    id: root
    property var th: null
    contentWidth: width
    contentHeight: _col.implicitHeight + 52
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    property var iconKeys: Object.keys(Ic.PATHS)
    property int glideIdx: 1

    // 过渡数学真值（全部走 ArcTheme → ArcMotion，不硬编码）
    function factRows() {
        var t = root.th; if (!t) return [];
        var pe = t.popupEnter(), px = t.popupExit();
        return [
            ["Popup enter / exit scale", pe.scale + " / " + px.scale],
            ["Popup enter / exit duration", pe.opacitySpec.duration + " / " + px.opacitySpec.duration + " ms"],
            ["RubberBand apply(20,100)", t.motion().rubberApply(20, 100).toFixed(4) + "  (DefaultFactor 0.55)"],
            ["RubberBand clamp(130,0,100)", t.rubberClamp(130, 0, 100, 100).toFixed(4)],
            ["PresenceHost Pop t=0 scale", t.presencePose(3, 0, 0.9, 12).scale.toFixed(2)],
            ["ContentSwap Slide x(+1,36)", t.contentSwapOffset(1, 1, 36).x],
            ["MotionTimeline RunValue(0.2,0.5)", t.motion().timelineRunValue(0.2, 0.5).toFixed(2)],
            ["RollingDigits shortest(9,1)", t.rollingShortest(9, 1) + "  (IsShortestTurn)"],
            ["Spring Snappy stiffness / settle", t.springAnim("Snappy").spring.toFixed(2) + " / " + Math.round(t.springSettle("Snappy")) + " ms"],
            ["BusyPulse period / min / opacity(0.9s)", "1.8 s / 0.45 / " + t.busyOpacity(0.9).toFixed(2)],
            ["MotionLevel default", "Full (2) — Reduced breathes, Off freezes"]
        ];
    }

    Component { id: _pgA; Rectangle { width: 260; height: 96; radius: 12; color: root.th !== null ? root.th.c("SurfaceMuted") : "#FFF8F8F8";
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: "Slide A"; color: root.th !== null ? root.th.c("Foreground") : "#000"; font.pixelSize: 22 } } }
    Component { id: _pgB; Rectangle { width: 260; height: 96; radius: 12; color: root.th !== null ? root.th.c("Accent") : "#FF3B5DC9";
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: "Slide B"; color: "#FFFFFF"; font.pixelSize: 22 } } }
    property var swapPages: [_pgA, _pgB]

    Column {
        id: _col
        x: 28; y: 24
        width: root.width - 56
        spacing: 20

        Arc.ArcPageHeader {
            th: root.th
            title: "Activity & TextEffects"
            subtitle: "Spinner, Pulse, ContentSwap, Gliding, Presence, RollingNumber, Ripple, FocusRing — Activity / TextEffects, with 128 lucide glyphs."
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Loading · ArcSpinner / ArcBusyPulse"
            description: "ArcSpinner.cs TurnSeconds=0.7 rotation; LiveLoop MinimumLevel=Reduced → 1→0.45→1 sine breath; Off = static. PulseStagger=0.09s."
            Column {
                width: parent.width; spacing: 12
                Row {
                    spacing: 28
                    Repeater {
                        model: [{ lv: 2, t: "Full" }, { lv: 1, t: "Reduced" }, { lv: 0, t: "Off" }]
                        delegate: Column {
                            required property var modelData
                            spacing: 4
                            Arc.ArcSpinner { th: root.th; spinnerSize: 24; level: modelData.lv; running: true }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.t; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
                        }
                    }
                }
                Row {
                    spacing: 28
                    Arc.ArcPulse { th: root.th; count: 3; dotSize: 10 }
                    Arc.ArcPulse { th: root.th; count: 3; dotSize: 10; bars: true }
                    Arc.ArcIcon { th: root.th; kind: "LoaderCircle"; spin: true; width: 24; height: 24; color: root.th.c("Accent") }
                    Arc.ArcButton { th: root.th; text: "Working"; busy: true; variant: "secondary"; size: "sm" }
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Transition math · spring / easing / slide"
            description: "ArcPopupMotions / RubberBand / PresenceHost / ArcContentSwap / MotionTimeline / RollingDigits / SpringTransitions / ArcBusyPulse — values from real source."
            Column {
                width: parent.width; spacing: 4
                Repeater {
                    model: root.factRows()
                    delegate: Row {
                        required property var modelData
                        width: parent.width; height: 20; spacing: 12
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  width: 300; text: modelData[0]; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData[1]; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") }
                    }
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Transitions · ContentSwap / Gliding / Presence"
            description: "ArcContentSwap.cs Slide mode (Enter/Exit layers), GlidingIndicator.cs MoveTo(Rect) with Snappy spring, PresenceHost.cs Pop mode."
            Column {
                width: parent.width; spacing: 12
                Row {
                    spacing: 28
                    Arc.ArcContentSwap { th: root.th; width: 260; height: 96; pages: root.swapPages; mode: 1; autoPlay: true; autoInterval: 3000 }
                    Item {
                        width: 300; height: 40
                        Row {
                            spacing: 4
                            Repeater {
                                model: ["Option 1", "Option 2", "Option 3"]
                                delegate: Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                                    required property string modelData
                                    width: 96; height: 36
                                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                    text: modelData; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS")
                                }
                            }
                        }
                        Arc.ArcGliding {
                            anchors.fill: parent
                            th: root.th
                            activeIndex: root.glideIdx
                            color: "transparent"
                            borderColor: root.th.c("Accent")
                            rects: [{ x: 0, y: 0, w: 96, h: 36 }, { x: 100, y: 0, w: 96, h: 36 }, { x: 200, y: 0, w: 96, h: 36 }]
                        }
                    }
                    Arc.ArcPresence { th: root.th; width: 150; height: 56; present: true; mode: 3;
                        Rectangle { width: 150; height: 56; radius: 12; color: root.th.c("SurfaceMuted");
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: "Present"; color: root.th.c("Foreground"); font.pixelSize: 17 } } }
                }
                Row {
                    spacing: 12
                    Arc.ArcButton { th: root.th; text: "Glide 1"; size: "sm"; variant: "secondary"; onClicked: root.glideIdx = 0 }
                    Arc.ArcButton { th: root.th; text: "Glide 2"; size: "sm"; variant: "secondary"; onClicked: root.glideIdx = 1 }
                    Arc.ArcButton { th: root.th; text: "Glide 3"; size: "sm"; variant: "secondary"; onClicked: root.glideIdx = 2 }
                    Arc.ArcRollingNumber { th: root.th; value: 2847; columns: 4; fontSize: 26 }
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Icons · 128 lucide glyphs (real LucidePaths.txt)"
            description: "SVG path data copied verbatim from TKCode.Arc.Icons.Lucide.Generators/LucidePaths.txt; rendered via data URI, no C++ image provider."
            Grid {
                width: parent.width; columns: 16; spacing: 8
                Repeater {
                    model: root.iconKeys
                    delegate: Item {
                        required property string modelData
                        width: (parent.width - 15 * 8) / 16; height: 34
                        Rectangle { anchors.fill: parent; radius: 6; color: root.th.c("SurfaceMuted") }
                        Arc.ArcIcon { anchors.centerIn: parent; th: root.th; kind: modelData; width: 20; height: 20; color: root.th.c("Foreground") }
                    }
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Feedback · Ripple / FocusRing / busy / spin"
            description: "Pointer state layer as animated wave (Considered 480ms + Ease.Standard), LazyFocusRing :focus-visible semantics, ArcButton.busy wired to a real Spinner."
            Row {
                width: parent.width; spacing: 20
                Arc.ArcRipple { th: root.th; width: 200; height: 64; previewRadius: 24 }
                Arc.ArcFocusRing {
                    th: root.th; width: 160; height: 44; demoKeyboard: true
                    Rectangle { width: 144; height: 32; radius: 8; color: root.th.c("Surface");
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: "Keyboard focus"; color: root.th.c("Foreground"); font.pixelSize: 15 } }
                }
                Arc.ArcButton { th: root.th; text: "Save"; icon: "Save"; busy: true }
                Arc.ArcIcon { th: root.th; kind: "RefreshCw"; spin: true; width: 28; height: 28; color: root.th.c("Accent"); anchors.verticalCenter: parent.verticalCenter }
            }
        }
    }
}
