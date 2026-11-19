// arc:TransferBox —— Selects/TransferBox 真源码移植（TransferBox.cs 755 行 + TransferBoxToken.cs + TransferBoxList/
// TransferBoxTypes/TransferBoxView）。
// 穿梭框：左右两个列表（PanelMinWidth180 / DefaultHeight320 / ListPadding[6,6,6,6]），中间是移动按钮
// （MoveButtonExtent36 / ActionsGap8 / ActionsMargin[12,0,12,0]）；行高 RowMinHeight36 / RowPadding[12,6,10,6] / 复选框 16。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var source: []           // [string]
    property var target: []
    property string sourceTitle: "Available"
    property string targetTitle: "Selected"
    property real boxHeight: 0

    readonly property real _minW: root.th.ct("TransferBox", "PanelMinWidth")
    readonly property real _h: root.boxHeight > 0 ? root.boxHeight : root.th.ct("TransferBox", "DefaultHeight")
    readonly property real _rowH: root.th.ct("TransferBox", "RowMinHeight")
    readonly property real _btn: root.th.ct("TransferBox", "MoveButtonExtent")
    readonly property real _gap: root.th.ct("TransferBox", "ActionsGap")
    readonly property real _listPad: root.th.pad(root.th.ct("TransferBox", "ListPadding"))
    readonly property real _hdrH: root.th.ct("TransferBox", "HeaderMinHeight")
    property var pickedLeft: ({})
    property var pickedRight: ({})
    implicitWidth: Math.max(root._minW * 2 + root._btn + 2 * root._gap, 420)
    implicitHeight: root._h
    function key(i, side) { return side + ":" + i; }
    function _picked(map) { var n = 0; for (var k in map) if (map[k]) n++; return n; }
    function moveRight() {
        var src = root.source.slice(), tgt = root.target.slice(), out = [];
        for (var i = 0; i < src.length; i++) {
            if (root.pickedLeft[root.key(i, "L")]) tgt.push(src[i]); else out.push(src[i]);
        }
        root.source = out; root.target = tgt; root.pickedLeft = ({}); 
    }
    function moveLeft() {
        var src = root.target.slice(), tgt = root.source.slice(), out = [];
        for (var i = 0; i < src.length; i++) {
            if (root.pickedRight[root.key(i, "R")]) tgt.push(src[i]); else out.push(src[i]);
        }
        root.target = out; root.source = tgt; root.pickedRight = ({}); 
    }
    function _toggle(map, k) { var m = {}; for (var kk in map) m[kk] = map[kk]; m[k] = !m[k]; return m; }
    // 左列
    Rectangle {
        width: (parent.width - root._btn - 2 * root._gap) / 2
        height: parent.height
        radius: 14
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        Text {
            x: 14; y: 12
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.sourceTitle + " (" + root.source.length + ")"
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightMedium : 500
        }
        ListView {
            x: root._listPad
            y: root._hdrH
            width: parent.width - 2 * root._listPad
            height: parent.height - root._hdrH - root._listPad
            clip: true
            model: root.source
            delegate: Rectangle {
                required property int index
                required property string modelData
                width: parent.width
                height: root._rowH
                radius: 8
                color: root.pickedLeft[root.key(index, "L")] ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                Rectangle {
                    x: 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16; height: 16; radius: 4
                    color: root.pickedLeft[root.key(index, "L")] ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : "transparent"
                    border.width: 1.5
                    border.color: root.pickedLeft[root.key(index, "L")] ? (root.th ? root.th.a("accent") : "#FF2FB8C6")
                                                                      : (root.th ? root.th.c("BorderStrong") : "#FFC0C0C0")
                }
                Text {
                    x: 34
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 42
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: modelData
                    color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
                MouseArea { anchors.fill: parent; onClicked: root.pickedLeft = root._toggle(root.pickedLeft, root.key(index, "L")) }
            }
        }
    }
    // 中间按钮
    Column {
        x: (parent.width - root._btn) / 2
        anchors.verticalCenter: parent.verticalCenter
        spacing: root._gap
        Repeater {
            model: 2
            delegate: Rectangle {
                required property int index
                width: root._btn; height: root._btn
                radius: 10
                color: _bm.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                border.width: 1
                border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
                Arc.ArcIcon {
                    anchors.centerIn: parent
                    width: 16; height: 16
                    th: root.th
                    kind: index === 0 ? "ChevronRight" : "ChevronLeft"
                    color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                }
                MouseArea {
                    id: _bm
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: index === 0 ? root.moveRight() : root.moveLeft()
                }
            }
        }
    }
    // 右列
    Rectangle {
        x: parent.width - width
        width: (parent.width - root._btn - 2 * root._gap) / 2
        height: parent.height
        radius: 14
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        Text {
            x: 14; y: 12
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.targetTitle + " (" + root.target.length + ")"
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightMedium : 500
        }
        ListView {
            x: root._listPad
            y: root._hdrH
            width: parent.width - 2 * root._listPad
            height: parent.height - root._hdrH - root._listPad
            clip: true
            model: root.target
            delegate: Rectangle {
                required property int index
                required property string modelData
                width: parent.width
                height: root._rowH
                radius: 8
                color: root.pickedRight[root.key(index, "R")] ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                Rectangle {
                    x: 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16; height: 16; radius: 4
                    color: root.pickedRight[root.key(index, "R")] ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : "transparent"
                    border.width: 1.5
                    border.color: root.pickedRight[root.key(index, "R")] ? (root.th ? root.th.a("accent") : "#FF2FB8C6")
                                                                       : (root.th ? root.th.c("BorderStrong") : "#FFC0C0C0")
                }
                Text {
                    x: 34
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 42
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: modelData
                    color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
                MouseArea { anchors.fill: parent; onClicked: root.pickedRight = root._toggle(root.pickedRight, root.key(index, "R")) }
            }
        }
    }
}
