// arc:DockLayout —— 官方帧 IDE 布局的可交互移植。
// 真源码 DockSamples.cs：ToolGroup(Explorer/Search) + DocumentGroup(README.md/App.axaml) +
// TerminalGroup + 右 Outline。真行为：工具窗格切换、文档标签换内容、分隔条拖拽调宽、
// 底部 Terminal/Problems 切换、Outline 展开、浮动文件卡拖动、代码区可编辑。
import QtQuick 2.15
import "." as Arc
import "ArcShowcaseData.js" as Showcase

Rectangle {
    id: root
    property var th: null
    property var showcase: Showcase.ArcShowcase.dock
    property int activeTab: 0
    property string activeTool: "Explorer"
    property string activeBottom: "Terminal"
    property real leftW: 218
    property bool outlineOpen: false
    property real floatX: -1
    property real floatY: -1
    property string codeText: ""
    property int _rev: 0
    readonly property real _pad: th.pad(th.ct("DockLayout", "Padding"))
    readonly property real _gap: th.ct("DockLayout", "Gap")
    readonly property real _tabH: th.ct("DockTab", "Height")
    readonly property real _groupH: th.ct("DockGroupView", "StripHeight")
    readonly property var _readme: ["# Northwind", "", "Avalonia app shell sample.", "", "- ArcTheme tokens", "- Dock layout", "- Import wizard"]
    readonly property var _appaxaml: (root.showcase && root.showcase.code) || []
    width: 1000; height: 430
    color: th.c("Background"); border.width: 1; border.color: th.c("Border"); radius: th.t4(th.design("RadiusPanel"), 0); clip: true
    function _touch() { root._rev = root._rev + 1; }
    onActiveTabChanged: _editor.text = root._codeLines().join("\n")
    function _selectTab(i) { root.activeTab = i; root._touch(); }
    function _toggleOutline() { root.outlineOpen = !root.outlineOpen; root._touch(); }
    function _codeLines() { return root.activeTab === 0 ? root._readme : root._appaxaml; }

    Row {
        x: root._pad; y: root._pad; spacing: root._gap
        width: parent.width - 2 * root._pad; height: parent.height - 2 * root._pad
        // ---- 左工具窗格（宽度可拖）----
        Rectangle {
            width: root.leftW; height: parent.height
            color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("Border")
            Column {
                width: parent.width
                Rectangle {
                    width: parent.width; height: root._groupH; color: root.th.c("Surface")
                    Row {
                        x: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 12
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.showcase.explorer; color: root.activeTool === "Explorer" ? root.th.c("Foreground") : root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium"); anchors.verticalCenter: parent.verticalCenter
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.activeTool = "Explorer" } }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.showcase.search; color: root.activeTool === "Search" ? root.th.c("Foreground") : root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium"); anchors.verticalCenter: parent.verticalCenter
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.activeTool = "Search" } }
                    }
                }
                Rectangle { width: parent.width; height: 1; color: root.th.c("Border") }
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    visible: root.activeTool === "Search"; x: 20; y: 24; text: root.showcase.searchEmpty
                    color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM")
                }
                Column {
                    visible: root.activeTool === "Explorer"; x: 20; y: 18; spacing: 8
                    Repeater {
                        model: ["src/", "  App.axaml", "  MainWindow.axaml", "assets/", "README.md"]
                        delegate: Text { renderType: Text.NativeRendering;  required property var modelData; text: modelData; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS"); font.family: root.th ? root.th.monoFamily : "Consolas" }
                    }
                }
                Repeater {
                    model: [{ x: 12, y: 180 }, { x: 88, y: 64 }, { x: 164, y: 64 }, { x: 240, y: 64 }, { x: 164, y: 140 }, { x: 164, y: 216 }]
                    delegate: Rectangle {
                        required property var modelData
                        x: modelData.x; y: modelData.y; width: 34; height: 34; radius: 8; color: root.th.c("SurfaceMuted")
                        Arc.ArcIcon { anchors.centerIn: parent; th: root.th; kind: "SquareDashed"; width: 15; height: 15; color: root.th.c("BorderStrong") }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.activeTab = 1 }
                    }
                }
            }
        }
        // ---- 分隔条（拖拽调宽）----
        Rectangle {
            objectName: "hit:dkSplit"
            width: 6; height: parent.height; color: "transparent"
            MouseArea {
                anchors.fill: parent; cursorShape: Qt.SplitHCursor
                preventStealing: true   // 拖分隔条不滚页面
                property real _sx: 0; property real _sw: 0
                onPressed: { _sx = mouseX; _sw = root.leftW; }
                onPositionChanged: if (pressed) root.leftW = Math.max(150, Math.min(360, _sw + mouseX - _sx));
            }
        }
        // ---- 右主区 ----
        Column {
            width: parent.width - root.leftW - 6 - root._gap - 30 - (root.outlineOpen ? 150 : 0); height: parent.height; spacing: 0
            Rectangle {
                width: parent.width; height: root._tabH + 8; color: root.th.c("SurfaceMuted")
                Row {
                    x: 0; y: 4; width: parent.width; height: root._tabH
                    Repeater {
                        model: root.showcase.tabs
                        delegate: Rectangle {
                            required property var modelData; required property int index
                            objectName: "hit:dkTab" + index
                            width: 132; height: root._tabH
                            color: root.activeTab === index ? root.th.c("Surface") : "transparent"
                            border.width: 1; border.color: root.th.c("BorderSubtle")
                            Row { anchors.verticalCenter: parent.verticalCenter; x: 10; spacing: 6; Arc.ArcIcon { th: root.th; kind: "FileText"; width: 12; height: 12; color: root.th.a("accent") } Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData; color: root.activeTab === index ? root.th.c("Foreground") : root.th.c("TextSecondary"); font.pixelSize: root.th.ct("DockTab", "FontSize") } }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root._selectTab(index) }
                        }
                    }
                }
            }
            // 代码编辑区（TextEdit 可编辑，切标签换内容）
            Rectangle {
                width: parent.width; height: parent.height * 0.68
                color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("Border"); clip: true
                TextEdit { renderType: Text.NativeRendering; 
                    id: _editor
                    x: 28; y: 20; width: parent.width - 56; height: parent.height - 40
                    color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.family: root.th ? root.th.monoFamily : "Consolas"
                    selectByMouse: true; wrapMode: TextEdit.NoWrap
                    text: root._codeLines().join("\n")
                    onTextChanged: root.codeText = text
                }
                Rectangle {
                    x: root.floatX < 0 ? parent.width / 2 - 96 : root.floatX
                    y: root.floatY < 0 ? parent.height - 92 : root.floatY
                    width: 192; height: 40; radius: 10; z: 3
                    color: root.th.c("SurfaceRaised"); border.width: 1; border.color: root.th.c("Border")
                    Row { anchors.centerIn: parent; spacing: 8; Arc.ArcIcon { th: root.th; kind: "FileText"; width: 14; height: 14; color: root.th.a("accent") } Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.showcase.float; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") } }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.SizeAllCursor
                        preventStealing: true   // 拖浮动卡不滚页面
                        property real _sx: 0; property real _sy: 0; property real _fx: 0; property real _fy: 0
                        onPressed: { _sx = mouseX; _sy = mouseY; _fx = parent.x; _fy = parent.y; }
                        onPositionChanged: if (pressed) { root.floatX = Math.max(0, Math.min(parent.parent.width - 192, _fx + mouseX - _sx)); root.floatY = Math.max(0, Math.min(parent.parent.height - 40, _fy + mouseY - _sy)); }
                    }
                }
            }
            // 底部 Terminal / Problems
            Rectangle {
                width: parent.width; height: parent.height * 0.32 - root._tabH - 8
                color: root.th.c("Surface"); border.width: 1; border.color: root.th.c("Border")
                Row {
                    x: 16; y: 12; spacing: 16
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.showcase.terminal; color: root.activeBottom === "Terminal" ? root.th.c("Foreground") : root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium"); anchors.verticalCenter: parent.verticalCenter
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.activeBottom = "Terminal" } }
                    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.showcase.problems; color: root.activeBottom === "Problems" ? root.th.c("Foreground") : root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium"); anchors.verticalCenter: parent.verticalCenter
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.activeBottom = "Problems" } }
                }
                Text { renderType: Text.NativeRendering;  x: 32; y: 52; text: root.activeBottom === "Terminal" ? "$ dotnet run  ·  ready" : root.showcase.problemsEmpty; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM"); font.family: root.th ? root.th.monoFamily : "Consolas" }
            }
        }
        // ---- 右自动隐藏条 / 展开面板 ----
        Rectangle {
            objectName: "hit:dkOutline"
            width: root.outlineOpen ? 150 : 30; height: parent.height
            color: root.th.c("SurfaceMuted"); border.width: 1; border.color: root.th.c("Border")
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  visible: !root.outlineOpen; anchors.centerIn: parent; text: root.showcase.outline; rotation: 90; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS") }
            Column {
                visible: root.outlineOpen; x: 12; y: 16; spacing: 10
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: root.showcase.outline; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") }
                Repeater { model: ["Application", "Styles", "ArcTheme", "Resources"]; delegate: Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  required property var modelData; text: "· " + modelData; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS") } }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root._toggleOutline() }
            Behavior on width { NumberAnimation { duration: root.th.dur("Standard"); easing.type: Easing.Bezier; easing.bezierCurve: root.th.ease("Standard") } }
        }
    }
}
