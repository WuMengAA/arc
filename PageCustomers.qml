// CustomersPage.axaml 的 QML 移植：标题 → 搜索/筛选/Clear → Table → Pagination → Drawer 详情。
import QtQuick 2.15
import "." as Arc
import "SampleData.js" as Sample

Item {
    id: root

    property var th: null
    property var strings: ({})   // issue 9：宿主文案桥
    property var customers: []
    property string search: ""
    property string status: "all"
    property int page: 1
    property int pageCount: 1
    property int selectedIndex: -1

    readonly property int pageSize: 12
    readonly property var filtered: {
        var out = [];
        var q = search.toLowerCase();
        var src = root.customers || [];
        for (var i = 0; i < src.length; i++) {
            var c = src[i];
            if (status !== "all" && c.status !== status) continue;
            if (q !== "" && (c.name + " " + c.email + " " + c.company).toLowerCase().indexOf(q) < 0) continue;
            out.push(c);
        }
        return out;
    }
    readonly property var pageRows: {
        var start = (page - 1) * pageSize;
        return filtered.slice(start, start + pageSize);
    }
    onFilteredChanged: { pageCount = Math.max(1, Math.ceil(filtered.length / pageSize)); if (page > pageCount) page = pageCount; }

    readonly property var columns: [
        { key: "name", title: qsTr("Customer") },
        { key: "company", title: qsTr("Company") },
        { key: "plan", title: qsTr("Plan"), width: 110 },
        { key: "status", title: qsTr("Status"), width: 110 },
        { key: "country", title: qsTr("Country"), width: 90 }
    ]

    Column {
        id: _col
        x: 28
        y: 24
        width: root.width - 56
        spacing: 0

        Arc.ArcPageHeader {
            th: root.th
            title: qsTr("Customers")
            subtitle: root.filtered.length + " customers · " + (root.status === "all" ? "all statuses" : root.status)
        }

        Item { width: 1; height: 16 }

        // 搜索 + 状态筛选 + Clear
        Row {
            width: parent.width
            spacing: 8

            Rectangle {
                width: Math.min(360, parent.width - 260)
                height: 36
                radius: root.th.t4(root.th.design("RadiusControl"), 0)
                color: root.th.c("Surface")
                border.width: root.th.design("EdgeThickness")
                border.color: _tf.activeFocus ? root.th.a("accent") : root.th.c("Border")

                TextInput { renderType: Text.NativeRendering; 
                    id: _tf
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    color: root.th.c("Foreground")
                    font.pixelSize: root.th.design("TypeSM")
                    selectByMouse: true
                    onTextChanged: root.search = text
                    Text { renderType: Text.NativeRendering; 
                        visible: _tf.text === ""
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Search by name, email or company")
                        color: root.th.c("TextMuted")
                        font: _tf.font
                    }
                }
            }

            Rectangle {
                width: 160
                height: 36
                radius: root.th.t4(root.th.design("RadiusControl"), 0)
                color: root.th.c("Surface")
                border.width: root.th.design("EdgeThickness")
                border.color: root.th.c("Border")
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.status === "all" ? "All statuses" : root.status
                    color: root.th.c("Foreground")
                    font.pixelSize: root.th.design("TypeSM")
                }
                Arc.ArcIcon {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    th: root.th
                    kind: "ChevronDown"
                    width: 14; height: 14
                    color: root.th.c("TextMuted")
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var order = ["all", "Active", "Trial", "PastDue", "Churned"];
                        var i = order.indexOf(root.status);
                        root.status = order[(i + 1) % order.length];
                        root.page = 1;
                    }
                }
            }

            Arc.ArcButton {
                th: root.th
                text: qsTr("Clear")
                variant: "ghost"
                onClicked: { root.search = ""; _tf.text = ""; root.status = "all"; root.page = 1; }
            }
        }

        Item { width: 1; height: 12 }

        // 表格
        Arc.ArcTable {
            width: parent.width
            height: root.height - _col.y - 24 - 44 - 12 - 16 - 36 - 12 - 12
            th: root.th
            columns: root.columns
            rows: root.pageRows
            caption: qsTr("Customers")
            selectedIndex: root.selectedIndex
            onRowActivated: function (i) { root.selectedIndex = i; }
        }

        Item { width: 1; height: 12 }

        // 分页
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6
            Arc.ArcButton {
                th: root.th; text: qsTr("Previous"); variant: "ghost"; size: "sm"
                enabled: root.page > 1
                onClicked: root.page = Math.max(1, root.page - 1)
            }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                anchors.verticalCenter: parent.verticalCenter
                text: root.page + " / " + root.pageCount
                color: root.th.c("TextSecondary")
                font.pixelSize: root.th.design("TypeSM")
            }
            Arc.ArcButton {
                th: root.th; text: qsTr("Next"); variant: "ghost"; size: "sm"
                enabled: root.page < root.pageCount
                onClicked: root.page = Math.min(root.pageCount, root.page + 1)
            }
        }
    }
}
