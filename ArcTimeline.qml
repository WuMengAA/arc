// arc:Timeline —— Activity/Timeline 真源码移植（Timeline.cs 1264 行 + TimelineToken.cs + TimelineEvent/
// TimelineParts/TimelineRow）。
// 时间线：左侧时间列（TimeMinWidth44 / TimeMargin[12,0,0,0]）+ 竖轴 + 事件卡（MarkerSize28 / MarkerRingColor，
// MarkerGlyphSize14 / MarkerGlyphStroke2）；日期分组（DayCountSpacing3 / DayPadding[0,8,12,8]）；
// 内容缩进 ContentMargin[36,0,0,0]；一天结束有 FeatherHeight36 渐隐。
import QtQuick 2.15
import "." as Arc

Item {
    id: root
    property var th: null
    property var events: []            // [{time, title, detail?, day?, glyph?}]
    property string now: ""
    property string label: ""
    property real dayGap: 0

    readonly property real _timeW: root.th.ct("Timeline", "TimeMinWidth")
    readonly property real _timeM: root.th.t4(root.th.ct("Timeline", "TimeMargin"), 0)
    readonly property real _marker: root.th.ct("Timeline", "MarkerSize")
    readonly property real _glyphSize: root.th.ct("Timeline", "MarkerGlyphSize")
    readonly property real _glyphStroke: root.th.ct("Timeline", "MarkerGlyphStroke")
    readonly property real _contentM: root.th.t4(root.th.ct("Timeline", "ContentMargin"), 0)
    readonly property real _rowPad: root.th.pad(root.th.ct("Timeline", "TriggerPadding"))
    readonly property real _titleLH: root.th.ct("Timeline", "TitleLineHeight")
    readonly property real _metaLH: root.th.ct("Timeline", "MetaLineHeight")
    readonly property real _gap: root.dayGap > 0 ? root.dayGap : root.th.ct("Timeline", "DayGap")
    implicitWidth: 380
    implicitHeight: _col.implicitHeight

    Column {
        id: _col
        width: parent.width
        spacing: root._gap
        Repeater {
            model: root.events.length
            delegate: Item {
                required property int index
                readonly property var ev: root.events[index]
                width: _col.width
                height: _card.height + 8
                // 时间
                Text {
                    x: root._timeM
                    y: 4
                    width: root._timeW
                    horizontalAlignment: Text.AlignRight
                    renderType: Text.NativeRendering
                    font.family: root.th ? root.th.fontFamily : "Segoe UI"
                    text: ev ? (ev.time || "") : ""
                    color: root.th ? root.th.c("TextMuted") : "#FF9A9A9A"
                    font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                    lineHeight: root._metaLH
                    lineHeightMode: Text.FixedHeight
                }
                // 轴与标记
                Rectangle {
                    x: root._timeM + root._timeW + 10
                    y: 0
                    width: 1
                    height: parent.height
                    color: root.th ? root.th.c("Border") : "#FFE0E0E0"
                    opacity: 0.7
                }
                Rectangle {
                    x: root._timeM + root._timeW + 10 - root._marker / 2 + 0.5
                    y: 2
                    width: root._marker; height: root._marker
                    radius: width / 2
                    color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
                    border.width: 2
                    border.color: root.th ? root.th.ct("Timeline", "MarkerRingColor") : "#1A0B0B0B"
                    Arc.ArcIcon {
                        anchors.centerIn: parent
                        width: root._glyphSize; height: root._glyphSize
                        th: root.th
                        kind: ev && ev.glyph ? ev.glyph : "Circle"
                        color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                    }
                }
                // 事件卡
                Rectangle {
                    id: _card
                    x: root._timeM + root._timeW + 10 + root._contentM - 10
                    width: parent.width - x - 4
                    height: _ti.implicitHeight + 2 * root._rowPad
                    radius: 12
                    color: root.th ? root.th.c("Surface") : "#FFFFFFFF"
                    border.width: root.th ? root.th.t4(root.th.design("EdgeThickness"), 0) : 1
                    border.color: root.th ? root.th.c("Border") : "#FFE0E0E0"
                    Column {
                        x: root._rowPad
                        y: root._rowPad
                        width: parent.width - 2 * root._rowPad
                        spacing: 2
                        Text {
                            id: _ti
                            width: parent.width
                            renderType: Text.NativeRendering
                            font.family: root.th ? root.th.fontFamily : "Segoe UI"
                            text: ev ? (ev.title || "") : ""
                            color: root.th ? root.th.c("Foreground") : "#FF1D1D1D"
                            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                            font.weight: root.th ? root.th.weightMedium : 500
                            lineHeight: root._titleLH
                            lineHeightMode: Text.FixedHeight
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            width: parent.width
                            visible: ev && ev.detail !== undefined
                            text: ev && ev.detail !== undefined ? ev.detail : ""
                            wrapMode: Text.WordWrap
                            renderType: Text.NativeRendering
                            font.family: root.th ? root.th.fontFamily : "Segoe UI"
                            font.pixelSize: root.th ? root.th.design("TypeXS") : 11
                            color: root.th ? root.th.c("TextSecondary") : "#FF6D6D6D"
                            lineHeight: root._metaLH
                            lineHeightMode: Text.FixedHeight
                        }
                    }
                }
            }
        }
    }
}
