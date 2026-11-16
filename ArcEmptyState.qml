// arc:EmptyState —— Cards/EmptyState 真源码移植：EmptyStateToken.cs + EmptyStateTheme.axaml。
// 居中图标块（48/32）+ 标题 + 描述（maxWidth 288）+ 可选动作按钮。small=true 走 compact 令牌。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string icon: "Inbox"
    property string title: ""
    property string description: ""
    property string actionText: ""
    property bool small: false
    signal actionClicked()

    readonly property real _iconD: small ? th.ct("EmptyState", "IconBlockSizeSmall") : th.ct("EmptyState", "IconBlockSize")
    readonly property real _pad: small ? th.ct("EmptyState", "BlockPaddingSmall") : th.ct("EmptyState", "InlinePadding")
    readonly property real _titleTop: th.t4(small ? th.ct("EmptyState", "TitleMarginSmall") : th.ct("EmptyState", "TitleMargin"), 1)
    readonly property real _descTop: th.t4(th.ct("EmptyState", "DescriptionMargin"), 1)
    readonly property real _actionTop: th.t4(small ? th.ct("EmptyState", "ActionMarginSmall") : th.ct("EmptyState", "ActionMargin"), 1)
    readonly property real _descMax: th.ct("EmptyState", "DescriptionMaxWidth")
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _iconR: th.t4(th.design(small ? "RadiusControl" : "RadiusPanel"), 0)

    width: implicitWidth; height: implicitHeight
    implicitWidth: 360
    implicitHeight: _col.implicitHeight + 2 * _pad

    Column {
        id: _col
        anchors.horizontalCenter: parent.horizontalCenter
        y: root._pad
        width: root.width - 2 * root._pad
        spacing: 0

        // PART_IconBlock（SurfaceMuted 底 + Border + RadiusPanel/Control）
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root._iconD; height: root._iconD
            radius: root._iconR
            color: root.th.c("SurfaceMuted")
            border.width: root._edge
            border.color: root.th.c("Border")
            Arc.ArcIcon {
                anchors.centerIn: parent
                width: root._iconD * 0.5; height: root._iconD * 0.5
                th: root.th
                kind: root.icon
                color: root.th.c("TextSecondary")
            }
        }

        // PART_Title
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            width: parent.width
            topPadding: root._titleTop
            horizontalAlignment: Text.AlignHCenter
            text: root.title
            color: root.th.c("Foreground")
            font.pixelSize: root.th.design(small ? "TypeSM" : "TypeBase")
            font.weight: root.th.design("WeightMedium")
            lineHeight: root.th.ct("EmptyState", "TitleLineHeight")
            lineHeightMode: Text.FixedHeight
            wrapMode: Text.WordWrap
        }

        // PART_Description（maxWidth 288 居中）
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width, root._descMax)
            topPadding: root._descTop
            horizontalAlignment: Text.AlignHCenter
            visible: root.description !== ""
            text: root.description
            color: root.th.c("TextSecondary")
            font.pixelSize: root.th.design("TypeSM")
            lineHeight: root.th.ct("EmptyState", "DescriptionLineHeight")
            lineHeightMode: Text.FixedHeight
            wrapMode: Text.WordWrap
        }

        // PART_Action：ArcButton 是 Item，无 topPadding；用占位 Item 承载上距（历史坑）
        Item {
            visible: root.actionText !== ""
            width: parent.width
            height: _btn.implicitHeight + root._actionTop
            Arc.ArcButton {
                id: _btn
                y: root._actionTop
                anchors.horizontalCenter: parent.horizontalCenter
                th: root.th
                text: root.actionText
                variant: "secondary"
                size: "sm"
                onClicked: root.actionClicked()
            }
        }
    }
}
