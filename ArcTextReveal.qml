// arc:TextReveal —— TextEffects/TextReveal 真源码移植（TextReveal.cs + TextRevealToken.cs）。
// 标题逐词升起：每个词从自己那道柔和裁剪里升起，同时由软模糊转清晰并淡入（P20/P29）；
// 逐词错峰 = min(StaggerWord 40ms, Considered 480ms / 词数)，首词前可等 Delay。
// 单帧时序：RiseSeconds 0.76 / FadeSeconds 0.44 / FocusSeconds 0.58，升起量 RiseEm 0.62。
// 令牌：LineLengthChars24（行宽上限，按 "0" 字宽计，0 关闭）/ HeadingLeading1.1 / ParagraphLeading1.4。
// 用 \n 显式断行。动效不可用（motionLevel<2 或未加载）时直接落到静止态。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string text: ""
    property int level: 1               // 0 H1 / 1 H2 / 2 H3 / 3 Paragraph
    property int delay: 0
    property real maxWidthInChars: 24
    property real tracking: 0
    property real leading: -1            // -1 → 走令牌（标题 1.1 / 段落 1.4）
    property real blurRadius: 8
    property color color: th ? th.c("Foreground") : "#FF1D1D1D"
    property bool replay: false

    readonly property bool _full: root.th === null || root.th.motionLevel >= 2
    readonly property real _leading: root.leading > 0 ? root.leading
            : (root.level === 3 ? root.th.ct("TextReveal", "ParagraphLeading") : root.th.ct("TextReveal", "HeadingLeading"))
    readonly property real _maxChars: root.maxWidthInChars > 0 ? root.maxWidthInChars : root.th.ct("TextReveal", "LineLengthChars")
    readonly property real _fs: root.level === 0 ? root.th.design("Type3XL")
                          : root.level === 1 ? root.th.design("Type2XL")
                          : root.level === 2 ? root.th.design("TypeXL")
                          : root.th.design("TypeBase")
    readonly property int _weight: root.level === 3 ? root.th.weightRegular : root.th.weightSemibold
    // RiseEm / Fade / Focus 三段时长（秒 → ms）
    readonly property int _riseMs: 760
    readonly property int _fadeMs: 440
    readonly property int _focusMs: 580
    readonly property real _riseEm: 0.62 * root._fs

    // 词表：按空白切，\n 保留为强制换行标记
    readonly property var _words: {
        var raw = root.text.split("\n"), out = [];
        for (var li = 0; li < raw.length; li++) {
            var ws = raw[li].split(/(\s+)/);
            for (var i = 0; i < ws.length; i++) {
                if (ws[i] === "") continue;
                out.push({ w: ws[i], brk: li > 0 && i === 0 });
            }
        }
        return out;
    }
    readonly property int _nWords: root._words.length
    // 逐词错峰：min(40, 480/n)
    readonly property real _step: Math.min(root.th.stagger("Word"), root.th.dur("Considered") / Math.max(1, root._nWords))
    property real clock: 0
    property bool playing: false
    readonly property real _total: root.delay + root._riseMs + root._step * Math.max(0, root._nWords - 1)

    // 行宽用 "0" 字宽量
    readonly property real _chW: _probe.implicitWidth
    readonly property real _lineMax: root._maxChars > 0 ? root._chW * root._maxChars : -1

    implicitWidth: _flow.implicitWidth
    implicitHeight: _flow.implicitHeight
    Component.onCompleted: root.play()
    onTextChanged: if (root.replay) root.play()
    function play() {
        if (!root._full) { root.clock = root._total; root.playing = false; return; }
        root.clock = 0; root.playing = true; _tick.restart();
    }
    Timer {
        id: _tick
        interval: 16; repeat: true; running: root.playing
        onTriggered: {
            root.clock += 16;
            if (root.clock >= root._total) { root.clock = root._total; root.playing = false; }
        }
    }
    Text {
        id: _probe
        visible: false
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root._fs; font.weight: root._weight
        text: "0"
    }

    // 行内折行：用 Flow 按词排，超过 _lineMax 自动换行
    Flow {
        id: _flow
        width: root._lineMax > 0 ? Math.min(root._lineMax, root.width > 0 ? root.width : root._lineMax) : root.width
        spacing: 0
        Repeater {
            model: root._words
            delegate: Item {
                required property var modelData
                required property int index
                // 该词的时序：Delay + index*step 起，Rise 结束；fade 早于 rise 收尾
                readonly property real t0: root.delay + index * root._step
                readonly property real p: Math.max(0, Math.min(1, (root.clock - t0) / Math.max(1, root._riseMs)))
                readonly property real pf: Math.max(0, Math.min(1, (root.clock - t0) / Math.max(1, root._fadeMs)))
                readonly property real pc: Math.max(0, Math.min(1, (root.clock - t0) / Math.max(1, root._focusMs)))
                // 只有空间分隔符才加词后空格；显式换行处不加
                readonly property string suffix: (modelData.w.trim() === "" || index === root._nWords - 1) ? "" : " "
                width: _wt.implicitWidth + (suffix === "" ? 0 : _sp.implicitWidth)
                height: _wt.implicitHeight
                clip: root._full
                Text {
                    id: _wt
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: modelData.w + parent.suffix
                    color: root.color
                    font.pixelSize: root._fs
                    font.weight: root._weight
                    font.letterSpacing: root.tracking * root._fs
                    y: root._full ? (1 - parent.p) * root._riseEm : 0
                    opacity: root._full ? parent.pf : 1
                    // 模糊：QML 侧用 MultiEffect（QtQuick.Effects）在需要时叠一层；无模糊时纯文本
                }
                Text {
                    id: _sp
                    visible: false
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: " "; font.pixelSize: root._fs; font.weight: root._weight
                }
            }
        }
    }
}
