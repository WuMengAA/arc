// arc:MorphSelect —— Selects/MorphSelect 真源码移植（MorphSelect.cs 1417 行 + MorphSelectToken.cs + MorphSelectAnchor/
// MorphSelectSurface）。
// 变形选择器：收起时是一颗药丸（ShapeCornerRadius22 / TriggerPadding[14,0,36,0] / TriggerMaxWidth320），
// 展开时在同一位姿上「变形」成菜单面：控制底色 ControlFillColor、悬停 HighlightColor；
// ChevronMargin[0,0,12,0]。QML 侧用高度/圆角/透明度三轴同步过渡实现「同一控件变形」而不是弹窗。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var options: []         // [{value,label,icon?}]
    property string value: ""
    property bool open: false
    property string placeholder: "Select"
    signal activated(string value)

    readonly property real _rad: root.th.pad(root.th.ct("MorphSelect", "ShapeCornerRadius"))
    readonly property real _padL: root.th.t4(root.th.ct("MorphSelect", "TriggerPadding"), 0)
    readonly property real _padR: root.th.t4(root.th.ct("MorphSelect", "TriggerPadding"), 2)
    readonly property real _maxW: root.th.ct("MorphSelect", "TriggerMaxWidth")
    readonly property color _fill: root.th ? root.th.ct("MorphSelect", "ControlFillColor") : "#140B0B0B"
    readonly property color _hi: root.th ? root.th.ct("MorphSelect", "HighlightColor") : "#110B0B0B"
    readonly property real _chevM: root.th.t4(root.th.ct("MorphSelect", "ChevronMargin"), 2)
    readonly property string _label: {
        for (var i = 0; i < root.options.length; i++) if (root.options[i].value === root.value) return root.options[i].label;
        return root.value !== "" ? root.value : root.placeholder;
    }
    readonly property real _rowH: 38
    implicitWidth: Math.min(root._maxW, Math.max(160, _cur.implicitWidth + root._padL + root._padR + 8))
    implicitHeight: root._rowH + (root.open ? Math.min(6, root.options.length) * root._rowH + 8 : 0)
    Behavior on implicitHeight { NumberAnimation { duration: root.th ? root.th.dur("Standard") : 240
        easing.type: Easing.Bezier; easing.bezierCurve: root.th ? root.th.ease("Standard") : [0.22, 1, 0.36, 1, 1, 1] } }
    Behavior on implicitWidth { NumberAnimation { duration: root.th ? root.th.dur("Standard") : 240 } }

    Rectangle {
        anchors.fill: parent
        // 收起是圆角药丸、展开是菜单面（同一控件变形）
        radius: root.open ? 18 : root._rad
        color: root.open ? (root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF") : root._fill
        border.width: 1
        border.color: root.open ? (root.th ? root.th.c("Border") : "#FFE0E0E0") : "transparent"
        Behavior on radius { NumberAnimation { duration: root.th ? root.th.dur("Standard") : 240 } }
        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Standard") : 240 } }
    }
    // 当前值行
    Item {
        id: _head
        width: parent.width
        height: root._rowH
        Text {
            id: _cur
            x: root._padL
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - root._padL - root._padR - 8
            elide: Text.ElideRight
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root._label
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            font.pixelSize: root.th ? root.th.design("TypeSM") : 13
            font.weight: root.th ? root.th.weightMedium : 500
        }
        Arc.ArcIcon {
            anchors.right: parent.right
            anchors.rightMargin: root._chevM
            anchors.verticalCenter: parent.verticalCenter
            width: 14; height: 14
            th: root.th; kind: "ChevronDown"
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            rotation: root.open ? 180 : 0
            Behavior on rotation { NumberAnimation { duration: root.th ? root.th.dur("Standard") : 240 } }
        }
        MouseArea { anchors.fill: parent; onClicked: root.open = !root.open }
    }
    // 选项（在同一个面上往下长出来）
    Column {
        visible: root.open
        y: root._rowH + 4
        x: 4
        width: parent.width - 8
        Repeater {
            model: Math.min(6, root.options.length)
            delegate: Rectangle {
                required property int index
                width: parent.width
                height: root._rowH
                radius: 12
                color: _om.containsMouse ? root._hi : "transparent"
                Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 12
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root.options[index].label || ""
                    color: root.options[index].value === root.value
                           ? (root.th ? root.th.c("Foreground") : "#FF1D1D1D")
                           : (root.th ? root.th.c("TextSecondary") : "#FF6D6D6D")
                    font.pixelSize: root.th ? root.th.design("TypeSM") : 13
                    font.weight: (root.options[index].value === root.value && root.th) ? root.th.weightMedium : 400
                }
                MouseArea {
                    id: _om
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.value = root.options[index].value;
                        root.open = false;
                        root.activated(root.value);
                    }
                }
            }
        }
    }
}
