// arc:MoneyInput —— SpecialInputs/MoneyInput 真源码移植（MoneyInput.cs + MoneyInputToken.cs + MoneyInputAmount/
// MoneyInputCurrency/MoneyInputCurrencyMenu/MoneyInputDraft/MoneyInputParts/MoneyInputSymbol）。
// 大额输入：ShellHeight76 / ShellPadding[18,0,8,0]，货币按钮 CurrencyButtonHeight36（CurrencyButtonPadding[12,0,8,0]），
// 金额 AmountLineHeight43.2 / AmountLetterSpacing-1.08（大字），符号与静默位用 GhostDigitColor 画灰。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string value: ""
    property string currency: "USD"
    property string currencySymbol: "$"
    property var currencies: ["USD", "EUR", "GBP", "JPY", "CNY"]
    property bool valid: true
    signal currencySelected(string code)

    readonly property real _h: root.th.ct("MoneyInput", "ShellHeight")
    readonly property real _padL: root.th.t4(root.th.ct("MoneyInput", "ShellPadding"), 0)
    readonly property real _padR: root.th.t4(root.th.ct("MoneyInput", "ShellPadding"), 2)
    readonly property real _btnH: root.th.ct("MoneyInput", "CurrencyButtonHeight")
    readonly property real _btnPadL: root.th.t4(root.th.ct("MoneyInput", "CurrencyButtonPadding"), 0)
    readonly property real _lineH: root.th.ct("MoneyInput", "AmountLineHeight")
    readonly property real _ghost: root.th.ct("MoneyInput", "ChipMutedOpacity")
    implicitWidth: 320
    implicitHeight: root._h

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
        border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
        border.color: root.valid ? (root.th ? root.th.c("Border") : "#FFE0E0E0")
                                 : (root.th ? root.th.c("Danger") : "#FFCD1526")
    }
    // 货币符号（大）
    Text {
        x: root._padL
        anchors.verticalCenter: parent.verticalCenter
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        text: root.currencySymbol
        color: root.th ? root.th.ct("MoneyInput", "GhostDigitColor") : "#8C7D7D7D"
        font.pixelSize: root.th ? root.th.design("Type2XL") : 24
        font.weight: root.th ? root.th.weightMedium : 500
    }
    // 金额
    TextInput {
        id: _ti
        x: root._padL + _sym.implicitWidth + 2
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - x - root._padR - _curBtn.width - 8
        height: root._lineH
        verticalAlignment: TextInput.AlignVCenter
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.th ? root.th.design("Type2XL") : 24
        font.weight: root.th ? root.th.weightMedium : 500
        font.letterSpacing: root.th.ct("MoneyInput", "AmountLetterSpacing")
        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
        text: root.value
        selectByMouse: true
        validator: DoubleValidator { bottom: 0; top: 1e12; decimals: 2 }
        onTextChanged: root.value = text
        onEditingFinished: root.valid = (text !== "" && !isNaN(parseFloat(text.replace(/,/g, ""))))
    }
    Text {
        id: _sym
        visible: false
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.th ? root.th.design("Type2XL") : 24
        text: root.currencySymbol
    }
    // 货币按钮
    Rectangle {
        id: _curBtn
        anchors.right: parent.right
        anchors.rightMargin: root._padR
        anchors.verticalCenter: parent.verticalCenter
        width: _curTxt.implicitWidth + root._btnPadL + 8 + 16 + 4
        height: root._btnH
        radius: root._btnH / 2
        color: _cm2.containsMouse ? (root.th ? root.th.c("SurfaceMuted") : "#FFF0F0F0") : "transparent"
        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        Text {
            id: _curTxt
            x: root._btnPadL
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.currency
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightMedium : 500
        }
        Arc.ArcIcon {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 14; height: 14
            th: root.th; kind: "ChevronDown"
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        }
        MouseArea {
            id: _cm2
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                var i = root.currencies.indexOf(root.currency);
                var next = root.currencies[(i + 1) % root.currencies.length];
                root.currency = next;
                root.currencySelected(next);
            }
        }
    }
}
