// arc:BillingToggle —— Toggles/BillingToggle + BillingPrice 真值移植。
// PART_Thumb 双档滑条 + Badge("Save 20%")；月付/年付金额走 BillingPrice 的 CurrencyFontSize/WasInset。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string period: "year"      // month | year
    property real monthly: 24
    property real yearly: 19
    property string currency: "$"
    property bool large: false
    signal activated(string period)

    readonly property real _optH: th.ct("BillingToggle", large ? "OptionHeightLG" : "OptionHeight")
    readonly property real _inset: th.pad(th.ct("BillingToggle", large ? "TrackInsetLG" : "TrackInset"))
    readonly property real _px: th.t4(th.ct("BillingToggle", large ? "OptionInsetLG" : "OptionInset"), 0)
    readonly property real _badgeH: th.ct("BillingToggle", large ? "BadgeHeightLG" : "BadgeHeight")
    readonly property real _labelGap: th.ct("BillingToggle", "LabelGap")
    readonly property real _curSize: th.ct("BillingPrice", "CurrencyFontSize")
    readonly property real _wasIn: th.t4(th.ct("BillingPrice", "WasInset"), 2)
    readonly property real _rad: th.t4(th.design("RadiusPill"), 0)
    implicitWidth: 340; implicitHeight: _optH + 2 * _inset + 8
    width: implicitWidth; height: implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: root._rad
        color: th.c("SurfaceMuted")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
    }
    Rectangle {
        id: _thumb
        x: root._inset + (root.period === "year" ? (root.width - 2 * root._inset) / 2 : 0)
        y: root._inset
        width: (root.width - 2 * root._inset) / 2
        height: root._optH
        radius: root._rad
        color: th.c("Surface")
        border.width: th.t4(th.design("EdgeThickness"), 0)
        border.color: th.c("Border")
        Behavior on x { NumberAnimation { duration: th.dur("Fast"); easing.type: Easing.Bezier; easing.bezierCurve: th.ease("Standard") } }
    }
    Row {
        x: root._inset; y: root._inset
        Repeater {
            model: [{p:"month", label:"Monthly"}, {p:"year", label:"Yearly"}]
            delegate: Item {
                required property var modelData
                width: (root.width - 2 * root._inset) / 2; height: root._optH
                Row {
                    anchors.centerIn: parent; spacing: root._labelGap
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.label; color: th.c("Foreground"); font.pixelSize: th.design("TypeSM") }
                    Rectangle {
                        visible: modelData.p === "year"
                        width: 62; height: root._badgeH; radius: root._badgeH / 2
                        color: th.ct("BillingToggle", "BadgeBackground")
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: "Save 20%"; color: th.c("Success"); font.pixelSize: th.design("TypeXS") }
                    }
                }
                MouseArea { anchors.fill: parent; onClicked: root.activated(modelData.p) }
            }
        }
    }
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root._optH + 2 * root._inset + 2
        spacing: root._wasIn
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.currency; color: th.c("TextSecondary"); font.pixelSize: root._curSize }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: String(root.period === "year" ? root.yearly : root.monthly); color: th.c("Foreground"); font.pixelSize: th.design("TypeLG"); font.weight: th.design("WeightMedium") }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "/mo"; color: th.c("TextMuted"); font.pixelSize: th.design("TypeXS") }
    }
}
