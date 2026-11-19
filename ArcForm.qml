// arc:Form —— Forms/Form 真源码移植（Form.cs 777 行 + Form + FormEnums）。
// 表单容器：纵向排 FormItem，SectionSpacing 分节；标签列宽自动取最长标签（上限 AutoLabelMaxWidth240）。
// 提交/重置由宿主调 submit() / reset()（真源码的验证与提交都在 C# 侧，QML 只发信号）。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property bool labelAbove: false
    property real itemGap: 16
    property real sectionGap: 28
    default property alias content: _col.data
    signal submitted()
    signal reset()

    readonly property real _maxLabel: root.th.ct("Form", "AutoLabelMaxWidth")
    // 标签列宽：取子项里最长的 label（上限 240，下限 0 = 不设列）
    readonly property real _labelW: {
        var m = 0;
        for (var i = 0; i < _col.children.length; i++) {
            var c = _col.children[i];
            if (c && c.label !== undefined && c.label !== "") {
                if (c.labelWidth > 0) m = Math.max(m, c.labelWidth);
            }
        }
        return m > 0 ? Math.min(m, root._maxLabel) : 0;
    }
    implicitWidth: 360
    implicitHeight: _col.implicitHeight

    Column {
        id: _col
        width: parent.width
        spacing: root.itemGap
        // 子项统一套用表单的标签排布（宿主可在子项上覆盖）
        onChildrenChanged: {
            for (var i = 0; i < children.length; i++) {
                var c = children[i];
                if (c && c.labelAbove !== undefined) c.labelAbove = root.labelAbove;
                if (c && c.labelWidth !== undefined) c.labelWidth = root._labelW;
            }
        }
    }
    function submit() { root.submitted(); }
    function doReset() { root.reset(); }
}
