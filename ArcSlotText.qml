// arc:SlotText —— TextEffects/SlotText 真源码移植（SlotText.cs + SlotTextToken.cs）。
// 老虎机文字：每个字符是一个卷轴（reel）。数字沿数值移动方向转过整轮（额外 Spins 整圈），字母在字母表里洗牌；
// 卷轴从左到右一个接一个停（Stagger），软着陆从不过冲。一个控件画完：卷轴只是几个字形 + 窗内裁切。
// 令牌：LineHeightEm 1.15 / CellPitchEm 1.6（比行高高，落地字形的邻居落在窗外）/ WindowInsetY 0.22 / WindowInsetX 0.08 / EdgeFade 0.24。
// Align：0 Start / 1 End / -1 自动（数字 End、文字 Start）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var value: 0
    property bool announce: false
    property int duration: 900
    property int stagger: 70
    property int spins: 1
    property int align: -1
    property real fontSize: th ? th.design("Type2XL") : 26
    property color color: th ? th.c("Foreground") : "#FF1D1D1D"
    property var formatter: null

    readonly property real _lhEm: root.th ? root.th.ct("SlotText", "LineHeightEm") : 1.15
    readonly property real _pitchEm: root.th ? root.th.ct("SlotText", "CellPitchEm") : 1.6
    readonly property real _inYEm: root.th ? root.th.ct("SlotText", "WindowInsetYEm") : 0.22
    readonly property real _inXEm: root.th ? root.th.ct("SlotText", "WindowInsetXEm") : 0.08
    readonly property real _fadeEm: root.th ? root.th.ct("SlotText", "EdgeFadeEm") : 0.24
    readonly property real _em: root.fontSize
    readonly property real _lineH: _lhEm * _em
    readonly property real _pitch: _pitchEm * _em
    readonly property real _winY: _inYEm * _em
    readonly property real _winX: _inXEm * _em
    readonly property real _fade: _fadeEm * _em
    readonly property real _cellW: Math.round(_em * 0.62)
    readonly property real _windowH: _lineH + 2 * _winY
    readonly property int _alignMode: root.align >= 0 ? root.align : (typeof root.value === "number" ? 1 : 0)

    readonly property string _display: {
        if (typeof root.value === "number" && isFinite(root.value)) {
            if (root.formatter) return String(root.formatter(root.value));
            var neg = root.value < 0, v = Math.abs(root.value);
            var s = v.toFixed(3).replace(/\.?0+$/, "");
            var parts = String(s).split("."), ip = parts[0], out = "";
            for (var i = 0; i < ip.length; i++) {
                if (i > 0 && (ip.length - i) % 3 === 0) out += ",";
                out += ip.charAt(i);
            }
            s = out + (parts.length > 1 && parts[1] !== undefined ? "." + parts[1] : "");
            return (neg ? "-" : "") + s;
        }
        return String(root.value === null || root.value === undefined ? "" : root.value);
    }

    property int dir: 1
    property int epoch: 0
    property real _prev: 0
    function bump(v) {
        if (typeof v === "number") {
            if (v !== root._prev) root.dir = v > root._prev ? 1 : -1;
            root._prev = v;
        }
        root.epoch++;
    }
    onValueChanged: root.bump(root.value)
    Component.onCompleted: { root._prev = typeof root.value === "number" ? root.value : 0; root.epoch++; }

    implicitWidth: _window.implicitWidth
    implicitHeight: _windowH

    Item {
        id: _window
        width: childrenRect.width
        height: root._windowH
        implicitWidth: width
        clip: true
        Row {
            id: _row
            spacing: 0
            height: root._windowH
            Repeater {
                model: root._display.length
                delegate: Item {
                    id: _reel
                    required property int index
                    readonly property string ch: root._display.charAt(index)
                    readonly property int wheel: (ch >= "0" && ch <= "9") ? 10 : (/[A-Za-z]/.test(ch) ? 26 : 1)
                    readonly property int target: _reel.wheel === 10 ? (ch.charCodeAt(0) - 48)
                            : (_reel.wheel === 26 ? (_reel.chChar() - (_reel.upper ? 65 : 97)) : 0)
                    readonly property bool upper: ch === ch.toUpperCase()
                    function chChar() { return _reel.ch.charCodeAt(0); }
                    // 落地后要停的位（0..wheel-1）
                    property real pos: _reel.wheel <= 1 ? 0 : _reel.target
                    width: _reel.wheel <= 1 ? Math.max(2, Math.round(_probe.implicitWidth)) : root._cellW
                    height: root._windowH

                    // 字形 i（0..wheel-1）对应的字符
                    function glyph(i) {
                        if (_reel.wheel === 10) return String(i);
                        if (_reel.wheel === 26) return String.fromCharCode((_reel.upper ? 65 : 97) + i);
                        return _reel.ch;
                    }
                    // 换值：从左到右依次起转（delay = index*stagger），终点 target + spins*wheel*dir
                    Connections {
                        target: root
                        function onEpochChanged() {
                            if (_reel.wheel <= 1) { _reel.pos = 0; return; }
                            _roll.restart();
                        }
                    }
                    Timer {
                        id: _roll
                        interval: _reel.index * root.stagger
                        onTriggered: {
                            _spin.from = _reel.pos;
                            _spin.to = _reel.target + root.spins * _reel.wheel * root.dir;
                            _spin.restart();
                        }
                    }
                    NumberAnimation {
                        id: _spin
                        target: _reel; property: "pos"; from: 0; to: 0
                        duration: Math.max(120, root.duration)
                        easing.type: Easing.Bezier
                        easing.bezierCurve: root.th ? root.th.ease("Standard") : [0.22, 1, 0.36, 1, 1, 1]
                    }
                    Repeater {
                        model: _reel.wheel
                        delegate: Text {
                            required property int index
                            // 环上距离归一到 [-w/2, w/2)
                            readonly property real off: {
                                var w = _reel.wheel;
                                if (w <= 1) return 0;
                                var raw = (((index - _reel.pos) % w) + w) % w;
                                return raw > w / 2 ? raw - w : raw;
                            }
                            // EdgeFade：窗边缘 root._fade 内线性渐隐
                            readonly property real edgeOp: {
                                var half = _reel.height / 2;
                                var d = Math.abs(off) * root._pitch;
                                if (d >= half) return 0;
                                if (d <= half - root._fade) return 1;
                                return (half - d) / Math.max(0.001, root._fade);
                            }
                            renderType: Text.NativeRendering
                            font.family: root.th ? root.th.fontFamily : "Segoe UI"
                            text: _reel.glyph(index)
                            color: root.color
                            opacity: edgeOp
                            font.pixelSize: root.fontSize
                            font.weight: root.th ? root.th.weightMedium : 500
                            width: _reel.width
                            height: root._lineH
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            y: _reel.height / 2 - root._lineH / 2 + off * root._pitch
                        }
                    }
                }
            }
        }
    }
    Text {
        id: _probe
        visible: false
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.fontSize
        font.weight: root.th ? root.th.weightMedium : 500
    }
}
