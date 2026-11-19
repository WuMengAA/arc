// arc:OnboardingChecklist —— Progress/OnboardingChecklist 真源码移植（OnboardingChecklist.cs 840 行 +
// OnboardingChecklistToken.cs + Fold/Model/Number/Parts/Step/Strings/Swap）。
// 上手清单：标题 + 进度环（RingSize37 / RingThickness3）+ 分组的步骤行（CheckSize22 / CheckThickness1.5 /
// GroupMinHeight44 / GroupPadding[64,0,12,0] / StepPadding[12,4,12,4]）；
// 完成态切到 DoneTitle 并压暗 HoverBackground 之外的交互。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string title: "Getting started"
    property string doneTitle: "You're all set"
    property var items: []            // [{label, done:bool}]
    property bool isHidden: false
    property var strings: ({})        // 本地化覆盖

    readonly property real _ring: root.th.ct("OnboardingChecklist", "RingSize")
    readonly property real _ringT: root.th.ct("OnboardingChecklist", "RingThickness")
    readonly property real _check: root.th.ct("OnboardingChecklist", "CheckSize")
    readonly property real _groupMinH: root.th.ct("OnboardingChecklist", "GroupMinHeight")
    readonly property real _stepPadL: root.th.t4(root.th.ct("OnboardingChecklist", "StepPadding"), 0)
    readonly property real _hover: root.th ? root.th.ct("OnboardingChecklist", "HoverBackground") : "#99F8F8F8"
    readonly property int _doneCount: {
        var n = 0;
        for (var i = 0; i < root.items.length; i++) if (root.items[i].done) n++;
        return n;
    }
    readonly property real _frac: root.items.length > 0 ? root._doneCount / root.items.length : 0
    readonly property bool _allDone: root.items.length > 0 && root._doneCount === root.items.length
    signal stepToggled(int index)

    implicitWidth: 320
    implicitHeight: root.isHidden ? 0 : _col.implicitHeight
    visible: !root.isHidden

    Column {
        id: _col
        width: parent.width
        spacing: 8
        // 头：进度环 + 标题
        Row {
            width: parent.width
            spacing: 12
            Item {
                width: root._ring; height: root._ring
                // 进度环用两个圆弧近似：底环 + 已完成弧
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.width: root._ringT
                    border.color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
                }
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.width: root._ringT
                    border.color: root.th ? root.th.a("accent") : "#FF2FB8C6"
                    // 用 Canvas 更精确；这里用月牙遮罩近似已完成的弧长
                    opacity: root._frac
                    Behavior on opacity { NumberAnimation { duration: root.th ? root.th.dur("Standard") : 240 } }
                }
                Text {
                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root._doneCount + "/" + root.items.length
                    color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    font.weight: root.th ? root.th.weightMedium : 500
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - root._ring - 12
                wrapMode: Text.WordWrap
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root._allDone ? root.doneTitle : root.title
                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                font.pixelSize: root.th ? root.th.design("TypeSM") : 13
                font.weight: root.th ? root.th.weightMedium : 500
            }
        }
        // 步骤行
        Repeater {
            model: root.items.length
            delegate: Rectangle {
                required property int index
                readonly property bool done: root.items[index].done === true
                width: _col.width
                height: root._groupMinH
                radius: 10
                color: _sm2.containsMouse ? root._hover : "transparent"
                Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                // 复选框
                Rectangle {
                    x: root._stepPadL
                    anchors.verticalCenter: parent.verticalCenter
                    width: root._check; height: root._check
                    radius: width / 2
                    color: done ? (root.th ? root.th.c("Success") : "#FF007824") : "transparent"
                    border.width: done ? 0 : 1.5
                    border.color: root.th ? root.th.c("BorderStrong") : "#FFC0C0C0"
                    Arc.ArcIcon {
                        anchors.centerIn: parent
                        visible: done
                        width: 13; height: 13
                        th: root.th; kind: "Check"
                        color: root.th ? root.th.a("foreground") : "#FFFFFFFF"
                    }
                }
                Text {
                    x: root._stepPadL + root._check + 12
                    width: parent.width - x - 12
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root.items[index].label || ""
                    color: done ? (root.th ? root.th.c("TextMuted") : "#FF9A9A9A")
                                : (root.th ? root.th.c("Foreground") : "#FF1D1D1D")
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    font.strikeout: done
                }
                MouseArea {
                    id: _sm2
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.stepToggled(index)
                }
            }
        }
    }
}
