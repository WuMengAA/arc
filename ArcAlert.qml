// arc:Alert —— Messages/Alert 真源码移植：AlertToken.cs + AlertTheme.axaml。
// Tone 决定图标与图标色（Info/Success/Warning/Danger），面统一 Surface 底 + RadiusControl。
// Alert.cs: Info→ArcIcons.Info / Success→ArcIcons.Check / Warning→TriangleAlert / Danger→MessagesIcons.CircleX。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string tone: "info"        // info | success | warning | danger
    property string title: ""
    property string description: ""
    property bool isOpen: true
    property bool dismissible: false
    signal dismissed()

    readonly property real _padL: th.t4(th.ct("Alert", "SurfacePadding"), 0)
    readonly property real _padT: th.t4(th.ct("Alert", "SurfacePadding"), 1)
    readonly property real _glyph: th.ct("Alert", "GlyphSize")
    readonly property real _glyphTop: th.t4(th.ct("Alert", "GlyphMargin"), 1)
    readonly property real _glyphGap: th.t4(th.ct("Alert", "GlyphMargin"), 2)
    readonly property real _descGap: th.ct("Alert", "DescriptionGap")
    readonly property real _dismissD: th.ct("Alert", "DismissDiameter")
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _r: th.t4(th.design("RadiusControl"), 0)

    readonly property string _icon: tone === "success" ? "Check"
        : tone === "warning" ? "TriangleAlert"
        : tone === "danger" ? "CircleX" : "Info"
    readonly property color _iconColor: tone === "success" ? th.c("Success")
        : tone === "warning" ? th.c("Warning")
        : tone === "danger" ? th.c("Danger") : th.c("Accent")

    visible: isOpen
    width: implicitWidth; height: implicitHeight
    implicitWidth: 360

    readonly property real _copyW: root.width - 2 * _padL - _glyph - _glyphGap
                                   - (dismissible ? _dismissD + 8 : 0)
    // 与 ArcCard 同形态：高度取 Column 的 implicitHeight（不用字符串长度估算行数，
    // 也不用 childrenRect —— 后者多层互推会触发 QML Column polish 死循环）。
    implicitHeight: Math.max(_glyph, _copy.implicitHeight) + 2 * _padT

    Rectangle {
        anchors.fill: parent
        radius: root._r
        color: root.th.c("Surface")
        border.width: root._edge
        border.color: root.th.c("Border")
    }

    // PART_Icon（GlyphMargin [0,1,12,0] 顶对齐标题首行）
    Arc.ArcIcon {
        x: root._padL; y: root._padT + root._glyphTop
        width: root._glyph; height: root._glyph
        th: root.th
        kind: root._icon
        color: root._iconColor
        strokeWidth: 2
    }

    // PART_Title + PART_Description
    Column {
        id: _copy
        x: root._padL + root._glyph + root._glyphGap
        y: root._padT
        width: root._copyW
        spacing: root._descGap
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.title !== ""
            width: parent.width
            text: root.title
            color: root.th.c("Foreground")
            font.pixelSize: root.th.design("TypeSM")
            font.weight: root.th.design("WeightMedium")
            lineHeight: root.th.ct("Alert", "TitleLineHeight")
            lineHeightMode: Text.FixedHeight
            wrapMode: Text.WordWrap
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.description !== ""
            width: parent.width
            text: root.description
            color: root.th.c("TextSecondary")
            font.pixelSize: root.th.design("TypeXS")
            lineHeight: root.th.ct("Alert", "DescriptionLineHeight")
            lineHeightMode: Text.FixedHeight
            wrapMode: Text.WordWrap
        }
    }

    // PART_Dismiss：28px 圆形 ghost 按钮
    Arc.ArcIcon {
        visible: root.dismissible
        anchors.right: parent.right; anchors.rightMargin: 6
        anchors.top: parent.top; anchors.topMargin: root._padT - 4
        width: 16; height: 16
        th: root.th
        kind: "X"
        color: root.th.c("TextMuted")
        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            onClicked: root.dismissed()
        }
    }
}
