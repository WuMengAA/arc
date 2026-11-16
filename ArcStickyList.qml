// arc:Sticky —— Layout/Sticky.cs 真逻辑：元素滚到视口顶端后用 render translation 固定，
// 内容布局与高度不变；父级底边到达时随父滚走，下一组头把上一组头推出去；stuck 时 ZIndex 抬高。
// QML 等价：组头 y = max(0, min(contentY - groupTop, groupBottom - headerH - contentY))，只改 y 不改 contentHeight。
import QtQuick 2.15

Rectangle {
    id: root
    property var th: null
    property var groups: []      // [{ name, items:[...] }]
    readonly property real _headH: 36
    width: 420; height: 300
    color: th.c("Surface"); border.width: 1; border.color: th.c("Border")
    radius: th.t4(th.design("RadiusPanel"), 0)
    clip: true
    Flickable {
        id: _f
        anchors.fill: parent
        contentWidth: width; contentHeight: _rows.implicitHeight + 20
        clip: true; boundsBehavior: Flickable.StopAtBounds
        Column {
            id: _rows
            x: 12; y: 10; width: parent.width - 24 - 12; spacing: 0
            Repeater {
                model: root.groups
                delegate: Column {
                    id: _g
                    required property var modelData
                    required property int index
                    property real _top: y
                    property real _h: implicitHeight
                    width: _rows.width; spacing: 0
                    Rectangle {
                        id: _header
                        width: _g.width; height: root._headH
                        // 只改 y（render translation 等价），不占额外布局空间
                        y: Math.max(0, Math.min(_f.contentY - _g.y, _g.y + _g._h - root._headH - _f.contentY - _g.y))
                        z: 2
                        color: root.th.c("SurfaceMuted")
                        border.width: 1; border.color: root.th.c("BorderSubtle")
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.verticalCenter: parent.verticalCenter; x: 12; text: modelData.name; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") }
                    }
                    Repeater {
                        model: modelData.items || []
                        delegate: Rectangle {
                            required property var modelData
                            width: _g.width; height: 38
                            color: root.th.c("Surface")
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.verticalCenter: parent.verticalCenter; x: 16; text: modelData; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
                            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.th.c("BorderSubtle") }
                        }
                    }
                }
            }
        }
    }
}
