// BillingPage.axaml 的 QML 移植：BillingOverview 块（方案 / 支付方式 / 发票列表），最大宽度 820。
import QtQuick 2.15
import "." as Arc

Flickable {
    id: root

    property var th: null
    property var strings: ({})   // issue 9：宿主文案桥
    property var info: null           // SampleData.billing()

    contentWidth: width
    contentHeight: _col.implicitHeight + 52
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: _col
        x: 28
        y: 24
        width: Math.min(root.width - 56, 820)
        spacing: 16

        Arc.ArcPageHeader {
            th: root.th
            title: qsTr("Billing")
            subtitle: qsTr("The plan, the card on file and past invoices.")
        }

        Arc.ArcCard {
            width: parent.width
            th: root.th
            title: root.info ? root.info.plan + " plan" : "Plan"
            description: root.info ? root.info.seats : ""

            Row {
                width: parent.width - 2 * root.th.pad(root.th.n("card","ContentPadding"))
                x: root.th.pad(root.th.n("card","ContentPadding"))
                height: 64
                spacing: 40

                Column {
                    spacing: 4
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.info ? root.info.price : ""; color: root.th.c("Foreground"); font.pixelSize: root.th.design("Type2XL"); font.weight: root.th.design("WeightMedium") }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.info ? root.info.renews : ""; color: root.th.c("TextMuted"); font.pixelSize: 15 }
                }

                Column {
                    spacing: 4
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: qsTr("Payment method"); color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM") }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.info ? root.info.paymentMethod : ""; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.info ? root.info.expires : ""; color: root.th.c("TextMuted"); font.pixelSize: 15 }
                }

            }
        }

        Arc.ArcCard {
            width: parent.width
            th: root.th
            title: qsTr("Invoices")
            description: qsTr("Everything charged to ") + (root.info ? root.info.billingEmail : "") + "."

            Column {
                width: parent.width - 2 * root.th.pad(root.th.n("card","ContentPadding"))
                x: root.th.pad(root.th.n("card","ContentPadding"))
                spacing: 0

                Repeater {
                    model: root.info ? root.info.invoices : []
                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: parent.width
                        height: 46
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.verticalCenter: parent.verticalCenter; x: 0; text: modelData.id; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.verticalCenter: parent.verticalCenter; x: 110; text: modelData.date; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.verticalCenter: parent.verticalCenter; anchors.right: parent.right; anchors.rightMargin: 90; text: modelData.amount; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM") }
                        Arc.ArcBadge { anchors.verticalCenter: parent.verticalCenter; anchors.right: parent.right; th: root.th; small: true; text: modelData.status; tone: "success" }
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: index < ((root.info && root.info.invoices ? root.info.invoices.length : 0) - 1) ? root.th.c("BorderSubtle") : "transparent" }
                    }
                }
            }
        }
    }
}
