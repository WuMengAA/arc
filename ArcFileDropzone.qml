// arc:FileDropzone —— Editors/FileDropzone 真源码移植（FileDropzone.cs 1187 行 + FileDropzoneToken.cs +
// FileDropzoneItem/FileDropzoneParts）。
// 拖放上传区：大触发区（TriggerPadding[20,26,20,34] / 紧凑 [20,16,20,16]，内侧变体 TriggerPaddingInside[20,26,20,26]）；
// 已选文件行 RowMinHeight58（缩略图 ThumbRadius10 / SheetRadius7 / RemoveSize32 / RetryHeight30），失败行描边 FailedRowBorderColor。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var files: []            // [{name, size, failed?}]
    property bool compact: false
    property bool inside: false
    property string title: "Drop files here"
    property string hint: "or click to browse"
    signal browseRequested()
    signal removeRequested(int index)
    signal retryRequested(int index)

    readonly property real _rowMinH: root.th.ct("FileDropzone", "RowMinHeight")
    readonly property real _thumbRad: root.th.pad(root.th.ct("FileDropzone", "ThumbRadius"))
    readonly property real _sheetRad: root.th.pad(root.th.ct("FileDropzone", "SheetRadius"))
    readonly property real _remove: root.th.ct("FileDropzone", "RemoveSize")
    readonly property real _retryH: root.th.ct("FileDropzone", "RetryHeight")
    readonly property real _failBorder: root.th ? root.th.ct("FileDropzone", "FailedRowBorderColor") : "#FFEABBB6"
    readonly property var _trigPad: root.inside
            ? (root.compact ? root.th.ct("FileDropzone", "TriggerPaddingCompactInside")
                            : root.th.ct("FileDropzone", "TriggerPaddingInside"))
            : (root.compact ? root.th.ct("FileDropzone", "TriggerPaddingCompact")
                            : root.th.ct("FileDropzone", "TriggerPadding"))
    implicitWidth: 360
    implicitHeight: _triggerBox.height + (root.files.length > 0 ? 12 + root.files.length * (root._rowMinH + 6) : 0)

    // 触发区
    Rectangle {
        id: _triggerBox
        width: parent.width
        height: root.th.t4(root._trigPad, 1) + 44 + root.th.t4(root._trigPad, 3)
        radius: 16
        color: _dz.containsMouse ? (root.th ? root.th.fade(root.th.a("accent"), 0.06) : "#0F2FB8C6")
                                 : (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0")
        border.width: 1.5
        border.color: root.th ? root.th.fade(root.th.a("accent"), 0.35) : "#592FB8C6"
        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        Column {
            anchors.centerIn: parent
            spacing: 4
            Arc.ArcIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 26; height: 26
                th: root.th; kind: "Upload"
                color: root.th ? root.th.a("accent") : "#FF2FB8C6"
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root.title
                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                font.pixelSize: root.th ? root.th.design("TypeSM") : 13
                font.weight: root.th ? root.th.weightMedium : 500
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root.hint
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
        }
        MouseArea {
            id: _dz
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.browseRequested()
        }
    }
    // 已选文件行
    Column {
        y: _triggerBox.height + 12
        width: parent.width
        spacing: 6
        Repeater {
            model: root.files.length
            delegate: Rectangle {
                required property int index
                readonly property bool failed: root.files[index].failed === true
                width: parent.width
                height: root._rowMinH
                radius: 12
                color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
                border.width: failed ? 1 : 0
                border.color: root._failBorder
                // 缩略图块
                Rectangle {
                    x: 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40; height: 40
                    radius: root._thumbRad
                    color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
                    Arc.ArcIcon {
                        anchors.centerIn: parent
                        width: 18; height: 18
                        th: root.th; kind: failed ? "TriangleAlert" : "File"
                        color: failed ? (root.th ? root.th.c("Danger") : "#FFCD1526")
                                      : (root.th ? root.th.c("TextMuted") : "#FF9A9A9A")
                    }
                }
                Column {
                    x: 60
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - x - (failed ? 90 : 44)
                    spacing: 2
                    Text {
                        width: parent.width
                        elide: Text.ElideMiddle
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: root.files[index].name || ""
                        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    }
                    Text {
                        width: parent.width
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: failed ? "Upload failed" : (root.files[index].size || "")
                        color: failed ? (root.th ? root.th.c("Danger") : "#FFCD1526")
                                      : (root.th ? root.th.c("TextMuted") : "#FF9A9A9A")
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    }
                }
                // 重试
                Rectangle {
                    visible: failed
                    anchors.right: parent.right
                    anchors.rightMargin: 40
                    anchors.verticalCenter: parent.verticalCenter
                    width: _rt.implicitWidth + 20
                    height: root._retryH
                    radius: height / 2
                    color: _rm2.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                    Text {
                        id: _rt
                        anchors.centerIn: parent
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: "Retry"
                        color: root.th ? root.th.a("accent") : "#FF2FB8C6"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    }
                    MouseArea { id: _rm2; anchors.fill: parent; hoverEnabled: true; onClicked: root.retryRequested(index) }
                }
                // 移除
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: root._remove; height: root._remove
                    radius: width / 2
                    color: _xv.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                    Arc.ArcIcon {
                        anchors.centerIn: parent
                        width: 14; height: 14
                        th: root.th; kind: "X"
                        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                    }
                    MouseArea { id: _xv; anchors.fill: parent; hoverEnabled: true; onClicked: root.removeRequested(index) }
                }
            }
        }
    }
}
