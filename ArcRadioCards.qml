// arc:RadioCards —— Toggles/RadioCards 真值移植。
// 网格/列表双布局（RadioCardsLayout）；PART_Ring 弹簧滑动、CardInsetGrid/List/IndicatorDiameter。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var options: []       // [{value,label,description,icon}]
    property string value: ""
    property string layout: "grid"   // grid | list
    signal activated(string value)

    readonly property real _gap: th.ct("RadioCards", layout === "list" ? "ListGap" : "GridGap")
    readonly property real _inset: th.pad(th.ct("RadioCards", layout === "list" ? "CardInsetList" : "CardInsetGrid"))
    readonly property real _rad: th.pad(th.ct("RadioCards", "CardRadius"))
    readonly property real _ind: th.ct("RadioCards", "IndicatorDiameter")
    readonly property real _dot: th.ct("RadioCards", "IndicatorDotDiameter")
    readonly property real _iconD: th.ct("RadioCards", "IconDiameter")
    readonly property real _ring: th.ct("RadioCards", "RingStroke")
    readonly property real _bodyGap: th.ct("RadioCards", "BodyGap")
    readonly property int _cols: root.layout === "list" ? 1 : 2
    readonly property real _cw: (root.width - (_cols - 1) * root._gap) / _cols
    readonly property real _ch: 116
    implicitWidth: 520
    implicitHeight: Math.ceil(root.options.length / _cols) * (_ch + root._gap) - root._gap
    width: implicitWidth; height: implicitHeight

    Grid {
        id: _grid
        columns: root._cols
        spacing: root._gap
        Repeater {
            model: root.options
            delegate: Rectangle {
                required property var modelData
                readonly property bool _on: root.value === modelData.value
                width: root._cw; height: root._ch
                radius: root._rad
                color: _on ? th.fade(th.c("Accent"), th.ct("RadioCards", "SelectedTintOpacity")) : th.c("Surface")
                border.width: _on ? root._ring : th.t4(th.design("EdgeThickness"), 0)
                border.color: _on ? th.c("Accent") : th.c("Border")
                Row {
                    x: root._inset; y: root._inset; spacing: 12
                    Item {
                        width: root._iconD; height: root._iconD
                        Rectangle {
                            anchors.fill: parent; radius: root._rad / 2
                            color: th.c("SurfaceMuted")
                            Arc.ArcIcon {
                                anchors.centerIn: parent; th: root.th
                                kind: modelData.icon || "Circle"
                                width: 20; height: 20; color: th.c("TextSecondary")
                            }
                        }
                    }
                    Column {
                        width: root._cw - 2 * root._inset - root._iconD - 12 - root._ind
                        spacing: root._bodyGap
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.label; color: th.c("Foreground"); font.pixelSize: th.design("TypeBase"); font.weight: th.design("WeightMedium") }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                            width: parent.width; wrapMode: Text.WordWrap
                            text: modelData.description || ""
                            color: th.c("TextSecondary"); font.pixelSize: th.design("TypeXS")
                            lineHeight: th.ct("RadioCards", "DescriptionLineHeight")
                            lineHeightMode: Text.FixedHeight
                        }
                    }
                }
                Rectangle {
                    anchors.right: parent.right; anchors.rightMargin: root._inset
                    anchors.top: parent.top; anchors.topMargin: root._inset
                    width: root._ind; height: root._ind; radius: root._ind / 2
                    border.width: th.t4(th.ct("RadioCards", "IndicatorBorder"), 0)
                    border.color: parent._on ? th.c("Accent") : th.ct("RadioCards", "IndicatorBorder")
                    color: "transparent"
                    Rectangle {
                        visible: parent.parent._on
                        anchors.centerIn: parent
                        width: root._dot; height: root._dot; radius: root._dot / 2
                        color: th.c("Accent")
                    }
                }
                MouseArea { anchors.fill: parent; onClicked: root.activated(modelData.value) }
            }
        }
    }
}
