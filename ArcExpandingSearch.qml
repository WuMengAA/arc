// arc:ExpandingSearch —— TextFields/ExpandingSearch 真源码移植（ExpandingSearch.cs + ExpandingSearchToken.cs +
// ExpandingSearchItem/ExpandingSearchParts）。
// 折叠式搜索：默认只是一个玻璃图标（GlassSize18），点开撑到 ExpandedWidth；输入框 FieldPadding[38,0,40,0]（左右让位图标与清除）；
// 清除按钮 ClearButtonSize28 / ClearGlassSize16 / ClearButtonMargin[0,0,7,0]；下面可挂建议列表（MaxResults）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string query: ""
    property string placeholderText: "Search"
    property real expandedWidth: 280
    property bool isExpanded: false
    property var suggestions: []
    property int maxResults: 6
    property string emptyHint: "No results"
    signal accepted(string text)

    readonly property real _glass: root.th.ct("ExpandingSearch", "GlassSize")
    readonly property real _padL: root.th.t4(root.th.ct("ExpandingSearch", "FieldPadding"), 0)
    readonly property real _padR: root.th.t4(root.th.ct("ExpandingSearch", "FieldPadding"), 2)
    readonly property real _clear: root.th.ct("ExpandingSearch", "ClearButtonSize")
    readonly property real _clearGlass: root.th.ct("ExpandingSearch", "ClearGlassSize")
    readonly property real _iconM: root.th.t4(root.th.ct("ExpandingSearch", "IconMargin"), 0)
    readonly property real _lineH: root.th.ct("ExpandingSearch", "TextLineHeight")
    implicitWidth: root.isExpanded ? Math.max(root.expandedWidth, 160) : 40
    implicitHeight: 36 + (root.isExpanded && root.suggestions.length > 0
                          ? Math.min(root.maxResults, root.suggestions.length) * 34 + 8 : 0)
    Behavior on implicitWidth { NumberAnimation { duration: root.th ? root.th.dur("Standard") : 240
        easing.type: Easing.Bezier; easing.bezierCurve: root.th ? root.th.ease("Standard") : [0.22, 1, 0.36, 1, 1, 1] } }

    Rectangle {
        id: _shell
        width: parent.width
        height: 36
        radius: 18
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: _si.activeFocus ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        // 玻璃图标（收起时就是整个按钮）
        Item {
            id: _glassBox
            width: 36; height: 36
            anchors.left: parent.left
            Arc.ArcIcon {
                anchors.centerIn: parent
                width: root._glass; height: root._glass
                th: root.th; kind: "Search"
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: { root.isExpanded = true; _si.forceActiveFocus(); }
            }
        }
        TextInput {
            id: _si
            visible: root.isExpanded
            anchors.fill: parent
            anchors.leftMargin: root._padL
            anchors.rightMargin: root._padR
            verticalAlignment: TextInput.AlignVCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            font.pixelSize: root.th ? root.th.design("TypeSM") : 13
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            text: root.query
            selectByMouse: true
            onTextChanged: root.query = text
            onAccepted: root.accepted(text)
            onActiveFocusChanged: if (!activeFocus && text === "") root.isExpanded = false
        }
        Text {
            visible: root.isExpanded && _si.text === ""
            anchors.left: parent.left
            anchors.leftMargin: root._padL
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            font.pixelSize: root.th ? root.th.design("TypeSM") : 13
            text: root.placeholderText
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        }
        // 清除
        Rectangle {
            visible: root.isExpanded && _si.text !== ""
            anchors.right: parent.right
            anchors.rightMargin: root.th.t4(root.th.ct("ExpandingSearch", "ClearButtonMargin"), 2)
            anchors.verticalCenter: parent.verticalCenter
            width: root._clear; height: root._clear
            radius: width / 2
            color: _cm.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
            Arc.ArcIcon {
                anchors.centerIn: parent
                width: root._clearGlass; height: root._clearGlass
                th: root.th; kind: "X"
                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            }
            MouseArea { id: _cm; anchors.fill: parent; hoverEnabled: true; onClicked: { _si.text = ""; root.query = ""; } }
        }
    }
    // 建议列表
    Rectangle {
        visible: root.isExpanded && root.suggestions.length > 0
        y: 40
        width: parent.width
        height: Math.min(root.maxResults, root.suggestions.length) * 34 + 8
        radius: 12
        color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
        border.width: 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        Column {
            x: 4; y: 4
            width: parent.width - 8
            Repeater {
                model: Math.min(root.maxResults, root.suggestions.length)
                delegate: Rectangle {
                    required property int index
                    width: parent.width; height: 34; radius: 8
                    color: _sm.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 10
                        renderType: Text.NativeRendering
                        font.family: root.th ? root.th.fontFamily : "Segoe UI"
                        text: root.suggestions[index] && root.suggestions[index].label !== undefined
                              ? root.suggestions[index].label : String(root.suggestions[index])
                        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                        font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    }
                    MouseArea {
                        id: _sm
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var s = root.suggestions[index];
                            _si.text = s && s.label !== undefined ? s.label : String(s);
                            root.query = _si.text;
                            root.isExpanded = false;
                            root.accepted(root.query);
                        }
                    }
                }
            }
        }
    }
}
