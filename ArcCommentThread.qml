// arc:CommentThread —— Activity/CommentThread 真源码移植（CommentThread.cs + CommentThreadToken.cs）。
// 结构：已解决态绿条（ResolvedRadius22）或评论列表（CommentThreadItem）+ 底部 composer（FieldRadius14）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var comments: []
    property bool isResolved: false
    property string title: "Comments"
    property string placeholder: "Write a comment"
    property int maxDepth: 3
    property int depth: 0
    readonly property real _cPad: root.th.pad(root.th.ct("CommentThread", "CommentPadding"))
    readonly property real _cGap: root.th.ct("CommentThread", "CommentGap")
    readonly property real _resolvedRadius: root.th.pad(root.th.ct("CommentThread", "ResolvedRadius"))
    signal resolved()
    signal replyRequested(string id)

    implicitWidth: 380
    implicitHeight: root.isResolved ? _resolved.height : _col.implicitHeight

    Rectangle {
        id: _resolved
        visible: root.isResolved
        width: parent.width
        height: _rt.implicitHeight + 2 * root._cPad
        radius: root._resolvedRadius
        color: root.th ? root.th.ct("CommentThread", "ResolvedIconBackground") : "#24007824"
        Row {
            anchors.verticalCenter: parent.verticalCenter
            x: root._cPad
            spacing: 8
            Arc.ArcIcon {
                width: 16; height: 16
                th: root.th; kind: "Check"
                color: root.th ? root.th.c("Success") : "#FF007824"
            }
            Text {
                id: _rt
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: "Resolved"
                color: root.th ? root.th.c("Success") : "#FF007824"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                font.weight: root.th ? root.th.weightMedium : 500
            }
        }
    }
    Column {
        id: _col
        visible: !root.isResolved
        width: parent.width
        spacing: root._cGap
        Repeater {
            model: root.isResolved ? 0 : root.comments.length
            delegate: Arc.ArcCommentThreadItem {
                required property int index
                width: _col.width
                th: root.th
                comment: root.comments[index]
                index: index
                depth: root.depth
                onReplyRequested: function (id) { root.replyRequested(id); }
                onResolved: root.resolved()
            }
        }
        Rectangle {
            width: parent.width
            height: _ci2.implicitHeight + 2 * root._cPad
            radius: root.th.pad(root.th.ct("CommentThread", "FieldRadius"))
            color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
            border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
            border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
            TextEdit {
                id: _ci2
                anchors.fill: parent
                anchors.margins: root._cPad
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                wrapMode: TextEdit.Wrap
            }
            Text {
                visible: _ci2.text === ""
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: root._cPad
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                text: root.placeholder
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            }
        }
    }
}
