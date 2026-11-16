// arc:Pagination —— Navigation/Pagination 真源码移植：PaginationToken.cs + PaginationTheme.axaml。
// 36px 按钮（ControlSizeSM）、4px 间隙（Space1）、前后箭头 ChevronLeft/Right 16px、
// current 由 GlidingIndicator（Surface 底 + Border + RadiusControl）标记、禁用箭头 opacity 0.4。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property int pageCount: 1
    property int currentPage: 1
    property int maxButtons: 5       // 显示的数字按钮数（真源码 PART_Page0..4）
    signal pageChanged(int page)

    readonly property real _btn: th.design("ControlSizeSM")
    readonly property real _gap: th.design("Space1")
    readonly property real _step: th.ct("Pagination", "StepGlyphSize")
    readonly property real _disO: th.ct("Pagination", "DisabledOpacity")
    readonly property real _ellW: th.ct("Pagination", "EllipsisWidth")
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _r: th.t4(th.design("RadiusControl"), 0)
    readonly property real _ringR: th.t4(th.ct("Pagination", "ButtonFocusRingRadius"), 0)

    // 计算窗口：以 current 为中心，[first..last] 共 maxButtons 个，必要时两侧加省略号
    readonly property int _win: Math.min(maxButtons, pageCount)
    readonly property int _first: Math.max(1, Math.min(currentPage - Math.floor((_win - 1) / 2), pageCount - _win + 1))
    readonly property int _last: Math.min(pageCount, _first + _win - 1)
    readonly property bool _leftEll: _first > 1
    readonly property bool _rightEll: _last < pageCount

    readonly property int _slots: _win + (_leftEll ? 1 : 0) + (_rightEll ? 1 : 0)
    readonly property real _totalW: 2 * _btn + (_slots + 1) * _gap + _win * _btn
        + (_leftEll ? _ellW : 0) + (_rightEll ? _ellW : 0)

    width: implicitWidth; height: implicitHeight
    implicitWidth: _totalW
    implicitHeight: _btn

    function _go(p) {
        if (p < 1 || p > pageCount || p === currentPage) return;
        root.currentPage = p; root.pageChanged(p);
    }

    // PART_Mark：滑到当前页背后
    Rectangle {
        id: _mark
        x: root._btn + root._gap + (root._leftEll ? root._ellW + root._gap : 0)
           + (root.currentPage - root._first) * (root._btn + root._gap)
        y: 0
        width: root._btn; height: root._btn
        radius: root._r
        color: root.th.c("Surface")
        border.width: root._edge
        border.color: root.th.c("Border")
        z: 0
        Behavior on x { NumberAnimation { duration: th.dur("Exit"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }
    }

    Row {
        id: _row
        spacing: root._gap
        z: 1

        // PART_Previous
        Arc.ArcButton {
            width: root._btn; height: root._btn
            th: root.th
            icon: "ChevronLeft"
            variant: "ghost"
            enabled: root.currentPage > 1
            onClicked: root._go(root.currentPage - 1)
        }

        // 左省略号
        Item {
            visible: root._leftEll
            width: root._ellW; height: root._btn
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: "…"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
        }

        // PART_Page0..N
        Repeater {
            model: root._win
            delegate: Item {
                required property int index
                readonly property int _p: root._first + index
                readonly property bool _cur: _p === root.currentPage
                width: root._btn; height: root._btn
                Rectangle {
                    anchors.fill: parent
                    radius: root._r
                    color: !_cur && ma.containsMouse ? root.th.c("SurfaceMuted") : "transparent"
                    border.width: 0
                }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    anchors.centerIn: parent
                    text: _p
                    color: _cur ? root.th.c("Foreground") : root.th.c("TextSecondary")
                    font.pixelSize: root.th.design("TypeXS")
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root._go(_p)
                }
            }
        }

        // 右省略号
        Item {
            visible: root._rightEll
            width: root._ellW; height: root._btn
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: "…"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
        }

        // PART_Next
        Arc.ArcButton {
            width: root._btn; height: root._btn
            th: root.th
            icon: "ChevronRight"
            variant: "ghost"
            enabled: root.currentPage < root.pageCount
            onClicked: root._go(root.currentPage + 1)
        }
    }
}
