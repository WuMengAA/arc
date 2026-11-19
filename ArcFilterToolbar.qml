// arc:FilterToolbar —— Tables/FilterToolbar 真源码移植（FilterToolbar.cs + FilterToolbarToken.cs + FilterMenu/
// FilterMenuList/FilterModels/FilterToolbarChipSlot/FilterToolbarIconButton/FilterToolbarSearchBox）。
// 筛选条：左边搜索框（SearchWidth200 / SearchInset[12,0,12,0]），右边已选条件 chip（ChipInset[12,0,8,0] / ChipGap8 /
// RemoveExtent24 的删除区），末位是「添加筛选」按钮；ToolbarInset[16,12,16,12] 是整条内边距；
// 宽度 < StackBreakpoint520 时搜索框换行到上面（SectionGap16）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string label: ""
    property string emptyText: "No filters"
    property string clearAllLabel: "Clear all"
    property string addFilterLabel: "Add filter"
    property bool isSearchVisible: true
    property string searchText: ""
    property string searchPlaceholder: "Search"
    property bool stackedHint: false
    property var chips: []            // [{label, key}]
    signal chipRemoved(string key)
    signal clearAllRequested()
    signal addFilterRequested()
    signal searchChanged(string text)

    readonly property real _padT: root.th.t4(root.th.ct("FilterToolbar", "ToolbarInset"), 1)
    readonly property real _padB: root.th.t4(root.th.ct("FilterToolbar", "ToolbarInset"), 3)
    readonly property real _padL: root.th.t4(root.th.ct("FilterToolbar", "ToolbarInset"), 0)
    readonly property real _searchW: root.th.ct("FilterToolbar", "SearchWidth")
    readonly property real _chipGap: root.th.ct("FilterToolbar", "ChipGap")
    readonly property real _actionGap: root.th.ct("FilterToolbar", "ActionGap")
    readonly property real _sectionGap: root.th.ct("FilterToolbar", "SectionGap")
    readonly property real _bp: root.th.ct("FilterToolbar", "StackBreakpoint")
    readonly property bool _stacked: root.stackedHint || (root.width > 0 && root.width < root._bp)
    implicitWidth: 520
    implicitHeight: _flow.implicitHeight + root._padT + root._padB

    Flow {
        id: _flow
        x: root._padL
        y: root._padT
        width: parent.width - 2 * root._padL
        spacing: root._actionGap
        // 搜索框
        Rectangle {
            visible: root.isSearchVisible
            width: root._searchW
            height: 36
            radius: 18
            color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
            border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
            border.color: _si.activeFocus ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
            Arc.ArcIcon {
                x: 12
                anchors.verticalCenter: parent.verticalCenter
                width: 16; height: 16
                th: root.th; kind: "Search"
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            }
            TextInput {
                id: _si
                anchors.fill: parent
                anchors.leftMargin: 36
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                text: root.searchText
                // TextInput 没有 placeholderText；用叠加的提示文本代替（见下方 _ph）
                selectByMouse: true
                onTextChanged: root.searchChanged(text)
            }
            // 占位提示（TextInput 无 placeholderText）
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 36
                anchors.verticalCenter: parent.verticalCenter
                visible: _si.text === ""
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                text: root.searchPlaceholder
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            }
        }
        // 已选 chip
        Repeater {
            model: root.chips.length
            delegate: Rectangle {
                required property int index
                readonly property real _lblW: _cl.implicitWidth
                width: _lblW + 12 + 8 + 24 + 8
                height: 32
                radius: 16
                color: root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0"
                Text {
                    id: _cl
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: root.chips[index].label || ""
                    color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                }
                Arc.ArcIcon {
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    width: 12; height: 12
                    th: root.th; kind: "X"
                    color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.chipRemoved(root.chips[index].key || root.chips[index].label || "")
                }
            }
        }
        // 添加筛选
        Rectangle {
            width: _add.implicitWidth + 24
            height: 32
            radius: 16
            color: _am.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
            border.width: 1
            border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
            Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
            Text {
                id: _add
                anchors.centerIn: parent
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root.addFilterLabel
                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
            MouseArea {
                id: _am
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.addFilterRequested()
            }
        }
        // 清空
        Rectangle {
            visible: root.chips.length > 0
            width: _clr.implicitWidth + 16
            height: 32
            radius: 16
            color: "transparent"
            Text {
                id: _clr
                anchors.centerIn: parent
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: root.clearAllLabel
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            }
            MouseArea { anchors.fill: parent; onClicked: root.clearAllRequested() }
        }
        // 空态文案
        Text {
            visible: root.chips.length === 0
            height: 32
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.emptyText
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
    }
}
