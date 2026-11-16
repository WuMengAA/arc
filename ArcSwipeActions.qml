// arc:SwipeActions —— Gestures/SwipeActions + SwipeActionsRow 真值移植。
// 行内容随 drag 左移露出右侧 action；ActionExtent/BodyInset/MoreRadius 走令牌。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string title: "Invoice #1042"
    property string subtitle: "Due Nov 30"
    property var actions: []        // [{label, icon, tone}]
    signal actionTriggered(int index)

    readonly property real _ext: th.ct("SwipeActionsRow", "ActionExtent")
    readonly property real _glyph: th.ct("SwipeActionsRow", "ActionGlyphExtent")
    readonly property real _bodyIn: th.t4(th.ct("SwipeActionsRow", "BodyInset"), 0)
    readonly property real _rowH: th.ct("SwipeActionsRow", "MinRowHeight")
    readonly property real _more: th.ct("SwipeActionsRow", "MoreExtent")
    readonly property real _rad: th.pad(th.ct("SwipeActionsRow", "MoreRadius"))
    readonly property real _max: root.actions.length * root._ext
    property real reveal: 0          // 0..1
    implicitWidth: 460; implicitHeight: _rowH
    width: implicitWidth; height: implicitHeight

    Rectangle {
        anchors.fill: parent
        color: th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        clip: true
        Row {
            anchors.right: parent.right
            height: parent.height
            Repeater {
                model: root.actions
                delegate: Rectangle {
                    required property int index
                    required property var modelData
                    width: root._ext; height: root._rowH
                    color: modelData.tone === "danger" ? th.c("Danger")
                         : modelData.tone === "neutral" ? th.ct("SwipeActionsRow", "NeutralActionColor") : th.c("Accent")
                    Column {
                        anchors.centerIn: parent; spacing: 2
                        Arc.ArcIcon { anchors.horizontalCenter: parent.horizontalCenter; th: root.th; kind: modelData.icon || "Circle"; width: root._glyph; height: root._glyph; color: "#FFFFFFFF" }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.label; color: "#FFFFFFFF"; font.pixelSize: th.design("TypeXS") }
                    }
                    MouseArea { anchors.fill: parent; onClicked: root.actionTriggered(index) }
                }
            }
        }
        Rectangle {
            id: _body
            x: -root.reveal * root._max
            width: parent.width; height: parent.height
            color: th.c("Surface")
            Row {
                x: root._bodyIn; anchors.verticalCenter: parent.verticalCenter
                spacing: 12
                Arc.ArcIcon { anchors.verticalCenter: parent.verticalCenter; th: root.th; kind: "FileText"; width: 20; height: 20; color: th.c("TextSecondary") }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.title; color: th.c("Foreground"); font.pixelSize: th.design("TypeSM") }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.subtitle; color: th.c("TextMuted"); font.pixelSize: th.design("TypeXS") }
                }
            }
            Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: th.c("Border") }
            MouseArea {
                id: _drag; anchors.fill: parent
                preventStealing: true   // 横向滑动不滚页面
                property real startX: 0
                onPressed: startX = mouseX
                onPositionChanged: {
                    var dx = startX - mouseX;
                    root.reveal = Math.max(0, Math.min(1, dx / root._max));
                }
                onReleased: { if (root.reveal < 0.5) _snapBack.start(); else _snapOpen.start(); }
            }
        }
    }
    Timer { id: _snapBack; interval: 16; repeat: true; onTriggered: { root.reveal = Math.max(0, root.reveal - 0.12); if (root.reveal <= 0) stop(); } }
    Timer { id: _snapOpen; interval: 16; repeat: true; onTriggered: { root.reveal = Math.min(1, root.reveal + 0.12); if (root.reveal >= 1) stop(); } }
    function open() { root.reveal = 1; }
    function close() { root.reveal = 0; }
}
