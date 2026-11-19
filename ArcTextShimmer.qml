// arc:TextShimmer —— TextEffects/TextShimmer 真源码移植（TextShimmer.cs + TextShimmerToken.cs）。
// 一道钟形光带扫过一行短状态文字，然后短暂停顿再扫。真源码：静止底 = 文字色以 BaseMix(0.12) 混进 muted；
// 光带 = 同一段文字经「滑动透明度遮罩」再画一遍，带宽 ±2.2em；一趟 SweepDuration(1.8s)，两趟间停 32%，
// 首次进场静 0.12s；IsActive 关掉时光带滑出、文字落到实心（settle 0→1）。循环只在 active 且全动效时跑。
// QML 侧无 OpacityMask，这里把钟形带切成若干窄片，每片画同一段文字的裁切，透明度按 bell 权重给——等价视觉。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string text: ""
    property bool isActive: true
    property int sweepDuration: 1800
    property color baseForeground: "transparent"
    property real fontSize: th ? th.design("TypeBase") : 14
    property color color: th ? th.c("Foreground") : "#FF1D1D1D"

    readonly property real _baseMix: root.th ? root.th.ct("TextShimmer", "BaseMix") : 0.12
    readonly property real _bandEm: 2.2
    readonly property real _bandW: root.fontSize * root._bandEm * 2
    readonly property real _lineH: Math.round(root.fontSize * 1.4)
    readonly property int _slices: 13

    // 静止底：文字色按 BaseMix 混进 muted
    readonly property color _baseColor: {
        var m = root.th ? root.th.c("TextMuted") : "#FF6D6D6D";
        var k = root._baseMix;
        return Qt.rgba(root.color.r * k + m.r * (1 - k), root.color.g * k + m.g * (1 - k),
                       root.color.b * k + m.b * (1 - k), 1);
    }

    property real settle: root.isActive ? 0 : 1
    property real sweep: 0
    property real pause: 0
    property real _textRise: 0

    implicitWidth: _label.implicitWidth
    implicitHeight: root._lineH
    clip: true

    Behavior on settle {
        NumberAnimation { duration: root.th ? root.th.dur("Standard") : 240
            easing.type: Easing.Bezier; easing.bezierCurve: root.th ? root.th.ease("Standard") : [0.22, 1, 0.36, 1, 1, 1] }
    }
    onIsActiveChanged: { if (root.isActive) { root.pause = root.sweep > 0 ? 0 : 120; } }
    onTextChanged: { root._textRise = 1; _rise.restart(); }
    NumberAnimation { id: _rise; target: root; property: "_textRise"; to: 0
        duration: root.th ? root.th.dur("Standard") : 240
        easing.type: Easing.Bezier; easing.bezierCurve: root.th ? root.th.ease("Enter") : [0.16, 1, 0.3, 1, 1, 1] }

    // LiveLoop：仅 active 且 motionLevel>=2 时跑；暂停时停在原处
    Timer {
        id: _loop
        interval: 16
        repeat: true
        running: root.isActive && (root.th === null || root.th.motionLevel >= 2)
        onTriggered: root._step()
    }

    function _step() {
        var dt = 16 / 1000;
        var duration = Math.max(root.sweepDuration / 1000, 0.05);
        if (root.pause > 0) {
            root.pause -= dt * 1000;
            if (root.pause > 0) return;
            dt = -root.pause / 1000;
            root.pause = 0;
            if (root.sweep >= 1) root.sweep = 0;
        }
        root.sweep += dt / duration;
        if (root.sweep >= 1) { root.sweep = 1; root.pause = duration * 0.32 * 1000; }
    }

    Text {
        id: _label
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.text
        color: root._baseColor
        font.pixelSize: root.fontSize
        font.weight: root.th ? root.th.weightMedium : 500
        height: root._lineH
        verticalAlignment: Text.AlignVCenter
        y: root._textRise * root.fontSize * 0.12
        opacity: 1 - root._textRise * 0.35
    }
    // 实心文字：settle 提升时露出来
    Text {
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.text
        color: root.color
        opacity: root.settle * (1 - root._textRise * 0.35)
        font.pixelSize: root.fontSize
        font.weight: root.th ? root.th.weightMedium : 500
        height: root._lineH
        verticalAlignment: Text.AlignVCenter
        y: root._textRise * root.fontSize * 0.12
    }
    // 光带：_slices 片窄窗，每片画整段文字但被 clip 到自己的窗口；权重取钟形
    Item {
        id: _band
        x: -root._bandW + (root.implicitWidth + 2 * root._bandW) * root.sweep
        y: 0
        width: root._bandW
        height: root._lineH
        visible: root.isActive && root.settle < 0.999
        Repeater {
            model: root._slices
            delegate: Item {
                required property int index
                // t ∈ (0,1)：片中心在带内的相对位置
                readonly property real t: (index + 0.5) / root._slices
                // 钟形权重：sin^2，两端 0、中间 1
                readonly property real weight: Math.pow(Math.sin(Math.PI * t), 2)
                width: root._bandW / root._slices
                height: root._lineH
                x: index * width
                clip: true
                opacity: weight * (1 - root.settle)
                Text {
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root.text
                    color: root.color
                    font.pixelSize: root.fontSize
                    font.weight: root.th ? root.th.weightMedium : 500
                    height: root._lineH
                    verticalAlignment: Text.AlignVCenter
                    x: -(_band.x + parent.x)
                }
            }
        }
    }
}
