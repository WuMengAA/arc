// arc:SidebarTree —— 把 ArcSidebarSection 组装成可交互树；顶部折叠按钮驱动整栏 rail/展开。
// 分组与嵌套行的展开/收起是「组件动效」的实体：height + chevron rotation 皆走令牌时长与缓动。
import QtQuick 2.15

Rectangle {
    id: root
    property var th: null
    property var sections: []
    property string currentKey: ""
    property bool collapsed: false
    property var openKeys: ["home"]
    signal navigate(string key)
    readonly property real _w: collapsed ? th.n("sidebar", "RailWidth") : th.n("sidebar", "ExpandedWidth")
    readonly property real _pad: th.t4(th.n("sidebar", "PanePadding"), 1)
    width: _w; height: _body.implicitHeight + 20
    radius: th.t4(th.design("RadiusPanel"), 0)
    color: th.c("Surface")
    border.width: th.t4(th.design("EdgeThickness"), 0); border.color: th.c("Border")
    clip: true
    Behavior on width { NumberAnimation { duration: root.th.dur("Standard"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
    Column {
        id: _body
        x: 12; y: 10; width: parent.width - 24; spacing: 8
        Item {
            width: parent.width; height: 32
            Row {
                width: parent.width; height: 32; spacing: 8
                Rectangle {
                    width: 28; height: 28; radius: 8; color: root.th.c("Foreground")
                    ArcIcon { anchors.centerIn: parent; th: root.th; kind: "PanelLeft"; width: 14; height: 14; color: root.th.c("Background") }
                }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  visible: !root.collapsed; text: "Sections"; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium"); anchors.verticalCenter: parent.verticalCenter }
                Item { width: 120; height: 1 }
                ArcIcon { th: root.th; kind: "PanelLeft"; width: 16; height: 16; color: root.th.c("TextMuted"); anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.collapsed = !root.collapsed }
        }
        Repeater {
            model: root.sections
            delegate: ArcSidebarSection {
                required property var modelData
                th: root.th; section: modelData; currentKey: root.currentKey; collapsed: root.collapsed; openKeys: root.openKeys
                width: _body.width
                onNavigate: function (k) { root.currentKey = k; root.navigate(k); }
            }
        }
    }
}
