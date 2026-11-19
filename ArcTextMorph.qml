// arc:TextMorph —— TextEffects/TextMorph 真源码移植（TextMorph.cs + TextMorphToken.cs）。
// 单行标签原地变形：两串共有的字用 ArcSpring.Morph 滑到新位置；新增字错峰 0.05+min(i,8)*0.032s、0.28s 内从
// 0.8 缩放 / 下移 0.14em 淡入；删掉的字 0.14 缩放 / 上移 0.1em 淡出（Exit 时长）；整行宽度跟 Morph 弹簧走。
// Matching：0 Occurrence（按「字符-第几次出现」配对，默认）/ 1 PrefixSuffix（公共首尾段各 ≥2 才保身份）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string text: ""
    property int matching: 0
    property real fontSize: th ? th.design("TypeBase") : 14
    property color color: th ? th.c("Foreground") : "#FF1D1D1D"
    property int fontWeight: th ? th.weightMedium : 500

    // 行高用 "Hg" 的量高（真源码 _lineHeight = Shape("Hg").Height）
    readonly property real lineHeight: Math.round(root.fontSize * 1.35)
    readonly property real _enterRise: (root.th ? root.th.ct("TextMorph", "EnterRiseEm") : 0.14) * root.fontSize
    readonly property real _exitLift: (root.th ? root.th.ct("TextMorph", "ExitLiftEm") : 0.1) * root.fontSize
    readonly property int _enterMs: 280
    readonly property int _exitMs: root.th ? root.th.dur("Exit") : 180
    readonly property int _morphMs: root.th ? root.th.springSettle("Morph") : 440
    readonly property bool _animate: root.th === null || root.th.motionLevel >= 2

    implicitWidth: Math.round(_widthP)
    implicitHeight: root.lineHeight
    property real _widthP: 0
    property real _widthT: 0
    property var rows: []          // [{k, ch, w, x0, tx, x, enter, exit, leaving, delay}]
    property real _seq: 0

    Component.onCompleted: root.remorph("")
    onTextChanged: root.remorph(root._prev || "")
    property string _prev: ""

    Text {
        id: _probe
        visible: false
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.fontSize
        font.weight: root.fontWeight
        property real w: 0
    }
    function _measure(ch) { _probe.text = (ch === " ") ? "\u00A0" : ch; return _probe.implicitWidth; }

    // ── 键配对（真源码 Keys()）──
    function _keys(next) {
        var chars = next.split(""), out = [], i;
        if (root.matching === 0) {
            var seen = {};
            for (i = 0; i < chars.length; i++) {
                var ch = chars[i];
                var c = (seen[ch] === undefined) ? 0 : seen[ch];
                seen[ch] = c + 1;
                out.push({ k: ch + "-" + c, ch: ch });
            }
            return out;
        }
        var prev = (root._prev || "").split(""), live = [], g;
        for (i = 0; i < root.rows.length; i++) if (!root.rows[i].leaving) live.push(root.rows[i]);
        var start = 0, end = 0;
        while (start < prev.length && start < chars.length && prev[start] === chars[start]) start++;
        while (end < prev.length - start && end < chars.length - start &&
               prev[prev.length - 1 - end] === chars[chars.length - 1 - end]) end++;
        if (start < 2) start = 0;
        if (end < 2) end = 0;
        root._seq++;
        for (i = 0; i < chars.length; i++) {
            if (i < start && i < live.length) out.push({ k: live[i].k, ch: chars[i] });
            else if (i >= chars.length - end && live.length - (chars.length - i) >= 0)
                out.push({ k: live[live.length - (chars.length - i)].k, ch: chars[i] });
            else out.push({ k: root._seq + ":" + i, ch: chars[i] });
        }
        return out;
    }

    function remorph(prev) {
        var keys = root._keys(root.text), i;
        var existing = {};
        for (i = 0; i < root.rows.length; i++) if (!root.rows[i].leaving) existing[root.rows[i].k] = root.rows[i];
        var ordered = [], entering = 0;
        for (i = 0; i < keys.length; i++) {
            var k = keys[i].k;
            if (existing[k] !== undefined) { ordered.push(existing[k]); delete existing[k]; }
            else {
                ordered.push({ k: k, ch: keys[i].ch, w: root._measure(keys[i].ch), x0: 0, tx: 0, x: 0,
                               enter: root._animate ? 0 : 1, exit: 0, leaving: false,
                               delay: (0.05 + Math.min(entering, 8) * 0.032) * 1000,
                               born: _clock.ms });
                entering++;
            }
        }
        // 删掉的字留在原位、脱离排版、淡出
        var leaving = [];
        for (var kk in existing) { var g2 = existing[kk]; g2.leaving = true; g2.exit = 0; g2.born = _clock.ms; leaving.push(g2); }
        var all = ordered;
        for (i = 0; i < leaving.length; i++) all.push(leaving[i]);
        root.rows = all;
        root._relayout();
        root._prev = root.text;
        _clock.restart();
    }

    function _relayout() {
        var x = 0;
        for (var i = 0; i < root.rows.length; i++) {
            var g = root.rows[i];
            if (g.leaving) continue;
            if (!g.placed) { g.placed = true; g.x0 = x; g.x = x; }
            else g.x0 = g.x;
            g.tx = x;
            x += g.w;
        }
        root._widthT = x;
        root._layoutAt = 0;
    }
    property real _layoutAt: 0

    // 一帧驱动：Morph 弹簧滑位 + enter/exit 进度
    Timer {
        id: _clock
        interval: 16; repeat: true; running: false
        property real ms: 0
        onRunningChanged: if (running) ms = 0
        onTriggered: {
            ms += interval;
            var done = true, i, g;
            for (i = 0; i < root.rows.length; i++) {
                g = root.rows[i];
                if (g.leaving) {
                    var q = Math.min(1, (ms - (g.born || 0)) / Math.max(1, root._exitMs));
                    g.exit = q;
                    if (q < 1) done = false;
                } else {
                    var pe = Math.min(1, Math.max(0, (ms - (g.delay || 0)) / Math.max(1, root._enterMs)));
                    g.enter = (g.enter === undefined || g.enter >= 1) ? 1 : pe;
                    if (g.enter < 1) done = false;
                    var pm = Math.min(1, ms / Math.max(1, root._morphMs));
                    var f = root.th ? root.th.springEase("Morph", pm) : pm;
                    g.x = g.x0 + (g.tx - g.x0) * f;
                    if (pm < 1 && Math.abs(g.tx - g.x0) > 0.001) done = false;
                }
            }
            var pw = Math.min(1, ms / Math.max(1, root._morphMs));
            root._widthP = root._widthP + (root._widthT - root._widthP) * (root.th ? root.th.springEase("Morph", pw) : pw);
            // 触发器：rows 是 JS 数组，改属性不会自动刷新，靠这个计数强制 delegate 重读
            root._frame++;
            if (done) { clockDone(); }
        }
    }
    property int _frame: 0
    function clockDone() {
        _clock.stop();
        var out = [], i;
        for (i = 0; i < root.rows.length; i++) {
            var g = root.rows[i];
            if (g.leaving) continue;
            g.enter = 1; g.x0 = g.x; g.x = g.tx;
            out.push(g);
        }
        root.rows = out;
        root._widthP = root._widthT;
        root._frame++;
    }

    Item {
        id: _stage
        width: root.implicitWidth
        height: root.lineHeight
        Repeater {
            model: root._frame >= 0 ? root.rows : root.rows
            delegate: Text {
                id: _gl
                required property var modelData
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: modelData.ch
                color: root.color
                font.pixelSize: root.fontSize
                font.weight: root.fontWeight
                width: Math.ceil(modelData.w)
                x: root._frame >= 0 ? (modelData.leaving ? (modelData.x || 0) : modelData.x) : 0
                y: modelData.leaving
                   ? -root._exitLift * (modelData.exit || 0)
                   : root._enterRise * (1 - (modelData.enter === undefined ? 1 : modelData.enter))
                opacity: modelData.leaving ? (1 - (modelData.exit || 0)) : (modelData.enter === undefined ? 1 : modelData.enter)
                scale: modelData.leaving ? (1 - 0.14 * (modelData.exit || 0))
                                         : (0.8 + 0.2 * (modelData.enter === undefined ? 1 : modelData.enter))
                transformOrigin: Item.Center
                height: root.lineHeight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
