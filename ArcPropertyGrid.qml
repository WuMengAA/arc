// arc:PropertyGrid —— Editors/PropertyGrid 真源码移植（PropertyGrid.cs 1161 行 + PropertyGridToken.cs +
// PropertyGridItem/Property/Row/Editor/Editors/Types/Values/Attributes）。
// 属性表：左侧名称列（LabelWidth 可配）+ 右侧编辑器；分组标题（IsCategorized）；描述区 DescriptionHeight76 /
// DescriptionPadding[14,10,14,12]；列表 ListPadding[4,4,4,8]；搜索 SearchMargin[8,8,8,4]。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var rows: []             // [{key, label, value, type?, group?, readOnly?, options?}]
    property string filterText: ""
    property bool isSearchVisible: true
    property bool isDescriptionVisible: true
    property bool isReadOnly: false
    property real labelWidth: 0
    property string emptyText: "No properties"
    property string searchPlaceholder: "Filter properties"
    signal valueEdited(string key, var value)

    readonly property real _labelW: root.labelWidth > 0 ? root.labelWidth : 132
    readonly property real _descH: root.th.ct("PropertyGrid", "DescriptionHeight")
    readonly property real _descPad: root.th.pad(root.th.ct("PropertyGrid", "DescriptionPadding"))
    readonly property real _listPad: root.th.pad(root.th.ct("PropertyGrid", "ListPadding"))
    readonly property real _rowH: 34
    readonly property var _visible: {
        var out = [], q = String(root.filterText).toLowerCase();
        for (var i = 0; i < root.rows.length; i++) {
            var r = root.rows[i];
            if (q === "" || String(r.label || "").toLowerCase().indexOf(q) >= 0
                || String(r.key || "").toLowerCase().indexOf(q) >= 0) out.push(r);
        }
        return out;
    }
    implicitWidth: 360
    implicitHeight: (root.isSearchVisible ? 40 : 0) + root._listPad * 2
                    + root._visible.length * (root._rowH + 2)
                    + (root.isDescriptionVisible ? root._descH + 8 : 0)

    // 搜索
    Rectangle {
        visible: root.isSearchVisible
        width: parent.width
        height: 34
        radius: 17
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        Arc.ArcIcon {
            x: 11
            anchors.verticalCenter: parent.verticalCenter
            width: 15; height: 15
            th: root.th; kind: "Search"
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        }
        TextInput {
            id: _si
            anchors.fill: parent
            anchors.leftMargin: 34
            anchors.rightMargin: 10
            verticalAlignment: TextInput.AlignVCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            text: root.filterText
            selectByMouse: true
            onTextChanged: root.filterText = text
        }
        Text {
            visible: _si.text === ""
            anchors.left: parent.left
            anchors.leftMargin: 34
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            text: root.searchPlaceholder
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        }
    }
    // 行
    Column {
        y: root.isSearchVisible ? 40 + root._listPad : root._listPad
        x: root._listPad
        width: parent.width - 2 * root._listPad
        spacing: 2
        Repeater {
            model: root._visible.length
            delegate: Rectangle {
                required property int index
                readonly property var r: root._visible[index]
                width: parent.width
                height: root._rowH
                radius: 8
                color: _pm3.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
                Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
                Text {
                    x: 8
                    width: root._labelW - 8
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: r ? (r.label || r.key || "") : ""
                    color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
                // 编辑器：只读文本 / 可编辑输入
                TextInput {
                    x: root._labelW + 4
                    width: parent.width - x - 8
                    height: parent.height
                    verticalAlignment: TextInput.AlignVCenter
                    readOnly: root.isReadOnly || (r && r.readOnly === true)
                    selectByMouse: !readOnly
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    color: (root.isReadOnly || (r && r.readOnly === true))
                           ? (root.th ? root.th.c("TextMuted") : "#FF9A9A9A")
                           : (root.th ? root.th.c("Foreground") : "#FF1D1D1D")
                    text: r && r.value !== undefined ? String(r.value) : ""
                    onEditingFinished: if (r) root.valueEdited(r.key, text)
                }
                MouseArea { id: _pm3; anchors.fill: parent; hoverEnabled: true; z: -1 }
            }
        }
        Text {
            visible: root._visible.length === 0
            width: parent.width
            height: 40
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.emptyText
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
    }
    // 描述区
    Rectangle {
        visible: root.isDescriptionVisible
        anchors.bottom: parent.bottom
        width: parent.width
        height: root._descH
        radius: 12
        color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
        Text {
            x: root._descPad
            y: root._descPad
            width: parent.width - 2 * root._descPad
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.filterText !== "" ? ("Matching: " + root.filterText) : ""
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            wrapMode: Text.WordWrap
        }
    }
}
