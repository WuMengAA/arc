// arc:TextFilterBox —— Tables/TextFilterBox 真源码移植（TextFilterBox.cs + TextFilterBoxToken.cs）。
// 文本条件框：算子（is / is not / contains / starts / ends）+ 文本输入（MaxLength / IsCaseSensitive 约束）；
// ColumnGap12 是算子与值输入之间的间距；OperatorWidth84 / InputMinWidth160。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string operator: "eq"
    property string text: ""
    property string placeholder: ""
    property int maxLength: 0
    property bool isCaseSensitive: false
    signal operatorSelected(string op)
    signal valueCommitted(string v)

    readonly property real _colGap: root.th.ct("TextFilterBox", "ColumnGap")
    readonly property real _opW: root.th.ct("TextFilterBox", "OperatorWidth")
    readonly property real _valW: Math.max(root.th.ct("TextFilterBox", "InputMinWidth"), 120)
    readonly property var _ops: [{k:"is",t:"is"},{k:"isNot",t:"is not"},{k:"contains",t:"contains"},{k:"starts",t:"starts with"},{k:"ends",t:"ends with"}]
    implicitWidth: root._opW + root._colGap + root._valW
    implicitHeight: 34

    // 算子下拉（用项目既有的 ArcSelect 语义：点击展开一小列）
    Rectangle {
        id: _opBox
        width: root._opW
        height: parent.height
        radius: 10
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
        Text {
            anchors.verticalCenter: parent.verticalCenter
            x: 10
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: {
                for (var i = 0; i < root._ops.length; i++) if (root._ops[i].k === root.operator) return root._ops[i].t;
                return root.operator;
            }
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
        }
        Arc.ArcIcon {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 12; height: 12
            th: root.th; kind: "ChevronDown"
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: root._next()
        }
    }
    // 值输入
    Rectangle {
        x: _opBox.width + root._colGap
        width: root._valW
        height: parent.height
        radius: 10
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: _vi.activeFocus ? (root.th ? root.th.a("accent") : "#FF2FB8C6") : (root.th ? root.th.c("Border") : "#FFE0E0E0")
        Behavior on border.color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        TextInput {
            id: _vi
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            verticalAlignment: TextInput.AlignVCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
            selectByMouse: true
            text: root.text
            // TextInput 无 placeholderText：叠加提示（宿主也可用 placeholder 只读展示）
            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                visible: !_vi.text && root.placeholder !== ""
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                text: root.placeholder
                color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
            }
            maximumLength: root.maxLength > 0 ? root.maxLength : 32767
            onEditingFinished: { root.text = text; root.valueCommitted(text); }
        }
    }
    function _next() {
        var i = 0;
        for (var j = 0; j < root._ops.length; j++) if (root._ops[j].k === root.operator) i = j;
        var n = root._ops[(i + 1) % root._ops.length].k;
        root.operator = n;
        root.operatorSelected(n);
    }
}
