// arc:NumberFilterBox —— Tables/NumberFilterBox 真源码移植（NumberFilterBox.cs + NumberFilterBoxToken.cs）。
// 数字条件框：算子（= ≠ < ≤ > ≥ between）+ 数值输入（NumberMode / DecimalPlaces / Minimum / Maximum 约束）；
// ColumnGap12 是算子与值输入之间的间距；OperatorWidth84 / ValueWidth168。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string operator: "eq"
    property real value: 0
    property int numberMode: 0        // 0 integer / 1 decimal
    property int decimalPlaces: 0
    property real minimum: -Infinity
    property real maximum: Infinity
    property bool useGrouping: true
    signal operatorSelected(string op)
    signal valueCommitted(real v)

    readonly property real _colGap: root.th.ct("NumberFilterBox", "ColumnGap")
    readonly property real _opW: root.th.ct("NumberFilterBox", "OperatorWidth")
    readonly property real _valW: root.th.ct("NumberFilterBox", "ValueWidth")
    readonly property var _ops: [{k:"eq",t:"="},{k:"ne",t:"≠"},{k:"lt",t:"<"},{k:"le",t:"≤"},{k:"gt",t:">"},{k:"ge",t:"≥"},{k:"between",t:"between"}]
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
            text: String(root.value)
            validator: DoubleValidator {
                bottom: isFinite(root.minimum) ? root.minimum : -1e9
                top: isFinite(root.maximum) ? root.maximum : 1e9
                decimals: Math.max(0, root.decimalPlaces)
            }
            onEditingFinished: {
                var v = parseFloat(text);
                if (isNaN(v)) v = 0;
                root.value = Math.max(root.minimum, Math.min(root.maximum, v));
                text = String(root.value);
                root.valueCommitted(root.value);
            }
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
