// arc:Countdown —— Progress/Countdown 真源码移植（Countdown.cs + CountdownToken.cs + CountdownFace/CountdownTime）。
// 倒计时：按秒/分/时拆段显示（两位补零），结束时切到 CompleteBackground/CompleteBorder 的完成态；
// 紧凑模式 CompactMinHeight32 / CompactPadding[12,0,12,0]。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property int seconds: 0
    property bool running: false
    property bool compact: false
    property string completeLabel: "Done"
    signal finished()

    readonly property real _compactH: root.th.ct("Countdown", "CompactMinHeight")
    readonly property int _h: Math.floor(root.seconds / 3600)
    readonly property int _m: Math.floor((root.seconds % 3600) / 60)
    readonly property int _s: root.seconds % 60
    readonly property string _text: {
        if (root.seconds <= 0) return root.completeLabel;
        var parts = [];
        if (root._h > 0) parts.push(root._pad2(root._h));
        parts.push(root._pad2(root._m));
        parts.push(root._pad2(root._s));
        return parts.join(":");
    }
    readonly property bool _done: root.seconds <= 0
    function _pad2(n) { return n < 10 ? "0" + n : String(n); }
    implicitWidth: _pill.implicitWidth
    implicitHeight: root.compact ? root._compactH : 40

    Timer {
        interval: 1000
        repeat: true
        running: root.running && root.seconds > 0
        onTriggered: {
            root.seconds = Math.max(0, root.seconds - 1);
            if (root.seconds === 0) root.finished();
        }
    }
    Rectangle {
        id: _pill
        width: _lbl.implicitWidth + (root.compact ? 2 * root.th.t4(root.th.ct("Countdown", "CompactPadding"), 0) : 32)
        height: root.compact ? root._compactH : 40
        radius: height / 2
        color: root._done ? (root.th ? root.th.ct("Countdown", "CompleteBackground") : "#FFEBF3EB")
                          : (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0")
        border.width: root._done ? 1 : 0
        border.color: root.th ? root.th.ct("Countdown", "CompleteBorder") : "#FFA3C2A4"
        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Standard") : 240 } }
        Text {
            id: _lbl
            anchors.centerIn: parent
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root._text
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            font.pixelSize: root.th ? root.th.design(root.compact ? "TypeXS" : "TypeSM") : 13
            font.weight: root.th ? root.th.weightMedium : 500
            font.letterSpacing: 0.4
        }
    }
}
