// arc:Breadcrumb —— Navigation/Breadcrumb 真源码移植：BreadcrumbToken.cs + Breadcrumb(Item)Theme.axaml。
// 首项无分隔符，后续每项前置 ChevronRight（SeparatorSize 16 / stroke 1.75）；current 用 AccentStrong；
// interactive hover 转 AccentStrong + underline（UnderlineOpacity 0.45）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var crumbs: []          // [{ label, current?, disabled? }]
    property int maxVisible: 0       // 0 = 全显示；>0 时中间折叠为 MoreHorizontal 溢出项
    signal activated(int index)

    readonly property real _gap: th.ct("Breadcrumb", "CrumbGap")
    readonly property real _sepSize: th.ct("BreadcrumbItem", "SeparatorSize")
    readonly property real _sepGap: th.ct("BreadcrumbItem", "SeparatorGap")
    readonly property real _padV: th.t4(th.ct("BreadcrumbItem", "CrumbPadding"), 1)
    readonly property real _padH: th.t4(th.ct("BreadcrumbItem", "CrumbPadding"), 0)
    readonly property real _crumbR: th.t4(th.ct("BreadcrumbItem", "CrumbRadius"), 0)
    readonly property real _lineH: th.ct("BreadcrumbItem", "LabelLineHeight")
    readonly property real _underlineO: th.ct("BreadcrumbItem", "UnderlineOpacity")
    readonly property real _ellW: th.ct("Pagination", "EllipsisWidth")
    readonly property real _rowH: Math.max(_lineH, _sepSize) + 2 * _padV

    width: implicitWidth; height: implicitHeight
    implicitWidth: _row.implicitWidth
    implicitHeight: _rowH

    // 折叠：保留首项、末 (maxVisible-1) 项，中间用一个溢出占位
    readonly property bool _folded: maxVisible > 0 && crumbs.length > maxVisible
    readonly property int _tail: maxVisible > 1 ? maxVisible - 1 : 1
    function _shown(i) {
        if (!_folded) return true;
        if (i === 0) return true;
        if (i === 1) return true;         // 索引 1 复用为折叠溢出占位，必须可见
        if (i >= crumbs.length - _tail) return true;
        return false;
    }
    function _isOverflow(i) { return _folded && i === 1; }

    Row {
        id: _row
        spacing: root._gap
        Repeater {
            model: root.crumbs
            delegate: Item {
                required property var modelData
                required property int index
                readonly property bool _show: root._shown(index)
                readonly property bool _overflow: root._isOverflow(index)
                readonly property bool _first: index === 0
                readonly property bool _cur: modelData.current === true
                readonly property bool _off: modelData.disabled === true
                readonly property bool _hover: ma.containsMouse && !_off && !_cur
                readonly property real _sepW: !_first ? root._sepSize + root._sepGap : 0
                readonly property real _labelW: _overflow ? root._ellW
                    : Math.max(24, _lbl.implicitWidth + 2 * root._padH)
                width: _show ? _sepW + _labelW : 0
                height: root._rowH
                visible: _show

                // PART_Separator
                Arc.ArcIcon {
                    visible: !_first
                    x: 0
                    anchors.verticalCenter: parent.verticalCenter
                    width: root._sepSize; height: root._sepSize
                    th: root.th
                    kind: "ChevronRight"
                    strokeWidth: 1.75
                    color: root.th.c("BorderStrong")
                }
                // PART_Frame
                Rectangle {
                    x: _sepW
                    width: _labelW
                    height: root._rowH
                    radius: root._crumbR
                    color: _overflow ? (_hover ? root.th.c("SurfaceMuted") : "transparent") : "transparent"
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        id: _lbl
                        visible: !_overflow
                        anchors.centerIn: parent
                        text: modelData.label
                        color: _cur ? root.th.c("AccentStrong")
                            : (_hover ? root.th.c("AccentStrong")
                            : (_off ? root.th.c("TextMuted") : root.th.c("TextSecondary")))
                        font.pixelSize: root.th.design("TypeSM")
                        font.weight: _cur ? root.th.design("WeightMedium") : root.th.design("WeightRegular")
                        lineHeight: root._lineH
                        lineHeightMode: Text.FixedHeight
                    }
                    Arc.ArcIcon {
                        visible: _overflow
                        anchors.centerIn: parent
                        width: 16; height: 16
                        th: root.th; kind: "MoreHorizontal"
                        color: root.th.c("TextMuted")
                    }
                    // PART_Underline
                    Rectangle {
                        visible: !_overflow && !_cur
                        x: root._padH; y: parent.height - 1
                        width: parent.width - 2 * root._padH; height: 1
                        color: _hover ? root.th.c("AccentStrong") : "transparent"
                        opacity: _hover ? root._underlineO : 0
                    }
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    enabled: !_off && !_cur && _show
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activated(index)
                }
            }
        }
    }
}
