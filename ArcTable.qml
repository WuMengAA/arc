// arc:Table —— Tables/Table 真源码移植（TableToken.cs 21 键 + TableTheme.axaml）。
// 表头 44 / 行 52 / 单元格 16 左右 / 页脚 44；斑马纹 StripeBackground（ct 返回随明暗的字符串）；
// 紧凑断点 620 → CompactHeaderHeight 41 / CompactRowHeight 64；列支持 align。
import QtQuick 2.15

Item {
    id: root
    property var th: null
    property var columns: []          // [{ key, title, width?, align? }]
    property var rows: []
    property string caption: ""
    property string emptyMessage: "No rows."
    property int selectedIndex: -1
    signal rowActivated(int index)

    readonly property bool _compact: root.width < root.th.ct("Table", "CompactBreakpoint")
    readonly property real _headerH: _compact ? th.ct("Table", "CompactHeaderHeight") : th.ct("Table", "HeaderHeight")
    readonly property real _rowH: _compact ? th.ct("Table", "CompactRowHeight") : th.ct("Table", "RowHeight")
    readonly property real _cellI: th.ct("Table", "CellInlinePadding")
    readonly property real _footerH: th.ct("Table", "FooterHeight")
    readonly property color _stripe: th.ct("Table", "StripeBackground")
    readonly property real _edge: th.t4(th.design("EdgeThickness"), 0)

    implicitHeight: _headerH + _list.contentHeight + _footerH

    Rectangle {
        id: _head
        width: parent.width; height: root._headerH
        color: root.th.c("Surface")
        Row {
            anchors.fill: parent
            Repeater {
                model: root.columns
                delegate: Item {
                    required property var modelData
                    required property int index
                    width: root._colW(modelData)
                    height: _head.height
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                        anchors.verticalCenter: parent.verticalCenter
                        x: root._cellI
                        width: parent.width - 2 * root._cellI
                        text: modelData.title
                        horizontalAlignment: modelData.align === "right" ? Text.AlignRight : Text.AlignLeft
                        color: root.th.c("TextMuted")
                        font.pixelSize: root.th.design("TypeSM")
                        font.weight: root.th.design("WeightMedium")
                    }
                }
            }
        }
        Rectangle {
            anchors.bottom: parent.bottom; width: parent.width; height: root._edge
            color: root.th.c("Border")
        }
    }

    ListView {
        id: _list
        anchors.top: _head.bottom
        width: parent.width
        height: root.height - root._headerH - root._footerH
        clip: true
        model: root.rows
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            id: _rowRect
            required property var modelData
            required property int index
            readonly property bool _sel: root.selectedIndex === index
            width: _list.width; height: root._rowH
            color: _sel ? root.th.sidebar("RowSelectedFill")
                 : (index % 2 === 1 ? root._stripe : "transparent")
            Behavior on color { ColorAnimation { duration: th.dur("Instant") } }
            Row {
                anchors.fill: parent
                Repeater {
                    model: root.columns
                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: root._colW(modelData, _rowRect.width)
                        height: _rowRect.height
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                            anchors.verticalCenter: parent.verticalCenter
                            x: root._cellI
                            width: parent.width - 2 * root._cellI
                            text: modelData.key === undefined ? ""
                                : ("" + (_rowRect.modelData[modelData.key] !== undefined ? _rowRect.modelData[modelData.key] : ""))
                            horizontalAlignment: modelData.align === "right" ? Text.AlignRight : Text.AlignLeft
                            color: root.th.c("Foreground")
                            font.pixelSize: root.th.design("TypeSM")
                            elide: Text.ElideRight
                        }
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: { root.selectedIndex = _rowRect.index; root.rowActivated(_rowRect.index); }
            }
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            anchors.centerIn: parent
            visible: root.rows.length === 0
            text: root.emptyMessage
            color: root.th.c("TextMuted")
            font.pixelSize: root.th.design("TypeSM")
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom; width: parent.width; height: root._footerH
        color: root.th.c("Surface")
        Rectangle {
            anchors.top: parent.top; width: parent.width; height: root._edge
            color: root.th.c("BorderSubtle")
        }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
            anchors.verticalCenter: parent.verticalCenter
            x: root._cellI
            text: root.caption + " · " + root.rows.length + " rows"
            color: root.th.c("TextMuted")
            font.pixelSize: root.th.design("TypeSM")
        }
    }

    function _fixedW() {
        var w = 0;
        for (var i = 0; i < columns.length; i++) if (columns[i].width !== undefined) w += columns[i].width;
        return w;
    }
    function _flexCount() {
        var c = 0;
        for (var i = 0; i < columns.length; i++) if (columns[i].width === undefined) c++;
        return Math.max(1, c);
    }
    function _colW(col, w) {
        if (col.width !== undefined) return col.width;
        return ((w === undefined ? root.width : w) - _fixedW()) / _flexCount();
    }
}

