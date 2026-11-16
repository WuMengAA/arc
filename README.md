# TKCode.Arc → Qt/QML 移植对照

> **跟进上游先读** [PORTING-MAP.md](PORTING-MAP.md)：上游 `.cs`/`.axaml`/令牌 JSON → 本地 `.qml` 的路径分类、组件改名、prop/方法改名、`ct()` 键、Theme/Md3 边界、新版判定流程。公开面 `public-api.json`，破坏性变更 `BREAKING.md`，钉版本 `PIN` + `SHA256SUMS`，文本 golden `GOLDEN.json`。

## 0. 这是什么 / 怎么用（第三方开源移植包）

> **独立性**：整个 `arc/` 目录是一个**可整目录拷贝出去的独立 Qt/QML 移植包**，
> 不依赖星集控外壳、C++ backend、QtShadcn 或任何 QtQuick.Controls。
> 上游是 [TKCode.Arc](https://github.com/AIDotNet/TKCode.Arc) v1.1.0（Avalonia/C#，MIT）；
> 本包是**按真源码真值重写的 QML/JS 实现**，不是上游 C# 代码的拷贝。

### 0.1 依赖（只有 Qt 自带模块）

| 依赖 | 版本 | 说明 |
|---|---|---|
| QtQuick | 2.15 | 125 个组件/页面 `.qml` 只 import 它 |
| QtQuick.Window | 2.15 | 仅包内 `Demo.qml` 用（宿主无需） |
| 系统 UI 字体 | — | `ArcDisplay.js` 按 `Qt.platform.os` 回退（`windows`→Segoe UI，`osx/ios`→Helvetica Neue，`linux/wasm`→Noto Sans，`android`→Roboto，`unix`→DejaVu Sans；等宽另有 MonoFallback），可由 `ArcTheme.fontFamilyOverride` / `monoFamilyOverride` 覆盖，**不捆绑字体** |

实测耦合扫描（125 个 `.qml`，含 `Demo.qml`）：`backendRef` 0、`ctx.window` 0、`QtShadcn` 0、
`QtQuick.Controls` 0、`QtQuick.Layouts` 0、`XMLHttpRequest`/`WebSocket`/`fetch`/`JSON.parse` 0、
`image://` provider 0、宿主绝对路径引用 0（仅注释里提过生成器，已中性化）。
二进制资产 0（无 png/jpg/svg 文件/ttf/otf/dll）。**复制 `arc/` 一个目录即可运行。**

### 0.2 三种接入方式

```qml
// A) 目录导入（最简单，任意 Qt 工程通用）
import "path/to/arc" as Arc
Arc.ArcAdminApp { anchors.fill: parent; section: "dashboard" }

// B) 模块导入（qmldir 的 module URI 必须逐字等于目录名，故保持目录叫 "arc"）
//    qml -I <arc 的父目录> main.qml
import arc 1.0
ArcAdminApp { anchors.fill: parent }

// C) 独立跑（包内 Demo.qml，不需要任何 CMake / C++）
//   qml Demo.qml        （import "." 由文件所在目录解析）
```

`ArcAdminApp` 公开属性：`section`（`dashboard`/`customers`/`team`/`billing`/`settings`
+ 12 个分类展示页 key，见 §2）、`startDark`(bool)、`startAccent`(0..7)、`collapsed`(bool)；
公开函数 `setDark(v)` / `setAccent(i)`。主题令牌由包内 `ArcTheme.qml` + `Tokens.js`
自持，**不要求宿主注入 theme**（宿主注入了也不会用，避免第二套令牌真源）。

数据/文案桥（issue 8/9 后新增，**默认全空，不注入商业假数据**）：

```qml
Arc.ArcAdminApp {
    anchors.fill: parent
    customersData: myCustomers()      // 或 null：客户页空白态
    dashboardData: myDashboard()      // 或 null：KPI/Revenue 卡整块隐藏
    workspaceData: myWorkspace()      // 或 null：侧栏工作区名/账号为空
    billingData:   myBilling()        // 或 null：账单页空白态
    strings: { dashboardTitle: "设备中心", revenueTitle: "在线率" }  // 覆盖写死英文
    visibleSections: ["dashboard", "customers"]  // 裁剪侧栏；空数组=全显示
}
```

`strings` 由 `app.t(key, qsTr(fallback))` 取值；`visibleSections` 由 `app.filterSections()`
过滤。包内 `Demo.qml` 显式注入 `SampleData.js` 合成数据用于展示，宿主不注入即空白态。

### 0.3 目录结构

```
arc/
├── ArcAdminApp.qml        入口应用（侧栏 4 组 17 栏）
├── ArcTheme.qml           令牌解析（design/ct/n/part/fade…）
├── Tokens.js              官方设计令牌基线（494 identity，勿改真值）
├── ControlTokens.js       官方控件令牌基线（勿改真值）
├── Icons.js               158 个 Lucide SVG path（ISC）
├── ArcDisplay.js          Qt 侧显示适配（字阶/对比度/字体，非上游）
├── Arc*.qml / Page*.qml   组件与展示页（每个 ≤200 行）
├── SampleData.js          合成示例数据（仅 Demo 用，宿主不注入）
├── Demo.qml               独立预览窗口（Window）
├── tools/gen_tokens.mjs   上游令牌基线复现脚本（参数化，非运行依赖）
├── tools/gen_qmldir.mjs   qmldir 全量登记生成器（参数化，非运行依赖）
├── qmldir                 `module arc` 1.0，125 个类型全量登记（目录名须为 arc）
├── README.md              本文件（移植对照 + 使用说明）
├── LICENSE                上游 MIT 全文 + 移植层 MIT
└── THIRD-PARTY-NOTICES.md 许可与归属（含 Arc Pro 边界）
```

### 0.4 上游版本钉死

- 仓库：`https://github.com/AIDotNet/TKCode.Arc`
- commit `695a85d727772490c03ff6586455796d6f4af16f`，`git describe v1.1.0-6-g695a85d7`
- 令牌来源 `tests/Baselines/tokens/{light,dark}-default.json`；示例 CSV 来源
  `src/TKCode.Arc.Blocks/Blocks/Developer/ImportWizard/ImportWizardDefaults.cs`；
  侧栏来源 `templates/.../ArcAdminApp/App/{Navigation/AppPages.cs,Views/MainView.axaml}`。
  **产物已入库，重生成不是运行依赖**：`node tools/gen_tokens.mjs <上游仓库根> ..`
  可复现 `ControlTokens.js`；`Tokens.js` 逐值照抄，
  升级上游时按 §1 的对照表重新核对，不要手改。

### 0.5 许可

MIT（见 `LICENSE`）。上游 MIT 版权声明逐字保留；Lucide 图标几何为 ISC，
完整归属见 `THIRD-PARTY-NOTICES.md`。**上游 Arc Pro 组件/文案/资源未使用**
（上游 `THIRD-PARTY-NOTICES.md:10-26` 已声明同名 Pro 项为其独立设计）。

### 0.6 贡献约束（保证不漂移）

- 新组件一律进 `arc/` 且 `.qml` ≤ 200 行；超线抽子件（§10.5）；**新增 `.qml` 后必须
  跑 `node tools/gen_qmldir.mjs .` 重登记 qmldir**（issue 1）。
- 零硬编码令牌：颜色/字号/圆角/间距一律走 `th.design()` / `th.ct()` / `th.n()`；
  **`th.ct()` 的键必须是静态字面量**，禁止 `_toneKey + 后缀` 这类动态拼接（issue 2/7）。
- QML 不连网、不解析 JSON、不写业务计算；交互只调包内 QML 函数
  （正式集成时映射到 C++ `Q_INVOKABLE`）。
- 函数命名对齐官方 PascalCase 的 camelCase 版本，逐项对照写在 §3，别自造名字；
  可见文案一律 `qsTr()`，交互控件补 `Accessible.role/name/onPressAction`（issue 5）。
- 改完至少跑：`qml -I <父目录> Demo.qml` + 逐页截图，别只推演。

---

本目录是把 **TKCode.Arc 1.1.0**（Avalonia / C# / .NET，MIT）真源码移植到
QtQuick 2.15 的 QML 层。上游仓库与版本钉死见 §0.4；本文件只记
「移植依据与对照」，不是任何宿主项目的状态指针。

## 1. 真源码依据（逐字，不推演）

| 事实 | 出处 |
|---|---|
| `The 112 components in 22 groups, organized like Arc's sidebar` | `README.md:33` |
| `22 个分组共 112 个组件，目录结构与 Arc 侧边栏一致` | `README.zh-CN.md:30` |
| `src/TKCode.Arc`: controls, organized as `<Category>/<Component>/` (category = Arc sidebar group) | `AGENTS.md:10` |
| 文档站是独立仓库 `AIDotNet/ArcGallery`（本机未检出） | `README.md:90-91`、`AGENTS.md:12/30` |
| `public sealed record BlockGroup(string Code, string Title, string ChineseTitle);` | `src/TKCode.Arc.Blocks/BlockCatalog.cs:7` |
| `The Blocks and Screens taxonomy, in sidebar order (as on uiarc.dev)` | `BlockCatalog.cs:18` |
| `public sealed record AppPage(string Key, string Title, Func<Control> Create);` | `templates/.../ArcAdminApp/App/Navigation/AppPages.cs:9` |
| `public const string Dashboard = "dashboard";` / Customers / Team / Billing / Settings | `AppPages.cs:20-24` |
| `public static AppPage? Find(string? key)` | `AppPages.cs:35-45` |
| `[RelayCommand] private void SignOut()` / `public void RunCommand(string? id)` / `partial void OnSelectedKeyChanged(string? value)` | `MainViewModel.cs:70/78/97` |
| `private void OnToggleSidebar(object? sender, RoutedEventArgs e) => Nav.ToggleCollapsed();` | `MainView.axaml.cs:70` |

### 1.1 官方 ArcAdminApp 侧栏只有 5 页 2 组

`templates/TKCode.Arc.Templates/content/ArcAdminApp/App/Views/MainView.axaml:66-74`：

- `:66-69` `<arc:SidebarSection>` **无 Header**：
  `<arc:SidebarItem Key="dashboard" Label="Dashboard" Icon="{lucide:LucideGeometry LayoutDashboard}" />`、
  `<arc:SidebarItem Key="customers" Label="Customers" Icon="{lucide:LucideGeometry Users}" />`
- `:70-74` `<arc:SidebarSection Header="Workspace">`：Team(`UserCog`) / Billing(`CreditCard`) / Settings(`Settings`)
- `:44-48` `<arc:Sidebar x:Name="Nav" ... IsCollapseButtonVisible="False" ResizeMode="Overlay" SelectedKey="{Binding SelectedKey}">`
- `:76-97` Footer = Avatar(AccountName, Status=Online) + AccountRole + `SignOutCommand`(`LogOut`)
- `:144-152` CommandPaletteDialog：Group="Go to" 五项 + Group="Actions" theme-light / theme-dark / sign-out

**早期那 17 个 section（Foundation / Controls / Library / More / Charts / Motion / Menus /
Buttons / Interactions / Analytics app / Surfaces / Layout …）不是官方预设分类**，是本移植早期
按组件名推演出来的 Gallery 式分组，2026-11-15 已按下方对照重整。

### 1.2 官方组件目录（`src/TKCode.Arc/` 实测 27 个子目录，README 写 22 groups）

```
Activity, Avatars, Buttons, Cards, Charts, Content, Editors, Expand, Forms, Gestures,
Illustrations, Layout, Media, Menus, Messages, Navigation, Overlays, Pickers, Progress,
Properties, Selects, Sliders, SpecialInputs, Tables, TextEffects, TextFields, Toggles
```

`Foundation` **不是组件分类**：它是包名 `TKCode.Arc.Foundation`（`README.md:63` 令牌/主题运行时）。

### 1.3 BlockCatalog 正式分类（Blocks 21 组 / ScreenGroups 6 组）

`src/TKCode.Arc.Blocks/BlockCatalog.cs:21-59`：

- Blocks：Analytics/分析、Finance/财务、LineCharts/折线图、Ai/AI、Agents/智能体、
  AppShell/应用外壳、Auth/认证、Settings/设置、People/人员、Developer/开发者、
  Pricing/定价、Commerce/电商、Support/支持、Media/媒体、Projects/项目、Heroes/首屏、
  Features/功能、SocialProof/社会证明、Content/内容、HeadersFooters/页眉与页脚、Showpieces/展示
- ScreenGroups：Dashboards/仪表盘、ScreenProjects/Projects、Calendars/日历、
  PeopleCustomers/People and customers、InboxSupport/Inbox and support、ScreenCommerce/Commerce
- 真条目示例：`:286 new("ImportWizard", "Import wizard", "import-wizard", "Developer",`、
  `:442 new("KanbanBoard", "Kanban board", "kanban-board", "ScreenProjects",`

### 1.4 场景模板（`templates/README.md:197-200`）

`ArcAdminApp/`、`ArcAiChatApp/`、`ArcDevtoolApp/`、`ArcWorkflowApp/`、
`ArcProjectsApp/`、`ArcAnalyticsApp/`。

⚠️「Analytics app」是模板应用名 **ArcAnalyticsApp**，不是组件分类。
`templates/README.md:125` workflow 模板含 `an editable WorkflowCanvas (drag to connect,
Delete, undo and redo, Arrange) with a minimap and zoom ... and Run`；
`:127` projects 模板含 KanbanBoard / GanttTimeline / WeekCalendar / ReleaseReadiness；
`:129` devtool 模板含 DockLayout + "Reset layout"。

## 2. 侧栏分类对照（`ArcAdminApp.qml` → 官方）

| 分组 | 本地页 key | 官方依据 |
|---|---|---|
| （无 Header） | dashboard / customers | `MainView.axaml:66-69` + `AppPages.cs:20-24` |
| Workspace | team / billing / settings | `MainView.axaml:70-74` + `AppPages.cs:20-24` |
| Components · 22 groups | foundation | `README.md:59` Foundation and tooling（包名，非组件分类） |
| | buttons | `src/TKCode.Arc/Buttons/` |
| | components → TextFields & Forms | `TextFields/` / `Forms/`（PageControls: Checkbox/Input/Progress/Slider/Select） |
| | library → Overlays & Tables | `Overlays/` / `Tables/` / `Avatars/`（PageControls2: Dialog/Tabs/Tooltip/Toast/DatePicker/Avatar/Badge/Table） |
| | more → Messages & Expand | `Messages/` / `Content/` / `Navigation/` / `Expand/` |
| | charts → Charts & Selects | `Charts/` / `Selects/` / `Activity/` |
| | menus → Menus & Overlays | `Menus/` / `Overlays/` |
| | interactions → Gestures & Toggles | `Gestures/` / `Toggles/` / `SpecialInputs/` |
| | motion → Activity & TextEffects | `Activity/` / `TextEffects/` |
| | layout → Layout | `Layout/`（AutoLayout/ResizablePanels/ScrollArea/StickyList） |
| Blocks & screens | surfaces | `BlockCatalog.cs` Groups + ScreenGroups（KanbanBoard / ImportWizard / DataGrid / WorkflowCanvas / DockLayout / ...） |
| | analytics → Analytics app | 模板 `ArcAnalyticsApp` |

## 3. 函数命名对照（官方 PascalCase → QML camelCase）

> **QML 语法硬限制**：`Property names cannot begin with an upper case letter` /
> `Method names cannot begin with an upper case letter`（Qt 6.12 实测 status=2）。
> 因此 QML 对外函数/属性一律 camelCase，**注释与下表保留官方真名逐字**，不自行发明别名语义。

### 3.1 WorkflowCanvas（`src/TKCode.Arc.Workflow/`，`ArcWorkflow.qml`）

| 官方签名 | 出处 | QML 函数 |
|---|---|---|
| `public void ArrangeNodes(bool animate = true)` | `WorkflowCanvas.Layout.cs:39` | `arrangeNodes()` |
| `public int DeleteSelection()` | `WorkflowCanvas.Editing.cs:119` | `deleteSelection()` |
| `public void Select(IEnumerable<WorkflowNode> nodes)` | `WorkflowCanvas.Editing.cs:105` | `selectNode(i)` |
| `public void ClearSelection()` | `WorkflowCanvas.Editing.cs:113` | `clearSelection()` |
| `public IReadOnlyList<WorkflowNode> SelectedNodes` / `SelectedEdges` | `Editing.cs:96` / `Connecting.cs:65` | `selectedNodes` |
| `public void ResetRun()` | `WorkflowGraph.cs:156` | `resetRun()` |
| `BeginMove` / `UpdateDrag` / `CommitMove` / `CancelMove` | `WorkflowCanvas.Editing.cs` | `beginMove(i)` / `updateDrag(i,dx,dy)` / `commitMove()` |
| `public void Undo()` / `public void Redo()` | `Connecting.cs:71/74` | `undo()` / `redo()`，返回 bool；`_snapshot()` 深拷贝入栈，`move/delete/arrange` 前 `_pushUndo()` |
| `public ICommand DeleteSelectionCommand` / `ZoomInCommand` / `ZoomOutCommand` / `FitCommand` | `Commands.cs:27/43/46/49` | 工具栏按钮 |
| `public void FitToContent(bool animate = true)` | `WorkflowCanvas.View.cs:53` | `fitToContent()` |
| `public void ZoomTo(double zoom, Point? anchor = null, bool animate = true)` / `ZoomIn()` / `ZoomOut()` | `View.cs:65/74/77` | `zoomTo(z)` / `zoomIn()` / `zoomOut()` |
| `public void ScrollIntoView(WorkflowNode node, bool animate = true)` | `View.cs:83` | `scrollIntoView(i, animate)`：选中节点 + `viewX/viewY` 平移画布（`transform: Translate`） |
| `public AvaloniaList<WorkflowNode> Nodes` / `Edges` / `Connect(...)` / `FindNode(string id)` | `WorkflowGraph.cs:28/31/47/134` | `_nodes` / `_edges` / `_wires()` |
| `public Point Position` / `State` / `IsLocked` | `WorkflowNode.cs:172/193/214` | `x/y` / `state` |

`startRun()` 来自 **ArcWorkflowApp 模板的 Run 命令**（`templates/README.md:125`），
不是 WorkflowCanvas 方法；`loadLayout()` 借用 DockLayout `LoadLayout(string json)` 语义
（`DockLayout/Commands.cs:257`）。

**官方不存在的名字（全库 0 命中，别再写进注释/文档）**：
`AutoArrange` / `ResetLayout` / `RunTestEvent` / `SelectedNode`（单数）。

### 3.2 ImportWizard（`Blocks/Developer/ImportWizard/` → `ArcImportWizard.qml`）

`StepNames = ["Upload", "Match fields", "Review", "Import"]` (`ImportWizardLabels.cs:14`)；
枚举 `ImportWizardStep Upload/Map/Review/Import`。

官方：`CanGoTo(...)` / `GoTo(...)` `Logic.cs:229/239`、`GoBack()` `:258`、
`LoadCsv(string text, string fileName, long? size = null)` `:305`、
`OpenPickerAsync()` `:333`、`LoadSample()` `:357`、`RemoveFile()` `:443`、
`Reset()` `:468`、`StartImport()` `:493`、`RetryImport()` `:509`、
`CancelImport(bool navigate = true)` `:607`、`GetSkippedRowsCsv()` `:618`；
属性 `Step` / `FileName` / `RowCount` / `Targets` / `ImportBatchAction` / `CompletedCommand`
(`ImportWizard.cs:214/217/220/167/173/208`)；事件 StepChanged / FileLoaded / BatchImported / Completed / Failed。

QML：`step` / `mappedCount` / `_targets` / `_choose(row,opt)` / `_issue(row)` /
`_next()` / `importPct` + Timer。样本 CSV 22 行逐字取自
`ImportWizardDefaults.cs` 的 `BuildSample()`（表头 `Contact name,Email,Organization,Team role,Cell,Country,Subscription,Comments`）。

### 3.3 DataGrid（`src/TKCode.Arc.AdvancedCharts/DataGrid/` → `ArcSpreadsheet.qml`）

官方：`BeginEdit()` `Editing.cs:41`、`CommitEdit()` `:51`、`CancelEdit()` `:54`、
`SetCellValue(int row, int accessor, object? value)` `:151`、`Undo()` `:545`、
`Redo()` `:562`、`ClearHistory()` `:579`、`DeleteChecked()` `:649`、
`CycleSort(string key, bool add)` `Model.cs:1001`、`SetFilter` `:901`、
`ClearAllFilters(bool announce = true)` `:918`、`ToggleGroup(DataGridGroupNode node)` `:379`、
`ExportAsync(DataGridExportFormat format, bool checkedRowsOnly = false)` `Export.cs:18`、
`OpenFind(bool replace = false)` / `FindNext()` / `ReplaceAll(...)` `Find.cs:47/140/193`、
`AddRow()` `Rows.cs:79`、`MoveColumn` / `GetLayoutState()` / `SetLayoutState(...)` `Layout.cs:55/217/230`；
属性 `ItemsSource` / `DataSource` / `ActiveCell` / `SelectedRange` / `IsEditing` /
`CanUndo` / `CanRedo` / `SortDescriptions` / `Filters` / `SearchText` / `GroupBy`。

QML：`editRow` / `editCol` / `_commit(rowObj,col,val)` / `_set(id,col,val)` /
`_undo()` / `_redo()` / `_sort(key)` / `_toggleGroup(lab)` / `_toggleCol(key)` /
`_tool(n)` / `_export()` / `_archive()`。
⚠️ 官方**没有 Archive 命名方法**——「归档」= `DeleteChecked()` + 可撤销，功能对齐即可，不改名。
`ArcGridCell.qml` 的 `submitEdit(txt)` 对应 `CommitEdit()`，`cancelled()` 对应 `CancelEdit()`。

### 3.4 KanbanBoard（`Blocks/Screens/Projects/KanbanBoard/` → `ArcKanbanBoard.qml`）

官方：`BeginQuickAdd(KanbanColumn column, ProjectPerson? person = null)` `Compose.cs:44`、
`CancelQuickAdd()` `:99`、`MoveCard(KanbanCard card, string columnKey, int index, string? assigneeKey = null, bool animate = true)` `Drag.cs:995`、
`BeginKeyboardDrag(...)` `:781`、`CancelDrag()` `:947`、`OpenCard(KanbanCard card)` / `CloseDetails()` `Details.cs:58/61`、
`FocusCard(...)` `:64`、`ScrollIntoView(...)` `:75`、`EditTitle(...)` `:139`、
`EditDescription(...)` `:151`、`ChangeStatus(...)` `:167`、`ChangeOwner(...)` `:191`、`AddStep(...)` `:225`；
`Cards` / `CardsSource` / `GroupBy` `KanbanBoard.cs:301/304/307`，
`SetCurrentValue(GroupByProperty, index == 1 ? KanbanGroupBy.Assignee : KanbanGroupBy.Status)` `:589`、
`SetOptions([strings.StatusView, strings.LanesView])` `:599`；
`KanbanBoardLabels.cs:12/15` `StatusView = "Status"` / `LanesView = "By person"`。

QML：`_view` / `_columnsFor()` / `_beginDrag/_moveDrag/_endDrag` / `_addCard/_removeCard/_moveNext` /
`openedKey` + `ArcKanbanDrawer.qml`。
⚠️ 官方**没有 DeleteCard / RemoveCard / CardDeleted**——增删走 `Cards` 集合 + `CardsChanged` 事件。

### 3.5 DockLayout（`src/TKCode.Arc.Dock/DockLayout/` → `ArcDockLayout.qml`）

官方：`SaveLayout()` / `LoadLayout(string json)` `Commands.cs:243/257`、
`Open(DockPane pane, DockTarget? target = null)` `:26`、`Close(DockPane pane)` `:63`、
`Move(DockPane pane, DockTarget target)` `:167`、`MoveTab(DockPane pane, int delta)` `:206`、
`Select(DockPane pane)` / `Activate(DockPane pane)` / `FocusTab(...)` `DockLayout.cs:373/390/412`、
`ActivePane` `:149`、`Float(DockPane pane)` / `Dock(DockPane pane)` `Floating.cs:335/355`、
`AutoHide(DockPane pane)` / `Pin(DockPane pane)` `AutoHide.cs:30/70`、
`ToggleMaximize(DockGroup group)` `Maximize.cs:21`。

QML：`activeTab` / `activeTool` / `activeBottom` / `leftW` / `outlineOpen` /
`_selectTab(i)` / `_toggleOutline()` / `_codeLines()` / `codeText`（TextEdit 可编辑）。
⚠️ 官方**没有 ResetLayout**——入口是 `LoadLayout(json)` / `DockPaneSource.Reset(source, template)`。
布局数据取自 `tests/TKCode.Arc.Tests/Docking/DockSamples.cs`：
ToolGroup(Explorer,Search) Size=22 / Documents Size=70 / TerminalGroup Size=30 / Right Size=78。

## 4. 显示适配（`ArcDisplay.js`，Qt 侧新增，真源码无此文件）

官方令牌基线 `Tokens.js` **逐字不变**（`tests/Baselines/tokens/*.json` 494 identity +
`ArcDesignToken.cs` / `ArcPalette.cs` / `SidebarToken.cs`）。用户点单「字体太小、对比度不行、
字体发虚」后新增 Qt 侧适配层，不改真值：

- `TypeScale = 1.25`：`design("Type*")` 全部 ×1.25（TypeXS 12→15 / TypeSM 14→18 /
  TypeBase 16→20 / TypeLG 18→23 / TypeXL 22→28 / Type2XL 28→35 / Type3XL 36→45 /
  Type4XL 52→65 / Type5XL 72→90）；`fontish()` 对 ct()/n() 里 `*FontSize`/`TextSize*` 同步放大，
  尺寸/圆角不动。
- `FontFamily = "Segoe UI"` + `renderType: Text.NativeRendering`：Qt 6.12 默认
  `Sans Serif` / QtRendering 发虚；`Qt.application.font` 是只读代理，整体赋值报
  `TypeError: Cannot assign to read-only property "font"`，故逐 `Text/TextInput/TextEdit` 注入
  （345 处）+ 22 处硬编码字号按 map 放大。
- 非 Windows 回退（issue 4）：`fontFamily(os)` / `monoFamily(os)` 按 `Qt.platform.os`
  取 `FontFallback` / `MonoFallback`；`ArcTheme.qml` 暴露 `fontFamily` / `monoFamily`
  只读属性与 `fontFamilyOverride` / `monoFamilyOverride`，345 处注入改成
  `root.th ? root.th.fontFamily : <兜底>`，等宽 3 处走 `monoFamily`。
- `LightBoost`：浅色下 `Foreground #FF000000` / `TextSecondary #FF3A3A3A` /
  `TextMuted #FF545454` / `Border #FFD9D9D9` / `BorderSubtle #FFE7E7E7` /
  `BorderStrong #FF9E9E9E`，仅覆盖 `design()` 返回值，深色不参与。

## 5. 工作流拖动（1:1 直接跟随）

旧实现三处叠加导致「间接性」，真 GUI 才暴露第三处：

1. `ArcWorkflowNode.qml` 的 `_sx/_sy` 只在 `onPressed` 记一次，`dx = mouseX - _sx`
   是**距按下点的总位移**，却每帧累加到当前坐标 → 越拖越快。
2. `ArcWorkflow.qml` 的 `_move()` 用 `var n = root._nodes.slice() ... n[i]=o; root._nodes=n;`
   **换数组引用** → `Repeater` 重建 delegate → 正在拖的 MouseArea 被销毁 → 拖动断续。
3. 改用局部 `mouseX` 帧间增量后仍有**自反馈阻尼**：节点跟着光标移动，MouseArea 自身的
   位移把局部坐标增量抵消了。真 GUI 15 步拖 150px，节点只走 80px（每两步才 +10）。
   离屏探针直接调 `updateDrag()` 绕过了 MouseArea，所以全绿却没发现。

最终实现：`MouseArea.onPositionChanged` 用 `_ma.mapToGlobal(Qt.point(mouseX, mouseY))`
取**全局光标坐标**算帧间增量 `dx/dy`，每帧推进 `_gx/_gy` 基准；
`updateDrag(i,dx,dy)` 直接 `n.x += dx; n.y += dy;`（**不除 zoom**，全局增量已是父坐标系
像素），**原地改同一对象**并只 `_touch()` 增 `_rev`；delegate 的 `x/y` 显式依赖
`root._rev >= 0 && root._nodes[ni]` 触发重算；`Repeater { model: root._nodes }` 不再换 model。

实证：真 GUI 15 步拖 (150,75) → 节点 `(300,10) → (450,85)`，逐帧
`+10,+5` 单调均匀，`WF_1TO1 True`；离屏 10 帧 ×(40,20) → `(700,210)` 亦通过。

## 6. 约束与边界

- 纯 `QtQuick 2.15` + `QtQuick.Window 2.15`，零 `QtQuick.Controls` / Layouts / QtShadcn；
  主题双契约 `root.theme`（本层 `th = ArcTheme`）。
- §10.9 QML 纯净 UI 封杀令：无 `XMLHttpRequest` / `WebSocket` / `fetch` / `JSON.parse` /
  业务复杂计算；交互只调组件内 QML 函数（正式集成时映射 C++ `Q_INVOKABLE`）。
- 每个 `.qml` ≤ 200 行（§10.5 规模门禁），超线抽子件；`Tokens.js` 是官方基线不许改真值。
- 预览窗口是包内 `Demo.qml`：`qml Demo.qml` 即可，无需 CMake / import path / 环境变量。
- 字体：`ArcDisplay.js` 按 `Qt.platform.os` 自动回退，宿主可用
  `ArcTheme.fontFamilyOverride` / `monoFamilyOverride` 覆盖；不捆绑字体文件（见
  `THIRD-PARTY-NOTICES.md` §3）。高分屏可设 `QT_SCALE_FACTOR=1` +
  `QT_ENABLE_HIGHDPI_SCALING=0` 让预览窗口按逻辑像素显示。

## 7. 竖向拖动不连带页面滚动（2026-11-15 追加）

页面陈列层 `PageSurfaces.qml` 是 `Flickable`，子控件拖拽时父级会偷走鼠标 grab
（真 GUI 实测竖向拖工作流节点 120px，`contentY` 从 3240 滚到 3133）。Qt 解法：给所有
需按压拖拽的 `MouseArea` 加 `preventStealing: true`，共 8 个文件 9 处：

| 控件 | 拖拽类型 |
|---|---|
| `ArcWorkflowNode.qml` | 画布节点全局坐标拖拽 |
| `ArcKanbanCard.qml` | 看板卡片跨列拖拽 |
| `ArcDockLayout.qml` ×2 | 分隔条调宽 + 浮动卡拖拽 |
| `ArcImageViewer.qml` | 对比滑块 |
| `ArcRating.qml` | 星级划选 |
| `ArcResizablePanels.qml` | 面板分隔条 |
| `ArcSlider.qml` | 滑块 |
| `ArcSwipeActions.qml` | 横向滑动 |

点击类 `MouseArea` 不加（否则页面空白处无法拖动滚动）；滚轮由 `WheelHandler` 处理，
与 grab 无关。真 GUI 复验：拖 120px → `contentY` 恒 3240、节点 +120，
滚轮 28 格 → `contentY 0→3240→0` 仍正常。

## 8. `v0.6.72-arc-lab` issue 整改台账（2026-11-16）

> 依据：下游集成评估记录的 9 条库本体未完成项（见 `CHANGELOG.md` §0.1.0）。
> 整改对象一律是本包 `arc/` 真源；本仓库是独立第三方移植包，不含任何宿主实验副本或页面适配层。

| issue | 级别 | 整改 | 落点 |
|---|---|---|---|
| 1 qmldir 只注册 2/125 | P1 | `qmldir` 全量登记 125 个 `TypeName 1.0 TypeName.qml`；新增参数化生成器，模块导入 `import arc 1.0` 可用 | `qmldir` / `tools/gen_qmldir.mjs` |
| 2 ArcBadge 动态令牌键 | P1 | 删 `_toneKey + 后缀`，改 `_neutral` / success / warning / danger 静态键表；accent/info 走 `th.a("subtle")` + `InfoRingOpacity`，补齐 hover 分支 | `ArcBadge.qml` |
| 3 主题开关浅深漂移 | P2 | 改受控：`onClicked` 只发 `changeRequested(!root.dark)`；调用方 `PageButtons.qml` 用 `_swDarkA/B` 回填，`AnalyticsApp.qml` 原已是回填接法 | `ArcThemeSwitcher.qml` / `PageButtons.qml` |
| 4 字体硬编码非 Windows 回退 | P2 | `ArcDisplay.js` 增 `FontFallback` / `MonoFallback` + `fontFamily(os)` / `monoFamily(os)`；`ArcTheme` 暴露 override；345+3 处注入改按 `Qt.platform.os` 取值 | `ArcDisplay.js` / `ArcTheme.qml` / 98 个 `.qml` |
| 5 零 qsTr / 零 Accessible | P2 | 5 个数据页 + `ArcButton` / `ArcSwitch` / `ArcPageHeader` / `Sidebar` 共 +35 处 `qsTr()`；按钮/开关/标题/侧栏行补 `Accessible.role/name/onPressAction` | 9 个 `.qml` |
| 6 Undo/Redo/ScrollIntoView 登记未实现 | P3 | `ArcWorkflow.qml` 补 `_snapshot()` / `_pushUndo()` / `_restore()` / `undo()` / `redo()` / `scrollIntoView(i,animate)`；工具条加 Undo/Redo，画布 `transform: Translate`；§3.1 方法表去掉「未实现」 | `ArcWorkflow.qml` / 本文件 §3.1 |
| 7 ArcActionSwap 动态键 | P3 | `_fill/_edge/_edgeHover/_px` 改静态三元；顺带清掉 `ArcInput.qml` / `ArcTextarea.qml` 的 `_padKey` | 3 个 `.qml` |
| 8 默认 SampleData 商业假数据 | P3 | 四个数据源改默认 `null`（空白态）；仅 `Demo.qml` 显式注入 `SampleData.js`，宿主默认不注入 | `ArcAdminApp.qml` / `Demo.qml` |
| 9 写死商业文案无法覆盖 | P1 | `ArcAdminApp` 增 `strings` + `visibleSections` + `t()` / `filterSections()`；`PageDashboard` 增 `title/subtitle/chartTitle/chartDescription/chartVisible` + `_hasChart`，无数据整块隐藏不留空图；22 处商业文案走 `t(key, qsTr(...))` | `ArcAdminApp.qml` / 5 个 `Page*.qml` |

验证：`tools/check.mjs` 静态自检（行数/括号/纯净/qmldir/动态键/字体）+ `qml -I <parent-of-arc> Demo.qml` + 离屏功能探针 + 真 GUI 截图；发布证据见 `CHANGELOG.md` §0.1.0。
