// arc:ExpandableText —— Expand/ExpandableText 真源码移植（ExpandableText.cs(43) + ExpandableTextToken.cs）。
// 长文折叠：Clamp 到 MaxLines 行后显示「展开/收起」按钮；按钮是个 Chip（TogglePadding[2,0,2,0] / ToggleRadius8 /
// ToggleMinHeight28），ChevronSize16，与正文 ToggleGap8，正文行高 TextLineHeight（19.6）。
// 展开态按钮在正文下方；TextLineHeight 与正文一致，收起态高度 = MaxLines * 行高。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string text: ""
    property int maxLines: 2
    property bool expanded: false
    property string expandText: "Show more"
    property string collapseText: "Show less"
    property real fontSize: th ? th.design("TypeSM") : 13
    property color color: th ? th.c("TextSecondary") : "#FF6D6D6D"

    readonly property real _lh: root.th.ct("ExpandableText", "TextLineHeight")
    readonly property real _gap: root.th.ct("ExpandableText", "ToggleGap")
    readonly property real _minH: root.th.ct("ExpandableText", "ToggleMinHeight")
    readonly property int _chev: root.th.ct("ExpandableText", "ChevronSize")
    readonly property real _padH: root.th.pad(root.th.ct("ExpandableText", "TogglePadding"))
    readonly property real _rad: root.th.pad(root.th.ct("ExpandableText", "ToggleRadius"))
    // 是否真的被截断：撑开后的高度 > maxLines 行
    readonly property bool _clamped: _body.implicitHeight > root.maxLines * root._lh + 1

    implicitWidth: _body.implicitWidth
    implicitHeight: (_clamped ? Math.min(_body.implicitHeight, root.maxLines * root._lh) : _body.implicitHeight)
                    + ((_clamped || root.expanded) ? root._gap + _toggle.height : 0)

    Text {
        id: _body
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        width: parent.width
        text: root.text
        color: root.color
        font.pixelSize: root.fontSize
        lineHeight: root._lh
        lineHeightMode: Text.FixedHeight
        wrapMode: Text.WordWrap
        clip: !root.expanded && root._clamped
        height: (!root.expanded && root._clamped) ? root.maxLines * root._lh : implicitHeight
    }
    // PART_Toggle：Chip 形态的展开/收起
    Item {
        id: _toggle
        visible: root._clamped || root.expanded
        y: _body.height + root._gap
        height: Math.max(root._minH, _lbl.implicitHeight + 8)
        width: _lbl.implicitWidth + 2 * root._padH + root._chev + 4
        Rectangle {
            anchors.fill: parent
            radius: root._rad
            color: _ma.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
            Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        }
        Text {
            id: _lbl
            anchors.verticalCenter: parent.verticalCenter
            x: root._padH
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.expanded ? root.collapseText : root.expandText
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            font.pixelSize: root.th.design("TypeXS")
            font.weight: root.th ? root.th.weightMedium : 500
        }
        Arc.ArcIcon {
            anchors.verticalCenter: parent.verticalCenter
            x: parent.width - root._padH - root._chev
            width: root._chev; height: root._chev
            th: root.th
            kind: "ChevronDown"
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            rotation: root.expanded ? 180 : 0
            Behavior on rotation { NumberAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        }
        MouseArea {
            id: _ma
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.expanded = !root.expanded
        }
    }
}
