// DashboardPage.axaml 的 QML 移植：标题块 → 4 列 MetricCard（间距 16）→ Card(Revenue) + LineChart PlotHeight 260。
// issue 9：title/subtitle/chartVisible 全部属性化，宿主经 strings 文案桥覆盖商业字面量；
// 无 days/revenue/previous 时整块图表不显示，而不是留一个空折线图框架。
import QtQuick 2.15
import "." as Arc

Flickable {
    id: root
    property var th: null
    property var model: null          // 宿主数据桥；null = 空白态
    property var strings: ({})
    property string title: ""
    property string subtitle: ""
    property string chartTitle: ""
    property string chartDescription: ""
    property bool chartVisible: true
    function t(key, fallback) { return root.strings && root.strings[key] !== undefined ? root.strings[key] : fallback; }
    readonly property bool _hasChart: !!root.model && !!root.model.days && !!root.model.revenue && root.model.revenue.length > 0
    contentWidth: width
    contentHeight: _col.implicitHeight + 52
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: _col
        x: 28
        y: 24
        width: root.width - 56
        spacing: 20

        Arc.ArcPageHeader {
            th: root.th
            title: root.title !== "" ? root.title : root.t("dashboardTitle", qsTr("Dashboard"))
            subtitle: root.subtitle !== "" ? root.subtitle : root.t("dashboardSubtitle", qsTr("How the business did over the last 30 days."))
        }

        // 4 列指标卡（无 model 时整块隐藏，不留空卡）
        Item {
            visible: !!root.model && !!root.model.kpis && root.model.kpis.length > 0
            width: parent.width
            height: _grid.implicitHeight
            Grid {
                id: _grid
                width: parent.width
                columns: 4
                columnSpacing: 16
                rowSpacing: 16
                Repeater {
                    model: root.model ? root.model.kpis : []
                    delegate: Arc.ArcMetricCard {
                        required property var modelData
                        th: root.th
                        width: (_grid.width - 3 * 16) / 4
                        label: modelData.label
                        value: modelData.value
                        prefix: modelData.prefix
                        suffix: modelData.suffix
                        decimals: modelData.decimals
                        change: modelData.change
                        context: root.model ? root.model.context : ""
                        up: modelData.change.indexOf("-") !== 0
                        sparkValues: root.model && root.model.revenue ? root.model.revenue.slice(0, 30) : []
                    }
                }
            }
        }

        // Revenue 卡片 + 折线图：无数据时整块隐藏（issue 9 要求）
        Arc.ArcCard {
            visible: root.chartVisible && root._hasChart
            width: parent.width
            th: root.th
            title: root.chartTitle !== "" ? root.chartTitle : root.t("revenueTitle", qsTr("Revenue"))
            description: root.chartDescription !== "" ? root.chartDescription : root.t("revenueDescription", qsTr("This period against the one before."))

            Column {
                id: _chartCol
                x: root.th.pad(root.th.n("card","ContentPadding"))
                y: root.th.pad(root.th.n("card","ContentPadding"))
                width: parent.width - 2 * root.th.pad(root.th.n("card","ContentPadding"))
                spacing: 12
                Item { width: 1; height: 0 }
                Arc.ArcLineChart {
                    th: root.th
                    width: parent.width
                    plotHeight: 260
                    days: root.model ? root.model.days : []
                    seriesList: root.model ? [
                        { name: root.t("seriesCurrent", qsTr("This period")), values: root.model.revenue, dashed: false },
                        { name: root.t("seriesPrevious", qsTr("Previous period")), values: root.model.previous || [], dashed: true }
                    ] : []
                }
            }
        }
    }
}
