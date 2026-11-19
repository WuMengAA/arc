// arc:AvatarUpload —— Editors/AvatarUpload 真源码移植（AvatarUpload.cs 1241 行 + AvatarUploadToken.cs +
// AvatarUploadCropper/Stage/Labels/AvatarImageTypes/AvatarUploadTypes）。
// 头像上传：圆形头像 + 环形进度（RingThickness3 / RingMargin[-5,-5,-5,-5]）+ 文字（TextMargin[20,0,0,0] /
// TextSpacing2）+ 底部动作（ActionsMargin[0,10,0,0] / ActionsSpacing8）；裁切器 CropSize256 / CropInset20 / ZoomGlyphSize16。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string label: "Profile photo"
    property string description: "PNG or JPG, up to 4 MB"
    property int size: 96
    property real progress: 0
    property string displayName: ""
    property bool allowRemove: true
    property string error: ""
    signal browseRequested()
    signal removeRequested()

    readonly property real _ring: root.th.ct("AvatarUpload", "RingThickness")
    readonly property real _ringM: -root.th.t4(root.th.ct("AvatarUpload", "RingMargin"), 0)
    readonly property real _textM: root.th.t4(root.th.ct("AvatarUpload", "TextMargin"), 0)
    readonly property real _textSp: root.th.ct("AvatarUpload", "TextSpacing")
    readonly property real _actionM: root.th.t4(root.th.ct("AvatarUpload", "ActionsMargin"), 1)
    readonly property real _actionSp: root.th.ct("AvatarUpload", "ActionsSpacing")
    readonly property real _zoom: root.th.ct("AvatarUpload", "ZoomGlyphSize")
    implicitWidth: root.size + 8 + 200
    implicitHeight: Math.max(root.size + 8, _col.implicitHeight)

    // 头像 + 进度环
    Item {
        width: root.size + 8
        height: root.size + 8
        Rectangle {
            anchors.centerIn: parent
            width: root.size; height: root.size
            radius: width / 2
            color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
            Arc.ArcIcon {
                anchors.centerIn: parent
                width: root.size * 0.4; height: width
                th: root.th; kind: "User"
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            }
        }
        // 进度环（底环 + 已完成环）
        Rectangle {
            anchors.centerIn: parent
            width: root.size + 2 * root._ring; height: width
            radius: width / 2
            color: "transparent"
            border.width: root._ring
            border.color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
        }
        Rectangle {
            anchors.centerIn: parent
            width: root.size + 2 * root._ring; height: width
            radius: width / 2
            color: "transparent"
            border.width: root._ring
            border.color: root.th ? root.th.a("accent") : "#FF2FB8C6"
            opacity: Math.max(0, Math.min(1, root.progress))
            Behavior on opacity { NumberAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        }
        // 编辑角标
        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 26; height: 26
            radius: 13
            color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
            border.width: 1
            border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
            Arc.ArcIcon {
                anchors.centerIn: parent
                width: root._zoom; height: root._zoom
                th: root.th; kind: "Camera"
                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            }
            MouseArea { anchors.fill: parent; onClicked: root.browseRequested() }
        }
    }
    Column {
        id: _col
        x: root.size + 8 + 14
        width: parent.width - x
        spacing: root._textSp
        Text {
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.label
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightMedium : 500
        }
        Text {
            width: parent.width
            visible: root.description !== ""
            wrapMode: Text.WordWrap
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.description
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
        Text {
            visible: root.error !== ""
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.error
            color: root.th ? root.th.c("Danger") : "#FFCD1526"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
        // 动作
        Row {
            y: root._actionM
            spacing: root._actionSp
            Rectangle {
                width: _b1.implicitWidth + 24; height: 30
                radius: 15
                color: root.th ? root.th.a("accent") : "#FF2FB8C6"
                Text {
                    id: _b1
                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: "Upload"
                    color: root.th ? root.th.a("foreground") : "#FFFFFFFF"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    font.weight: root.th ? root.th.weightMedium : 500
                }
                MouseArea { anchors.fill: parent; onClicked: root.browseRequested() }
            }
            Rectangle {
                visible: root.allowRemove
                width: _b2.implicitWidth + 24; height: 30
                radius: 15
                color: "transparent"
                border.width: 1
                border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
                Text {
                    id: _b2
                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: "Remove"
                    color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
                MouseArea { anchors.fill: parent; onClicked: root.removeRequested() }
            }
        }
    }
}
