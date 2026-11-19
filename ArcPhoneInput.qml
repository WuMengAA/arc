// arc:PhoneInput —— SpecialInputs/PhoneInput 真源码移植（PhoneInput.cs 971 行 + PhoneInputToken.cs + PhoneNumbers/
// PhoneInputCountryList/PhoneInputFace/PhoneInputParts）。
// 电话号码输入：左侧国家触发器（TriggerCornerRadius14 / TriggerPadding[9,0,33,0] / TriggerMargin[3,3,3,3]），
// 输入框 NumberPadding[12,0,36,0]；号码合法时右侧打勾（ValidSlotSize18 / ValidMargin[0,0,12,0]）；
// 控件底色 ControlFillColor（淡），聚焦时 HighlightColor。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property string number: ""
    property string country: "US"
    property string dialCode: "+1"
    property var countries: [{code:"US",dial:"+1",flag:"US"},{code:"CN",dial:"+86",flag:"CN"},{code:"JP",dial:"+81",flag:"JP"}]
    property bool valid: false
    signal countrySelected(string code, string dial)

    readonly property real _h: 44
    readonly property real _fill: root.th ? root.th.ct("PhoneInput", "ControlFillColor") : "#140B0B0B"
    readonly property real _hi: root.th ? root.th.ct("PhoneInput", "HighlightColor") : "#110B0B0B"
    readonly property real _trigRad: root.th.pad(root.th.ct("PhoneInput", "TriggerCornerRadius"))
    readonly property real _trigPadL: root.th.t4(root.th.ct("PhoneInput", "TriggerPadding"), 0)
    readonly property real _trigPadR: root.th.t4(root.th.ct("PhoneInput", "TriggerPadding"), 2)
    readonly property real _trigM: root.th.pad(root.th.ct("PhoneInput", "TriggerMargin"))
    readonly property real _numPadL: root.th.t4(root.th.ct("PhoneInput", "NumberPadding"), 0)
    readonly property real _validSize: root.th.ct("PhoneInput", "ValidSlotSize")
    readonly property real _validM: root.th.t4(root.th.ct("PhoneInput", "ValidMargin"), 2)
    implicitWidth: 260
    implicitHeight: root._h

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: root._fill
        border.width: _ni.activeFocus ? 1 : 0
        border.color: root.th ? root.th.a("accent") : "#FF2FB8C6"
        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
    }
    // 国家触发器
    Rectangle {
        x: root._trigM
        anchors.verticalCenter: parent.verticalCenter
        width: _ct.implicitWidth + root._trigPadL + root._trigPadR + 14
        height: parent.height - 2 * root._trigM
        radius: root._trigRad
        color: _cm6.containsMouse ? root._hi : "transparent"
        Behavior on color { ColorAnimation { duration: root.th ? root.th.dur("Fast") : 160 } }
        Text {
            id: _ct
            x: root._trigPadL
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.NativeRendering
            font.family: root.th ? root.th.fontFamily : "Segoe UI"
            text: root.country + " " + root.dialCode
            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
            font.weight: root.th ? root.th.weightMedium : 500
        }
        Arc.ArcIcon {
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            width: 12; height: 12
            th: root.th; kind: "ChevronDown"
            color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
        }
        MouseArea {
            id: _cm6
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                var i = 0;
                for (var j = 0; j < root.countries.length; j++) if (root.countries[j].code === root.country) i = j;
                var n = root.countries[(i + 1) % root.countries.length];
                root.country = n.code;
                root.dialCode = n.dial;
                root.countrySelected(n.code, n.dial);
            }
        }
    }
    // 号码
    TextInput {
        id: _ni
        anchors.left: parent.left
        anchors.leftMargin: root._trigM + _ct.parent.width + 6
        anchors.right: parent.right
        anchors.rightMargin: root._numPadL + (root.valid ? root._validSize + root._validM : 0)
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        verticalAlignment: TextInput.AlignVCenter
        renderType: Text.NativeRendering
        font.family: root.th ? root.th.fontFamily : "Segoe UI"
        font.pixelSize: root.th ? root.th.design("TypeSM") : 13
        color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
        text: root.number
        selectByMouse: true
        inputMethodHints: Qt.ImhDialableCharactersOnly
        onTextChanged: {
            root.number = text;
            root.valid = text.replace(/[^0-9]/g, "").length >= 7;
        }
    }
    // 合法勾
    Arc.ArcIcon {
        visible: root.valid
        anchors.right: parent.right
        anchors.rightMargin: root._validM
        anchors.verticalCenter: parent.verticalCenter
        width: root._validSize; height: root._validSize
        th: root.th; kind: "Check"
        color: root.th ? root.th.c("Success") : "#FF007824"
    }
}
