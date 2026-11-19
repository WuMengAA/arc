// arc:FluidTabControl —— Navigation/FluidTabControl 真源码移植（FluidTabControl.cs + FluidTabControlToken.cs +
// FluidTabItem/FluidTabListPanel）。
// 侧列式页签：左侧 tab 列（TabListWidth200 / TabListPadding[8,8,8,8] / ItemSpacing2），
// 选中态是滑动的高亮块（HighlightRadius12），左侧指示条 IndicatorThickness3 / IndicatorInset9 / IndicatorRadius1.5；
// 右侧内容区 ContentPadding[24,24,24,24]；切换用 ScrollDuration480ms。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var tabs: []             // [{label, icon?}]
    property int currentIndex: 0
    property var content: []          // [Component]
    property real tabListWidth: 0

    readonly property real _w: root.tabListWidth > 0 ? root.tabListWidth : root.th.ct("FluidTabControl", "TabListWidth")
    readonly property real _pad: root.th.pad(root.th.ct("FluidTabControl", "TabListPadding"))
    readonly property real _spacing: root.th.ct("FluidTabControl", "ItemSpacing")
    readonly property real _hlRad: root.th.pad(root.th.ct("FluidTabControl", "HighlightRadius"))
    readonly property real _indT: root.th.ct("FluidTabControl", "IndicatorThickness")
    readonly property real _indInset: root.th.ct("FluidTabControl", "IndicatorInset")
    readonly property real _contentPad: root.th.pad(root.th.ct("FluidTabControl", "ContentPadding"))
    readonly property real _itemH: 40
    implicitWidth: root._w + root._contentPad * 2 + 320
    implicitHeight: Math.max(_col.implicitHeight, _host.implicitHeight) + 2 * root._contentPad

    // 左列
    Column {
        id: _col
        x: root._pad
        y: root._pad
        width: root._w - 2 * root._pad
        spacing: root._spacing
        // 滑动高亮块
        Rectangle {
            width: parent.width
            height: root._itemH
            radius: root._hlRad
            color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
            y: root.currentIndex * (root._itemH + root._spacing)
            Behavior on y { NumberAnimation { duration: 480
                easing.type: Easing.Bezier; easing.bezierCurve: root.th ? root.th.ease("Standard") : [0.22, 1, 0.36, 1, 1, 1] } }
        }
        Repeater {
            model: root.tabs.length
            delegate: Item {
                required property int index
                readonly property bool cur: index === root.currentIndex
                width: parent.width
                height: root._itemH
                Text {
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root.tabs[index].label || ""
                    color: cur ? (root.th ? root.th.c("Foreground") : "#FF1D1D1D")
                               : (root.th ? root.th.c("TextSecondary") : "#FF6D6D6D")
                    font.pixelSize: root.th ? root.th.design("TypeSM") : 13
                    font.weight: cur ? (root.th ? root.th.weightMedium : 500) : (root.th ? root.th.weightRegular : 400)
                }
                // 左侧指示条
                Rectangle {
                    visible: cur
                    x: -root._indInset + 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: root._indT
                    height: parent.height - 14
                    radius: root._indT / 2
                    color: root.th ? root.th.a("accent") : "#FF2FB8C6"
                }
                MouseArea { anchors.fill: parent; onClicked: root.currentIndex = index }
            }
        }
    }
    // 右内容
    Item {
        id: _host
        x: root._w + root._contentPad
        y: root._contentPad
        width: parent.width - x - root._contentPad
        height: parent.height - 2 * root._contentPad
        Loader {
            anchors.fill: parent
            sourceComponent: (root.content.length > 0 && root.currentIndex < root.content.length)
                             ? root.content[root.currentIndex] : null
        }
    }
}
