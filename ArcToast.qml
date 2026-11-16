// arc:Toast —— Messages/Toast 真源码移植：SurfaceColor 面 + 30px 状态圆盘（真源码 Check 字形
// M4 12.5l5 5L20 6.5，stroke 2.25）+ 标题/描述 + 32px 关闭。宽上限 416、RadiusPanel(26)。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string title: ""
    property string description: ""
    property string tone: "success"   // success | info | warning | danger
    property bool closable: true
    signal dismissed()

    readonly property real _padL: th.t4(th.ct("Toast", "SurfacePadding"), 0)
    readonly property real _padT: th.t4(th.ct("Toast", "SurfacePadding"), 1)
    readonly property real _padB: th.t4(th.ct("Toast", "SurfacePadding"), 3)
    readonly property real _iconD: th.ct("Toast", "IconDiameter")
    readonly property real _iconGap: th.t4(th.ct("Toast", "IconMargin"), 2)
    readonly property real _closeD: th.ct("Toast", "CloseDiameter")
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _r: th.t4(th.design("RadiusPanel"), 0)
    readonly property real _copyY: th.t4(th.ct("Toast", "CopyPadding"), 1)

    readonly property color _glyph: tone === "warning" ? th.c("Warning")
                                  : tone === "danger" ? th.c("Danger")
                                  : tone === "info" ? th.c("AccentStrong")
                                  : th.c("Success")
    readonly property color _fill: tone === "success" ? th.ct("Toast", "IconFill") : th.fade(root._glyph, 0.10)
    readonly property color _ring: tone === "success" ? th.ct("Toast", "IconRing") : th.fade(root._glyph, 0.24)

    // 宽度由 toastWidth 给出并在 MaxToastWidth(416) 内收敛。首版让 implicitWidth 依赖
    // _copy.implicitWidth、而 _copy.width 又依赖 root.width，形成循环 → 实测只剩 138px、
    // 文案被挤成竖条。断开循环：宽度不读任何子项尺寸。
    property real toastWidth: 360
    implicitWidth: Math.min(th.ct("Toast", "MaxToastWidth"), toastWidth)
    implicitHeight: Math.max(_iconD, _copy.implicitHeight + _copyY) + _padT + _padB
    width: implicitWidth; height: implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: root._r
        color: root.th.ct("Toast", "SurfaceColor")
        border.width: root._edge
        border.color: root.th.c("Border")
    }

    // PART_Icon + PART_Check（SVG data URI，真机已验证渲染路径）
    Rectangle {
        id: _icon
        x: root._padL; y: root._padT
        width: root._iconD; height: root._iconD
        radius: root._iconD / 2
        color: root._fill
        border.width: root._edge
        border.color: root._ring
        Image {
            anchors.centerIn: parent
            width: root.th.ct("Toast", "CheckSize"); height: root.th.ct("Toast", "CheckSize")
            sourceSize.width: 32; sourceSize.height: 32
            source: "data:image/svg+xml;utf8," + encodeURIComponent(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="' +
                root._glyph + '" stroke-width="2.25" stroke-linecap="round" stroke-linejoin="round">' +
                '<path d="M4 12.5l5 5L20 6.5"/></svg>')
        }
    }

    // PART_Title + PART_Description
    Column {
        id: _copy
        x: _icon.x + _icon.width + root._iconGap
        y: root._padT + root._copyY
        width: Math.max(40, root.width - x - (root.closable ? root._closeD + 8 : root._padL))
        spacing: 2
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            width: parent.width
            text: root.title
            color: root.th.c("Foreground")
            font.pixelSize: root.th.design("TypeSM")
            font.weight: root.th.design("WeightMedium")
            lineHeight: root.th.ct("Toast", "CopyLineHeight") / root.th.design("TypeSM")
            lineHeightMode: Text.FixedHeight
            elide: Text.ElideRight
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.description !== ""
            width: parent.width
            text: root.description
            color: root.th.c("TextSecondary")
            font.pixelSize: root.th.design("TypeSM")
            wrapMode: Text.WordWrap
        }
    }

    // PART_Close
    Arc.ArcIcon {
        visible: root.closable
        anchors.right: parent.right; anchors.rightMargin: 8
        anchors.top: parent.top; anchors.topMargin: 4
        th: root.th; kind: "X"; color: root.th.c("TextMuted")
        width: 15; height: 15
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.dismissed()
        }
    }
}

