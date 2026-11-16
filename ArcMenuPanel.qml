// 共用菜单面：Menus/_Shared MenuSurface + MenuEntry + MenuEntryLabel + MenuEntrySeparator 真值。
// DropdownMenu / ContextMenu / UserMenu 都复用它，避免第二套令牌真源（§10）。
import QtQuick 2.15
import "." as Arc

Rectangle {
    id: root
    property var th: null
    property var items: []              // [{label, icon, shortcut, danger, disabled, separator, checked}]
    property real rowWidth: 220
    property bool accountStyle: false
    signal activated(int index)

    readonly property real _pad: th.pad(th.ct("MenuSurface", "PanelInset"))
    readonly property real _rad: th.pad(th.ct("MenuSurface", accountStyle ? "AccountRadius" : "HighlightRadius"))
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)
    readonly property real _rowH: th.ct("MenuEntry", accountStyle ? "AccountRowHeight" : "RowHeight")
    readonly property real _rowIn: th.t4(th.ct("MenuEntry", accountStyle ? "AccountRowInset" : "RowInset"), 0)
    readonly property real _rowRad: th.pad(th.ct("MenuEntry", accountStyle ? "AccountRowRadius" : "RowRadius"))
    readonly property real _glyph: th.ct("MenuEntry", "GlyphSize")
    readonly property real _slot: th.ct("MenuEntry", "IconSlotWidth")
    readonly property real _iconGap: th.t4(th.ct("MenuEntry", "IconSpacing"), 2)
    readonly property real _labelIn: th.t4(th.ct("MenuEntryLabel", accountStyle ? "AccountLabelInset" : "LabelInset"), 0)
    readonly property real _lineH: th.ct("MenuEntrySeparator", "LineThickness")
    readonly property color _hl: th.ct("MenuSurface", "AccountHighlight")
    readonly property color _danger: th.ct("MenuSurface", "DangerHighlight")
    readonly property color _sep: th.ct("MenuEntrySeparator", "AccountLineColor")

    width: root.rowWidth + 2 * _pad
    height: _col.implicitHeight + 2 * _pad
    implicitWidth: width
    implicitHeight: height
    radius: _rad
    color: th.c("Surface")
    border.width: _edge
    border.color: th.c("Border")

    Column {
        id: _col
        x: root._pad; y: root._pad
        width: root.rowWidth
        spacing: 0
        Repeater {
            model: root.items
            delegate: Item {
                id: _d
                required property int index
                required property var modelData
                width: root.rowWidth
                height: modelData.separator ? root._lineH + 8 : root._rowH
                opacity: modelData.disabled ? th.ct("MenuEntry", "DisabledOpacity") : 1
                Rectangle {
                    visible: !!modelData.separator
                    x: root._rowIn; y: 4
                    width: parent.width - 2 * root._rowIn
                    height: root._lineH
                    color: root._sep
                }
                Rectangle {
                    id: _bg
                    visible: !modelData.separator
                    anchors.fill: parent
                    radius: root._rowRad
                    color: !modelData.disabled && _ma.containsMouse
                           ? (modelData.danger ? root._danger : root._hl) : "transparent"
                    Behavior on color { ColorAnimation { duration: th.dur("Instant") } }
                }
                Row {
                    visible: !modelData.separator
                    anchors.verticalCenter: parent.verticalCenter
                    x: root._rowIn
                    spacing: 0
                    Item {
                        width: root._slot + root._iconGap; height: root._rowH
                        Arc.ArcIcon {
                            visible: (modelData.icon || "") !== ""
                            anchors.centerIn: parent
                            th: root.th; kind: modelData.icon || "Circle"
                            width: root._glyph; height: root._glyph
                            color: modelData.danger ? th.c("Danger") : th.c("TextSecondary")
                        }
                    }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        width: root.rowWidth - 2 * root._rowIn - root._slot - root._iconGap - 54
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label || ""
                        color: modelData.danger ? th.c("Danger") : th.c("Foreground")
                        font.pixelSize: th.design("TypeSM")
                        elide: Text.ElideRight
                    }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.shortcut || ""
                        color: th.c("TextMuted")
                        font.pixelSize: th.design("TypeXS")
                    }
                    Arc.ArcIcon {
                        visible: !!modelData.checked
                        anchors.verticalCenter: parent.verticalCenter
                        th: root.th; kind: "Check"; color: th.c("AccentStrong")
                        width: 14; height: 14
                    }
                }
                MouseArea {
                    id: _ma
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !modelData.separator && !modelData.disabled
                    onClicked: root.activated(index)
                }
            }
        }
    }
}
