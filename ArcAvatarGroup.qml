// arc:AvatarGroup —— Avatars/AvatarGroup 真源码移植（AvatarGroup.cs + AvatarGroupToken.cs + AvatarGroupTheme.axaml）。
// 头像叠放：每张后一张向左压 StackOverlap(6)，超出 Max 的收成 "+N" 圆片；组内可点选（selectedIndex）。
// 令牌：DiameterSM28 / MD36 / LG48 / StackOverlap6 / ChipFontSizeSM10 / NamePadding[8,4,8,4]。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var members: []        // [{name, status, seed}] 或字符串数组
    property int max: 4             // 最多露几张，超出收进 +N
    property string size: "md"      // sm | md | lg
    property int selectedIndex: -1
    property bool showNames: false
    signal memberActivated(int index)

    readonly property real _d: root.size === "sm" ? root.th.ct("AvatarGroup", "DiameterSM")
                            : root.size === "lg" ? root.th.ct("AvatarGroup", "DiameterLG")
                            : root.th.ct("AvatarGroup", "DiameterMD")
    readonly property real _overlap: root.th.ct("AvatarGroup", "StackOverlap")
    readonly property int _shown: Math.max(0, Math.min(root.max, root.members.length))
    readonly property int _extra: Math.max(0, root.members.length - root._shown)
    readonly property real _chipW: _extra > 0 ? root._d : 0
    readonly property string _sizeName: root.size === "sm" ? "sm" : (root.size === "lg" ? "lg" : "md")

    implicitWidth: Math.max(0, root._shown * (root._d - root._overlap) + root._overlap + root._chipW
                            + (root._extra > 0 ? -root._overlap : 0))
    implicitHeight: root._d

    Row {
        id: _row
        spacing: -root._overlap
        Repeater {
            model: root._shown
            delegate: Item {
                required property int index
                width: root._d
                height: root._d
                z: 10 - index
                Arc.ArcAvatar {
                    anchors.fill: parent
                    th: root.th
                    name: root._nameOf(index)
                    seed: index
                    size: root._sizeName
                    status: root._statusOf(index)
                    monochrome: true
                }
                // 选中环：FocusRing（真源码选中态加一圈 outline）
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.width: 2
                    border.color: root.th ? root.th.a("accent") : "#FF2FB8C6"
                    visible: root.selectedIndex === index
                }
                // 名字（可选）：NamePadding [8,4,8,4] 的 chip
                Rectangle {
                    visible: root.showNames
                    anchors.top: parent.bottom
                    anchors.topMargin: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: _nm.implicitWidth + 16
                    height: _nm.implicitHeight + 8
                    radius: height / 2
                    color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
                    Text {
                        id: _nm
                        anchors.centerIn: parent
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: root._nameOf(index)
                        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                        font.pixelSize: root.size === "sm" ? root.th.ct("AvatarGroup", "ChipFontSizeSM") : root.th.design("TypeXS")
                    }
                }
                MouseArea { anchors.fill: parent; onClicked: root.memberActivated(index) }
            }
        }
        // +N 圆片
        Item {
            visible: root._extra > 0
            width: root._d
            height: root._d
            z: 1
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
                border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 0
                border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
            }
            Text {
                anchors.centerIn: parent
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: "+" + root._extra
                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                font.pixelSize: root.size === "sm" ? root.th.ct("AvatarGroup", "ChipFontSizeSM") : root.th.design("TypeSM")
                font.weight: root.th ? root.th.weightMedium : 500
            }
            MouseArea { anchors.fill: parent; onClicked: root.memberActivated(root._shown) }
        }
    }
    function _nameOf(i) {
        var m = root.members[i];
        if (m === undefined || m === null) return "";
        return (typeof m === "string") ? m : (m.name || "");
    }
    function _statusOf(i) {
        var m = root.members[i];
        if (m === undefined || m === null || typeof m === "string") return "";
        return m.status || "";
    }
}
