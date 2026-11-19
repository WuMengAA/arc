// arc:CardStack —— Media/CardStack 真源码移植（CardStack.cs + CardStackToken.cs + CardStackCard/CardStackMath/
// CardStackPanel/CardStackStage）。
// 卡片叠层：舞台 StageHeight328（MaxWidth320）上三张卡错位叠放，左右滑出判定（LeftOutcome/RightOutcome）；
// 卡高 CardHeight304，根间距 RootGap20，控件间距 ControlsGap8，阴影 ShadeColor；
// 印章 KeepStamp 用 StampHeight32 / StampPadding[10,0,12,0] / StampMargin[16,16,16,16]。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var cards: []            // [{title, body}]
    property int currentIndex: 0
    property string leftLabel: "Skip"
    property string rightLabel: "Keep"
    property bool compact: false
    signal decided(int index, string outcome)

    readonly property real _stageH: root.compact ? root.th.ct("CardStack", "CompactStageHeight") : root.th.ct("CardStack", "StageHeight")
    readonly property real _cardH: root.compact ? root.th.ct("CardStack", "CompactCardHeight") : root.th.ct("CardStack", "CardHeight")
    readonly property real _maxW: root.th.ct("CardStack", "StageMaxWidth")
    readonly property real _rootGap: root.compact ? root.th.ct("CardStack", "CompactRootGap") : root.th.ct("CardStack", "RootGap")
    readonly property real _controlsGap: root.th.ct("CardStack", "ControlsGap")
    readonly property real _shade: root.th.ct("CardStack", "ShadeColor")
    readonly property real _stampH: root.th.ct("CardStack", "StampHeight")
    readonly property real _cardW: Math.min(root._maxW, root.width)
    property real dragX: 0
    readonly property bool _armed: Math.abs(root.dragX) > root._cardW * 0.28
    implicitWidth: Math.min(root._maxW, 320)
    implicitHeight: root._stageH + root._rootGap + 40

    function decide(outcome) {
        if (root.cards.length === 0) return;
        root.decided(root.currentIndex, outcome);
        root.dragX = 0;
        root.currentIndex = Math.min(root.cards.length, root.currentIndex + 1);
    }
    // 舞台：可见三张，越往后越小越淡
    Item {
        id: _stage
        width: parent.width
        height: root._stageH
        Repeater {
            model: Math.min(3, root.cards.length - root.currentIndex)
            delegate: Rectangle {
                required property int index
                readonly property bool front: index === 0
                readonly property real depthOff: index * 10
                width: root._cardW - index * 16
                height: root._cardH - index * 12
                x: (parent.width - width) / 2 + (front ? root.dragX : 0)
                y: depthOff + (front ? 0 : 8 * index)
                radius: 20
                color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
                border.width: 1
                border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
                opacity: front ? 1 : (0.9 - 0.18 * index)
                scale: front ? 1 : (1 - 0.03 * index)
                rotation: front ? root.dragX * 0.02 : 0
                Behavior on x { NumberAnimation { duration: front ? 0 : 160 } }
                Column {
                    anchors.centerIn: parent
                    width: parent.width - 48
                    spacing: 8
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: {
                            var c = root.cards[root.currentIndex + index];
                            return c && c.title !== undefined ? c.title : "";
                        }
                        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                        font.pixelSize: root.th ? root.th.design("TypeLG") : 16
                        font.weight: root.th ? root.th.weightMedium : 500
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: {
                            var c = root.cards[root.currentIndex + index];
                            return c && c.body !== undefined ? c.body : "";
                        }
                        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
                    }
                }
                // 顶部卡的拖拽
                MouseArea {
                    anchors.fill: parent
                    enabled: front
                    drag.target: front ? parent : null
                    drag.axis: Drag.XAxis
                    onPositionChanged: if (front) root.dragX = parent.x - (root.width - parent.width) / 2
                    onReleased: {
                        if (!front) return;
                        if (root.dragX > root._cardW * 0.28) root.decide("right");
                        else if (root.dragX < -root._cardW * 0.28) root.decide("left");
                        else root.dragX = 0;
                    }
                }
                // KeepStamp：向右拖时露出的印章
                Rectangle {
                    visible: front && root.dragX > 12
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: root.th.t4(root.th.ct("CardStack", "StampMargin"), 0)
                    width: _ks.implicitWidth + root.th.t4(root.th.ct("CardStack", "StampPadding"), 0) * 2
                    height: root._stampH
                    radius: height / 2
                    rotation: -8
                    color: root.th ? root.th.ct("CardStack", "KeepStampFill") : "#FFEBF3EB"
                    border.width: 1
                    border.color: root.th ? root.th.ct("CardStack", "KeepStampBorder") : "#FFA9C5AA"
                    Text {
                        id: _ks
                        anchors.centerIn: parent
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: root.rightLabel
                        color: root.th ? root.th.c("Success") : "#FF007824"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                        font.weight: root.th ? root.th.weightMedium : 500
                    }
                }
            }
        }
        // 空态
        Text {
            visible: root.currentIndex >= root.cards.length
            anchors.centerIn: parent
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: "All done"
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        }
    }
    // 控制：左/右
    Row {
        y: _stage.height + root._rootGap
        width: parent.width
        spacing: root._controlsGap
        anchors.horizontalCenter: parent.horizontalCenter
        Item { width: (parent.width - 2 * 96 - parent.spacing) / 2; height: 1 }
        Arc.ArcButton { th: root.th; text: root.leftLabel; variant: "secondary"; size: "sm"; onClicked: root.decide("left") }
        Arc.ArcButton { th: root.th; text: root.rightLabel; variant: "primary"; size: "sm"; onClicked: root.decide("right") }
        Item { width: (parent.width - 2 * 96 - parent.spacing) / 2; height: 1 }
    }
}
