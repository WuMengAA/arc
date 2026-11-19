// arc:ImageCompare —— Media/ImageCompare 真源码移植（ImageCompare.cs 747 行 + ImageCompareToken.cs +
// ImageCompareDivider/ImageCompareHandle/ImageCompareMath）。
// 前后对比：上层图按 Position(0..1) 裁切盖在下层之上，中间是 DividerColor 竖线（HairlineColor 发丝阴影）；
// 顶部两个标签 Chip（ChipBackground / ChipPadding[10,3,10,3] / ChipMargin[12,12,12,12]）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property real position: 0.5
    property string orientation: "horizontal"   // horizontal | vertical
    property string beforeLabel: "Before"
    property string afterLabel: "After"
    property bool showLabels: true
    property real aspectRatio: 1.6
    // 图像来源：宿主注入（QML 不联网）；可为 URL 或 image://provider
    property var beforeSource: ""
    property var afterSource: ""

    readonly property real _chipBg: root.th ? root.th.ct("ImageCompare", "ChipBackground") : "#BDFFFFFF"
    readonly property real _hairline: root.th ? root.th.ct("ImageCompare", "HairlineColor") : "#140B0B0B"
    readonly property real _divider: root.th ? root.th.ct("ImageCompare", "DividerColor") : "#FFFFFFFF"
    readonly property real _chipPad: root.th.pad(root.th.ct("ImageCompare", "ChipPadding"))
    readonly property real _chipM: root.th.pad(root.th.ct("ImageCompare", "ChipMargin"))
    readonly property real _chipLH: root.th.ct("ImageCompare", "ChipLineHeight")
    implicitWidth: 360
    implicitHeight: root.aspectRatio > 0 ? root.width / root.aspectRatio : 240

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
        clip: true
        // After（底层）
        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: root.afterSource
            visible: root.afterSource !== ""
        }
        // Before（上层，按 Position 裁切）
        Rectangle {
            width: root.orientation === "horizontal" ? parent.width * root.position : parent.width
            height: root.orientation === "horizontal" ? parent.height : parent.height * root.position
            clip: true
            color: "transparent"
            Image {
                width: root.orientation === "horizontal" ? parent.parent.width : parent.width
                height: root.orientation === "horizontal" ? parent.height : parent.parent.height
                fillMode: Image.PreserveAspectCrop
                source: root.beforeSource
                visible: root.beforeSource !== ""
            }
        }
        // 分隔线 + 手柄
        Rectangle {
            x: root.orientation === "horizontal" ? parent.width * root.position - 1 : 0
            y: root.orientation === "horizontal" ? 0 : parent.height * root.position - 1
            width: root.orientation === "horizontal" ? 2 : parent.width
            height: root.orientation === "horizontal" ? parent.height : 2
            color: root._divider
        }
        // 手柄
        Rectangle {
            x: root.orientation === "horizontal" ? parent.width * root.position - 16 : parent.width / 2 - 16
            y: root.orientation === "horizontal" ? parent.height / 2 - 16 : parent.height * root.position - 16
            width: 32; height: 32
            radius: 16
            color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
            border.width: 1
            border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
            Arc.ArcIcon {
                anchors.centerIn: parent
                width: 16; height: 16
                th: root.th
                kind: root.orientation === "horizontal" ? "ChevronsLeftRight" : "ChevronsUpDown"
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            }
        }
        // 拖拽区
        MouseArea {
            anchors.fill: parent
            cursorShape: root.orientation === "horizontal" ? Qt.SplitHCursor : Qt.SplitVCursor
            onPositionChanged: {
                if (!pressed) return;
                var f = root.orientation === "horizontal" ? (mouse.x / width) : (mouse.y / height);
                root.position = Math.max(0, Math.min(1, f));
            }
        }
        // 标签
        Row {
            visible: root.showLabels
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: root._chipM
            spacing: 6
            Rectangle {
                width: _bl.implicitWidth + 2 * root._chipPad
                height: root._chipLH + 6
                radius: height / 2
                color: root._chipBg
                Text {
                    id: _bl
                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root.beforeLabel
                    color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
            }
        }
        Row {
            visible: root.showLabels
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: root._chipM
            Rectangle {
                width: _al.implicitWidth + 2 * root._chipPad
                height: root._chipLH + 6
                radius: height / 2
                color: root._chipBg
                Text {
                    id: _al
                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root.afterLabel
                    color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
            }
        }
    }
}
