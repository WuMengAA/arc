// arc:Button —— ButtonTheme.axaml：高 36/44/50，内边距 12/16/20，圆角 RadiusControl，
// 变体 primary / secondary / ghost / text，hover 0.91 / pressed 0.84 / disabled 0.52。
import QtQuick 2.15

Item {
    id: root

    property var th: null
    property string text: ""
    property string icon: ""
    property string variant: "primary"   // primary | secondary | ghost | text
    property string size: "md"           // sm | md | lg
    property bool busy: false
    signal clicked()
    Accessible.role: Accessible.Button
    Accessible.name: root.busy ? qsTr("Working") : root.text
    Accessible.onPressAction: if (root.enabled && !root.busy) root.clicked()

    readonly property int _h: size === "sm" ? 36 : (size === "lg" ? 50 : 44)
    readonly property var _pad: size === "sm" ? th.pad(th.n("button","InlinePaddingSM"))
                            : (size === "lg" ? th.pad(th.n("button","InlinePaddingLG")) : th.pad(th.n("button","InlinePaddingMD")))
    readonly property bool _hover: ma.containsMouse && enabled
    readonly property bool _down: ma.pressed && enabled

    readonly property color _fg: !enabled ? th.c("TextMuted")
        : variant === "primary" ? th.c("Background")
        : variant === "ghost" ? (_hover ? th.c("Foreground") : th.c("TextSecondary"))
        : variant === "text" ? (_hover ? th.c("Foreground") : th.c("TextSecondary"))
        : th.c("Foreground")
    readonly property color _bg: !enabled ? (variant === "secondary" ? th.c("SurfaceMuted") : "transparent")
        : variant === "primary" ? th.c("Foreground")
        : variant === "secondary" ? (_hover ? th.c("SurfaceMuted") : th.c("Surface"))
        : variant === "ghost" ? (_hover ? th.c("SurfaceMuted") : "transparent")
        : "transparent"
    readonly property color _bd: !enabled ? th.c("Border")
        : variant === "primary" ? th.c("Foreground")
        : variant === "secondary" ? th.c("Border")
        : "transparent"

    implicitWidth: _row.implicitWidth + 2 * th.t4(_pad, 0) + 2
    implicitHeight: _h
    opacity: !enabled ? th.n("button","DisabledOpacity") : (_down ? th.n("button","PressedOpacity") : (_hover ? th.n("button","HoverOpacity") : 1))
    Behavior on opacity { NumberAnimation { duration: th.dur("Instant"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }

    Rectangle {
        anchors.fill: parent
        radius: th.t4(th.design("RadiusControl"), 0)
        color: root._bg
        border.width: th.design("EdgeThickness")
        border.color: root._bd
        Behavior on color { ColorAnimation { duration: th.dur("Instant") } }
        Behavior on border.color { ColorAnimation { duration: th.dur("Instant") } }
    }

    Row {
        id: _row
        anchors.centerIn: parent
        spacing: th.t4(th.n("button","LabelGap"), 0)

        ArcSpinner {
            visible: root.busy
            th: root.th
            spinnerSize: 16
            color: root._fg
            trackColor: "transparent"
            anchors.verticalCenter: parent.verticalCenter
        }
        ArcIcon {
            visible: root.icon !== "" && !root.busy
            th: root.th
            kind: root.icon
            color: root._fg
            width: 16; height: 16
            anchors.verticalCenter: parent.verticalCenter
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            anchors.verticalCenter: parent.verticalCenter
            text: root.busy ? "Working…" : root.text
            color: root._fg
            font.pixelSize: th.design("TypeSM")
            font.weight: th.design("WeightMedium")
            Behavior on color { ColorAnimation { duration: th.dur("Instant") } }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled && !root.busy
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
