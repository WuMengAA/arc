// arc:Progress —— Progress/Progress/ProgressTheme.axaml + ProgressToken.cs 真值移植。
// Meta 行（label/count）+ 7px 轨道；Track=SurfaceMuted+Border / Fill=Accent / Complete=Success。
import QtQuick 2.15

Item {
    id: root

    property var th: null
    property string label: ""
    property int percentage: 0        // 0..100（DirectProperty Percentage）
    property bool isValueVisible: true

    readonly property bool _complete: percentage >= 100
    readonly property real _trackH: th.ct("Progress", "TrackHeight")
    readonly property color _fill: _complete ? th.c("Success") : th.a("accent")
    readonly property real _metaGap: th.t4(th.ct("Progress", "MetaMargin"), 3)
    readonly property real _readoutGap: th.t4(th.ct("Progress", "ReadoutMargin"), 0)

    width: implicitWidth
    height: implicitHeight
    implicitWidth: 240
    implicitHeight: _col.implicitHeight

    Column {
        id: _col
        width: root.width
        spacing: root._metaGap

        // PART_Meta：label TextSecondary / readout TextMuted，MetaLineHeight 19.6
        Item {
            visible: root.label !== "" || root.isValueVisible
            width: parent.width
            height: visible ? root.th.ct("Progress", "MetaLineHeight") : 0
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.label
                color: root.th.c("TextSecondary")
                font.pixelSize: root.th.design("TypeSM")
                font.weight: root.th.design("WeightRegular")
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                visible: root.isValueVisible
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: root._complete ? "Complete" : (root.percentage + "%")
                color: root.th.c("TextMuted")
                font.pixelSize: root.th.design("TypeSM")
            }
        }

        // PART_Track：7px 含 1px 边框，填充宽度按 percentage
        Rectangle {
            width: parent.width
            height: root._trackH
            radius: root._trackH / 2
            color: root.th.c("SurfaceMuted")
            border.width: root.th.t4(root.th.design("EdgeThickness"), 0)
            border.color: root.th.c("Border")
            clip: true
            Rectangle {
                width: parent.width * Math.max(0, Math.min(100, root.percentage)) / 100
                height: parent.height
                radius: parent.radius
                color: root._fill
                Behavior on width { NumberAnimation { duration: th.dur("Standard"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }
                Behavior on color { ColorAnimation { duration: th.dur("Standard") } }
            }
        }
    }
}
