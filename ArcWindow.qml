// arc:ArcWindow —— Content/ArcWindow 真源码移植（ArcWindow.cs + ArcWindowToken.cs + TitleBar/TitleBarPanel/
// WindowCaptionButtons/WindowCaptionButton/TitleBarCaptionToggleButton）。
// 自绘窗口外壳：圆角窗框 + 自绘标题栏（标题 + 标题栏右侧的窗口按钮：最小化/最大化/关闭）。
// 令牌 ArcWindow：MinWidth360 / MinHeight240；标题栏按钮 WindowCaptionButtons：ButtonSize30 / ButtonSpacing4 /
// GlyphSize15（最大化 13 / 还原 14）。
// 说明：QML 模块无 C++ 窗口 API，窗口控制通过 signal 交给宿主；本件只负责外观与命中。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string title: ""
    property bool isTitleBarVisible: true
    property bool isMaximized: false
    property bool showCaptionButtons: true
    property color titleBarColor: "transparent"
    default property alias content: _content.data
    signal minimizeRequested()
    signal maximizeRequested()
    signal closeRequested()
    signal titleBarDoubleClicked()

    readonly property real _minW: root.th.ct("ArcWindow", "MinWidth")
    readonly property real _minH: root.th.ct("ArcWindow", "MinHeight")
    readonly property real _btn: root.th.ct("WindowCaptionButtons", "ButtonSize")
    readonly property real _btnSp: root.th.ct("WindowCaptionButtons", "ButtonSpacing")
    readonly property real _glyph: root.th.ct("WindowCaptionButtons", "GlyphSize")
    readonly property real _glyphMax: root.th.ct("WindowCaptionButtons", "MaximizeGlyphSize")
    readonly property real _glyphRestore: root.th.ct("WindowCaptionButtons", "RestoreGlyphSize")
    readonly property real _titleBarH: 44
    implicitWidth: Math.max(root._minW, 640)
    implicitHeight: Math.max(root._minH, 420)

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        clip: true
    }
    // PART_TitleBar
    Item {
        id: _titleBar
        visible: root.isTitleBarVisible
        width: parent.width
        height: root._titleBarH
        Rectangle {
            anchors.fill: parent
            color: root.titleBarColor === "transparent" ? "transparent" : root.titleBarColor
        }
        Text {
            x: 14
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - x - (root.showCaptionButtons ? 3 * (root._btn + root._btnSp) + 8 : 14)
            elide: Text.ElideRight
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.title
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            font.pixelSize: root.th ? root.th.design("TypeSM") : 13
            font.weight: root.th ? root.th.weightMedium : 500
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onDoubleClicked: root.titleBarDoubleClicked()
        }
        // PART_CaptionButtons：最小化 / 最大化 / 关闭
        Row {
            visible: root.showCaptionButtons
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: root._btnSp
            Repeater {
                model: 3
                delegate: Rectangle {
                    required property int index
                    width: root._btn; height: root._btn
                    radius: 6
                    color: index === 2
                           ? (_c3.containsMouse ? (root.th ? root.th.c("Danger") : "#FFCD1526") : "transparent")
                           : (_cm5.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent")
                    Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                    Arc.ArcIcon {
                        anchors.centerIn: parent
                        width: index === 1 ? (root.isMaximized ? root._glyphRestore : root._glyphMax) : root._glyph
                        height: width
                        th: root.th
                        kind: index === 0 ? "Minus" : (index === 1 ? (root.isMaximized ? "Copy" : "Square") : "X")
                        color: index === 2 && _c3.containsMouse
                               ? (root.th ? root.th.a("foreground") : "#FFFFFFFF")
                               : (root.th ? root.th.c("TextSecondary") : "#FF6D6D6D")
                    }
                    MouseArea {
                        id: _cm5
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (index === 0) root.minimizeRequested();
                            else if (index === 1) { root.isMaximized = !root.isMaximized; root.maximizeRequested(); }
                            else root.closeRequested();
                        }
                    }
                    // 关闭按钮单独一个可 hover 的命中区
                    MouseArea {
                        id: _c3
                        anchors.fill: parent
                        hoverEnabled: true
                        visible: index === 2
                        onClicked: root.closeRequested()
                    }
                }
            }
        }
    }
    // 内容区
    Item {
        id: _content
        x: 0
        y: root.isTitleBarVisible ? root._titleBarH : 0
        width: parent.width
        height: parent.height - y
    }
}
