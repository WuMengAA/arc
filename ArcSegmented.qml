// arc:SegmentedControl —— SegmentedControlTheme：轨道内缩 3、选项间隙 2、圆角 14、选中块圆角 12。
// options: [{value,label}, ...]
import QtQuick 2.15

Item {
    id: root

    property var th: null
    property var options: []
    property string value: ""
    signal activated(string value)

    readonly property real _trackInset: th.pad(th.n("segmented","TrackInset"))
    readonly property real _gap: th.n("segmented","SegmentGap")
    readonly property real _segH: 30

    implicitHeight: _segH + 2 * _trackInset
    implicitWidth: _row.implicitWidth + 2 * _trackInset

    Rectangle {
        anchors.fill: parent
        radius: root.th.pad(root.th.n("segmented","SegmentRadius"))
        color: root.th.c("SurfaceMuted")
    }

    Row {
        id: _row
        anchors.centerIn: parent
        spacing: root._gap

        Repeater {
            model: root.options
            delegate: Rectangle {
                required property var modelData
                readonly property bool _on: root.value === modelData.value
                width: _lbl.implicitWidth + 2 * 14
                height: root._segH
                radius: root.th.pad(root.th.n("segmented","SelectionRadius"))
                color: _on ? root.th.c("Surface") : "transparent"
                border.width: _on ? root.th.design("EdgeThickness") : 0
                border.color: root.th.c("Border")
                Behavior on color { ColorAnimation { duration: th.dur("Instant") } }

                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    id: _lbl
                    anchors.centerIn: parent
                    text: modelData.label
                    color: parent._on ? root.th.c("Foreground") : root.th.c("TextSecondary")
                    font.pixelSize: root.th.design("TypeSM")
                    font.weight: parent._on ? root.th.design("WeightMedium") : root.th.design("WeightRegular")
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activated(modelData.value)
                }
            }
        }
    }
}
