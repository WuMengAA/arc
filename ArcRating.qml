// Toggles/Rating —— RatingToken: CellSize MD36/SM28/LG44 / GlyphSize 24/18/30 /
// CellGap 2 / CellRadius 12 / KeptOpacity 0.3 / FillBrush Warning / EmptyBrush BorderStrong。
// 部分填充照抄 RatingStars.cs: Portion(value,index) => Math.Clamp(value-index,0,1)。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string label: ""
    property string description: ""
    property real value: 0         // 0..max，支持小数
    property int max: 5
    property string size: "md"     // sm | md | lg
    property bool showValue: true
    property real hoverValue: -1
    signal rated(real value)

    implicitWidth: _col.implicitWidth
    implicitHeight: _col.implicitHeight

    readonly property real _cell: size === "sm" ? th.ct("Rating", "CellSizeSM")
                                : (size === "lg" ? th.ct("Rating", "CellSizeLG") : th.ct("Rating", "CellSizeMD"))
    readonly property real _glyph: size === "sm" ? th.ct("Rating", "GlyphSizeSM")
                                 : (size === "lg" ? th.ct("Rating", "GlyphSizeLG") : th.ct("Rating", "GlyphSizeMD"))
    readonly property real _gap: th.ct("Rating", "CellGap")
    readonly property real _fieldGap: th.ct("Rating", "FieldGap")
    readonly property real _shown: hoverValue >= 0 ? hoverValue : value

    function portion(i) { return Math.max(0, Math.min(1, _shown - i)); }

    Column {
        id: _col
        spacing: root._fieldGap
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            visible: root.label !== ""
            text: root.label
            color: root.th.c("Foreground")
            font.pixelSize: root.th.design("TypeSM")
            font.weight: root.th.weightMedium
        }
        Row {
            id: _stars
            spacing: root._gap
            Repeater {
                model: root.max
                delegate: Rectangle {
                    required property int index
                    width: root._cell; height: root._cell
                    radius: root.th.t4(root.th.ct("Rating", "CellRadius"), 0)
                    color: "transparent"
                    // 底层空星
                    Arc.ArcIcon {
                        anchors.centerIn: parent
                        width: root._glyph; height: root._glyph
                        th: root.th; kind: "Star"; filled: false
                        color: root.th.c("BorderStrong")
                    }
                    // 上层填充星（按 portion 裁剪）
                    Item {
                        anchors.centerIn: parent
                        width: root._glyph * root.portion(index)
                        height: root._glyph
                        clip: true
                        Arc.ArcIcon {
                            x: 0; y: 0
                            width: root._glyph; height: root._glyph
                            th: root.th; kind: "Star"; filled: true
                            color: root.th.c("Warning")
                        }
                    }
                }
            }
        }
        Row {
            visible: root.showValue || root.description !== ""
            spacing: root.th.ct("Rating", "ValueGap")
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                visible: root.showValue
                text: root.value > 0 ? root.value.toFixed(1) + " / " + root.max : "Not rated"
                color: root.value > 0 ? root.th.c("TextSecondary") : root.th.c("TextMuted")
                font.pixelSize: root.th.design("TypeSM")
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                visible: root.description !== ""
                text: root.description
                color: root.th.c("TextMuted")
                font.pixelSize: root.th.design("TypeXS")
            }
        }
    }

    MouseArea {
        anchors.fill: _col
        hoverEnabled: true
        preventStealing: true   // 划过星级不滚页面
        onPositionChanged: function (mouse) {
            var row = _stars;
            root.hoverValue = Math.max(1, Math.min(root.max,
                Math.ceil((mouse.x - row.x) / (root._cell + root._gap))));
        }
        onExited: root.hoverValue = -1
        onClicked: function (mouse) {
            var row = _stars;
            var v = Math.max(1, Math.min(root.max,
                Math.ceil((mouse.x - row.x) / (root._cell + root._gap))));
            root.value = v; root.rated(v);
        }
    }
}
