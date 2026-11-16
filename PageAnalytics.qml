// 「更大的整块」陈列页 —— 完整 TKCode.Arc 预设应用 ArcAnalyticsApp 整页。
// 真源码 templates/.../ArcAnalyticsApp：顶栏 56 + 五页 SegmentedControl 切换 + ThemeSwitcher；
// 五页各承载一个 showpiece，数据全部来自 SampleData/*.cs 真值（AnalyticsData.js）。
import QtQuick 2.15
import "." as Arc

Flickable {
    id: root
    property var th: null
    contentWidth: width
    contentHeight: _col.implicitHeight + 52
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: _col
        x: 28; y: 24
        width: root.width - 56
        spacing: 20

        Arc.ArcPageHeader {
            th: root.th; width: parent.width
            title: "Analytics app"
            subtitle: "ArcAnalyticsApp template — MainView.axaml + 5 showpiece pages, seeded SampleData."
        }

        Rectangle {
            width: parent.width; height: 1400
            radius: root.th.t4(root.th.design("RadiusPanel"), 0)
            color: root.th.c("SurfaceMuted")
            border.width: 1; border.color: root.th.c("Border")
            clip: true
            Arc.AnalyticsApp {
                anchors.fill: parent
                anchors.margins: 1
            }
        }
    }
}
