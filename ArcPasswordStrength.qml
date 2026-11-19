// arc:PasswordStrength —— TextFields/PasswordStrength 真源码移植（PasswordStrength.cs + PasswordStrengthToken.cs +
// PasswordStrengthParts/PasswordStrengthScoring）。
// 强度计：四段 SegmentHeight4 / SegmentGap5（按分数点亮，弱红/中黄/强绿），右边是强度词 WordWidth72；
// 下面是规则清单 RulesSpacing6 / RulesMargin[0,16,0,0]；计量行 MeterRowMargin[0,12,0,0]。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string text: ""
    property string wordWidthLabel: ""
    property var rules: []           // [{label, ok:bool}]
    property bool showReveal: false
    property bool isRevealed: false

    readonly property real _segH: root.th.ct("PasswordStrength", "SegmentHeight")
    readonly property real _segGap: root.th.ct("PasswordStrength", "SegmentGap")
    readonly property real _wordW: root.th.ct("PasswordStrength", "WordWidth")
    readonly property real _wordGap: root.th.ct("PasswordStrength", "WordMargin")
    readonly property real _meterTop: root.th.t4(root.th.ct("PasswordStrength", "MeterRowMargin"), 1)
    readonly property real _rulesTop: root.th.t4(root.th.ct("PasswordStrength", "RulesMargin"), 1)
    readonly property real _rulesGap: root.th.ct("PasswordStrength", "RulesSpacing")
    readonly property real _btn: root.th.ct("PasswordStrength", "RevealButtonSize")
    readonly property real _btnR: root.th.pad(root.th.ct("PasswordStrength", "RevealButtonRadius"))
    // 评分：长度 + 字符类（上游 PasswordStrengthScoring 的等价精简）
    readonly property int _score: {
        var s = String(root.text || ""), n = s.length, sc = 0;
        if (n >= 8) sc++;
        if (n >= 12) sc++;
        if (/[a-z]/.test(s) && /[A-Z]/.test(s)) sc++;
        if (/\d/.test(s)) sc++;
        if (/[^A-Za-z0-9]/.test(s)) sc++;
        return Math.max(0, Math.min(4, sc));
    }
    readonly property string _word: ["Weak", "Fair", "Good", "Strong", "Excellent"][root._score]
    readonly property color _tone: root._score <= 1 ? (root.th ? root.th.c("Danger") : "#FFCD1526")
                                   : root._score <= 2 ? (root.th ? root.th.c("Warning") : "#FFB08000")
                                   : (root.th ? root.th.c("Success") : "#FF007824")
    implicitWidth: 260
    implicitHeight: root._segH + root._meterTop + _row.implicitHeight + root._rulesTop + _rules.implicitHeight

    Row {
        id: _row
        y: root._meterTop
        spacing: 0
        Repeater {
            model: 4
            delegate: Rectangle {
                required property int index
                width: (root.width - root._wordW - root._wordGap - 3 * root._segGap) / 4
                height: root._segH
                radius: height / 2
                x: index * (width + root._segGap)
                color: index < root._score ? root._tone : (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0")
                Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
            }
        }
    }
    // 强度词
    Text {
        id: _wordTxt
        x: parent.width - root._wordW
        y: root._meterTop + (root._segH - implicitHeight) / 2
        width: root._wordW
        horizontalAlignment: Text.AlignRight
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.wordWidthLabel !== "" ? root.wordWidthLabel : root._word
        color: root._tone
        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        font.weight: root.th ? root.th.weightMedium : 500
    }
    // 规则清单
    Column {
        id: _rules
        y: root._meterTop + root._segH + root._rulesTop
        width: parent.width
        spacing: root._rulesGap
        Repeater {
            model: root.rules.length
            delegate: Row {
                required property int index
                spacing: 6
                Arc.ArcIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 12; height: 12
                    th: root.th
                    kind: root.rules[index].ok ? "Check" : "X"
                    color: root.rules[index].ok ? (root.th ? root.th.c("Success") : "#FF007824")
                                                : (root.th ? root.th.c("TextMuted") : "#FF9A9A9A")
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root.rules[index].label || ""
                    color: root.rules[index].ok ? (root.th ? root.th.c("TextSecondary") : "#FF6D6D6D")
                                                : (root.th ? root.th.c("TextMuted") : "#FF9A9A9A")
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
            }
        }
    }
}
