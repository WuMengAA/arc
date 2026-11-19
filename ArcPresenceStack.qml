// arc:PresenceStack —— Avatars/PresenceStack 真源码移植（PresenceStack.cs + PresenceStackToken.cs）。
// 在线头像栈：按状态排序（online → busy → away → offline），每张后一张压 Overlap(10)，超出收成 +N；
// 空闲成员 IdleOpacity(0.45) 压暗，+N 的 CountGap(8) 是数字与图标的间距。
// 令牌：Overlap10 / IdleOpacity0.45 / CountGap8 / ChipFontSize11。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var people: []         // [{name, status, seed}]
    property var th: null
    property string size: "sm"      // sm | md | lg
    property int max: 4
    property bool showCount: true
    property string viewerName: ""  // 可选：显示「你看」的那个人
    signal personActivated(int index)

    readonly property real _d: root.size === "sm" ? root.th.ct("Avatar", "DiameterSM")
                            : root.size === "lg" ? root.th.ct("Avatar", "DiameterLG")
                            : root.th.ct("Avatar", "DiameterMD")
    readonly property real _overlap: root.th.ct("PresenceStack", "Overlap")
    readonly property real _idle: root.th.ct("PresenceStack", "IdleOpacity")
    readonly property real _countGap: root.th.ct("PresenceStack", "CountGap")
    // 状态序：online 0 / busy 1 / away 2 / offline 3，其余排到最后
    function _rank(s) { return s === "online" ? 0 : s === "busy" ? 1 : s === "away" ? 2 : s === "offline" ? 3 : 4; }
    readonly property var _sorted: {
        var arr = [];
        for (var i = 0; i < root.people.length; i++) arr.push({ p: root.people[i], i: i });
        arr.sort(function (a, b) { var d = root._rank(a.p.status) - root._rank(b.p.status); return d !== 0 ? d : a.i - b.i; });
        return arr;
    }
    readonly property int _shown: Math.max(0, Math.min(root.max, root._sorted.length))
    readonly property int _extra: Math.max(0, root._sorted.length - root._shown)
    readonly property string _sizeName: root.size === "sm" ? "sm" : (root.size === "lg" ? "lg" : "md")
    implicitWidth: Math.max(0, root._shown * (root._d - root._overlap) + root._overlap
                            + (root._extra > 0 && root.showCount ? root._countGap + _cnt.implicitWidth + 6 : 0))
    implicitHeight: root._d

    Row {
        spacing: -root._overlap
        Repeater {
            model: root._shown
            delegate: Item {
                required property int index
                readonly property var entry: root._sorted[index]
                width: root._d; height: root._d
                z: 20 - index
                Arc.ArcAvatar {
                    anchors.fill: parent
                    th: root.th
                    name: (entry && entry.p && entry.p.name) ? entry.p.name : ""
                    seed: entry ? entry.i : 0
                    size: root._sizeName
                    status: (entry && entry.p) ? (entry.p.status || "") : ""
                    monochrome: true
                }
                // 空闲（非 online/busy）压暗
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: root.th ? root.th.c("Background") : "#FFFFFFFF"
                    opacity: (entry && entry.p && (entry.p.status === "online" || entry.p.status === "busy")) ? 0 : root._idle
                }
                MouseArea { anchors.fill: parent; onClicked: root.personActivated(entry ? entry.i : index) }
            }
        }
        Item {
            visible: root._extra > 0 && root.showCount
            width: root._countGap + _cnt.implicitWidth
            height: root._d
            Text {
                id: _cnt
                anchors.verticalCenter: parent.verticalCenter
                x: root._countGap
                renderType: Text.NativeRendering
                font.family: root.th ? root.th.fontFamily : "Segoe UI"
                text: "+" + root._extra
                color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                font.pixelSize: root.th.ct("PresenceStack", "ChipFontSize")
                font.weight: root.th ? root.th.weightMedium : 500
            }
        }
    }
}
