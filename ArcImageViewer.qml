// arc:ImageCompare + Carousel —— Media 真值：DividerColor #FFFFFFFF / DividerEdgeColor / HairlineColor /
// ChipBackground / ChipPadding [10,3,10,3] / ChipLineHeight 16.8；Carousel ControlsGap 8 / RowGap 16 / PlayGlyphSize 15。
// 拖动分割线对比 before/after；下方缩略图条走 Carousel 令牌。
import QtQuick 2.15

Rectangle {
    id: root
    property var th: null
    property real split: 0.5
    property int active: 0
    property var slides: ["Studio", "Campus", "Lab", "Hall"]
    readonly property real _chipH: th.ct("ImageCompare", "ChipLineHeight")
    readonly property real _chipM: th.t4(th.ct("ImageCompare", "ChipMargin"), 0)
    readonly property real _chipPad: th.t4(th.ct("ImageCompare", "ChipPadding"), 0)
    readonly property real _ctlGap: th.ct("Carousel", "ControlsGap")
    readonly property real _rowGap: th.ct("Carousel", "RowGap")
    readonly property real _play: th.ct("Carousel", "PlayGlyphSize")
    width: 620; height: 360
    color: th.c("Surface"); border.width: 1; border.color: th.c("Border")
    radius: th.t4(th.design("RadiusPanel"), 0)
    clip: true
    Rectangle {
        id: _frame
        x: 12; y: 12; width: parent.width - 24; height: parent.height - 96
        color: root.th.c("SurfaceMuted"); clip: true
        radius: root.th.t4(root.th.design("RadiusControl"), 0)
        // after（彩色渐变）
        Rectangle { anchors.fill: parent; gradient: Gradient { GradientStop { position: 0; color: "#FF2B6CB0" } GradientStop { position: 1; color: "#FF48BB78" } } }
        // before（灰度），裁到分割线左侧
        Item {
            width: root.split * parent.width; height: parent.height; clip: true
            Rectangle { width: _frame.width; height: _frame.height; gradient: Gradient { GradientStop { position: 0; color: "#FF9AA0A6" } GradientStop { position: 1; color: "#FFD9DCE1" } } }
        }
        Rectangle { x: root.split * parent.width - 1; width: 2; height: parent.height; color: root.th.ct("ImageCompare", "DividerColor") }
        Rectangle { x: root.split * parent.width - 10; y: parent.height / 2 - 10; width: 20; height: 20; radius: 10; color: "#FFFFFFFF"; border.width: 1; border.color: root.th.ct("ImageCompare", "DividerEdgeColor"); ArcIcon { anchors.centerIn: parent; th: root.th; kind: "ChevronsUpDown"; width: 12; height: 12; color: root.th.c("Foreground") } }
        Rectangle {
            x: root._chipM; y: root._chipM; height: root._chipH + 8; width: 92
            radius: 8; color: root.th.ct("ImageCompare", "ChipBackground")
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: "Before"; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeXS") }
        }
        Rectangle {
            anchors.right: parent.right; anchors.rightMargin: root._chipM; y: root._chipM; height: root._chipH + 8; width: 92
            radius: 8; color: root.th.ct("ImageCompare", "ChipBackground")
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: "After"; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeXS") }
        }
        MouseArea {
            anchors.fill: parent; cursorShape: Qt.SizeHorizontalCursor
            preventStealing: true   // 拖对比滑块不滚页面
            onPositionChanged: function (m) { root.split = Math.max(0.05, Math.min(0.95, m.x / _frame.width)); }
            onPressed: function (m) { root.split = Math.max(0.05, Math.min(0.95, m.x / _frame.width)); }
        }
    }
    Row {
        x: 12; y: _frame.y + _frame.height + 12; spacing: root._ctlGap
        ArcButton { th: root.th; icon: "Play"; variant: "secondary"; size: "sm" }
        Repeater {
            model: root.slides
            delegate: Rectangle {
                required property var modelData; required property int index
                width: 88; height: 48; radius: 8
                color: root.active === index ? root.th.a("subtle") : root.th.c("SurfaceMuted")
                border.width: root.active === index ? 2 : 1; border.color: root.active === index ? root.th.a("accent") : root.th.c("Border")
                gradient: Gradient { GradientStop { position: 0; color: index % 2 ? "#FF6B8FB3" : "#FF8FBF9F" } GradientStop { position: 1; color: "#FFD6E4F0" } }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: modelData; color: "#FFFFFFFF"; font.pixelSize: root.th.design("TypeXS"); font.weight: root.th.design("WeightMedium") }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.active = index }
            }
        }
    }
}
