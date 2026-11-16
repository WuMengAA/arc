// arc:Avatar —— Avatars/Avatar 真源码移植（AvatarToken.cs 22 键 + AvatarTheme.axaml PART_）。
// 直径 SM28/MD36/LG48/LGPlus64/XL88；TRUE 源码底色 SurfaceMuted（monochrome），
// 默认沿用项目序列色（seed）保持既有页面视觉；补 status 状态点（online/busy/offline）。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property string name: ""
    property string size: "md"        // sm | md | lg | lgPlus | xl
    property int seed: 0
    property string status: ""        // "" | online | busy | offline
    property bool monochrome: false   // true = 真源码 SurfaceMuted 底

    readonly property real _d: size === "sm" ? th.ct("Avatar", "DiameterSM")
                            : size === "lg" ? th.ct("Avatar", "DiameterLG")
                            : size === "lgPlus" ? th.ct("Avatar", "DiameterLGPlus")
                            : size === "xl" ? th.ct("Avatar", "DiameterXL")
                            : th.ct("Avatar", "DiameterMD")
    readonly property real _fs: size === "sm" ? th.ct("Avatar", "InitialsFontSizeSM")
                            : size === "lgPlus" ? th.design("TypeLG")
                            : size === "xl" ? th.design("TypeXL")
                            : size === "lg" ? th.design("TypeSM") : th.design("TypeXS")
    readonly property real _dot: size === "sm" ? th.ct("Avatar", "StatusSizeSM")
                            : size === "lg" ? th.ct("Avatar", "StatusSizeLG")
                            : size === "xl" ? th.ct("Avatar", "StatusSizeXL")
                            : th.ct("Avatar", "StatusSizeMD")
    readonly property real _ring: size === "sm" ? th.pad(th.ct("Avatar", "StatusRingSM"))
                            : th.pad(th.ct("Avatar", "StatusRing"))
    readonly property color _dotColor: status === "online" ? th.c("Success")
                                     : status === "busy" ? th.c("Danger")
                                     : th.c("TextMuted")

    function initials() {
        var parts = (name || "").split(" ");
        var a = parts.length > 0 && parts[0] ? parts[0].charAt(0) : "?";
        var b = parts.length > 1 && parts[1] ? parts[1].charAt(0) : "";
        return (a + b).toUpperCase();
    }

    width: _d; height: _d

    // PART_Frame
    Rectangle {
        anchors.fill: parent
        radius: parent.height / 2
        color: root.monochrome ? root.th.c("SurfaceMuted") : root.th.fade(root.th.series(root.seed), 0.16)
        border.width: root.th.t4(root.th.design("EdgeThickness"), 0)
        border.color: root.th.c("Border")
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            anchors.centerIn: parent
            text: root.initials()
            color: root.monochrome ? root.th.c("Foreground") : root.th.series(root.seed)
            font.pixelSize: root._fs
            font.weight: root.th.design("WeightMedium")
        }
    }

    // 状态点（PART_Status + Busy 横杠 + Halo 环）
    Rectangle {
        visible: root.status !== ""
        anchors.right: parent.right; anchors.bottom: parent.bottom
        width: root._dot; height: root._dot
        radius: root._dot / 2
        color: root._dotColor
        border.width: root._ring
        border.color: root.th.c("Background")
        Rectangle {
            visible: root.status === "busy"
            anchors.centerIn: parent
            width: root.th.ct("Avatar", "StatusBarWidth")
            height: root.th.ct("Avatar", "StatusBarHeight")
            color: root.th.c("Background")
        }
    }
}

