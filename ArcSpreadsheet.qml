// arc:DataGrid —— 官方帧 "5 rows 行内编辑" 与 "240 rows 分组账本" 的可交互移植。
// 真行为：单击单元格编辑(Enter 提交/Esc 取消)、勾选与归档、搜索、列头排序、撤销重做、
// 分组折叠、列显隐、紧凑密度、导出；数值汇总随编辑实时重算。数据 AdvancedCharts/DataGrid。
import QtQuick 2.15
import "." as Arc
import "ArcShowcaseData.js" as Showcase
Rectangle {
    id: root
    property var th: null
    property string variant: "inline"
    property var showcase: ({})
    signal cellEdited(int row, string column, string value)
    signal exported(int rows)
    property int _rev: 0
    property int editRow: root.variant === "inline" ? 0 : -1
    property string editCol: "q1"
    property var _checked: []
    property string query: ""
    property string sortKey: ""
    property bool sortAsc: true
    property var _collapsed: []
    property var _hidden: []
    property bool compact: false
    property bool onlyNegative: false
    property var _undoStack: []
    property var _redoStack: []
    property string toast: ""
    readonly property var _moneyCols: ["q1", "q2", "debit", "credit"]
    readonly property var _d: root.showcase && root.showcase.columns ? root.showcase : (root.variant === "ledger" ? Showcase.ArcShowcase.gridLedger : Showcase.ArcShowcase.gridInline)
    readonly property var _cols: _d.columns || []
    readonly property var _rows: {
        var out = [], src = _d.rows || [];
        for (var i = 0; i < src.length; i++) { var o = {}; for (var k in src[i]) o[k] = src[i][k]; o._id = i; out.push(o); }
        return out;
    }
    readonly property real _toolH: th.ct("DataGrid", "ToolbarHeight")
    readonly property real _headH: th.ct("DataGrid", "HeaderRowHeight")
    readonly property real _rowH: root.compact ? 30 : th.ct("DataGrid", "RowHeightStandard")
    readonly property real _checkW: 40
    readonly property real _nW: root.variant === "ledger" ? 36 : 0
    readonly property real _pad: th.ct("DataGrid", "CellInlinePadding")
    readonly property real _totalH: th.ct("DataGrid", "TotalsRowHeight")
    width: 980; height: 400; radius: th.t4(th.design("RadiusPanel"), 0)
    color: th.c("Surface"); border.width: th.t4(th.design("EdgeThickness"), 0); border.color: th.c("Border"); clip: true
    function _touch() { root._rev = root._rev + 1; }
    function _shownCols() { var o = []; for (var i = 0; i < root._cols.length; i++) if (root._hidden.indexOf(root._cols[i].key) < 0) o.push(root._cols[i]); return o; }
    function _visibleRows() {
        var out = [];
        for (var i = 0; i < root._rows.length; i++) {
            var r = root._rows[i];
            if (root.variant === "ledger") { var hide = false; for (var g = 0; g < root._collapsed.length; g++) { var lab = root._collapsed[g]; if (r.account === lab || r.period === lab) { hide = true; break; } } if (hide) continue; }
            if (root.onlyNegative && root.variant === "inline") { var cv = String(r.change || ""); if (cv.indexOf("−") < 0 && cv.indexOf("-") < 0) continue; }
            if (root.onlyNegative && root.variant === "ledger" && String(r.debit || "") !== "") continue;
            if (root.query !== "") { var hit = false; for (var c = 0; c < root._cols.length; c++) if (String(r[root._cols[c].key] || "").toLowerCase().indexOf(root.query.toLowerCase()) >= 0) { hit = true; break; } if (!hit) continue; }
            out.push(r);
        }
        if (root.sortKey !== "") out.sort(function (a, b) { var x = String(a[root.sortKey] || ""), y = String(b[root.sortKey] || ""); return x === y ? 0 : (x < y ? -1 : 1) * (root.sortAsc ? 1 : -1); });
        return out;
    }
    function _sumFor(key) { var s = 0, n = 0; for (var i = 0; i < root._rows.length; i++) { var v = String(root._rows[i][key] || "").replace(/[^0-9.\-]/g, ""); if (v !== "") { s += parseFloat(v) || 0; n++; } } return n ? "$" + (s / 1000).toFixed(1) + "K" : ""; }
    function _totalText(key) { if (root._moneyCols.indexOf(key) >= 0) { var v = root._sumFor(key); if (v) return "Sum  " + v; } return (root._d.totals && root._d.totals[key]) || ""; }
    function _commit(rowObj, col, val) {
        if (root.editRow < 0) return;
        var old = String(rowObj[col] || ""); root.editRow = -1;
        if (old === val) { root._touch(); return; }
        var u = root._undoStack.slice(); u.push({ id: rowObj._id, col: col, old: old, val: val }); root._undoStack = u; root._redoStack = [];
        root._set(rowObj._id, col, val); root._touch(); root.cellEdited(rowObj._id, col, val);
    }
    function _set(id, col, val) { for (var i = 0; i < root._rows.length; i++) if (root._rows[i]._id === id) { root._rows[i][col] = val; break; } }
    function _undo() { var u = root._undoStack.slice(); if (!u.length) return; var e = u.pop(); root._undoStack = u; root._set(e.id, e.col, e.old); var r = root._redoStack.slice(); r.push(e); root._redoStack = r; root._touch(); }
    function _redo() { var r = root._redoStack.slice(); if (!r.length) return; var e = r.pop(); root._redoStack = r; root._set(e.id, e.col, e.val); var u = root._undoStack.slice(); u.push(e); root._undoStack = u; root._touch(); }
    function _toggleCheck(id) { var c = root._checked.slice(), k = c.indexOf(id); if (k < 0) c.push(id); else c.splice(k, 1); root._checked = c; root._touch(); }
    function _toggleAll() { if (root._checked.length) { root._checked = []; } else { var c = []; for (var i = 0; i < root._rows.length; i++) c.push(root._rows[i]._id); root._checked = c; } root._touch(); }
    function _archive() { var n = root._checked.length; for (var i = root._rows.length - 1; i >= 0; i--) if (root._checked.indexOf(root._rows[i]._id) >= 0) root._rows.splice(i, 1); root._checked = []; root.toast = "Archived " + n + " rows"; _toastTimer.restart(); root._touch(); }
    function _toggleGroup(lab) { var c = root._collapsed.slice(), k = c.indexOf(lab); if (k < 0) c.push(lab); else c.splice(k, 1); root._collapsed = c; root._touch(); }
    function _toggleCol(key) { var h = root._hidden.slice(), k = h.indexOf(key); if (k < 0) h.push(key); else h.splice(k, 1); root._hidden = h; root._touch(); }
    function _sort(key) { if (root.sortKey === key) root.sortAsc = !root.sortAsc; else { root.sortKey = key; root.sortAsc = true; } root._touch(); }
    function _toolActive(n) { return (n === "Filter" && root.onlyNegative) || (n === "Columns2" && root._hidden.length > 0) || (n === "Rows3" && root.compact); }
    function _tool(n) {
        if (n === "Undo2") root._undo(); else if (n === "Redo2") root._redo();
        else if (n === "Filter") { root.onlyNegative = !root.onlyNegative; root._touch(); }
        else if (n === "Columns2") { var c = root._shownCols(); if (c.length) root._toggleCol(c[c.length - 1].key); }
        else if (n === "Rows3") { root.compact = !root.compact; root._touch(); }
        else if (n === "Download") root._export();
    }
    function _export() { var n = root._visibleRows().length; root.toast = "Exported " + n + " rows to CSV"; root.exported(n); _toastTimer.restart(); }
    Timer { id: _toastTimer; interval: 2600; onTriggered: root.toast = "" }
    Arc.ArcGridToolbar { th: root.th; grid: root; z: 2 }
    // PART_Header：全选勾选 + 可点列头排序
    Row {
        id: _head; y: root._toolH; width: parent.width; height: root._headH
        Rectangle {
            width: root._checkW + root._nW; height: parent.height; color: root.th.c("SurfaceMuted"); border.width: 1; border.color: root.th.c("BorderSubtle")
            Rectangle { width: 14; height: 14; radius: 3; anchors.centerIn: parent; color: root._checked.length ? root.th.a("accent") : "transparent"; border.width: 1; border.color: root.th.c("BorderStrong") }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root._toggleAll() }
        }
        Repeater {
            model: root._rev >= 0 ? root._shownCols() : []
            delegate: Rectangle {
                required property var modelData
                width: modelData.width || 150; height: root._headH
                color: root.th.c("SurfaceMuted"); border.width: 1; border.color: root.th.c("BorderSubtle")
                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  anchors.verticalCenter: parent.verticalCenter; x: root._pad; text: modelData.title; color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium") }
                Arc.ArcIcon { visible: root.sortKey === modelData.key; anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; th: root.th; kind: "ChevronDown"; width: 12; height: 12; color: root.th.a("accent"); rotation: root.sortAsc ? 180 : 0 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root._sort(modelData.key) }
            }
        }
    }
    // PART_Body：分组行 + 数据行（Flickable 可滚）
    Flickable {
        id: _body
        y: root._toolH + root._headH; width: parent.width; height: parent.height - root._toolH - root._headH - root._totalH
        contentWidth: _col.width; contentHeight: _col.implicitHeight; clip: true
        boundsBehavior: Flickable.StopAtBounds
        Column {
            id: _col; width: root.width; spacing: 0
            Repeater {
                model: root.variant === "ledger" ? (root._d.groups || []) : []
                delegate: Rectangle {
                    required property var modelData
                    width: _col.width; height: root._rowH; color: root.th.c("SurfaceMuted"); border.width: 1; border.color: root.th.c("BorderSubtle")
                    Row {
                        x: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 8
                        Arc.ArcIcon { th: root.th; kind: "ChevronDown"; width: 13; height: 13; color: root.th.c("TextSecondary"); rotation: root._collapsed.indexOf(modelData.label) >= 0 ? -90 : 0; anchors.verticalCenter: parent.verticalCenter }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.label; color: root.th.c("Foreground"); font.pixelSize: root.th.design("TypeSM"); font.weight: root.th.design("WeightMedium"); anchors.verticalCenter: parent.verticalCenter }
                        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  text: modelData.count; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS"); anchors.verticalCenter: parent.verticalCenter }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root._toggleGroup(modelData.label) }
                }
            }
            Repeater {
                model: root._rev >= 0 ? root._visibleRows() : []
                delegate: Rectangle {
                    id: _rowItem
                    required property var modelData; required property int index
                    property var rowData: modelData
                    width: _col.width; height: root._rowH
                    color: root._checked.indexOf(rowData._id) >= 0 ? root.th.fade(root.th.a("accent"), 0.09) : (index % 2 ? root.th.ct("DataGrid", "StripeCellBackground") : root.th.c("Surface"))
                    border.width: 1; border.color: root.th.c("BorderSubtle")
                    Row {
                        width: parent.width; height: parent.height
                        Rectangle {
                            width: root._checkW + root._nW; height: parent.height; color: "transparent"
                            Row {
                                anchors.centerIn: parent; spacing: 4
                                Rectangle { visible: root.variant === "inline"; width: 14; height: 14; radius: 3; color: root._checked.indexOf(rowData._id) >= 0 ? root.th.a("accent") : "transparent"; border.width: 1; border.color: root.th.c("BorderStrong") }
                                Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  visible: root.variant === "ledger"; text: rowData.n || ""; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS") }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root._toggleCheck(rowData._id) }
                        }
                        Repeater {
                            model: root._rev >= 0 ? root._shownCols() : []
                            delegate: Arc.ArcGridCell {
                                objectName: "hit:cell" + rowData._id + "_" + modelData.key
                                required property var modelData
                                property string ck: modelData.key
                                th: root.th; width: modelData.width || 150; height: root._rowH; pad: root._pad
                                colKey: ck; value: String(rowData[ck] !== undefined ? rowData[ck] : "")
                                alignRight: ck === "q1" || ck === "q2" || ck === "change" || ck === "debit" || ck === "credit"
                                editing: root.editRow === rowData._id && root.editCol === ck
                                onEditRequested: { root.editRow = rowData._id; root.editCol = ck; }
                                onCommitted: function (v) { root._commit(rowData, ck, v); }
                                onCancelled: root.editRow = -1
                            }
                        }
                    }
                }
            }
            Rectangle { width: _col.width; height: 1; color: root.th.c("BorderSubtle") }
        }
    }
    // PART_TotalsRow：Sum 随编辑实时重算
    Rectangle {
        y: parent.height - root._totalH; width: parent.width; height: root._totalH; color: root.th.c("SurfaceMuted"); border.width: 1; border.color: root.th.c("BorderSubtle")
        Row {
            x: root._pad; anchors.verticalCenter: parent.verticalCenter; spacing: 0
            Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  width: root._checkW + root._nW; text: root._d.title || ""; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeXS"); anchors.verticalCenter: parent.verticalCenter }
            Repeater {
                model: root._rev >= 0 ? root._shownCols() : []
                delegate: Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI"; 
                    required property var modelData
                    width: modelData.width || 150; text: root._totalText(modelData.key)
                    color: root.th.c("TextSecondary"); font.pixelSize: root.th.design("TypeXS")
                    horizontalAlignment: Text.AlignRight; anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
    Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  visible: root.variant === "inline" && root.toast === ""; x: root._pad; anchors.bottom: parent.bottom; anchors.bottomMargin: 10; text: "Click a cell to edit · Enter saves · Esc cancels"; color: root.th.c("TextMuted"); font.pixelSize: root.th.design("TypeSM") }
    Rectangle {
        visible: root.toast !== ""; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 12; z: 8
        width: _toast.implicitWidth + 28; height: 34; radius: 17; color: root.th.c("Foreground")
        Text { renderType: Text.NativeRendering; font.family: root.th ? root.th.fontFamily : "Segoe UI";  id: _toast; anchors.centerIn: parent; text: root.toast; color: root.th.c("Background"); font.pixelSize: root.th.design("TypeSM") }
    }
}