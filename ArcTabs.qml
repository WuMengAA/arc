// arc:Tabs —— Navigation/Tabs 真源码移植：ListShell（SurfaceMuted 轨道）+ 滑动 SelectionPill
// + TabItem 触发器（minWidth 88 / minHeight 36）+ ContentHost（上距 16）。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property var options: []          // [{ value, label, disabled }]
    property string value: ""
    default property alias content: _content.data
    signal activated(string value)

    readonly property real _inset: th.pad(th.ct("Tabs", "ListPadding"))
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _pillR: th.t4(th.ct("Tabs", "PillRadius"), 0)
    readonly property real _gap: th.design("Space1")
    readonly property real _trigH: th.design("ControlSizeSM")
    readonly property real _contentGap: th.t4(th.ct("Tabs", "ContentMargin"), 1)

    implicitWidth: _row.implicitWidth + 2 * _inset + 2 * _edge
    implicitHeight: _shellH + _contentGap + _content.implicitHeight
    width: implicitWidth; height: implicitHeight
    readonly property real _shellH: _trigH + 2 * _inset + 2 * _edge

    function _index() {
        for (var i = 0; i < options.length; i++)
            if (options[i].value === value) return i;
        return 0;
    }
    function _movePill() {
        var it = _rep.itemAt(_index());
        if (it) { _pill.x = it.x; _pill.width = it.width; }
    }
    onValueChanged: _movePill()
    Timer { interval: 0; running: true; repeat: false; onTriggered: root._movePill() }

    // PART_ListShell
    Rectangle {
        id: _shell
        width: root.width
        height: root._shellH
        radius: root.th.t4(root.th.design("RadiusControl"), 0)
        color: root.th.c("SurfaceMuted")
        border.width: root._edge
        border.color: root.th.c("Border")
        clip: true

        Item {
            x: root._inset + root._edge; y: root._inset + root._edge
            width: _row.implicitWidth; height: root._trigH

            // PART_SelectionPill：Surface 底 + Border 描边，随选中项滑动
            Rectangle {
                id: _pill
                y: 0; height: root._trigH
                radius: root._pillR
                color: root.th.c("Surface")
                border.width: root._edge
                border.color: root.th.c("Border")
                Behavior on x { NumberAnimation { duration: th.dur("Exit"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }
                Behavior on width { NumberAnimation { duration: th.dur("Exit"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }
            }

            Row {
                id: _row
                spacing: root._gap
                Repeater {
                    id: _rep
                    model: root.options
                    delegate: Item {
                        required property var modelData
                        required property int index
                        readonly property bool _on: root.value === modelData.value
                        readonly property bool _dis: modelData.disabled === true
                        width: Math.max(root.th.ct("TabItem", "TriggerMinWidth"),
                                        _lbl.implicitWidth + 2 * root.th.t4(root.th.ct("TabItem", "InlinePadding"), 0))
                        height: root._trigH
                        opacity: _dis ? root.th.ct("TabItem", "DisabledOpacity") : 1
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                            id: _lbl
                            anchors.centerIn: parent
                            text: modelData.label
                            color: parent._on ? root.th.c("Foreground")
                                : (ma.containsMouse ? root.th.c("Foreground") : root.th.c("TextMuted"))
                            font.pixelSize: root.th.design("TypeSM")
                            font.weight: root.th.design("WeightMedium")
                        }
                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            enabled: !parent._dis
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activated(modelData.value)
                        }
                    }
                }
            }
        }
    }

    // PART_ContentHost
    Column {
        id: _content
        y: root._shellH + root._contentGap
        width: root.width
        spacing: 8
    }
}

