// arc:ControlCenter —— Special/Surfaces 真值：PanelCornerRadius [30..] / TileCornerRadius [22..] /
// TileOnTint 0.09 / DialTrackColor / DialMajorTickColor / DialMinorTickColor / MeterTrackColor / MutedFillColor / ScrimColor。
// 2x2 快捷磁贴 + 亮度/音量环形刻度 + 焦点模式，右侧展开详情面板（scrim 遮罩）。
import QtQuick 2.15

Rectangle {
    id: root
    property var th: null
    property int volume: 64
    property int brightness: 78
    property bool wifi: true
    property bool bluetooth: false
    property bool focusMode: false
    property string detail: ""
    readonly property real _panelR: th.pad(th.ct("ControlCenter", "PanelCornerRadius"))
    readonly property real _tileR: th.pad(th.ct("ControlCenter", "TileCornerRadius"))
    readonly property real _onTint: th.ct("ControlCenter", "TileOnTint")
    width: 420; height: 400
    radius: root._panelR
    color: th.c("SurfaceRaised")
    border.width: 1; border.color: th.c("Border")
    clip: true
    Column {
        x: 24; y: 22; width: parent.width - 48; spacing: 18
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Control Center"; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeLG"); font.weight: root.th.design("WeightMedium") }
        Grid {
            width: parent.width; columns: 2; spacing: 12
            Repeater {
                model: [
                    { label: "Wi-Fi", icon: "Wifi", on: root.wifi },
                    { label: "Bluetooth", icon: "Bluetooth", on: root.bluetooth },
                    { label: "Focus", icon: "Moon", on: root.focusMode },
                    { label: "AirDrop", icon: "Share2", on: true }
                ]
                delegate: Rectangle {
                    required property var modelData; required property int index
                    property int di: index; property var md: modelData; property var host: root
                    width: (parent.width - 12) / 2; height: 72
                    radius: root._tileR
                    color: modelData.on ? root.th.fade(root.th.a("accent"), root._onTint) : root.th.ct("ControlCenter", "MutedFillColor")
                    Row {
                        anchors.verticalCenter: parent.verticalCenter; x: 14; spacing: 12
                        Rectangle { width: 34; height: 34; radius: 17; color: modelData.on ? root.th.a("accent") : root.th.c("SurfaceMuted"); ArcIcon { anchors.centerIn: parent; th: root.th; kind: modelData.icon; width: 17; height: 17; color: modelData.on ? root.th.a("foreground") : root.th.c("TextSecondary") } }
                        Column { anchors.verticalCenter: parent.verticalCenter; Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.label; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") } Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.on ? "On" : "Off"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { host.detail = md.label; if (di === 0) host.wifi = !host.wifi; if (di === 1) host.bluetooth = !host.bluetooth; if (di === 2) host.focusMode = !host.focusMode; } }
                }
            }
        }
        // 两个环形刻度（SVG data URI，避 Canvas 首帧空绘）
        Row {
            width: parent.width; spacing: 18
            Repeater {
                model: [{ name: "Brightness", value: root.brightness, icon: "Sun" }, { name: "Volume", value: root.volume, icon: "Volume2" }]
                delegate: Column {
                    required property var modelData
                    width: (parent.width - 18) / 2; spacing: 8
                    Image {
                        width: 116; height: 116; anchors.horizontalCenter: parent.horizontalCenter
                        source: "data:image/svg+xml;utf8," + encodeURIComponent(root._dial(modelData.value))
                    }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.name + " · " + modelData.value + "%"; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS"); anchors.horizontalCenter: parent.horizontalCenter }
                }
            }
        }
        Row {
            width: parent.width; spacing: 8
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Focus"; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM"); anchors.verticalCenter: parent.verticalCenter }
            Item { width: parent.width - 220; height: 1 }
            ArcButton { th: root.th; text: "Do Not Disturb"; variant: "secondary"; size: "sm"; icon: "Moon" }
            ArcButton { th: root.th; text: "Details"; variant: "ghost"; size: "sm"; onClicked: root.detail = "Focus" }
        }
    }
    Rectangle {
        visible: root.detail !== ""
        anchors.fill: parent
        color: root.th.ct("ControlCenter", "ScrimColor")
        Rectangle {
            anchors.centerIn: parent; width: 260; height: 150
            radius: root.th.t4(root.th.design("RadiusPanel"), 0)
            color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("Border")
            Column {
                anchors.centerIn: parent; spacing: 12
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.detail; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeLG"); font.weight: root.th.design("WeightMedium"); anchors.horizontalCenter: parent.horizontalCenter }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Nearby devices and options"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS"); anchors.horizontalCenter: parent.horizontalCenter }
                ArcButton { th: root.th; text: "Close"; variant: "secondary"; size: "sm"; anchors.horizontalCenter: parent.horizontalCenter; onClicked: root.detail = "" }
            }
        }
        MouseArea { anchors.fill: parent; onClicked: root.detail = "" }
    }
    function _hex(c) {
        var s = String(c);
        if (s.charAt(0) !== "#") return "#808080";
        return s.length === 9 ? "#" + s.substring(3) : s;
    }
    function _alpha(c) {
        var s = String(c);
        if (s.charAt(0) !== "#" || s.length !== 9) return 1;
        return parseInt(s.substring(1, 3), 16) / 255;
    }
    function _dial(v) {
        var ticks = "", i, a, r0 = 44, r1 = 52;
        for (i = 0; i < 40; i++) {
            a = (i / 40) * 2 * Math.PI - Math.PI / 2;
            var on = i / 40 <= v / 100;
            var rr = i % 5 === 0 ? r1 : r0;
            var col = on ? root.th.a("accent") : root.th.ct("ControlCenter", "DialMinorTickColor");
            ticks += '<line x1="' + (58 + Math.cos(a) * rr) + '" y1="' + (58 + Math.sin(a) * rr) + '" x2="' + (58 + Math.cos(a) * 52) + '" y2="' + (58 + Math.sin(a) * 52) + '" stroke="' + root._hex(col) + '" stroke-opacity="' + root._alpha(col).toFixed(3) + '" stroke-width="' + (i % 5 === 0 ? 2.5 : 1.5) + '" stroke-linecap="round"/>';
        }
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 116 116">' +
            '<circle cx="58" cy="58" r="42" fill="none" stroke="' + root._hex(root.th.ct("ControlCenter", "DialTrackColor")) + '" stroke-opacity="' + root._alpha(root.th.ct("ControlCenter", "DialTrackColor")).toFixed(3) + '" stroke-width="10"/>' + ticks +
            '<circle cx="58" cy="58" r="30" fill="' + root._hex(root.th.c("Surface")) + '"/>' +
            '<text x="58" y="63" text-anchor="middle" font-size="14" fill="' + root._hex(root.th.c("Foreground")) + '">' + v + '</text></svg>';
    }
}
