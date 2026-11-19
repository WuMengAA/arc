// arc:ToastStack —— Messages/ToastStack 真源码移植（ToastStack.cs 747 行 + ToastStackToken.cs + ToastHost/ToastStackItem/
// ToastStackPanel/ToastStackTypes）。
// 通知栈：右下角堆叠，最大宽 MaxListWidth360；每条 ContentPadding[16,12,12,12]，
// 图标槽 IconSlotWidth18 / IconSlotHeight20 / IconMargin[0,0,12,0]；关闭 CloseDiameter28 / CloseMargin[12,-4,-2,0]；
// 动作按钮 ActionHeight28 / ActionPadding[12,0,12,0] / ActionMargin[12,0,0,0]。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var toasts: []           // [{title, body?, tone?, actions?:[string]}]
    property int maxVisible: 4
    signal dismissed(int index)
    signal actionTriggered(int index, string action)

    readonly property real _maxW: root.th.ct("ToastStack", "MaxListWidth")
    readonly property real _close: root.th.ct("ToastStack", "CloseDiameter")
    readonly property real _iconW: root.th.ct("ToastStack", "IconSlotWidth")
    readonly property real _iconH: root.th.ct("ToastStack", "IconSlotHeight")
    readonly property real _iconM: root.th.t4(root.th.ct("ToastStack", "IconMargin"), 2)
    readonly property real _contentPadL: root.th.t4(root.th.ct("ToastStack", "ContentPadding"), 0)
    readonly property real _contentPadT: root.th.t4(root.th.ct("ToastStack", "ContentPadding"), 1)
    readonly property real _actionH: root.th.ct("ToastStack", "ActionHeight")
    readonly property real _actionM: root.th.t4(root.th.ct("ToastStack", "ActionMargin"), 0)
    implicitWidth: root._maxW
    implicitHeight: _col.implicitHeight
    width: root._maxW
    height: _col.implicitHeight

    function _tone(c) {
        if (c === "success") return root.th ? root.th.c("Success") : "#FF007824";
        if (c === "danger") return root.th ? root.th.c("Danger") : "#FFCD1526";
        if (c === "warning") return root.th ? root.th.c("Warning") : "#FFB08000";
        return root.th ? root.th.a("accent") : "#FF2FB8C6";
    }
    function _glyph(c) {
        if (c === "success") return "Check";
        if (c === "danger") return "TriangleAlert";
        if (c === "warning") return "TriangleAlert";
        return "Info";
    }
    Column {
        id: _col
        width: root.width
        spacing: 8
        Repeater {
            model: Math.min(root.maxVisible, root.toasts.length)
            delegate: Rectangle {
                required property int index
                width: _col.width
                height: _body.implicitHeight + _contentPadT + 12
                radius: 16
                color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
                border.width: 1
                border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
                // 图标
                Arc.ArcIcon {
                    x: root._contentPadL
                    y: root._contentPadT + 2
                    width: root._iconW; height: root._iconH
                    th: root.th
                    kind: root._glyph(root.toasts[index].tone)
                    color: root._tone(root.toasts[index].tone)
                }
                // 文案
                Column {
                    id: _body
                    x: root._contentPadL + root._iconW + root._iconM
                    y: root._contentPadT
                    width: parent.width - x - root._close - 20
                    spacing: 2
                    Text {
                        width: parent.width
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: root.toasts[index].title || ""
                        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                        font.weight: root.th ? root.th.weightMedium : 500
                    }
                    Text {
                        width: parent.width
                        visible: (root.toasts[index].body || "") !== ""
                        wrapMode: Text.WordWrap
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: root.toasts[index].body || ""
                        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                        lineHeight: root.th.ct("ToastStack", "CopyLineHeight")
                        lineHeightMode: Text.FixedHeight
                    }
                    // 动作
                    Row {
                        visible: root.toasts[index].actions !== undefined
                        spacing: 4
                        Repeater {
                            // actions 是数组：模型直接给元素，delegate 用 modelData 拿标签（不声明 index2，避免遮蔽外层 index）
                            model: root.toasts[index].actions !== undefined ? root.toasts[index].actions : []
                            delegate: Rectangle {
                                required property var modelData
                                width: _ax.implicitWidth + 24
                                height: root._actionH
                                radius: height / 2
                                color: _axm.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                                Text {
                                    id: _ax
                                    anchors.centerIn: parent
                                    renderType: Text.NativeRendering
                                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                                    text: String(modelData)
                                    color: root.th ? root.th.a("accent") : "#FF2FB8C6"
                                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                                    font.weight: root.th ? root.th.weightMedium : 500
                                }
                                MouseArea {
                                    id: _axm
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: root.actionTriggered(index, String(modelData))
                                }
                            }
                        }
                    }
                }
                // 关闭
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.top: parent.top
                    anchors.topMargin: 6
                    width: root._close; height: root._close
                    radius: width / 2
                    color: _cx.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                    Arc.ArcIcon {
                        anchors.centerIn: parent
                        width: 14; height: 14
                        th: root.th; kind: "X"
                        color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                    }
                    MouseArea { id: _cx; anchors.fill: parent; hoverEnabled: true; onClicked: root.dismissed(index) }
                }
            }
        }
    }
}
