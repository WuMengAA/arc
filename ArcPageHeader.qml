// 页面标题块：Type2XL Medium + 副标题 TypeBase TextSecondary（Spacing 4），五个页面共用。
import QtQuick 2.15

Column {
    id: root

    property var th: null
    property string title: ""
    property string subtitle: ""

    spacing: 4

    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
        text: root.title
        color: root.th.c("Foreground")
        font.pixelSize: root.th.design("Type2XL")
        font.weight: root.th.design("WeightMedium")
        font.letterSpacing: -0.4
        Accessible.role: Accessible.StaticText; Accessible.name: root.title
    }
    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
        visible: root.subtitle !== ""
        text: root.subtitle
        color: root.th.c("TextSecondary")
        font.pixelSize: root.th.design("TypeBase")
    }
}
