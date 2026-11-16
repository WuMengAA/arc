// TeamPage.axaml 的 QML 移植：Tabs(Members / Roles)，最大宽度 960，间距 16。
import QtQuick 2.15
import "." as Arc

Flickable {
    id: root

    property var th: null
    property var strings: ({})   // issue 9：宿主文案桥
    property var ws: null             // SampleData.workspace()
    property int tab: 0

    contentWidth: width
    contentHeight: _col.implicitHeight + 52
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: _col
        x: 28
        y: 24
        width: Math.min(root.width - 56, 960)
        spacing: 16

        Arc.ArcPageHeader {
            th: root.th
            title: qsTr("Team")
            subtitle: qsTr("Who can work in the workspace, and what each role may do.")
        }

        // Tabs
        Rectangle {
            width: _tabRow.implicitWidth + 8
            height: 38
            radius: root.th.pad(root.th.n("tabs","PillRadius"))
            color: root.th.c("SurfaceMuted")

            Row {
                id: _tabRow
                anchors.centerIn: parent
                spacing: 2
                Repeater {
                    model: ["Members", "Roles"]
                    delegate: Rectangle {
                        required property string modelData
                        required property int index
                        readonly property bool _on: root.tab === index
                        width: _tl.implicitWidth + 28
                        height: 32
                        radius: root.th.pad(root.th.n("tabs","PillRadius")) - 2
                        color: _on ? root.th.c("Surface") : "transparent"
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                            id: _tl
                            anchors.centerIn: parent
                            text: parent.modelData
                            color: parent._on ? root.th.c("Foreground") : root.th.c("TextSecondary")
                            font.pixelSize: root.th.design("TypeSM")
                            font.weight: parent._on ? root.th.design("WeightMedium") : root.th.design("WeightRegular")
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.tab = index }
                    }
                }
            }
        }

        // ── Members 面板 ──
        Arc.ArcCard {
            visible: root.tab === 0
            width: parent.width
            th: root.th
            title: (root.ws ? root.ws.name : "") + " · " + (root.ws && root.ws.members ? root.ws.members.length : 0) + " of " + (root.ws ? root.ws.seatLimit : 0) + " seats"
            description: qsTr("Everyone who can sign in to this workspace.")

            Column {
                width: parent.width - 2 * root.th.pad(root.th.n("card","ContentPadding"))
                x: root.th.pad(root.th.n("card","ContentPadding"))
                spacing: 0

                Repeater {
                    model: root.ws ? root.ws.members : []
                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: _col.width
                        height: 56
                        Arc.ArcAvatar {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 0
                            th: root.th
                            name: modelData.name
                            size: "md"
                            seed: index
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 48
                            spacing: 2
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.name; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.email; color: root.th.c("TextMuted"); font.pixelSize: 15 }
                        }
                        Arc.ArcBadge {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            th: root.th
                            small: true
                            text: modelData.role
                            tone: modelData.role === "Owner" ? "accent" : (modelData.role === "Admin" ? "success" : "neutral")
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 1
                            color: index < (root.ws ? root.ws.members.length - 1 : 0) ? root.th.c("BorderSubtle") : "transparent"
                        }
                    }
                }
            }
        }

        // ── Roles 面板 ──
        Arc.ArcCard {
            visible: root.tab === 1
            width: parent.width
            th: root.th
            title: qsTr("Roles")
            description: qsTr("What each role may do in this workspace.")

            Column {
                width: _col.width - 2 * root.th.pad(root.th.n("card","ContentPadding"))
                x: root.th.pad(root.th.n("card","ContentPadding"))
                spacing: 0

                Repeater {
                    model: root.ws && root.ws.roles ? root.ws.roles : []
                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: parent.width
                        height: 60
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 0
                            width: parent.width - 90
                            spacing: 2
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.name; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.description; color: root.th.c("TextMuted"); font.pixelSize: 15; elide: Text.ElideRight; width: parent.width }
                        }
                        Arc.ArcBadge {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            th: root.th
                            small: true
                            text: modelData.members + (modelData.members === 1 ? " member" : " members")
                            tone: "neutral"
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 1
                            color: index < (root.ws ? root.ws.roles.length - 1 : 0) ? root.th.c("BorderSubtle") : "transparent"
                        }
                    }
                }
            }
        }
    }
}
