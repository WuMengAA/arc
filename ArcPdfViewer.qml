// arc:PdfViewer —— Pdf 项目真值：SidebarWidth 224 / ThumbnailWidth 120 / ThumbnailSpacing 12 /
// SearchBarWidth 360 / SearchHighlight #66FFD60A / LinkHoverFill；PageViewer 真值：ToolbarHeight 48 /
// CanvasPadding 24 / PageSpacing 12 / PageNumberBoxWidth 56 / ZoomMenuWidth 72 / PlaceholderInk。
// 页面用矢量占位（白纸+文本行），不依赖任何 PDF 渲染后端。
import QtQuick 2.15

Rectangle {
    id: root
    property var th: null
    property int page: 1
    property int pageCount: 12
    property bool sidebarOpen: true
    property real zoom: 1.0
    readonly property real _toolH: th.ct("PageViewer", "ToolbarHeight")
    readonly property real _sideW: th.ct("PdfViewer", "SidebarWidth")
    readonly property real _thumbW: th.ct("PdfViewer", "ThumbnailWidth")
    readonly property real _thumbGap: th.ct("PdfViewer", "ThumbnailSpacing")
    readonly property real _canvasPad: th.ct("PageViewer", "CanvasPadding")
    readonly property real _pageGap: th.ct("PageViewer", "PageSpacing")
    readonly property real _numW: th.ct("PageViewer", "PageNumberBoxWidth")
    readonly property real _zoomW: th.ct("PageViewer", "ZoomMenuWidth")
    width: 760; height: 430
    color: th.c("Surface")
    border.width: 1; border.color: th.c("Border")
    radius: th.t4(th.design("RadiusPanel"), 0)
    clip: true
    Rectangle {
        width: parent.width; height: root._toolH; color: root.th.c("SurfaceMuted")
        Row {
            x: 8; anchors.verticalCenter: parent.verticalCenter; spacing: 6
            ArcButton { th: root.th; icon: "PanelLeft"; variant: "ghost"; size: "sm"; onClicked: root.sidebarOpen = !root.sidebarOpen }
            ArcButton { th: root.th; icon: "Search"; variant: "ghost"; size: "sm" }
            Rectangle { width: 180; height: 30; radius: 8; color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("Border"); Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.verticalCenter: parent.verticalCenter; x: 10; text: "Find in document"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } }
            Item { width: 20; height: 1 }
            ArcButton { th: root.th; icon: "ChevronLeft"; variant: "ghost"; size: "sm"; onClicked: root.page = Math.max(1, root.page - 1) }
            Rectangle { width: root._numW; height: 30; radius: 8; color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("Border"); Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: root.page + " / " + root.pageCount; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeXS") } }
            ArcButton { th: root.th; icon: "ChevronRight"; variant: "ghost"; size: "sm"; onClicked: root.page = Math.min(root.pageCount, root.page + 1) }
            Item { width: 12; height: 1 }
            Rectangle { width: root._zoomW; height: 30; radius: 8; color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("Border"); Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: Math.round(root.zoom * 100) + "%"; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS") } }
            ArcButton { th: root.th; icon: "Download"; variant: "ghost"; size: "sm" }
        }
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.th.c("Border") }
    }
    Row {
        y: root._toolH; width: parent.width; height: parent.height - root._toolH
        Rectangle {
            visible: root.sidebarOpen; width: root._sideW; height: parent.height
            color: root.th.c("SurfaceMuted"); border.width: 1; border.color: root.th.c("Border")
            Flickable {
                anchors.fill: parent; contentHeight: _thumbs.implicitHeight; clip: true
                Column {
                    id: _thumbs; x: (root._sideW - root._thumbW) / 2; y: 12; spacing: root._thumbGap
                    Repeater {
                        model: 4
                        delegate: Rectangle {
                            required property int index
                            width: root._thumbW; height: 150
                            color: "#FFFFFFFF"
                            border.width: root.page === (index + 1) ? 2 : 1
                            border.color: root.page === (index + 1) ? root.th.a("accent") : root.th.c("Border")
                            Column { x: 12; y: 14; spacing: 8; Repeater { model: 7; delegate: Rectangle { width: root._thumbW - 24; height: 5; radius: 2; color: "#FFE2E2E2" } } }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 6; text: String(index + 1); color: "#FF9A9A9A"; font.pixelSize: 13 }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.page = index + 1 }
                        }
                    }
                }
            }
        }
        Flickable {
            width: parent.width - (root.sidebarOpen ? root._sideW : 0); height: parent.height
            contentWidth: width; contentHeight: _paper.height + 2 * root._canvasPad; clip: true
            boundsBehavior: Flickable.StopAtBounds
            Rectangle {
                id: _paper
                x: (parent.width - width) / 2; y: root._canvasPad
                width: 420 * root.zoom; height: 560 * root.zoom
                color: "#FFFFFFFF"; border.width: 1; border.color: root.th.c("Border")
                Column {
                    x: 40; y: 44; width: parent.width - 80; spacing: 16
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Chapter " + root.page; color: "#FF1A1A1A"; font.pixelSize: 26; font.weight: root.th.design("WeightMedium") }
                    Rectangle { width: parent.width; height: 1; color: "#FFE6E6E6" }
                    Repeater { model: 9; delegate: Rectangle { width: _paper.width - 80; height: 9; radius: 2; color: "#FFEBEBEB" } }
                    Rectangle { y: 8; width: _paper.width - 80; height: 120; radius: 8; color: root.th.ct("PdfViewer", "SearchHighlight") }
                }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 14; text: "Page " + root.page; color: "#FF9A9A9A"; font.pixelSize: 14 }
            }
        }
    }
}
