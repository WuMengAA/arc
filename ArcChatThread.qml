// arc:ChatThread —— Activity/ChatThread 真源码移植（ChatThread.cs 2013 行 + ChatThreadToken.cs + ChatComposer/
// ChatThreadLayout/Parts/Picker/Rows/Types/Views）。
// 聊天流：气泡（BubbleRadius18 / 紧邻 6 / BubblePadding[13,8,13,9] / BubbleFill），左右按 CurrentUserId 分；
// 分组（GroupMargin[0,14,0,0]）+ 日期分隔（DayPadding[4,20,4,4]）；气泡列最大宽 StackMaxRatio0.78（窄 0.84 / 上限 544）；
// 底部 composer（PillHeight32 / PillPadding[11,0,14,0]）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var messages: []          // [{id, userId, name, text, time, mine?}]
    property string currentUserId: ""
    property string placeholder: "Message"
    property bool isComposerVisible: true
    property string label: ""

    readonly property real _bubRad: root.th.ct("ChatThread", "BubbleRadius")
    readonly property real _tightRad: root.th.ct("ChatThread", "BubbleTightRadius")
    readonly property real _padL: root.th.t4(root.th.ct("ChatThread", "BubblePadding"), 0)
    readonly property real _padT: root.th.t4(root.th.ct("ChatThread", "BubblePadding"), 1)
    readonly property real _padR: root.th.t4(root.th.ct("ChatThread", "BubblePadding"), 2)
    readonly property real _padB: root.th.t4(root.th.ct("ChatThread", "BubblePadding"), 3)
    readonly property real _lineH: root.th.ct("ChatThread", "BubbleLineHeight")
    readonly property real _groupM: root.th.t4(root.th.ct("ChatThread", "GroupMargin"), 1)
    readonly property real _rowGap: root.th.ct("ChatThread", "RowGap")
    readonly property real _dayPad: root.th.pad(root.th.ct("ChatThread", "DayPadding"))
    readonly property real _stackMax: root.th.ct("ChatThread", "StackMaxRatio")
    readonly property real _stackMaxW: root.th.ct("ChatThread", "StackMaxWidth")
    readonly property real _pillH: root.th.ct("ChatThread", "PillHeight")
    readonly property real _gutter: root.th.ct("ChatThread", "GutterWidth")
    readonly property real _bubbleFill: root.th ? root.th.ct("ChatThread", "BubbleFill") : "#FFF8F8F8"
    property var draft: ""
    signal sendRequested(string text)

    implicitWidth: 380
    implicitHeight: _list.height + (root.isComposerVisible ? root._pillH + 24 : 0)

    ListView {
        id: _list
        width: parent.width
        height: root.height - (root.isComposerVisible ? root._pillH + 24 : 0)
        clip: true
        model: root.messages
        spacing: root._rowGap
        delegate: Item {
            required property int index
            required property var modelData
            readonly property bool mine: modelData.mine === true
                    || (root.currentUserId !== "" && String(modelData.userId) === String(root.currentUserId))
            // 与上一条是否同一人（决定紧邻圆角）
            readonly property bool sameAsPrev: index > 0 && root.messages[index - 1].userId === modelData.userId
            width: _list.width
            // 气泡宽：按文本估宽，上限 = 列表宽 × StackMaxRatio（且不超过 StackMaxWidth）
            readonly property real maxBubW: Math.min(root._stackMaxW, width * root._stackMax)
            height: _bub.height + (sameAsPrev ? 2 : root._groupM) + 4
            // 名字（仅分组第一条）
            Text {
                visible: !parent.sameAsPrev && !parent.mine
                x: root._gutter + 4
                y: 2
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: parent.modelData.name || ""
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                font.weight: root.th ? root.th.weightMedium : 500
            }
            Rectangle {
                id: _bub
                y: (parent.sameAsPrev ? 2 : root._groupM) + (parent.sameAsPrev || parent.mine ? 0 : 16)
                width: Math.min(parent.maxBubW, _txt.implicitWidth + root._padL + root._padR)
                height: _txt.implicitHeight + root._padT + root._padB
                radius: root._bubRad
                color: parent.mine ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : root._bubbleFill
                // 同人紧邻时收窄朝上的一角
                Rectangle {
                    visible: parent.parent.sameAsPrev
                    width: height
                    height: root._tightRad
                    x: parent.parent.mine ? parent.width - width : 0
                    y: 0
                    color: parent.color
                }
                x: parent.mine ? parent.width - width - 8 : root._gutter + 8
                Text {
                    id: _txt
                    x: root._padL
                    y: root._padT
                    width: Math.min(_list.width * root._stackMax - root._padL - root._padR, implicitWidth)
                    text: parent.parent.modelData.text || ""
                    wrapMode: Text.WordWrap
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    font.pixelSize: root.th ? root.th.design("TypeSM") : 13
                    color: parent.parent.mine ? (root.th ? root.th.a("foreground") : "#FFFFFFFF")
                                              : (root.th ? root.th.c("Foreground") : "#FF1D1D1D")
                    lineHeight: root._lineH
                    lineHeightMode: Text.FixedHeight
                }
            }
            // 时间（每条右侧/左侧小字）
            Text {
                y: _bub.y + _bub.height + 2
                x: parent.mine ? parent.width - width - 10 : root._gutter + 10
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: parent.modelData.time || ""
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
        }
    }
    // Composer
    Rectangle {
        visible: root.isComposerVisible
        y: _list.height + 12
        width: parent.width
        height: root._pillH
        radius: height / 2
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: _ci.activeFocus ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        TextInput {
            id: _ci
            anchors.fill: parent
            anchors.leftMargin: root.th.t4(root.th.ct("ChatThread", "PillPadding"), 0)
            anchors.rightMargin: 40
            verticalAlignment: TextInput.AlignVCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            font.pixelSize: root.th ? root.th.design("TypeSM") : 13
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            text: root.draft
            selectByMouse: true
            onTextChanged: root.draft = text
            onAccepted: { if (text !== "") { root.sendRequested(text); text = ""; root.draft = ""; } }
        }
        Text {
            visible: _ci.text === ""
            anchors.left: parent.left
            anchors.leftMargin: root.th.t4(root.th.ct("ChatThread", "PillPadding"), 0)
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            font.pixelSize: root.th ? root.th.design("TypeSM") : 13
            text: root.placeholder
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        }
        // 发送
        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            width: 28; height: 28
            radius: 14
            color: root.draft !== "" ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : "transparent"
            Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
            Arc.ArcIcon {
                anchors.centerIn: parent
                width: 15; height: 15
                th: root.th; kind: "Send"
                color: root.draft !== "" ? (root.th ? root.th.a("foreground") : "#FFFFFFFF")
                                         : (root.th ? root.th.c("TextMuted") : "#FF9A9A9A")
            }
            MouseArea {
                anchors.fill: parent
                onClicked: if (_ci.text !== "") { root.sendRequested(_ci.text); _ci.text = ""; root.draft = ""; }
            }
        }
    }
}
