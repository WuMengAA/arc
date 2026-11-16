// arc:Badge —— Avatars/Badge 真源码移植（BadgeToken.cs 24 键 + BadgeTheme.axaml 四类 tone）。
// 高 MD26/SM22，RadiusPill；success/info(accent)/warning/danger/neutral 五 tone。
// issue 2/7：所有 th.ct("Badge", ...) 的键都是字面量，绝不用 _toneKey + 后缀动态拼接，
// 否则 neutral/info/accent 会查到 ControlTokens.js 不存在的 10 个键（Arc control token missing）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string text: ""
    property string tone: "neutral"   // neutral | success | info | warning | danger | accent
    property bool small: false
    property string icon: ""

    readonly property real _h: small ? th.ct("Badge", "PillHeightSM") : th.ct("Badge", "PillHeightMD")
    readonly property real _px: th.t4(th.ct("Badge", small ? "InlinePaddingSM" : "InlinePaddingMD"), 0)
    readonly property real _gap: th.ct("Badge", small ? "ContentGapSM" : "ContentGapMD")
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property bool _neutral: tone === "neutral" || tone === "accent" || tone === "info"
    readonly property bool _hover: ma.containsMouse && !small

    // 静态键表：success/warning/danger 各有 4 个真实键；未知 tone 兜到 Danger*（不会拼出缺失键）。
    readonly property color _bg: root._neutral
        ? (root.tone === "neutral"
            ? (ma.containsMouse ? th.ct("Badge", "NeutralHoverBackground") : th.c("SurfaceMuted"))
            : th.a("subtle"))
        : (root._hover
            ? (root.tone === "success" ? th.ct("Badge", "SuccessHoverBackground")
               : root.tone === "warning" ? th.ct("Badge", "WarningHoverBackground")
               : th.ct("Badge", "DangerHoverBackground"))
            : (root.tone === "success" ? th.ct("Badge", "SuccessBackground")
               : root.tone === "warning" ? th.ct("Badge", "WarningBackground")
               : th.ct("Badge", "DangerBackground")))
    readonly property color _bd: root._neutral
        ? (root.tone === "neutral"
            ? (ma.containsMouse ? th.ct("Badge", "NeutralHoverBorder") : th.c("Border"))
            : th.fade(th.a("accent"), th.ct("Badge", "InfoRingOpacity")))
        : (root._hover
            ? (root.tone === "success" ? th.ct("Badge", "SuccessHoverBorder")
               : root.tone === "warning" ? th.ct("Badge", "WarningHoverBorder")
               : th.ct("Badge", "DangerHoverBorder"))
            : (root.tone === "success" ? th.ct("Badge", "SuccessBorder")
               : root.tone === "warning" ? th.ct("Badge", "WarningBorder")
               : th.ct("Badge", "DangerBorder")))
    readonly property color _fg: tone === "success" ? th.c("Success")
                                : tone === "warning" ? th.c("Warning")
                                : tone === "danger" ? th.c("Danger")
                                : (tone === "accent" || tone === "info") ? th.c("AccentStrong")
                                : th.c("TextSecondary")

    implicitWidth: _row.implicitWidth + 2 * _px
    implicitHeight: _h
    width: implicitWidth; height: implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: parent.height / 2
        color: root._bg
        border.width: root._edge
        border.color: root._bd
        Behavior on color { ColorAnimation { duration: th.dur("Instant") } }

        Row {
            id: _row
            anchors.centerIn: parent
            spacing: root._gap
            Arc.ArcIcon {
                visible: root.icon !== ""
                anchors.verticalCenter: parent.verticalCenter
                th: root.th; kind: root.icon; color: root._fg
                width: 12; height: 12
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                anchors.verticalCenter: parent.verticalCenter
                text: root.text
                color: root._fg
                font.pixelSize: root.small ? root.th.ct("Badge", "LabelFontSizeSM") : root.th.design("TypeXS")
                font.weight: root.th.design("WeightMedium")
                Accessible.role: Accessible.StaticText; Accessible.name: root.text
            }
        }
        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true }
    }
}
