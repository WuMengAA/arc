// arc:OnScreenKeyboard —— SpecialInputs/OnScreenKeyboard 真源码移植（OnScreenKeyboard.cs 841 行 + OnScreenKeyboardToken.cs
// + KeyPresenter/Layout/Panel/Types）。
// 软键盘：tray（TrayBackground / TrayPadding[8,8,8,8]）里排键，KeyHeight46 / KeyUnitWidth52 / KeyGap6 / RowGap8；
// 键有底边 KeyLip(KeyLipThickness2)，按下 KeyPressedBackground、悬停 KeyHoverBackground；功能键 FunctionKeyBackground。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property bool shift: false
    property bool enabledState: true
    signal keyPressed(string key)

    readonly property real _keyH: root.th.ct("OnScreenKeyboard", "KeyHeight")
    readonly property real _unit: root.th.ct("OnScreenKeyboard", "KeyUnitWidth")
    readonly property real _gap: root.th.ct("OnScreenKeyboard", "KeyGap")
    readonly property real _rowGap: root.th.ct("OnScreenKeyboard", "RowGap")
    readonly property real _pad: root.th.pad(root.th.ct("OnScreenKeyboard", "TrayPadding"))
    readonly property real _lip: root.th.ct("OnScreenKeyboard", "KeyLipThickness")
    readonly property var _rows: [
        ["q","w","e","r","t","y","u","i","o","p"],
        ["a","s","d","f","g","h","j","k","l"],
        ["z","x","c","v","b","n","m"],
        ["123","space","return"]
    ]
    // 每行宽度按「最宽行」= 10 个键
    readonly property real _rowW: 10 * root._unit + 9 * root._gap
    implicitWidth: root._rowW + 2 * root._pad
    implicitHeight: 4 * root._keyH + 3 * root._rowGap + 2 * root._pad
    opacity: root.enabledState ? 1 : root.th.ct("OnScreenKeyboard", "DisabledOpacity")

    Rectangle {
        anchors.fill: parent
        color: root.th ? root.th.ct("OnScreenKeyboard", "TrayBackground") : "#FFF0F0F0"
    }
    Column {
        x: root._pad
        y: root._pad
        spacing: root._rowGap
        Repeater {
            model: root._rows.length
            delegate: Row {
                required property int index
                spacing: root._gap
                Repeater {
                    model: root._rows[index]
                    delegate: Item {
                        required property string modelData
                        readonly property bool fn: modelData.length > 1
                        readonly property real w: modelData === "space" ? root._unit * 5 + root._gap * 4
                                             : (modelData === "return" ? root._unit * 2 + root._gap : root._unit)
                        width: w
                        height: root._keyH
                        Rectangle {
                            anchors.fill: parent
                            anchors.bottomMargin: root._lip
                            radius: 8
                            color: _km.pressed ? (root.th ? root.th.ct("OnScreenKeyboard", "KeyPressedBackground") : "#FFDEDEDE")
                                 : (fn ? (root.th ? root.th.ct("OnScreenKeyboard", "FunctionKeyBackground") : "#FFE1E1E1")
                                       : (root.th ? root.th.ct("OnScreenKeyboard", "KeyBackground") : "#FFFFFFFF"))
                            border.width: fn ? 0 : 1
                            border.color: root.th ? root.th.ct("OnScreenKeyboard", "KeyEdge") : "#FFE9E9E9"
                            Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Instant") : 120 } }
                            Text {
                                anchors.centerIn: parent
                                renderType: Text.NativeRendering
                                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                                text: root.shift && !fn ? String(modelData).toUpperCase() : modelData
                                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                                font.pixelSize: root.th ? root.th.design("TypeSM") : 13
                            }
                        }
                        // 键帽底边
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: root._lip
                            radius: root._lip / 2
                            color: root.th ? root.th.ct("OnScreenKeyboard", "KeyLip") : "#FFC4C4C4"
                        }
                        MouseArea {
                            id: _km
                            anchors.fill: parent
                            onClicked: {
                                if (modelData === "space") root.keyPressed(" ");
                                else if (modelData === "return") root.keyPressed("\n");
                                else root.keyPressed(root.shift ? String(modelData).toUpperCase() : modelData);
                            }
                        }
                    }
                }
            }
        }
    }
}
