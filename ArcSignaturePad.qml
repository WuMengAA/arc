// arc:SignaturePad —— Editors/SignaturePad 真源码移植（SignaturePad.cs 890 行 + SignaturePadToken.cs + SignatureInk/
// SignaturePadParts）。
// 签名板：画布上连续的墨迹（InkWidth / InkColor 或序列色），下方是操作行（清空 / 撤销 / 导出，OptionSize36 /
// GroupDividerHeight20）。指针点累积成折线，松手时才重绘一次。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property color inkColor: "transparent"
    property real inkWidth: 2.4
    property string hint: "Sign here"
    property string fileName: "signature.png"
    property bool readOnly: false
    signal cleared()
    signal exported()

    readonly property color _ink: root.inkColor.a > 0 ? root.inkColor
            : (root.th ? root.th.ct("SignaturePad", "InkBlueColor") : "#FF1C50B5")
    readonly property real _optSize: root.th.ct("SignaturePad", "OptionSize")
    readonly property real _divH: root.th.ct("SignaturePad", "GroupDividerHeight")
    readonly property real _rowGap: root.th.ct("SignaturePad", "RowGap")
    property var strokes: []
    implicitWidth: 360
    implicitHeight: _canvas.height + root._rowGap + root._optSize

    Canvas {
        id: _canvas
        width: parent.width
        height: 180
        antialiasing: true
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.lineWidth = root.inkWidth;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            ctx.strokeStyle = root._ink;
            for (var i = 0; i < root.strokes.length; i++) {
                var s = root.strokes[i];
                if (!s || s.length < 2) continue;
                ctx.beginPath();
                ctx.moveTo(s[0].x, s[0].y);
                for (var j = 1; j < s.length; j++) ctx.lineTo(s[j].x, s[j].y);
                ctx.stroke();
            }
        }
        Component.onCompleted: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }
    Rectangle {
        anchors.fill: _canvas
        radius: 14
        color: "transparent"
        border.width: 1.5
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
    }
    Text {
        visible: root.strokes.length === 0
        anchors.centerIn: _canvas
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.hint
        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
    }
    MouseArea {
        anchors.fill: _canvas
        enabled: !root.readOnly
        onPressed: {
            var arr = root.strokes.slice();
            arr.push([{ x: mouse.x, y: mouse.y }]);
            root.strokes = arr;
        }
        onPositionChanged: {
            if (!pressed) return;
            var arr = root.strokes.slice();
            var s = arr[arr.length - 1].slice();
            s.push({ x: mouse.x, y: mouse.y });
            arr[arr.length - 1] = s;
            root.strokes = arr;
            _canvas.requestPaint();
        }
        onReleased: _canvas.requestPaint()
    }
    Row {
        y: _canvas.height + root._rowGap
        spacing: 6
        Repeater {
            model: 3
            delegate: Rectangle {
                required property int index
                width: root._optSize; height: root._optSize
                radius: 10
                color: _om2.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                Arc.ArcIcon {
                    anchors.centerIn: parent
                    width: 18; height: 18
                    th: root.th
                    kind: index === 0 ? "Undo" : (index === 1 ? "Trash" : "Download")
                    color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                }
                MouseArea {
                    id: _om2
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (index === 0) {
                            var arr = root.strokes.slice();
                            arr.pop();
                            root.strokes = arr;
                            _canvas.requestPaint();
                        } else if (index === 1) {
                            root.strokes = [];
                            _canvas.requestPaint();
                            root.cleared();
                        } else root.exported();
                    }
                }
            }
        }
        Rectangle {
            width: 1; height: root._divH
            anchors.verticalCenter: parent.verticalCenter
            color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.fileName
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
    }
}
