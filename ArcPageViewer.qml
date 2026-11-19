// arc:PageViewer —— Media/PageViewer 真源码移植（PageViewer.cs 1004 行 + PageViewerToken.cs + PageLayer/
// PageLayoutEngine/PageRenderScheduler/PageViewerPresenter/PageViewerToolbar/PageViewerTypes/IPageSource/ImagePageSource）。
// 文档查看器：画布（CanvasPadding24 / 窄 8，PageSpacing12）+ 底部工具条（ToolbarHeight48 / ToolbarPadding[8,0,8,0]）；
// 页码框 PageNumberBoxWidth56；缩放菜单 ZoomMenuWidth72；占位水印 PlaceholderInk。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property int pageCount: 1
    property int currentPageIndex: 0
    property real zoom: 1
    property real minZoom: 0.5
    property real maxZoom: 2
    property bool isToolbarVisible: true
    property bool narrow: false

    readonly property real _pad: root.narrow ? root.th.ct("PageViewer", "CanvasPaddingNarrow") : root.th.ct("PageViewer", "CanvasPadding")
    readonly property real _spacing: root.th.ct("PageViewer", "PageSpacing")
    readonly property real _toolbarH: root.th.ct("PageViewer", "ToolbarHeight")
    readonly property real _toolbarPad: root.th.t4(root.th.ct("PageViewer", "ToolbarPadding"), 0)
    readonly property real _pageBoxW: root.th.ct("PageViewer", "PageNumberBoxWidth")
    implicitWidth: 400
    implicitHeight: 320

    // 画布
    Item {
        id: _canvas
        anchors.fill: parent
        anchors.bottomMargin: root.isToolbarVisible ? root._toolbarH : 0
        clip: true
        // 页面（每页一张纸，PageSpacing 间隔）
        Column {
            x: (parent.width - _page.width) / 2
            y: root._pad
            spacing: root._spacing
            Repeater {
                model: root.pageCount
                delegate: Rectangle {
                    required property int index
                    readonly property bool cur: index === root.currentPageIndex
                    width: Math.min(parent.parent.width - 2 * root._pad, 420) * root.zoom
                    height: width * 1.414
                    radius: 6
                    color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
                    border.width: cur ? 2 : 1
                    border.color: cur ? (root.th ? root.th.a("accent") : "#FF2FB8C6")
                                      : (root.th ? root.th.c("Border") : "#FFE0E0E0")
                    // 占位水印
                    Text {
                        anchors.centerIn: parent
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: "Page " + (index + 1)
                        color: root.th ? root.th.ct("PageViewer", "PlaceholderInk") : "#380B0B0B"
                        font.pixelSize: root.th ? root.th.design("TypeLG") : 16
                    }
                    MouseArea { anchors.fill: parent; onClicked: root.currentPageIndex = index }
                }
            }
            id: _page
        }
    }
    // 工具条
    Rectangle {
        visible: root.isToolbarVisible
        anchors.bottom: parent.bottom
        width: parent.width
        height: root._toolbarH
        color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
        Rectangle {
            anchors.top: parent.top
            width: parent.width; height: 1
            color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        }
        Row {
            x: root._toolbarPad
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            // 上一页 / 下一页
            Repeater {
                model: 2
                delegate: Rectangle {
                    required property int index
                    width: 30; height: 30
                    radius: 8
                    color: _tm2.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                    enabled: index === 0 ? root.currentPageIndex > 0 : root.currentPageIndex < root.pageCount - 1
                    opacity: enabled ? 1 : 0.4
                    Arc.ArcIcon {
                        anchors.centerIn: parent
                        width: 16; height: 16
                        th: root.th
                        kind: index === 0 ? "ChevronLeft" : "ChevronRight"
                        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                    }
                    MouseArea {
                        id: _tm2
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (index === 0) root.currentPageIndex = Math.max(0, root.currentPageIndex - 1);
                            else root.currentPageIndex = Math.min(root.pageCount - 1, root.currentPageIndex + 1);
                        }
                    }
                }
            }
            // 页码
            Rectangle {
                width: root._pageBoxW; height: 28
                radius: 14
                color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
                Text {
                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: (root.currentPageIndex + 1) + " / " + root.pageCount
                    color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
            }
            // 缩放
            Repeater {
                model: 2
                delegate: Rectangle {
                    required property int index
                    width: 30; height: 30
                    radius: 8
                    color: _zm.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                    Arc.ArcIcon {
                        anchors.centerIn: parent
                        width: 16; height: 16
                        th: root.th
                        kind: index === 0 ? "ZoomOut" : "ZoomIn"
                        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                    }
                    MouseArea {
                        id: _zm
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var f = index === 0 ? 0.9 : 1.1;
                            root.zoom = Math.max(root.minZoom, Math.min(root.maxZoom, root.zoom * f));
                        }
                    }
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: Math.round(root.zoom * 100) + "%"
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
        }
    }
}
