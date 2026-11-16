// arc:Card —— CardTheme.axaml 真值：CornerRadius RadiusPanel(26)、1px Border、ContentPadding 20、
// 标题 TypeBase Medium 行高 23.4、描述上距 8、内容与标题间距 8、页脚上距 20。
// 高度用 height 绑定 Column（不用 childrenRect：多层 childrenRect 互推会触发 polish 死循环）。
import QtQuick 2.15

Rectangle {
    id: root

    property var th: null
    property string title: ""
    property string description: ""
    default property alias content: _body.data
    property alias footer: _footer.data
    property bool showFooter: false

    readonly property real _pad: th.pad(th.n("card","ContentPadding"))

    implicitHeight: _col.implicitHeight + 2 * _pad
    radius: th.t4(th.design("RadiusPanel"), 0)
    color: th.c("Surface")
    border.width: th.design("EdgeThickness")
    border.color: th.c("Border")

    Column {
        id: _col
        x: root._pad
        y: root._pad
        width: root.width - 2 * root._pad
        spacing: 8

        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.title !== ""
            width: parent.width
            text: root.title
            color: root.th.c("Foreground")
            font.pixelSize: root.th.design("TypeBase")
            font.weight: root.th.design("WeightMedium")
            lineHeight: root.th.n("card","TitleLineHeight") / root.th.design("TypeBase")
            lineHeightMode: Text.FixedHeight
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.description !== ""
            width: parent.width
            text: root.description
            color: root.th.c("TextSecondary")
            font.pixelSize: root.th.design("TypeSM")
            wrapMode: Text.WordWrap
        }

        Column {
            id: _body
            width: parent.width
            spacing: root.th.n("card","FooterGap")
        }

        Column {
            id: _footer
            visible: root.showFooter
            width: parent.width
            spacing: 8
            topPadding: root.th.t4(root.th.n("card","FooterMargin"), 1)
        }
    }
}
