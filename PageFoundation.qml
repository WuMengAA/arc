// 底层基础设施陈列页：Core/Motion（弹簧·缓动·时长·动效等级）、Core/Theme（Oklch）、Foundation + Themes.Corners / Themes.Pixel（预设 slot）。
import QtQuick 2.15
import "." as Arc
Flickable {
    id: root
    property var th: null
    contentWidth: width
    contentHeight: _col.implicitHeight + 52
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    property var durNames: ["Instant", "Fast", "Exit", "Standard", "Considered", "CssSpring"]
    property var springNames: ["Smooth", "Snappy", "Morph", "Responsive", "Gentle", "Quick", "Settle"]
    property var easeNames: ["Enter", "Exit", "Standard", "InOut"]
    property var swatches: ["#7747FF", "#0DB879", "#F3AD20", "#585858"]

    function svgColor(c) {
        var s = String(c);
        return s.length === 9 ? "#" + s.substring(3) : s;
    }
    // 弹簧曲线：采样 ArcSpringEasing.Ease(progress) 画成 SVG 折线（避 Canvas 首帧空绘）
    function springSvg(name) {
        var pts = [];
        for (var i = 0; i <= 40; i++) {
            var x = i * 4;
            var y = 46 - root.th.springEase(name, i / 40) * 40;
            pts.push(x + "," + y.toFixed(1));
        }
        return "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 160 52'>" +
               "<polyline fill='none' stroke='" + svgColor(root.th.c("Accent")) + "' stroke-width='2' points='" + pts.join(" ") + "'/></svg>";
    }

    Column {
        id: _col
        x: 28; y: 24
        width: root.width - 56
        spacing: 20

        Arc.ArcPageHeader {
            th: root.th
            title: "Foundation"
            subtitle: "TKCode.Arc.Foundation / Core / Themes.Corners / Themes.Pixel — motion engine, OKLCH color math and theme preset slots."
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Motion · durations & stagger"
            description: "ArcMotionPresets / ArcDesignToken.ApplyMotion — 120/160/180/240/480/580 ms; stagger 16/40/80/35 ms."
            Column {
                width: parent.width; spacing: 6
                Repeater {
                    model: root.durNames
                    delegate: Row {
                        required property var modelData
                        width: parent.width; height: 20; spacing: 12
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  width: 130; text: "Dur." + modelData; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  width: 90; text: root.th.dur(modelData) + " ms"; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") }
                        Rectangle { width: Math.max(2, root.th.dur(modelData) / 3); height: 8; radius: 4; anchors.verticalCenter: parent.verticalCenter; color: root.th.c("Accent") }
                    }
                }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    width: parent.width; text: "Stagger: char " + root.th.stagger("Char") + " / word " + root.th.stagger("Word") +
                        " / line " + root.th.stagger("Line") + " / item " + root.th.stagger("Item") + " ms";
                    color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM")
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Motion · spring solver"
            description: "SpringSpec.FromVisual / SpringSolver.Evaluate closed form — curve = 1 + x(t), length = EstimateSettle()."
            Grid {
                width: parent.width; columns: 4; spacing: 12
                Repeater {
                    model: root.springNames
                    delegate: Item {
                        required property var modelData
                        width: (parent.width - 3 * 12) / 4; height: 84
                        Rectangle { anchors.fill: parent; radius: 8; color: root.th.c("SurfaceMuted") }
                        Image {
                            x: 8; y: 4; width: 160; height: 52; sourceSize: Qt.size(160, 52)
                            source: "data:image/svg+xml;utf8," + encodeURIComponent(root.springSvg(modelData))
                        }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  x: 8; y: 58; text: modelData; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeXS"); font.weight: root.th.design("WeightMedium") }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  x: 8; y: 72; text: Math.round(root.th.springSettle(modelData)) + " ms settle"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
                    }
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Motion · cubic-bezier easings"
            description: "ArcEasings.Enter / Exit / Standard / InOut → QML easing.bezierCurve (type = Easing.Bezier)."
            Column {
                width: parent.width; spacing: 6
                Repeater {
                    model: root.easeNames
                    delegate: Row {
                        required property var modelData
                        width: parent.width; height: 20; spacing: 12
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  width: 130; text: "Ease." + modelData; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "cubic-bezier(" + root.th.ease(modelData).slice(0, 4).join(",") + ")"; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM") }
                    }
                }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "CSS spring: 36 linear() stops, 580 ms — Ease(0.5) = " + root.th.motion().LinearEase(root.th.motion().CssSpringStops, 0.5).toFixed(4);
                    color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM") }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  width: parent.width; text: "MotionLevel: Off → dur=0, Reduced → 160 ms, Full → 160 ms (springs jump to end)."; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM") }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Color math · OKLCH (CSS Color 4 gamut mapping)"
            description: "Oklch.FromColor → ToColor round trip, Contrast (WCAG2), MixOklab; matrix constants from Oklch.cs."
            Column {
                width: parent.width; spacing: 8
                Row {
                    width: parent.width; height: 44; spacing: 12
                    Repeater {
                        model: root.swatches
                        delegate: Rectangle {
                            required property var modelData
                            width: 76; height: 44; radius: 8; color: root.th.oklch().toRgb(
                                (function () { var p = root.th.oklch().fromColor(modelData); return [p.L, p.C, p.H]; })()[0],
                                (function () { var p = root.th.oklch().fromColor(modelData); return [p.L, p.C, p.H]; })()[1],
                                (function () { var p = root.th.oklch().fromColor(modelData); return [p.L, p.C, p.H]; })()[2])
                            border.width: 1; border.color: root.th.c("Border")
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: modelData; color: "#FFFFFF"; font.pixelSize: 13 }
                        }
                    }
                }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Contrast(#FFFFFF, #3B5DC9) = " + root.th.contrast("#FFFFFF", "#3B5DC9").toFixed(2) + " : 1";
                    color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM") }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "ToColor(0.46, 0, 0) = " + root.th.oklch().toRgb(0.46, 0, 0) + "   ToColor(0.19, 0, 0) = " + root.th.oklch().toRgb(0.19, 0, 0);
                    color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "MixOklab(#3B5DC9, #F4F4F4, 0.5) = " + root.th.mixOklab("#3B5DC9", "#F4F4F4", 0.5);
                    color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Theme presets · corner slot"
            description: "ArcCornerPresets — square / half / double override every radius token; later preset wins."
            Row {
                width: parent.width; spacing: 12
                Repeater {
                    model: [{n:"Default",c:""},{n:"Square",c:"corner-square"},{n:"Half",c:"corner-half"},{n:"Double",c:"corner-double"}]
                    delegate: Item {
                        required property var modelData
                        width: (parent.width - 3 * 12) / 4; height: 112
                        Arc.ArcTheme { id: pv; dark: root.th.dark; cornerPreset: modelData.c }
                        Rectangle {
                            width: parent.width; height: 84
                            radius: pv.t4(pv.design("RadiusPanel"), 0)
                            color: pv.c("Surface"); border.width: 1; border.color: pv.c("Border")
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: modelData.n; color: pv.c("Foreground"); font.pixelSize: pv.design("TypeSM") }
                        }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  y: 90; width: parent.width; horizontalAlignment: Text.AlignHCenter;
                            text: "r=" + pv.t4(pv.design("RadiusPanel"), 0); color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
                    }
                }
            }
        }

        Arc.ArcCard {
            width: parent.width; th: root.th
            title: "Theme presets · style slot (ArcPixel)"
            description: "ArcPixelPresets — Sweetie-16 palette, 2px edges, square corners, zero-blur shadows; light and dark."
            Row {
                width: parent.width; spacing: 12
                Repeater {
                    model: [{n:"Pixel light",d:false},{n:"Pixel dark",d:true}]
                    delegate: Item {
                        required property var modelData
                        width: (parent.width - 12) / 2; height: 112
                        Arc.ArcTheme { id: pv; dark: modelData.d; stylePreset: "pixel" }
                        Rectangle {
                            width: parent.width; height: 84
                            radius: pv.t4(pv.design("RadiusPanel"), 0)
                            color: pv.c("Background")
                            border.width: pv.t4(pv.design("EdgeThickness"), 0); border.color: pv.c("Border")
                            Rectangle { anchors.centerIn: parent; width: parent.width - 32; height: 44;
                                color: pv.c("Surface"); border.width: pv.t4(pv.design("EdgeThickness"), 0); border.color: pv.c("Border")
                                Rectangle { x: 8; y: 8; width: 12; height: 12; color: pv.c("Accent") }
                                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  x: 28; y: 8; text: modelData.n; color: pv.c("Foreground"); font.pixelSize: pv.design("TypeSM"); font.weight: pv.design("WeightMedium") }
                                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  x: 28; y: 26; text: "accent " + pv.c("Accent"); color: pv.c("TextMuted"); font.pixelSize: pv.design("TypeXS") }
                            }
                        }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  y: 90; width: parent.width; horizontalAlignment: Text.AlignHCenter;
                            text: "bg " + pv.c("Background"); color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
                    }
                }
            }
        }
    }
}
