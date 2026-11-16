// SettingsPage.axaml 的 QML 移植：左侧 248 分区导航 + 右侧表单。
// 三节：General（工作区名）/ Appearance（System-Light-Dark + 8 强调色）/ Notifications（两个开关）。
import QtQuick 2.15
import "." as Arc
import "SampleData.js" as Sample

Row {
    id: root

    property var th: null
    property var strings: ({})   // issue 9：宿主文案桥
    property var hostApp: null        // 根壳，用于改外观；勿叫 app（会遮蔽 ArcAdminApp 的 id: app）
    property int section: 0

    readonly property var sections: [
        { title: qsTr("General"), icon: "Settings" },
        { title: qsTr("Appearance"), icon: "Sun" },
        { title: qsTr("Notifications"), icon: "Bell" }
    ]

    Item { width: 28; height: 1 }
    Item {
        width: root.th.n("settingsPage","NavWidth") - 24
        height: root.height

        Column {
            x: 0
            y: 24
            width: parent.width
            spacing: 4

            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                x: 12
                text: qsTr("Settings")
                color: root.th.c("Foreground")
                font.pixelSize: root.th.design("Type2XL")
                font.weight: root.th.design("WeightMedium")
            }
            Item { width: 1; height: 12 }

            Repeater {
                model: root.sections
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    readonly property bool _on: root.section === index
                    width: parent.width
                    height: 36
                    radius: 10
                    color: _on ? root.th.sidebar("RowSelectedFill") : (_hm.containsMouse ? root.th.sidebar("RowHoverFill") : "transparent")

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 12
                        spacing: 10
                        Arc.ArcIcon {
                            th: root.th
                            kind: modelData.icon
                            width: 16; height: 16
                            color: parent.parent._on ? root.th.c("Foreground") : root.th.c("TextSecondary")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                            text: modelData.title
                            color: parent.parent._on ? root.th.c("Foreground") : root.th.c("TextSecondary")
                            font.pixelSize: root.th.design("TypeSM")
                            font.weight: parent.parent._on ? root.th.design("WeightMedium") : root.th.design("WeightRegular")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea { id: _hm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.section = index }
                }
            }
        }
    }

    // 右侧内容区（ContentInset 36,30,36,36）
    Flickable {
        width: root.width - root.th.n("settingsPage","NavWidth")
        height: root.height
        contentWidth: width
        contentHeight: _body.implicitHeight + 30 + 36
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: _body
            x: root.th.t4(root.th.n("settingsPage","ContentInset"), 0)
            y: root.th.t4(root.th.n("settingsPage","ContentInset"), 1)
            width: parent.width - 2 * root.th.t4(root.th.n("settingsPage","ContentInset"), 0)
            spacing: 28

            // ── General ──
            Column {
                visible: root.section === 0
                width: parent.width
                spacing: 12
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: qsTr("General"); color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeLG"); font.weight: root.th.design("WeightMedium") }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: qsTr("The workspace's name."); color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
                Rectangle {
                    width: Math.min(420, parent.width)
                    height: 40
                    radius: root.th.t4(root.th.design("RadiusControl"), 0)
                    color: root.th.c("Surface")
                    border.width: root.th.design("EdgeThickness")
                    border.color: _wsk.hasActiveFocus ? root.th.a("accent") : root.th.c("Border")
                    TextInput { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        id: _wsk
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        text: root.hostApp && root.hostApp.workspaceData ? (root.hostApp.workspaceData.name || "") : ""
                        color: root.th.c("Foreground")
                        font.pixelSize: root.th.design("TypeSM")
                        selectByMouse: true
                    }
                }
            }

            // ── Appearance ──
            Column {
                visible: root.section === 1
                width: parent.width
                spacing: 14
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: qsTr("Appearance"); color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeLG"); font.weight: root.th.design("WeightMedium") }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: qsTr("Saved on this computer."); color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }

                Arc.ArcSegmented {
                    th: root.th
                    options: [ { value: "Light", label: qsTr("Light") }, { value: "Dark", label: qsTr("Dark") } ]
                    value: root.th && root.th.dark ? "Dark" : "Light"
                    onActivated: function (v) { if (root.hostApp) root.hostApp.setDark(v === "Dark"); }
                }

                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: qsTr("Accent"); color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM") }
                Flow {
                    width: parent.width
                    spacing: 8
                    Repeater {
                        model: Sample.ACCENTS
                        delegate: Rectangle {
                            required property string modelData
                            required property int index
                            readonly property bool _on: index === root.th.accentIndex
                            width: 34; height: 34; radius: 17
                            color: root.th.data.accents[index][root.th.dark ? "dark" : "light"].accent
                            border.width: _on ? 2 : 0
                            border.color: root.th.c("Foreground")
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (root.hostApp) root.hostApp.setAccent(index) }
                        }
                    }
                }
            }

            // ── Notifications ──
            Column {
                visible: root.section === 2
                width: parent.width
                spacing: 14
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: qsTr("Notifications"); color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeLG"); font.weight: root.th.design("WeightMedium") }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: qsTr("What the workspace emails you."); color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }

                Repeater {
                    model: [
                        { h: "Weekly digest", d: "New customers, churn and revenue, every Monday.", on: true },
                        { h: "Payment alerts", d: "When a customer's payment fails.", on: true }
                    ]
                    delegate: Item {
                        required property var modelData
                        width: parent.width
                        height: 56
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 0
                            width: parent.width - 70
                            spacing: 2
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.h; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.d; color: root.th.c("TextMuted"); font.pixelSize: 15; elide: Text.ElideRight; width: parent.width }
                        }
                        Arc.ArcSwitch {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            th: root.th
                            checked: modelData.on
                        }
                    }
                }
            }
        }
    }
}
