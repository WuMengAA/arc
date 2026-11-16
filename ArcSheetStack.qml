// arc:SheetStack —— Special/Surfaces 真值：ScrimColor #52000000 / SheetMaxWidth 560 / SheetPeek 10 /
// SheetTopInset 20 / DialogWidth 440 / DialogPeek 14 / DepthScaleStep 0.05 / DepthDimStep 0.5 /
// ExitOvershoot 24；SheetStackSheet 真值：GrabberWidth 36 / GrabberHeight 5 / HeaderRowHeight 44 / CloseButtonSize 36。
// 抽屉堆叠：每深一层 scale 缩一档、位移一档、遮罩暗一档；点击顶层关闭退一层。
import QtQuick 2.15

Rectangle {
    id: root
    property var th: null
    property int depth: 3
    property var titles: ["Filters", "Sort & group", "Advanced"]
    signal changed(int depth)
    readonly property real _scrim: th.ct("SheetStack", "ScrimColor")
    readonly property real _maxW: th.ct("SheetStack", "SheetMaxWidth")
    readonly property real _peek: th.ct("SheetStack", "SheetPeek")
    readonly property real _top: th.ct("SheetStack", "SheetTopInset")
    readonly property real _scaleStep: th.ct("SheetStack", "DepthScaleStep")
    readonly property real _dimStep: th.ct("SheetStack", "DepthDimStep")
    readonly property real _grabW: th.ct("SheetStackSheet", "GrabberWidth")
    readonly property real _grabH: th.ct("SheetStackSheet", "GrabberHeight")
    readonly property real _close: th.ct("SheetStackSheet", "CloseButtonSize")
    width: 560; height: 400
    color: th.c("Background")
    border.width: 1; border.color: th.c("Border")
    radius: th.t4(th.design("RadiusPanel"), 0)
    clip: true
    Column { x: 24; y: 24; spacing: 8; Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Underlying page"; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeLG"); font.weight: root.th.design("WeightMedium") } Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Tap a sheet to dismiss it, or use Open stack to add one."; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") } Row { spacing: 8; ArcButton { th: root.th; text: "Open stack"; size: "sm"; onClicked: root.depth = Math.min(4, root.depth + 1) } ArcButton { th: root.th; text: "Close all"; variant: "secondary"; size: "sm"; onClicked: root.depth = 0 } } }
    Rectangle { anchors.fill: parent; visible: root.depth > 0; color: root._scrim; opacity: Math.min(0.9, 0.3 + root.depth * 0.14) }
    Repeater {
        model: root.depth
        delegate: Rectangle {
            id: _sheet
            required property int index
            property var host: root
            property int _layer: index
            property real _shrink: (root.depth - 1 - _layer) * root._scaleStep
            property real _y: root._top + (root.depth - 1 - _layer) * root._peek
            property real _scale: 1 - _shrink
            width: Math.min(root._maxW, root.width - 40); height: 300
            x: (root.width - width) / 2; y: _y
            scale: _scale
            transformOrigin: Item.Top
            z: _layer + 1
            radius: root.th.t4(root.th.design("RadiusSurface"), 0)
            color: root.th.c("SurfaceRaised")
            border.width: 1; border.color: root.th.c("Border")
            opacity: 1 - (root.depth - 1 - _layer) * root._dimStep * 0.18
            Behavior on y { NumberAnimation { duration: root.th.dur("Standard"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
            Behavior on scale { NumberAnimation { duration: root.th.dur("Standard"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
            Rectangle { anchors.horizontalCenter: parent.horizontalCenter; y: 8; width: root._grabW; height: root._grabH; radius: root._grabH / 2; color: root.th.c("BorderStrong") }
            Row {
                x: 16; y: 20; width: parent.width - 32; height: 44
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.titles[Math.min(_layer, root.titles.length - 1)]; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeBase"); font.weight: root.th.design("WeightMedium"); anchors.verticalCenter: parent.verticalCenter }
                Item { width: parent.width - 180; height: 1 }
                ArcIcon { th: root.th; kind: "X"; width: 16; height: 16; color: root.th.c("TextMuted"); anchors.verticalCenter: parent.verticalCenter }
            }
            Column { x: 20; y: 84; width: parent.width - 40; spacing: 12; Repeater { model: 3; delegate: Row { spacing: 10; Rectangle { width: 18; height: 18; radius: 9; color: root.th.c("SurfaceMuted"); border.width: 1; border.color: root.th.c("Border") } Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "Option " + (index + 1); color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM"); anchors.verticalCenter: parent.verticalCenter } } } }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { host.depth = Math.max(0, _layer); host.changed(host.depth); } }
        }
    }
}
