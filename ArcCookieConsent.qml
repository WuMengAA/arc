// arc:CookieConsent —— Messages/CookieConsent 真源码移植（CookieConsent.cs 835 行 + CookieConsentToken.cs +
// CookieConsentSurface/CookieConsentTypes）。
// 同意横幅：底部条（BarPadding[18,10,10,10]）或居中面板（PanelPadding[18,18,18,18] / PanelGap12）；
// 图标 ChipDiameter44，关闭按钮 CloseDiameter32；动作按钮 ActionGap6；标题 TitleLineHeight22.4。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string title: "We use cookies"
    property string message: ""
    property var actions: []          // [{label, primary?}]
    property bool isPanel: false
    property bool closable: true
    signal actionTriggered(int index)
    signal dismissed()

    readonly property real _chip: root.th.ct("CookieConsent", "ChipDiameter")
    readonly property real _close: root.th.ct("CookieConsent", "CloseDiameter")
    readonly property real _actionGap: root.th.ct("CookieConsent", "ActionGap")
    readonly property real _panelGap: root.th.ct("CookieConsent", "PanelGap")
    readonly property real _titleLH: root.th.ct("CookieConsent", "TitleLineHeight")
    readonly property var _barPad: root.th.ct("CookieConsent", "BarPadding")
    readonly property var _panelPad: root.th.ct("CookieConsent", "PanelPadding")
    implicitWidth: root.isPanel ? 420 : 640
    implicitHeight: _row.implicitHeight + (root.isPanel ? 2 * root.th.t4(root._panelPad, 1)
                                                        : root.th.t4(root._barPad, 1) + root.th.t4(root._barPad, 3))

    Rectangle {
        anchors.fill: parent
        radius: root.isPanel ? 20 : 0
        color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
        border.width: root.isPanel ? 1 : 0
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
    }
    Row {
        id: _row
        x: root.isPanel ? root.th.t4(root._panelPad, 0) : root.th.t4(root._barPad, 0)
        y: root.isPanel ? root.th.t4(root._panelPad, 1) : root.th.t4(root._barPad, 1)
        width: parent.width - 2 * x
        spacing: root.isPanel ? root._panelGap : 14
        // 图标
        Rectangle {
            width: root._chip; height: root._chip
            radius: width / 2
            color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
            Arc.ArcIcon {
                anchors.centerIn: parent
                width: 22; height: 22
                th: root.th; kind: "Cookie"
                color: root.th ? root.th.a("accent") : "#FF2FB8C6"
            }
        }
        // 文案
        Column {
            width: parent.width - root._chip - (root.closable ? root._close : 0) - _actions.width - 3 * 14
            spacing: 4
            Text {
                width: parent.width
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root.title
                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                font.pixelSize: root.th ? root.th.design("TypeSM") : 13
                font.weight: root.th ? root.th.weightMedium : 500
                lineHeight: root._titleLH
                lineHeightMode: Text.FixedHeight
            }
            Text {
                width: parent.width
                visible: root.message !== ""
                wrapMode: Text.WordWrap
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root.message
                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
        }
        // 动作
        Row {
            id: _actions
            anchors.verticalCenter: parent.verticalCenter
            spacing: root._actionGap
            Repeater {
                model: root.actions.length
                delegate: Rectangle {
                    required property int index
                    width: _at.implicitWidth + 24
                    height: 34
                    radius: 17
                    color: root.actions[index].primary
                           ? (root.th ? root.th.a("accent") : "#FF2FB8C6")
                           : (_am.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent")
                    border.width: root.actions[index].primary ? 0 : 1
                    border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
                    Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                    Text {
                        id: _at
                        anchors.centerIn: parent
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: root.actions[index].label || ""
                        color: root.actions[index].primary
                               ? (root.th ? root.th.a("foreground") : "#FFFFFFFF")
                               : (root.th ? root.th.c("Foreground") : "#FF1D1D1D")
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                        font.weight: root.th ? root.th.weightMedium : 500
                    }
                    MouseArea {
                        id: _am
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.actionTriggered(index)
                    }
                }
            }
        }
        // 关闭
        Rectangle {
            visible: root.closable
            width: root._close; height: root._close
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            color: _cm4.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
            Arc.ArcIcon {
                anchors.centerIn: parent
                width: 14; height: 14
                th: root.th; kind: "X"
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            }
            MouseArea { id: _cm4; anchors.fill: parent; hoverEnabled: true; onClicked: root.dismissed() }
        }
    }
}
