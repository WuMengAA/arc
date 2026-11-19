// arc:AnimatedCounter —— Charts/AnimatedCounter 真源码移植（AnimatedCounter.cs + AnimatedCounterTheme.axaml +
// Core/Primitives/RollingDigits.cs）。标签在上（ArcContentSwap BlurSwap，LabelMargin），下面是 odometer 数字：
// 每一列是 0..9 一轮字形，按 offset=((((d-pos)%10)+15)%10)-5 绕着读数线排；只有变了的列转动，方向随数值增减。
// 首次揭示（AnimateOnView）每列从 0 起、按 min(order*0.035, 0.25)s 错峰。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property real value: 0
    property string label: ""
    property string prefix: ""
    property string suffix: ""
    property int decimals: 0
    property bool animateOnView: false
    property string cultureName: "en-US"
    // RollingDigits 全参（Arc 公开面逐字）
    property bool useGrouping: true
    property string wheelSpring: "Smooth"
    property bool isShortestTurn: false
    property real glyphPitch: 1.0
    property int falloff: 0            // 0 Linear / 1 Eased / 2 None
    property int fontSize: th ? th.design("Type3XL") : 36
    property color color: th ? th.c("Foreground") : "#FF1D1D1D"

    readonly property int _lineH: Math.round(root.fontSize * 1.25)
    readonly property real _cellW: root.fontSize * 0.62
    readonly property int _dur: root.th !== null ? root.th.springSettle(root.wheelSpring) : 466
    readonly property var _ease: root.th !== null ? root.th.ease("Enter") : [0.16, 1, 0.3, 1, 1, 1]
    readonly property string _num: root._format(Math.abs(root.value))
    readonly property string _text: (root.value < 0 ? "-" : "") + root._num
    property bool armed: root.animateOnView
    // Feather：0.16em；无衰减时按行高裁切
    readonly property real _feather: root.fontSize * 0.16
    readonly property real _reach: root.falloff === 2 ? Math.max(1, root._lineH / (root.fontSize * root.glyphPitch)) : 1

    width: Math.max(_label.implicitWidth, _row.implicitWidth)
    height: _col.implicitHeight

    // Number.ToString("N"+decimals, culture)：千分位 + 定点小数（en-US 分组逗号）
    function _format(v) {
        var d = Math.max(0, root.decimals);
        var s = v.toFixed(d);
        var parts = s.split(".");
        var ip = parts[0], out = "";
        if (root.useGrouping) {
            for (var i = 0; i < ip.length; i++) {
                if (i > 0 && (ip.length - i) % 3 === 0) out += ",";
                out += ip.charAt(i);
            }
        } else out = ip;
        return d > 0 ? out + "." + parts[1] : out;
    }
    // 分段：数字列会转，字母/分隔符原样画
    readonly property var _columns: {
        var s = root._text, arr = [];
        for (var i = 0; i < s.length; i++) {
            var ch = s.charAt(i);
            arr.push({ isDigit: ch >= "0" && ch <= "9", ch: ch });
        }
        return arr;
    }
    Component.onCompleted: if (root.animateOnView) _reveal.restart()
    onAnimateOnViewChanged: if (root.animateOnView) _reveal.restart()
    Timer { id: _reveal; interval: Math.min(root._columns.length * 35, 250); onTriggered: root.armed = false }

    Column {
        id: _col
        // PART_Label：BlurSwap 交叉淡入 + 短上浮（此处用 opacity/位移近似同一时序）
        Text {
            id: _label
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            visible: root.label !== ""
            text: root.label
            color: root.th ? root.th.c("TextMuted") : "#FF6D6D6D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightRegular : 400
            bottomPadding: root.th ? root.th.pad(root.th.ct("AnimatedCounter", "LabelMargin")) : 0
        }
        Row {
            id: _row
            spacing: 0
            height: root._lineH
            Text {
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                visible: root.prefix !== ""
                text: root.prefix
                color: root.color
                font.pixelSize: root.fontSize
                font.weight: root.th ? root.th.weightMedium : 500
                height: root._lineH
                verticalAlignment: Text.AlignVCenter
            }
            Repeater {
                model: root._columns
                delegate: Item {
                    id: _cell
                    required property var modelData
                    required property int index
                    readonly property int digit: modelData.isDigit ? modelData.ch.charCodeAt(0) - 48 : 0
                    // 列的序（用于错峰）：只数数字列
                    readonly property int order: {
                        var n = 0;
                        for (var i = 0; i < index; i++) if (root._columns[i].isDigit) n++;
                        return n;
                    }
                    // pos 是当前轮位；首次揭示从 0 起，之后每次 digit 变化都滚过去
                    property real pos: 0
                    width: modelData.isDigit ? root._cellW : _ch.implicitWidth
                    height: root._lineH

                    Component.onCompleted: {
                        if (root.armed) _armAnim.restart();
                        else _cell.pos = _cell.digit;
                    }
                    onModelDataChanged: _cell.pos = _cell.digit

                    // 错峰起滚：min(order*0.035, 0.25)s 后从 0 滚到目标位
                    Timer {
                        id: _armAnim
                        interval: Math.min(_cell.order * 35, 250)
                        repeat: false
                        onTriggered: _cell.pos = _cell.digit
                    }
                    Behavior on pos {
                        NumberAnimation {
                            duration: root._dur
                            easing.type: Easing.Bezier
                            easing.bezierCurve: root._ease
                        }
                    }

                    Text {
                        id: _ch
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        visible: !modelData.isDigit
                        text: modelData.isDigit ? "" : modelData.ch
                        color: root.color
                        font.pixelSize: root.fontSize
                        font.weight: root.th ? root.th.weightMedium : 500
                        height: root._lineH
                        verticalAlignment: Text.AlignVCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Repeater {
                        model: modelData.isDigit ? 10 : 0
                        delegate: Text {
                            id: _g
                            required property int index
                            // offset = ((((d - pos) % 10) + 15) % 10) - 5
                            readonly property real off: ((((index - _cell.pos) % 10) + 15) % 10) - 5
                            readonly property real dist: Math.abs(off)
                            // Falloff：Linear 1-d / Eased 1-1.1·d^1.5 / None 恒 1
                            readonly property real glyphOpacity: root.falloff === 1
                                    ? Math.max(0, 1 - Math.pow(dist, 1.5) * 1.1)
                                    : (root.falloff === 2 ? 1 : Math.max(0, 1 - dist))
                            renderType: Text.NativeRendering
                            font.family: root.th ? root.th.fontFamily : "Segoe UI"
                            visible: dist < root._reach
                            text: String(index)
                            color: root.color
                            opacity: glyphOpacity
                            font.pixelSize: root.fontSize
                            font.weight: root.th ? root.th.weightMedium : 500
                            width: _cell.width
                            height: root._lineH
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            y: off * root.fontSize * root.glyphPitch
                        }
                    }
                }
            }
            Text {
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                visible: root.suffix !== ""
                text: root.suffix
                color: root.color
                font.pixelSize: root.fontSize
                font.weight: root.th ? root.th.weightMedium : 500
                height: root._lineH
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
