// arc:ArcRollingNumber —— Core/Primitives/RollingDigits.cs：Value/Decimals/Prefix/Suffix/columns 数字轮。
// 每位一列 0..9 三个循环（30 行），wheelPos 绑定 digit 后由 Behavior 以真弹簧 settle 时长滚动；
// Mo.rollingShortest（IsShortestTurn）由 th 暴露，陈列页展示其计算真值。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property real value: 0
    property int columns: 4
    property string prefix: ""
    property string suffix: ""
    property real fontSize: 32
    property color color: th ? th.c("Foreground") : "#FF1D1D1D"
    property string springName: "Snappy"
    property bool demo: false

    readonly property real _lineH: root.fontSize * 1.25
    readonly property real _digitW: root.fontSize * 0.62
    readonly property int _dur: root.th !== null ? root.th.springSettle(root.springName) : 466
    readonly property var _ease: root.th !== null ? root.th.ease("Enter") : [0.16,1,0.3,1,1,1]
    implicitWidth: _row.implicitWidth
    implicitHeight: root._lineH

    Timer {
        interval: 2200; repeat: true; running: root.demo
        onTriggered: root.value = Math.floor(root.value + 137) % 10000
    }

    Row {
        id: _row
        spacing: 0
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.prefix; visible: root.prefix !== ""; color: root.color; font.pixelSize: root.fontSize;
               height: root._lineH; verticalAlignment: Text.AlignVCenter; font.weight: root.th ? root.th.weightMedium : 500 }
        Repeater {
            model: root.columns
            Item {
                property int place: Math.pow(10, root.columns - 1 - index)
                property int digit: Math.floor(Math.abs(root.value) / place) % 10
                // 中间循环（第 2 个 10 行）：wheelPos=10+digit → 可见行 index%10===digit，上下各有一整轮可滚
                property real wheelPos: 10 + digit
                width: root._digitW
                height: root._lineH
                clip: true
                Behavior on wheelPos {
                    NumberAnimation { duration: root._dur; easing.type: Easing.Bezier; easing.bezierCurve: root._ease }
                }
                Column {
                    width: root._digitW
                    y: -wheelPos * root._lineH
                    Repeater {
                        model: 30
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                            width: root._digitW; height: root._lineH
                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            text: String(index % 10); color: root.color
                            font.pixelSize: root.fontSize; font.weight: root.th ? root.th.weightMedium : 500
                        }
                    }
                }
            }
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.suffix; visible: root.suffix !== ""; color: root.color; font.pixelSize: root.fontSize;
               height: root._lineH; verticalAlignment: Text.AlignVCenter; font.weight: root.th ? root.th.weightMedium : 500 }
    }
}
