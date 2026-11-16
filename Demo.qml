// TKCode.Arc → Qt/QML port · standalone demo
// 运行：qml Demo.qml     （Qt 6；不需要 CMake / C++ / QtShadcn / import path）
// 说明：本文件是包内自带的预览窗口；宿主工程直接用 ArcAdminApp，不必加载本文件。
import QtQuick 2.15
import QtQuick.Window 2.15
import "." as Arc
import "SampleData.js" as Sample

Window {
    id: win
    visible: true
    width: 1600; height: 1000
    minimumWidth: 1024; minimumHeight: 700
    title: "TKCode.Arc → Qt/QML | dark=" + app.startDark + " accent=" + app.startAccent
    color: "#FFFFFFFF"

    // Window 不是 Item（没有 focus 属性）：焦点放在内容 Item 上处理快捷键。
    Item {
        anchors.fill: parent
        focus: true
        Keys.onPressed: function (ev) {
            if (ev.key === Qt.Key_D) app.setDark(!app.startDark)
            else if (ev.key === Qt.Key_A) app.setAccent((app.startAccent + 1) % 8)
            else if (ev.key === Qt.Key_S) app.section = "surfaces"
            else if (ev.key === Qt.Key_1) app.section = "dashboard"
        }

        Arc.ArcAdminApp {
            id: app
            anchors.fill: parent
            section: "dashboard"
            // Demo 是包内展示窗口：显式注入合成示例数据；宿主默认四个数据源为空（issue 8）。
            customersData: Sample.customers()
            dashboardData: Sample.dashboard(app.customersData)
            workspaceData: Sample.workspace()
            billingData: Sample.billing()
        }
    }

    Component.onCompleted: console.log("ARC_DEMO_READY section=dashboard")
}
