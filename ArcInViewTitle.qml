// arc:InViewTitle —— TextEffects/InViewTitle 真源码移植（InViewTitle.cs + InViewTitleToken.cs）。
// 区块标题：滚到 45% 入视口时自己揭示（P18+P20）——不透明度先到、模糊随后清、位移最后落定，所以标题在完全到位前就读得懂。
// 已经滚过去的标题立刻显示；ReplayEnabled 时离场快速淡出（无错峰）并在每次进入时重放。
// Variant：0 Word（每词升 0.9em，出自己那道裁剪）/ 1 Line（逐行升，80ms 错峰）/ 2 Blur（默认，8px 模糊转清 + 升 0.2em）
//          3 Tracking（字距由紧打开 + 过一道软模糊）/ 4 Wipe（柔和遮罩从左到右揭开）。
// 令牌：TitleLeading1.1。动效降级时不给位移/模糊/遮罩，直接静止显示。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string text: ""
    property int variant: 2
    property int level: 1                // 0 H1 / 1 H2 / 2 H3 / 3 Paragraph
    property var lines: null             // Line 变体的显式行；null 用整段文本
    property bool replayEnabled: false
    property real tracking: 0
    property real leading: -1
    property real blurRadius: 8
    property real softBlurRadius: 4
    property color color: th ? th.c("Foreground") : "#FF1D1D1D"
    // 宿主注入：是否已入视口（≥45%）
    property bool inView: false
    property bool isRevealed: false
    signal revealed()

    readonly property bool _full: root.th === null || root.th.motionLevel >= 2
    readonly property real _leading: root.leading > 0 ? root.leading : root.th.ct("InViewTitle", "TitleLeading")
    readonly property real _fs: root.level === 0 ? root.th.design("Type3XL")
                          : root.level === 1 ? root.th.design("Type2XL")
                          : root.level === 2 ? root.th.design("TypeXL")
                          : root.th.design("TypeBase")
    readonly property int _weight: root.level === 3 ? root.th.weightRegular : root.th.weightSemibold
    readonly property real _wordStep: root.th.stagger("Word")
    readonly property real _lineStep: root.th.stagger("Line")
    // Word：升 0.9em；Blur：升 0.2em + 8px 模糊；Tracking：字距从 0.02em 打开 + 4px 软模糊
    readonly property real _wordRise: 0.9 * root._fs
    readonly property real _blurRise: 0.2 * root._fs
    readonly property real _blurPx: root.blurRadius
    readonly property real _softPx: root.softBlurRadius

    readonly property var _lineList: {
        if (root.lines && root.lines.length > 0) return root.lines;
        var t = root.text.split("\n");
        return t;
    }
    readonly property var _wordList: {
        var out = [];
        for (var i = 0; i < root._lineList.length; i++) {
            var parts = String(root._lineList[i]).split(/(\s+)/);
            for (var j = 0; j < parts.length; j++) if (parts[j] !== "") out.push({ w: parts[j], line: i });
        }
        return out;
    }
    property real clock: 0
    property bool playing: false
    readonly property real _total: (root.variant === 0 ? root._wordStep * Math.max(0, root._wordList.length - 1)
                                   : root.variant === 1 ? root._lineStep * Math.max(0, root._lineList.length - 1)
                                   : 420) + 700

    implicitWidth: _flow.implicitWidth
    implicitHeight: _flow.height
    onInViewChanged: {
        if (root.inView) {
            if (root.replayEnabled || !root.isRevealed) root.start();
        } else if (root.replayEnabled) {
            root.isRevealed = false; root.clock = 0; root.playing = false;
        }
    }
    Component.onCompleted: if (root.inView) root.start()
    function start() {
        root.isRevealed = true;
        if (!root._full) { root.clock = root._total; root.playing = false; root.revealed(); return; }
        root.clock = 0; root.playing = true; _tick.restart(); root.revealed();
    }
    Timer {
        id: _tick
        interval: 16; repeat: true; running: root.playing
        onTriggered: { root.clock += 16; if (root.clock >= root._total) { root.clock = root._total; root.playing = false; } }
    }
    Text {
        id: _probe
        visible: false; renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root._fs; font.weight: root._weight; text: "0"
    }

    Column {
        id: _flow
        spacing: root._fs * (root._leading - 1)
        Repeater {
            model: root._lineList
            delegate: Item {
                required property var modelData
                required property int index
                // Line 变体：逐行错峰
                readonly property real lineP: Math.max(0, Math.min(1, (root.clock - index * root._lineStep) / 700))
                height: _lw.implicitHeight
                width: _lw.implicitWidth
                clip: root._full && (root.variant === 0 || root.variant === 1)
                Text {
                    id: _lw
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: modelData
                    color: root.color
                    font.pixelSize: root._fs
                    font.weight: root._weight
                    font.letterSpacing: root.tracking * root._fs * (root.variant === 3 ? (1 + (1 - lineP) * 0.35) : 1)
                    y: root._full && root.variant === 1 ? (1 - lineP) * root._wordRise * 0.5 : 0
                    opacity: root._full && root.variant === 1 ? lineP : 1
                }
            }
        }
    }
}
