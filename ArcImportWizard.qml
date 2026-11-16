// arc:ImportWizard —— 官方帧 "Match fields / 1 of 8 columns mapped" 的可交互移植。
// 真源码 ImportWizardDefaults.cs（customers-q3.csv 8 列 / 22 行真实样本）、ImportWizardMapView/Footer。
// 真行为：4 步翻页、映射下拉选目标并实时计数、Review 逐行校验、Import 进度动画。
import QtQuick 2.15
import "." as Arc
import "ArcShowcaseData.js" as Showcase

Rectangle {
    id: root
    property var th: null
    property var showcase: Showcase.ArcShowcase.importWizard
    property int step: 1
    property int mappedCount: 1
    property int importPct: 0
    property int openRow: -1
    property real _dropX: 0
    property real _dropY: 0
    property int _rev: 0
    property var _targets: [0, 1, 2, 3, 4, 5, 6, 7]
    property var _confirmed: [0]
    signal completed()
    readonly property real _pad: th.pad(th.ct("ImportWizard", "StepPadding"))
    readonly property real _headT: th.t4(th.ct("ImportWizard", "HeaderPadding"), 1)
    readonly property real _stepGap: th.ct("ImportWizard", "StepSpacing")
    readonly property var _steps: (root.showcase && root.showcase.steps) || ["Upload", "Match fields", "Review", "Import"]
    readonly property var _rows: (root.showcase && root.showcase.rows) || []
    readonly property var _opts: (root.showcase && root.showcase.options) || []
    readonly property var _contacts: (root.showcase && root.showcase.contacts) || []
    width: Math.min(th.ct("ImportWizard", "MaxWidth"), 760); height: 640
    radius: th.t4(th.design("RadiusSurface"), 0)
    color: th.c("Surface"); border.width: th.t4(th.design("EdgeThickness"), 0); border.color: th.c("Border")
    clip: true
    function _touch() { root._rev = root._rev + 1; }
    function _choose(row, opt) {
        var t = root._targets.slice(); t[row] = opt; root._targets = t;
        var c = root._confirmed.slice();
        if (c.indexOf(row) < 0 && opt !== 7) c.push(row);
        if (opt === 7) { var k = c.indexOf(row); if (k >= 0) c.splice(k, 1); }
        root._confirmed = c; root.mappedCount = c.length; root.openRow = -1; root._touch();
    }
    function _issue(row) {
        var c = root._contacts[row]; if (!c) return "";
        var name = c["Contact name"] || "", email = c["Email"] || "", phone = c["Cell"] || "";
        if (name.trim() === "") return "Add a name";
        if ((email.match(/@/g) || []).length !== 1 || email.indexOf(".") < 0 || /\s/.test(email.trim()) || email !== email.trim()) return "Fix email";
        if (email !== email.toLowerCase() || email.indexOf("..") >= 0) return "Lowercase email";
        if (/^(US|U\.S\.|USA|U\.S\.A\.|UK|U\.K\.|GB|NL|DE|FR|ES|BR|JP|AU|CA|SE|PT|MX)$/i.test(c["Country"] || "")) return "Expand country";
        if (phone && /[a-zA-Z]/.test(phone)) return "Fix phone";
        return "";
    }
    function _next() {
        if (root.step < 3) { root.step = root.step + 1; root.openRow = -1; }
        if (root.step === 3) { root.importPct = 0; _timer.running = true; }
    }
    Timer {
        id: _timer; interval: 180; repeat: true; running: false
        onTriggered: {
            root.importPct = Math.min(100, root.importPct + 8);
            if (root.importPct >= 100) { _timer.running = false; root.completed(); }
        }
    }
    // PART_Stepper：圆点 + 名称 + 连接线；点击可跳步。
    Row {
        x: root._pad; y: root._headT; spacing: root._stepGap
        Repeater {
            model: root._steps
            delegate: Row {
                required property var modelData; required property int index
                spacing: 8
                Rectangle {
                    objectName: "hit:iwStep" + index
                    width: 24; height: 24; radius: 12
                    color: index < root.step ? root.th.c("TextMuted") : index === root.step ? root.th.c("Foreground") : root.th.c("SurfaceMuted")
                    border.width: index > root.step ? 1 : 0; border.color: root.th.c("Border")
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.centerIn: parent; text: index < root.step ? "✓" : String(index + 1); color: index > root.step ? root.th.c("TextMuted") : root.th.c("Background"); font.pixelSize: 14 }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.step = index; root.openRow = -1; } }
                }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData; color: index === root.step ? root.th.c("Foreground") : root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS"); anchors.verticalCenter: parent.verticalCenter }
                Rectangle { visible: index < 3; width: 34; height: 1; color: index < root.step ? root.th.c("Foreground") : root.th.c("Border"); anchors.verticalCenter: parent.verticalCenter }
            }
        }
    }
    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  x: root._pad; y: 76; text: root.step === 0 ? "Upload a CSV" : root.step === 1 ? "Match fields" : root.step === 2 ? "Check rows" : "Importing contacts"; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeXL"); font.weight: root.th.design("WeightMedium") }
    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  x: root._pad; y: 110; text: root.step === 1 ? String(root.mappedCount) + " of 8 columns mapped — click a target to change it" : root.step === 2 ? String(root._contacts.length) + " rows · issues are highlighted" : root.step === 3 ? String(root.importPct) + "% complete" : "customers-q3.csv · 8 columns · 22 rows"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM") }

    // ---- Step 0：上传 ----
    Rectangle {
        visible: root.step === 0; x: root._pad; y: 150; width: parent.width - 2 * root._pad; height: 300
        radius: 22; color: root.th.c("SurfaceMuted"); border.width: 1; border.color: root.th.c("Border")
        Column {
            anchors.centerIn: parent; spacing: 12
            Arc.ArcIcon { th: root.th; kind: "FileText"; width: 38; height: 38; color: root.th.a("accent"); anchors.horizontalCenter: parent.horizontalCenter }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "customers-q3.csv"; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeLG"); font.weight: root.th.design("WeightMedium"); anchors.horizontalCenter: parent.horizontalCenter }
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "22 rows · drag & drop or click to replace"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM"); anchors.horizontalCenter: parent.horizontalCenter }
        }
    }

    // ---- Step 1：映射表（下拉可点，实时计数）----
    Rectangle {
        visible: root.step === 1; x: root._pad; y: 140; width: parent.width - 2 * root._pad; height: 8 * 56 + 8
        radius: 22; color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("Border"); clip: true; z: 6
        Column {
            id: _list; x: 8; y: 4; width: parent.width - 16; spacing: 0
            Repeater {
                model: root._rev >= 0 ? root._rows : []
                delegate: Rectangle {
                    required property var modelData; required property int index
                    property int rowIndex: index
                    z: root.openRow === rowIndex ? 30 : 0
                    width: _list.width; height: 56
                    color: "transparent"; border.width: rowIndex > 0 ? 1 : 0; border.color: root.th.c("BorderSubtle")
                    Row {
                        x: 10; anchors.verticalCenter: parent.verticalCenter; spacing: 8
                        Column {
                            width: 216; anchors.verticalCenter: parent.verticalCenter
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.source; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium"); width: parent.width; elide: Text.ElideRight }
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.samples; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS"); width: parent.width; elide: Text.ElideRight }
                        }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: "→"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM"); anchors.verticalCenter: parent.verticalCenter }
                        Rectangle {
                            id: _drop
                            objectName: "hit:iwDrop" + rowIndex
                            width: 240; height: 34; radius: 17; z: root.openRow === rowIndex ? 4 : 1
                            color: root.th.c("Surface"); border.width: 1; border.color: root.openRow === rowIndex ? root.th.a("accent") : root.th.c("Border")
                            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.verticalCenter: parent.verticalCenter; x: 14; text: root._opts[root._targets[rowIndex]] || ""; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") }
                            Arc.ArcIcon { anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; th: root.th; kind: "ChevronDown"; width: 14; height: 14; color: root.th.c("TextMuted"); rotation: root.openRow === rowIndex ? 180 : 0 }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { if (root.openRow === rowIndex) root.openRow = -1; else { root._dropX = 258; root._dropY = rowIndex * 56 + 49; root.openRow = rowIndex; } } }
                        }
                        Item { width: 20; height: 1 }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root._confirmed.indexOf(rowIndex) >= 0 ? "Chosen" : "Matching"; color: root._confirmed.indexOf(rowIndex) >= 0 ? root.th.c("Success") : root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS"); anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }
        }
    }

    // 单一浮层：点在 _box 坐标系，避开行 delegate 的 clip / z 兄弟覆盖。
    Rectangle {
        visible: root.openRow >= 0; x: root._pad + root._dropX; y: 140 + root._dropY; width: 240; height: root._opts.length * 30 + 8
        radius: 14; z: 40; color: root.th.c("SurfaceRaised"); border.width: 1; border.color: root.th.c("Border")
        Repeater {
            model: root._opts
            delegate: Rectangle {
                required property var modelData; required property int index
                property int oi: index
                width: 228; height: 30; x: 6; y: 4 + oi * 30; radius: 8
                objectName: "hit:iwOpt" + oi
                color: root.openRow >= 0 && root._targets[root.openRow] === oi ? root.th.c("SurfaceMuted") : "transparent"
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  x: 10; anchors.verticalCenter: parent.verticalCenter; text: modelData; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeXS") }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; enabled: root.openRow >= 0; onClicked: root._choose(root.openRow, oi) }
            }
        }
    }
    // ---- Step 2：Review 22 行真实数据 ----
    Flickable {
        visible: root.step === 2; x: root._pad; y: 140; width: parent.width - 2 * root._pad; height: 420
        contentWidth: width; contentHeight: _review.implicitHeight; clip: true
        boundsBehavior: Flickable.StopAtBounds
        Column {
            id: _review; width: parent.width; spacing: 0
            Repeater {
                model: root._contacts
                delegate: Rectangle {
                    required property var modelData; required property int index
                    width: _review.width; height: 42
                    color: root._issue(index) !== "" ? root.th.fade(root.th.c("Warning"), 0.10) : (index % 2 ? root.th.c("SurfaceMuted") : root.th.c("Surface"))
                    border.width: 1; border.color: root.th.c("BorderSubtle")
                    Row {
                        x: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 12
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  width: 170; text: modelData["Contact name"] || "(missing)"; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeXS"); elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  width: 210; text: modelData["Email"] || ""; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS"); elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  width: 150; text: modelData["Organization"] || ""; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS"); elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root._issue(index); color: root.th.c("Warning"); font.pixelSize: root.th.design("TypeXS"); anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }
        }
    }

    // ---- Step 3：进度 ----
    Column {
        visible: root.step === 3; x: root._pad; y: 180; width: parent.width - 2 * root._pad; spacing: 16
        Rectangle { width: parent.width; height: 10; radius: 5; color: root.th.c("SurfaceMuted")
            Rectangle { width: parent.width * root.importPct / 100; height: 10; radius: 5; color: root.th.a("accent"); Behavior on width { NumberAnimation { duration: root.th.dur("Fast") } } } }
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.importPct >= 100 ? "Done — 22 contacts imported" : "Validating and writing contacts…"; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM") }
    }

    // PART_Footer：Back / Next（第 3 步变 Done）
    Row {
        anchors.bottom: parent.bottom; anchors.bottomMargin: 16; spacing: 8
        x: root._pad; width: parent.width - 2 * root._pad
        Arc.ArcButton { th: root.th; text: "Back"; variant: "secondary"; size: "sm"; icon: "ArrowLeft"; onClicked: if (root.step > 0) { root.step = root.step - 1; root.openRow = -1; } }
        Item { width: parent.width - 250; height: 1 }
        Arc.ArcButton { th: root.th; text: root.step === 2 ? "Import" : root.step === 3 ? "Done" : "Check rows"; size: "sm"; icon: "ArrowRight"; onClicked: root._next() }
    }
}
