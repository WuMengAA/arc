// arc:Cascader —— Selects/Cascader 真源码移植（Cascader.cs 1373 行 + CascaderToken.cs + CascaderColumn/CascaderColumnsPanel/
// CascaderTypes）。
// 级联选择：一层一列（MinColumnWidth160 / MaxColumnWidth280 / ColumnGap6），列内选项 OptionHeight36 / OptionCornerRadius14 /
// OptionPadding[11,0,34,0]；菜单 MenuPadding[6,6,6,6] / MenuCornerRadius20；有子项的选项右侧画折角（ChevronInset10）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var columns: []          // [[{value,label,children?}], ...] 或 [{label,children}]
    property var value: []            // 已选路径
    property string placeholder: "Select"
    property bool open: false
    signal activated(var path)

    readonly property real _minW: root.th.ct("Cascader", "MinColumnWidth")
    readonly property real _maxW: root.th.ct("Cascader", "MaxColumnWidth")
    readonly property real _gap: root.th.ct("Cascader", "ColumnGap")
    readonly property real _optH: root.th.ct("Cascader", "OptionHeight")
    readonly property real _optRad: root.th.pad(root.th.ct("Cascader", "OptionCornerRadius"))
    readonly property real _menuPad: root.th.pad(root.th.ct("Cascader", "MenuPadding"))
    readonly property real _menuRad: root.th.pad(root.th.ct("Cascader", "MenuCornerRadius"))
    readonly property real _chevInset: root.th.ct("Cascader", "ChevronInset")
    // 由 value 路径展开出各列
    readonly property var _cols: root._buildColumns()
    function _buildColumns() {
        var out = [], level = root.columns, path = root.value || [];
        var i = 0;
        while (level && level.length > 0) {
            out.push({ items: level, sel: path.length > i ? path[i] : null });
            var pick = null;
            if (path.length > i) {
                for (var j = 0; j < level.length; j++)
                    if (level[j].value === path[i] || level[j].label === path[i]) { pick = level[j]; break; }
            }
            if (!pick || !pick.children || pick.children.length === 0) break;
            level = pick.children;
            i++;
        }
        return out;
    }
    function pick(colIndex, item, fullPath) {
        var arr = (root.value || []).slice(0, colIndex);
        arr.push(item.value !== undefined ? item.value : item.label);
        root.value = arr;
        if (!item.children || item.children.length === 0) {
            root.open = false;
            root.activated(arr);
        }
    }
    implicitWidth: Math.max(240, root._cols.length * (root._minW + root._gap))
    implicitHeight: 38 + (root.open ? root._menuPad * 2 + Math.min(7, Math.max(1, root._cols.length ? root._cols[0].items.length : 1)) * root._optH : 0)

    Rectangle {
        id: _trigger
        width: parent.width
        height: 38
        radius: 12
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root.open ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        Text {
            x: root.th.t4(root.th.ct("Cascader", "TriggerPadding"), 0)
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - x - 32
            elide: Text.ElideRight
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: (root.value && root.value.length > 0) ? root.value.join(" / ") : root.placeholder
            color: (root.value && root.value.length > 0)
                   ? (root.th ? root.th.c("Foreground") : "#FF1D1D1D")
                   : (root.th ? root.th.c("TextMuted") : "#FF9A9A9A")
            font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        }
        Arc.ArcIcon {
            anchors.right: parent.right
            anchors.rightMargin: root._chevInset
            anchors.verticalCenter: parent.verticalCenter
            width: 14; height: 14
            th: root.th; kind: "ChevronDown"
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            rotation: root.open ? 180 : 0
            Behavior on rotation { NumberAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        }
        MouseArea { anchors.fill: parent; onClicked: root.open = !root.open }
    }
    // PART_Menu：逐列
    Rectangle {
        visible: root.open
        y: 42
        width: parent.width
        height: root._menuPad * 2 + Math.min(7, root._cols.length ? root._cols[0].items.length : 1) * root._optH
        radius: root._menuRad
        color: root.th ? root.th.c("SurfaceRaised") : "#FFFFFFFF"
        border.width: 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        Row {
            x: root._menuPad
            y: root._menuPad
            spacing: root._gap
            Repeater {
                model: root._cols.length
                delegate: Column {
                    id: _colBox
                    required property int index
                    // 先把本列的数据抓下来，避免内层 Repeater 的 index 把它遮蔽
                    readonly property var colInfo: root._cols[index]
                    width: (parent.width - (root._cols.length - 1) * root._gap) / Math.max(1, root._cols.length)
                    Repeater {
                        model: Math.min(7, _colBox.colInfo.items.length)
                        delegate: Rectangle {
                            required property int index
                            readonly property var item: _colBox.colInfo.items[parent.index]
                            width: parent.width
                            height: root._optH
                            radius: root._optRad
                            color: (_cm3.containsMouse || _colBox.colInfo.sel === item.value)
                                   ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                            Text {
                                x: 11
                                width: parent.width - 11 - (item.children ? 34 : 0)
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                renderType: Text.NativeRendering
                                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                                text: item.label || ""
                                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                            }
                            Arc.ArcIcon {
                                visible: item.children !== undefined
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                width: 12; height: 12
                                th: root.th; kind: "ChevronRight"
                                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                            }
                            MouseArea {
                                id: _cm3
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.pick(_colBox.index, item, root.value)
                            }
                        }
                    }
                }
            }
        }
    }
}
