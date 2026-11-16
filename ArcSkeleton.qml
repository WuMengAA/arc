// Progress/Skeleton —— SkeletonToken: BlockColor #FFE8E8E8 / BlockRadius 18 / ContentRise 4；
// SkeletonBlocks.cs 真几何：Lines 1..6 / FirstLineHeight 16 / LineHeight 12 / LineGap 12 /
// AvatarGap 16 / PulsePeriod 1.8s / PulseLow 0.52 / PulseStagger 0.09。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property int lines: 3
    property bool avatar: false
    property real avatarDiameter: 48
    property bool loading: true

    implicitWidth: 320
    implicitHeight: _row.implicitHeight

    readonly property int _n: Math.max(1, Math.min(6, lines))
    readonly property real _r: th.ct("Skeleton", "BlockRadius")
    readonly property color _fill: th.ct("Skeleton", "BlockColor")

    Row {
        id: _row
        spacing: 16
        Rectangle {
            visible: root.avatar
            width: root.avatarDiameter; height: root.avatarDiameter
            radius: width / 2
            color: root._fill
            SequentialAnimation on opacity {
                running: root.loading; loops: Animation.Infinite
                NumberAnimation { from: 1; to: 0.52; duration: th.pulseHalf() }
                NumberAnimation { from: 0.52; to: 1; duration: th.pulseHalf() }
            }
        }
        Column {
            width: Math.max(60, root.width - (root.avatar ? root.avatarDiameter + 16 : 0))
            spacing: 12
            Repeater {
                model: root._n
                delegate: Rectangle {
                    required property int index
                    width: index === 0 ? parent.width : parent.width * (index % 2 === 0 ? 0.72 : 0.9)
                    height: index === 0 ? 16 : 12
                    radius: Math.min(root._r, height / 2)
                    color: root._fill
                    SequentialAnimation on opacity {
                        running: root.loading; loops: Animation.Infinite
                        NumberAnimation { from: 1; to: 0.52; duration: th.pulseHalf() }
                        NumberAnimation { from: 0.52; to: 1; duration: th.pulseHalf() }
                    }
                }
            }
        }
    }
}
