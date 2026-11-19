// arc:Carousel —— Media/Carousel 真源码移植（Carousel.cs + CarouselToken.cs + CarouselMath/CarouselPager/
// CarouselPlayGlyph/CarouselSlide/CarouselTrackPanel/CarouselViewport）。
// 轮播：视口圆角 ViewportRingRadius32 / 外扩 ViewportRingMargin[-6,-6,-6,-6]；
// 滑片宽 = 视口宽 × SlideWidthRatio（上限 MaxSlideWidth），片间距 SlideGap；自动播放 Interval；
// 控制条 ControlsGap8（紧凑 4）/ RowGap16，播放标记 PlayGlyphSize15 / PlayGlyphSlot16。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var slides: []           // [{title?, body?}] 或 Component 数组
    property real slideWidthRatio: 0.86
    property real maxSlideWidth: 0
    property real slideGap: 12
    property int interval: 4200
    property bool isAutoPlay: false
    property int currentIndex: 0
    property bool compact: false

    readonly property real _rad: root.th.pad(root.th.ct("Carousel", "ViewportRingRadius"))
    readonly property real _ringM: -root.th.t4(root.th.ct("Carousel", "ViewportRingMargin"), 0)
    readonly property real _controlsGap: root.compact ? root.th.ct("Carousel", "CompactControlsGap") : root.th.ct("Carousel", "ControlsGap")
    readonly property real _rowGap: root.th.ct("Carousel", "RowGap")
    readonly property real _glyph: root.th.ct("Carousel", "PlayGlyphSize")
    readonly property real _glyphSlot: root.th.ct("Carousel", "PlayGlyphSlot")
    // 片宽：视口宽 × 比例，上限 maxSlideWidth（0 = 不限）
    readonly property real _slideW: {
        var w = root.width * root.slideWidthRatio;
        if (root.maxSlideWidth > 0) w = Math.min(w, root.maxSlideWidth);
        return Math.max(60, w);
    }
    readonly property real _viewportH: root.height > 0 ? Math.max(80, root.height - root._rowGap - 28) : 200
    implicitWidth: 420
    implicitHeight: root._viewportH + root._rowGap + 28

    function next() { root.currentIndex = (root.currentIndex + 1) % Math.max(1, root.slides.length); }
    function prev() { root.currentIndex = (root.currentIndex - 1 + root.slides.length) % Math.max(1, root.slides.length); }

    Timer {
        interval: Math.max(800, root.interval)
        repeat: true
        running: root.isAutoPlay && root.slides.length > 1
        onTriggered: root.next()
    }
    // PART_Viewport
    Item {
        id: _viewport
        width: parent.width
        height: root._viewportH
        clip: true
        Item {
            id: _track
            height: parent.height
            // 轨道中心对齐当前片
            x: (root.width - root._slideW) / 2 - root.currentIndex * (root._slideW + root.slideGap)
            Behavior on x { NumberAnimation { duration: root.th ? root.th.dur("Considered") : 480
                easing.type: Easing.Bezier; easing.bezierCurve: root.th ? root.th.ease("Standard") : [0.22, 1, 0.36, 1, 1, 1] } }
            Row {
                spacing: root.slideGap
                Repeater {
                    model: root.slides.length
                    delegate: Rectangle {
                        required property int index
                        readonly property bool cur: index === root.currentIndex
                        width: root._slideW
                        height: _viewport.height
                        radius: root._rad
                        color: root.th ? (cur ? root.th.c("SurfaceRaised") : root.th.c("SurfaceMuted")) : "#FFFFFFFF"
                        border.width: 1
                        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
                        // 不透明度 / 缩放：当前片最实
                        opacity: cur ? 1 : 0.55
                        scale: cur ? 1 : 0.96
                        Behavior on opacity { NumberAnimation { duration: root.th ? root.th.dur("Standard") : 240 } }
                        Behavior on scale { NumberAnimation { duration: root.th ? root.th.dur("Standard") : 240 } }
                        Column {
                            anchors.centerIn: parent
                            x: 0
                            width: parent.width - 48
                            spacing: 6
                            Text {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                renderType: Text.NativeRendering
                                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                                text: root.slides[index] && root.slides[index].title !== undefined ? root.slides[index].title : ""
                                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                                font.pixelSize: root.th ? root.th.design("TypeLG") : 16
                                font.weight: root.th ? root.th.weightMedium : 500
                            }
                            Text {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                visible: root.slides[index] && root.slides[index].body !== undefined
                                renderType: Text.NativeRendering
                                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                                text: root.slides[index] && root.slides[index].body !== undefined ? root.slides[index].body : ""
                                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                            }
                        }
                        MouseArea { anchors.fill: parent; onClicked: root.currentIndex = index }
                    }
                }
            }
        }
    }
    // PART_Controls：播放/暂停 + 分页点
    Row {
        y: _viewport.height + root._rowGap
        width: parent.width
        spacing: root._controlsGap
        Rectangle {
            width: root._glyphSlot; height: root._glyphSlot
            radius: width / 2
            color: _pm2.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
            Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
            Arc.ArcIcon {
                anchors.centerIn: parent
                width: root._glyph; height: root._glyph
                th: root.th
                kind: root.isAutoPlay ? "Pause" : "Play"
                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            }
            MouseArea { id: _pm2; anchors.fill: parent; hoverEnabled: true; onClicked: root.isAutoPlay = !root.isAutoPlay }
        }
        // 分页点
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Repeater {
                model: root.slides.length
                delegate: Rectangle {
                    required property int index
                    width: index === root.currentIndex ? 18 : 6
                    height: 6
                    radius: 3
                    color: index === root.currentIndex ? (root.th ? root.th.a("accent") : "#FF2FB8C6")
                                                       : (root.th ? root.th.c("BorderStrong") : "#FFC0C0C0")
                    Behavior on width { NumberAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                    Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                    MouseArea { anchors.fill: parent; onClicked: root.currentIndex = index }
                }
            }
        }
    }
}
