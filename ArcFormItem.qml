// arc:FormItem —— Forms/FormItem 真源码移植（FormItem.cs 909 行 + FormItemToken.cs）。
// 表单项：左标签列（LabelColumnGap16，标签列宽上限 AutoLabelMaxWidth240）+ 右控件；
// 必填标记 RequiredMarkGap4；错误文案在控件下方，聚焦时滚到可见（ErrorScrollMargin24）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string label: ""
    property string description: ""
    property string error: ""
    property bool required: false
    property bool labelAbove: false
    property real labelWidth: 0
    property real labelColGap: 0
    default property alias content: _slot.data

    readonly property real _gap: root.labelColGap > 0 ? root.labelColGap : root.th.ct("FormItem", "LabelColumnGap")
    readonly property real _maxLabel: root.th.ct("Form", "AutoLabelMaxWidth")
    readonly property real _reqGap: root.th.ct("FormItem", "RequiredMarkGap")
    readonly property real _w: root.labelWidth > 0 ? root.labelWidth : Math.min(root._maxLabel, 140)
    readonly property real _h: root.labelAbove ? (_labelRow.implicitHeight + 6 + _slot.implicitHeight + (root._msg !== "" ? 6 + _msg.implicitHeight : 0))
                                               : Math.max(_labelRow.implicitHeight, _slot.implicitHeight + (root._msg !== "" ? 6 + _msg.implicitHeight : 0))
    readonly property string _msg: root.error !== "" ? root.error : root.description
    implicitWidth: 320
    implicitHeight: root._h

    Row {
        id: _labelRow
        visible: !root.labelAbove
        width: root._w
        height: root._h
        spacing: 2
        Text {
            width: parent.width - (root.required ? 8 : 0)
            y: 6
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.label
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightMedium : 500
        }
        Text {
            visible: root.required
            y: 6
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: "*"
            color: root.th ? root.th.c("Danger") : "#FFCD1526"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
    }
    // 上方标签
    Row {
        visible: root.labelAbove
        width: parent.width
        spacing: root._reqGap - 2
        Text {
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.label
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightMedium : 500
        }
        Text {
            visible: root.required
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: "*"
            color: root.th ? root.th.c("Danger") : "#FFCD1526"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
    }
    Column {
        x: root.labelAbove ? 0 : root._w + root._gap
        y: root.labelAbove ? _labelRow.implicitHeight + 6 : 0
        width: root.labelAbove ? parent.width : parent.width - x
        spacing: 6
        Item {
            id: _slot
            width: parent.width
            height: childrenRect.height
            implicitHeight: childrenRect.height
        }
        Text {
            id: _msg
            visible: root._msg !== ""
            width: parent.width
            wrapMode: Text.WordWrap
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root._msg
            color: root.error !== "" ? (root.th ? root.th.c("Danger") : "#FFCD1526")
                                     : (root.th ? root.th.c("TextMuted") : "#FF9A9A9A")
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
    }
}
