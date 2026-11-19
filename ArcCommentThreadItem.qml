// arc:CommentThreadItem —— Activity/CommentThread/CommentThreadItem.cs 真源码移植。
// 单条评论：头像 28 + 名称/时间 + 正文 + 操作行（Reply / Resolve）+ 缩进回复（ReplyIndent[24,0,0,0]）。
import QtQuick 2.15
import "." as Arc

Column {
    id: root
    property var th: null
    property var comment: null
    property int index: 0
    property int depth: 0
    readonly property real _avatar: root.th.ct("CommentThread", "AvatarDiameter")
    readonly property real _cGap: root.th.ct("CommentThread", "CommentGap")
    readonly property real _headerGap: root.th.ct("CommentThread", "HeaderGap")
    readonly property real _bodyLH: root.th.ct("CommentThread", "BodyLineHeight")
    readonly property real _replyIndent: root.th.t4(root.th.ct("CommentThread", "ReplyIndent"), 0)
    readonly property real _actionH: root.th.ct("CommentThread", "ActionHeight")
    readonly property real _resolveH: root.th.ct("CommentThread", "ResolveHeight")
    spacing: root._cGap
    signal replyRequested(string id)
    signal resolved()

    Row {
        width: parent.width
        spacing: root._headerGap
        Arc.ArcAvatar {
            width: root._avatar; height: root._avatar
            th: root.th
            name: root.comment ? (root.comment.name || "") : ""
            seed: root.index
            size: "sm"
            monochrome: true
        }
        Column {
            width: parent.width - root._avatar - root._headerGap
            spacing: 2
            Row {
                spacing: 8
                Text {
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root.comment ? (root.comment.name || "") : ""
                    color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    font.weight: root.th ? root.th.weightMedium : 500
                }
                Text {
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root.comment ? (root.comment.time || "") : ""
                    color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
            }
            Text {
                width: parent.width
                text: root.comment ? (root.comment.text || "") : ""
                wrapMode: Text.WordWrap
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                lineHeight: root._bodyLH
                lineHeightMode: Text.FixedHeight
            }
            Row {
                spacing: 4
                Rectangle {
                    width: _rp.implicitWidth + 16; height: root._actionH
                    radius: height / 2
                    color: _rm3.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                    Text {
                        id: _rp
                        anchors.centerIn: parent
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: "Reply"
                        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    }
                    MouseArea {
                        id: _rm3
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.replyRequested(root.comment ? (root.comment.id || String(root.index)) : String(root.index))
                    }
                }
                Rectangle {
                    visible: root.depth === 0
                    width: _rs.implicitWidth + 20; height: root._resolveH
                    radius: height / 2
                    color: _sm4.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                    border.width: 1
                    border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
                    Text {
                        id: _rs
                        anchors.centerIn: parent
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: "Resolve"
                        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    }
                    MouseArea { id: _sm4; anchors.fill: parent; hoverEnabled: true; onClicked: root.resolved() }
                }
            }
        }
    }
    // 缩进回复
    Column {
        visible: root.comment && root.comment.replies !== undefined && root.comment.replies.length > 0
        x: root._replyIndent
        width: parent.width - root._replyIndent
        spacing: root._cGap
        Repeater {
            model: root.comment && root.comment.replies !== undefined ? root.comment.replies : []
            delegate: Row {
                required property var modelData
                width: parent.width
                spacing: root._headerGap
                Arc.ArcAvatar {
                    width: 22; height: 22
                    th: root.th
                    name: modelData.name || ""
                    seed: 0
                    size: "sm"
                    monochrome: true
                }
                Text {
                    width: parent.width - 22 - root._headerGap
                    text: modelData.text || ""
                    wrapMode: Text.WordWrap
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                }
            }
        }
    }
}
