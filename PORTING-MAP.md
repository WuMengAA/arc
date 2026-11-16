# 移植映射表 · TKCode.Arc (.NET / Avalonia) → arc (Qt / QML)

> 用途：上游 `AIDotNet/TKCode.Arc` 是 C# / .axaml / 令牌 JSON；本包是 .qml / .js。
> 二者**没有文件级对应**，所以「跟进最新版」不能靠 `git compare` 直接推行为。
> 这张表就是中间那层翻译契约：拿到上游任意一个变更文件，先按 §1 判它落到本地哪一层，
> 再按 §2–§5 查名字 / 属性 / 令牌 / 主题的改名规则，最后按 §6 判是否需要新 port tag。

**基线**：上游 `695a85d727772490c03ff6586455796d6f4af16f`（`v1.1.0-6-g695a85d7`）；
本包 `port/v0.1.0`。`module arc 1.0` 是**移植包版本**，与上游 `1.1.x`（.NET 库版本）不同轴，不要互相套。

## 1. 上游路径 → 本地落点（判读 97 个变更文件的第一刀）

| 上游路径模式 | 内容 | 本地落点 | 影响面 / 重生成命令 |
|---|---|---|---|
| `src/TKCode.Arc.Core/Theme/ArcDesignToken.cs`、`ArcPalette.cs`、`Oklch.cs` | 全局语义令牌 177 键 | `Tokens.js` 的 `DATA.numbers.design` / `parts` / `accents` / `series` | 全库 `th.c()` / `th.design()` / `th.a()`；`ArcTheme.qml` 是唯一解析口 |
| `tests/Baselines/tokens/{light,dark}-default.json` | 494 identity 控件令牌基线 | `ControlTokens.js`（LIGHT 493 域全量 + DARK 524 键/164 域差异） | 全库 `th.ct()`；`node tools/gen_tokens.mjs <上游仓库根> ..` 重生成，产物已入库 |
| `src/TKCode.Arc/<组>/<控件>/<控件>Token.cs` | 单控件 `[ControlDesignToken]` 属性 | `ControlTokens.js` 的 `<控件>` 域 | 对应 `Arc<控件>.qml` 里 `th.ct("<控件>", "<键>")` 的**字面量**键 |
| `src/TKCode.Arc/<组>/<控件>/<控件>.cs` | `StyledProperty` / `DirectProperty` / 公开方法 | `Arc<控件>.qml` 的 property / signal / function | 见 §3 改名规则；方法名必须 camelCase |
| `src/TKCode.Arc/<组>/<控件>/*.axaml`（ControlTheme） | 视觉模板 PART / 伪类 | 同 QML 的 Rectangle / Column / Repeater 结构 | 见 §2；`:hover` → `MouseArea.containsMouse`，`:small` → `bool small` |
| `templates/…/ArcAdminApp/App/Views/MainView.axaml` + `App/Navigation/AppPages.cs` | 模板外壳 + 5 页 2 组侧栏 | `ArcAdminApp.qml` + `Sidebar.qml` + `Page*.qml` | §2 侧栏分组逐字对齐 `MainView.axaml:66-74` |
| `templates/…/ArcAdminApp/App/Pages/*.axaml` + `ViewModels/*.cs` | 5 个业务页 + VM | `PageDashboard.qml` / `PageCustomers.qml` / `PageTeam.qml` / `PageBilling.qml` / `PageSettings.qml` | `DataContext` → `model` / 四个 `xxxData` 数据桥 |
| `templates/…/ArcAdminApp/App/SampleData/*.cs` | 示例服务 | `SampleData.js`（`customers()/dashboard()/workspace()/billing()`） | 仅 `Demo.qml` 注入；**库本体不默认调用** |
| `templates/…/ArcAnalyticsApp/**` | 分析模板 5 图 | `AnalyticsApp.qml` + `AnOverview/AnRevenue/AnRetention/AnStatus/AnUsage.qml` | 前缀 `An`，不叫 `Page*` |
| `templates/…/ArcWorkflowApp/**` | 工作流模板 | `ArcWorkflow.qml` + `ArcWorkflowNode.qml` | 命令口径见 §3.3 |
| `src/TKCode.Arc.Workflow/WorkflowCanvas/*.cs` | `ArrangeNodes` / `DeleteSelection` / `Undo` … | `ArcWorkflow.qml` | §3.3 全表；官方 PascalCase → QML camelCase |
| `src/TKCode.Arc.Blocks/Blocks/Developer/ImportWizard/**`、`Screens/Projects/KanbanBoard/**` | 区块控件 | `ArcImportWizard.qml` / `ArcKanbanBoard.qml`(+Card/Drawer) | §3.3；真实 CSV 22 行在 `ArcShowcaseData.js` |
| `src/TKCode.Arc.Special/Surfaces/{ControlCenter,SheetStack}/**` | 特殊曲面 | `ArcControlCenter.qml` / `ArcSheetStack.qml` | 无上游同名 `AutoLayout` / `ContentSwap` 类，那两个是 Qt 侧陈列件 |
| `src/TKCode.Arc.Dock/DockLayout/**` + `tests/TKCode.Arc.Tests/Docking/DockSamples.cs` | 停靠布局 | `ArcDockLayout.qml` | 22/70/30/78 分栏逐字来自 `DockSamples.cs:15-20` |
| `src/TKCode.Arc.AdvancedCharts/DataGrid/**` | 高级表格 | `ArcSpreadsheet.qml` + `ArcGridCell.qml` + `ArcGridToolbar.qml` | 版式令牌域 `DataGrid`；官方 `Spreadsheet` 类 0 命中 |
| `src/TKCode.Arc.Blocks/BlockCatalog.cs` | 21 Blocks 组 + 6 ScreenGroups 组 | `ArcAdminApp.qml` 的 `navSections` 后两组 | 目录名 27 个子目录；README 的「22 groups」是分类口径，不是目录数 |
| `**/Localization/*.xlf` | Avalonia 本地化（42 个） | **不落 QML 包** | 本包用 `qsTr()`（54 处）+ `Accessible`（26 处），翻译由宿主 Qt `.qm` / `QTranslator` 承担 |
| `.github/workflows/*.yml`、`*.csproj`、`*.props` | .NET 构建链 | **不落 QML 包** | 本包依赖只有 `QtQuick 2.15` + `QtQuick.Window 2.15` |
| `src/TKCode.Arc/SpecialInputs/SlideToConfirm/**`（`.4` 新增 9 件） | 新控件 | **尚未移植** | 列入 `port/v0.2.0`；引入前必须真机验不依赖 QtQuick.Controls（见 §7） |

## 2. 组件名怎么落

| 规则 | 上游 | 本地 | 证据 |
|---|---|---|---|
| 普通控件：`Arc` 前缀 + 类名逐字 | `Badge` / `MetricCard` / `ThemeSwitcher` | `ArcBadge.qml` / `ArcMetricCard.qml` / `ArcThemeSwitcher.qml` | 125 个 `.qml` 中 70 个可机械对上上游类名 |
| 区块控件同样加 `Arc` 前缀 | `KanbanBoard` / `ImportWizard` / `ControlCenter` / `SheetStack` | `ArcKanbanBoard.qml` / `ArcImportWizard.qml` / `ArcControlCenter.qml` / `ArcSheetStack.qml` | `git grep 'class KanbanBoard'` → `Blocks/Screens/Projects/KanbanBoard/KanbanBoard.Compose.cs:8` |
| 模板页面：`Page` 前缀 + 页名 | `DashboardPage.axaml` / `CustomersPage.axaml` | `PageDashboard.qml` / `PageCustomers.qml` | `AppPages.cs:20-33` 五个 key 逐字 |
| 模板骨架整壳合并 | `MainView.axaml` + `AppPages.cs` + `MainViewModel.cs` | `ArcAdminApp.qml` + `Sidebar.qml` | 一个 QML 承载侧栏/顶栏/Loader 17 分支 |
| 陈列页（Qt 侧新增，无上游类） | — | `PageButtons/Controls*/Interactions/Menus/Motion/Surfaces/Layout/Foundation/Analytics.qml` | 按 §1 的 27 目录与 BlockCatalog 分类建组，不是上游文件直译 |
| 支撑件（无上游同名类） | — | `ArcTheme.qml` / `ArcIcon.qml` / `ArcGridCell.qml` / `ArcKanbanCard.qml` / `ArcWorkflowNode.qml` / `ArcKanbanDrawer.qml` / `ArcGridToolbar.qml` / `Demo.qml` | 为 QML 无反射/无模板 PART 而拆；`ArcIcon` 承载 158 个 Lucide path（`Icons.js`，ISC） |

`qmldir` 登记全部 **125** 个类型，`module arc`、版本 `1.0`；由 `node tools/gen_qmldir.mjs` 从目录生成。
**目录必须叫 `arc`**：Qt 要求 module URI 逐字等于目录名，写 `module ArcQt` 实测报 `module "ArcQt" is not installed`。
无 `prefer` / `depends` / `classname` —— 纯 QML 模块，零 C++ 插件、零 `QtQuick.Controls`。

## 3. prop / 方法怎么改名

### 3.1 通用规则（QML 语法硬约束，实测报错逐字）

- C# `StyledProperty` PascalCase → QML `property` camelCase；C# `enum` → QML `string` 取值联合。
- C# `Content` / `ItemsSource` / `DataContext` → QML 具名数据属性（`model` / `rows` / `customersData` …）。
- **方法/属性名不能以大写开头**：`Property names cannot begin with an upper case letter`（`ArcWorkflow.qml:40`）、`Method names cannot begin with an upper case letter`（`:42`）。故官方 PascalCase 一律转 camelCase，注释里保留官方签名逐字对照。
- C# 事件 / `ICommand` → QML `signal`；受控组件只发请求、不改自身状态。
- 内部状态/函数一律 `_` 前缀，不进公开契约。

### 3.2 逐控件 prop 对照（上游 `AvaloniaProperty.Register` 实测）

| 上游类 | 上游属性（实测） | 本地 QML | 本地 property / signal |
|---|---|---|---|
| `Badge.cs` | `Tone`, `Size`, `Icon` | `ArcBadge.qml` | `tone: string`(neutral/success/info/accent/warning/danger), `small: bool`, `icon: string`, `text: string` |
| `MetricCard.cs` | `Label`,`Value`,`Prefix`,`Suffix`,`Decimals`,`Context`,`Change`,`IsChangeGlyphVisible` | `ArcMetricCard.qml` | `label,value,prefix,suffix,decimals,context,change,sparkValues,up` |
| `ThemeSwitcher.cs` | `Appearance`,`Variant`,`Label`,`Text`,`IsIconOnly` | `ArcThemeSwitcher.qml` | `dark: bool`(受控), `iconOnly: bool`, `label: string`, `signal changeRequested(bool nextDark)` |
| `Card.cs` | `Title`,`Description`,`Media`,`Action`,`IsDetailsOpen`… | `ArcCard.qml` | `title,description,footer,showFooter` |
| `Button.cs` | `Variant`,`Size`,`IsLoading`,`IsPressScaleEnabled`,`LabelSwapMode` | `ArcButton.qml` | `variant,size,busy,text,icon`, `signal clicked()` |
| `DashboardPageViewModel.cs` | `Kpis`, `IsLoading` + `ICustomerService.GetDashboardAsync` | `PageDashboard.qml` | `model: var`(`{kpis,days,revenue,previous,context}`), `strings`, `title/subtitle/chartTitle/chartDescription/chartVisible`, `_hasChart` |
| `AppPages.cs` / `MainViewModel.cs` | `SelectedKey`, `SignOut()`, `RunCommand(id)` | `ArcAdminApp.qml` | `section: string`, `setDark(v)`, `setAccent(i)`, `t(key,fallback)`, `filterSections(list)`, `visibleSections: []` |
| `SidebarItem` / `SidebarSection` (axaml) | `Key`, `Label`, `Icon`, `Header` | `Sidebar.qml` / `ArcSidebarSection.qml` | `sections`, `currentKey`, `workspaceName`, `accountName`, `accountRole`, `signals navigate/toggleCollapse/signOut` |

### 3.3 官方方法 → QML 方法（改名表，逐字对照）

| 官方签名（`git grep` 实证） | QML | 注 |
|---|---|---|
| `WorkflowCanvas.Layout.cs:39 ArrangeNodes(bool animate = true)` | `arrangeNodes()` | 官方**不存在** `AutoArrange` |
| `WorkflowCanvas.Editing.cs:119 DeleteSelection()` | `deleteSelection()` | |
| `Editing.cs:105 Select(IEnumerable<WorkflowNode>)`, `:113 ClearSelection()`, `:96 SelectedNodes` | `selectNode(i)`, `clearSelection()`, `selectedNodes` | |
| `WorkflowGraph.cs:156 ResetRun()` | `resetRun()` | 官方**不存在** `ResetLayout` |
| `Editing.cs BeginMove/UpdateDrag/CommitMove` | `beginMove(i)`, `updateDrag(i,dx,dy)`, `commitMove()` | 全局光标帧间增量，节点 1:1 跟随 |
| `View.cs:53 FitToContent`, `:65 ZoomTo`, `:74 ZoomIn`, `:77 ZoomOut` | `fitToContent()`, `zoomTo(z)`, `zoomIn()`, `zoomOut()` | |
| `WorkflowCanvas Undo()/Redo()`, `View.cs:83 ScrollIntoView(node, animate)` | `undo(): bool`, `redo(): bool`, `scrollIntoView(i, animate)` | 本包实现，`_snapshot()` 历史栈 |
| `Run` 命令（`ArcWorkflowApp` 模板） | `startRun()` | **不是** `WorkflowCanvas` 方法；官方无 `RunTestEvent` |
| `ImportWizard.Logic.cs:258 GoBack()`, `:305 LoadCsv(text,fileName,size)`, `:468 Reset()`, `:493 StartImport()` | `_next()`, `_choose(row,opt)`, `_issue(row)`, `completed()` | `StepNames = Upload/Match fields/Review/Import` |
| `DataGrid.Editing.cs:41 BeginEdit()`, `:51 CommitEdit()`, `:54 CancelEdit()`, `:545 Undo()`, `:562 Redo()` | `ArcGridCell.submitEdit(txt)`, `_commit(rowObj,col,val)`, `_undo()`, `_redo()` | 官方**无** `Archive` 命名 |
| `KanbanBoard.Drag.cs:995 MoveCard(card,columnKey,index,assigneeKey,animate)` | `_endDrag()`, `_moveNext(k)` | 官方**无** `DeleteCard/RemoveCard/CardDeleted` |
| `KanbanBoard.Details.cs:58 OpenCard(card)` | `openedKey` + `ArcKanbanDrawer.qml` | |
| `DockLayout.Commands.cs:243 SaveLayout()`, `:257 LoadLayout(json)` | `loadLayout()`（借用语义） | 官方**无** `ResetLayout` |

## 4. ct() 配色键怎么对应

链路（三层，逐字照抄，不推演）：

```
[ControlDesignToken] BadgeToken.cs 属性  →  tests/Baselines/tokens/light-default.json
   →  ControlTokens.js 的 LIGHT.Badge / DARK.Badge（差异覆盖）  →  th.ct("Badge", "键")
```

实证：`BadgeToken.cs` 声明 **24** 个属性，`light-default.json` 的 `tokens.Badge` 是 **24** 键，
`ControlTokens.js` 的 `Badge` 域也是 **24** 键，逐字同名（含 `InfoRingOpacity` / `NeutralHoverBackground` / `DangerHoverBorder` …）。
全局 177 键的 `ArcDesignToken.cs` → `Tokens.js` → `th.design(key)` / `th.c(key)`。

| 令牌口 | 真源 | 本包实现 | 返回形态 |
|---|---|---|---|
| `th.ct(domain,key)` | `<Control>Token.cs` + 基线 JSON（494 域） | `ControlTokens.js` LIGHT/DARK | 标量 / `[l,t,r,b]` 四元 / `#AARRGGBB` / 时长串 |
| `th.design(key)` / `th.c(key)` | `ArcDesignToken.cs` | `Tokens.js DATA.numbers.design` | 颜色 `{light,dark}` 按 `dark` 取；`Type*` 经 `ArcDisplay.js` ×1.25 |
| `th.a(key)` | `ArcPalette.cs` 强调色派生 | `Tokens.js DATA.accents[8]` | `accent/strong/subtle/foreground/controlOn/glyph/fill` |
| `th.n(domain,key)` | 模板派生数值 | `Tokens.js DATA.numbers.<domain>` | 标量；`*FontSize` 类同步放大 |
| `th.part(domain,key)` | 随明暗变的组件色 | `Tokens.js DATA.parts` | `Badge/Table/Card/SettingsPage/Drawer/Sidebar` |
| `th.pad(v)` / `th.t4(v,i)` | `Thickness` / `CornerRadius` | `ArcTheme.qml` | 四元数组取首分量 / 第 i 边 |

**硬约束：`ct()` 的键必须是字面量，禁止 `_toneKey + "Background"` 动态拼。**
`v0.6.72-arc-lab` issue 2/7 就是这个：6 tone × 4 后缀拼出 10 个基线里不存在的键
（`NeutralBackground` / `InfoBackground` / `AccentBorder` …），运行时刷 `Arc control token missing`。
整改后 `ArcBadge.qml` / `ArcActionSwap.qml` / `ArcInput.qml` / `ArcTextarea.qml` 全改静态键表；
`tools/check.mjs` 把「`ct()` 首参非字面量」列为 FAIL。
本地 125 个 QML 实际引用 **103** 个 `ct` 域（不是 494 个全用）。

## 5. Theme 令牌怎么接 Md3 —— 结论：不接，且不应该接

这是下游 issue #5 B1 担心的「会不会变成第二套令牌」。答复是**本包不引入宿主令牌，也不做双向映射**：

| | 宿主（星集控 / QtShadcn） | 本包（第三方移植） |
|---|---|---|
| 真源 | `Stelarith-shared-qml/ui/theme/Theme.qml`（`pragma Singleton`，§9.2 唯一真源） | `ArcTheme.qml` + `Tokens.js` + `ControlTokens.js`（逐值来自上游基线） |
| 取值 | `Theme.color.background` / `Theme.radius.lg` / `Theme.spacing.md` | `th.c("Background")` / `th.design("RadiusControl")` / `th.n("sidebar","RowFontSize")` |
| 明暗 | `Theme.dark` 由外壳切 | `ArcTheme.dark` 由 `ArcAdminApp.setDark(v)` 切 |
| 依赖 | QtShadcn 体系、C++ 外壳 | 零宿主依赖（125 QML 的 import 只有 `QtQuick 2.15` / `QtQuick.Window 2.15` / 相对 JS） |

**语义对照（仅供下游写适配层，不是库内实现，值不同源、不联动）**：

| 宿主 | 本包 |
|---|---|
| `Theme.color.background` | `th.c("Background")` |
| `Theme.color.surface` / `surfaceVariant` | `th.c("Surface")` / `th.c("SurfaceMuted")` |
| `Theme.color.textPrimary` / `textSecondary` | `th.c("Foreground")` / `th.c("TextSecondary")` |
| `Theme.color.primary` / `accentStrong` | `th.a("accent")` / `th.a("strong")` |
| `Theme.color.destructive` / `success` / `warning` | `th.c("Danger")` / `Success` / `Warning` |
| `Theme.color.scrim` | `th.c("Scrim")` |
| `Theme.radius.sm/md/lg/xl/full` | `th.design("RadiusControl")` / `RadiusPanel` / `RadiusPill`（四元，用 `pad()`/`t4()`） |
| `Theme.spacing.xs..xl`（4/8/16/24/32） | `th.design("Space1..Space6/Space8")` |
| `Theme.motion.fast/normal/slow` | `th.dur("Fast"/"Standard"/"Slow")` + `th.spring(name)` |

宿主封装 `ArcAdminPage.qml` 现有注释即此决策：「**theme / ctx 只接收、不透传**，强行做一层映射会造出第二套真源（§9 禁止），保持一套界面一套令牌」。
若下游要联动明暗：在自己的适配层做单向 `Theme.dark → app.setDark(Theme.dark)`，**不要改库本体**，也不要把 `Theme` import 进 `arc/`。
字体同理：本包不捆绑字体，不读 `.xlf`；`ArcDisplay.js` 按 `Qt.platform.os` 回退（windows `Segoe UI` / osx,ios `Helvetica Neue` / linux,wasm `Noto Sans` / android `Roboto` / unix `DejaVu Sans`，mono 同理），宿主可设 `ArcTheme.fontFamilyOverride` / `monoFamilyOverride`。

## 6. 拿到上游新版 diff 后的判定流程

1. 按 §1 把变更文件分类；`.csproj`/`.props`/`.github`/`.xlf`/`.md` 直接判「不影响本包」。
2. 令牌类 → 跑 `node tools/gen_tokens.mjs <新上游根> ..`，diff `ControlTokens.js`；新增/改名键要同步改 `th.ct()` 字面量（§4）。
3. `*Token.cs` 新增属性 → 检查本地 `Arc<控件>.qml` 是否需要新 `th.ct()` 字面量；禁拼动态键。
4. `*.cs` 新增 `StyledProperty` → 按 §3 加 camelCase property；新增公开方法 → camelCase function + 注释保留官方签名。
5. `*.axaml` 模板变更 → 改对应 QML 视觉结构；伪类 → `containsMouse` / bool 属性。
6. 新控件（如 `SlideToConfirm`）→ 新建 `Arc<类名>.qml`（≤200 行）、跑 `node tools/gen_qmldir.mjs`、补 `public-api.json`、真机验无 QtQuick.Controls（§7）。
7. 跑 `node tools/check.mjs` + `node tools/golden.mjs` + 三路加载；全绿才打新 `port/<semver>` tag。
8. 出件信号 = **tag 推送 + `PIN` 变更**；下游按事件触发重对，不追 `main`、不按日历。

## 7. 工具链红线（下游 B2 的实测答复）

- Qt 6.12.0 / MSVC 2022 / Windows：本包 125 个 QML 的 import 去重后只有 `QtQuick 2.15`、`QtQuick.Window 2.15` 与相对 JS 库。
- 零 `QtQuick.Controls` / `QtQuick.Layouts` / `ScrollBar` —— 所以真机 `ScrollBar is not a type` 让整块面板空白的风险**在本包内不存在**。
- `SlideToConfirm`（上游 `.4` 新增 9 件）尚未移植；`port/v0.2.0` 引入时必须先过 `tools/check.mjs` 的 import 白名单 + 真机加载，禁止为它开 Controls 例外。
- 每个 `.qml` ≤ 200 行、括号平衡、`qsTr()`/`Accessible` 覆盖、§10.9 纯净 UI（禁 `XMLHttpRequest`/`WebSocket`/`fetch`/`JSON.parse`）——全部由 `tools/check.mjs` 机器判。

## 8. 相关文件

- 公开面机器契约：`public-api.json`（125 类型逐件 property/signal/function/ct 域）
- 版本钉：`PIN`（port tag + 上游 commit + 聚合 SHA-256）+ `SHA256SUMS`（逐文件）
- 破坏性变更：`BREAKING.md`
- 文本 golden：`GOLDEN.json`（`node tools/golden.mjs` 重算）
- 接入：`INTEGRATION.md`；变更史：`CHANGELOG.md`；包说明：`README.md`


## 9. 下游 12 问逐条答复（issue #5 第三、四条评论）

这张表本身就是最想问的那一个答案：上游 97 个变更文件里 0 个 QML，跟进不能靠 diff；
按 §1 分类 → §2 改名 → §3 prop/方法 → §4 键 → §5 令牌边界 → §6 出件判定。其余 11 问：

### A · 阻塞 5

| # | 答复 | 落点 |
| --- | --- | --- |
| A1 | `module arc 1.0`，目录必须叫 `arc`（URI 逐字等于目录名），**125 全量注册**，无 `prefer`/`depends`/`classname`（纯 QML、零 C++ 插件）。下游 9 件适配层把 `import "arclab" as Arc` 换成 `import arc 1.0` 即可，组件名不变。 | `qmldir`、`tools/gen_qmldir.mjs`、§2 |
| A2 | 稳定公开面 = 105 个非 preview 类型所有非 `_` 前缀 property/signal/function，逐件列在 `public-api.json`（schema `arc-port-public-api/v1`）。20 个 preview 类型（Demo / 12 陈列 Page / AnalyticsApp / 5 An*）可在 minor 内变。`PageDashboard.model`、`ArcAdminApp.dashboardData`、`ArcThemeSwitcher` 受控契约全部登记。 | `public-api.json` |
| A3 | 从整改前 arclab 副本到 `port/v0.1.0` 的 10 条破坏性变更逐条列在 `BREAKING.md`。**上游 `695a85d7 → 66627fcda4d4` 的 21 提交尚未移植**，不产生新的 breaking；进 `port/v0.2.0` 时另发一表。 | `BREAKING.md` |
| A4 | **`Sample.dashboard(customers)` 长期保留**（`SampleData.js` 公开函数，签名稳定），但 **库本体不再默认调用**：`ArcAdminApp` 四数据源默认 `null`。⚠️ 与 #5 评论③「撤四行注入、走库默认 `Sample.dashboard(customersData)`」**冲突** —— 新版撤注入后 Dashboard 是空白态，不是上游原貌。要恢复上游原貌，下游必须**显式注入** `dashboardData: Sample.dashboard(customersData)`（见 `Demo.qml` 的四行）。这是 BREAKING #2，请下游按新版改，不要按旧假设撤。 | `BREAKING.md` #2、`INTEGRATION.md` 数据桥、`Demo.qml` |
| A5 | **给**：`PIN` = port tag + 上游 commit + describe + 文件数 + 聚合 SHA-256；`SHA256SUMS` = 151 个文件逐件 SHA-256；`cmp_manifest` 列 13 个关键件。两端各自 `cmp SHA256SUMS` + `sha256sum -c` 即硬验收。包内 `tools/pin.mjs` 可重生成，PIN/SHA256SUMS 自身不计入聚合，故端口 commit 可写入而不漂移。 | `PIN`、`SHA256SUMS`、`INTEGRATION.md` |

### B · 风险 4

| # | 答复 | 落点 |
| --- | --- | --- |
| B1 | **不会变成第二套令牌**：本包零 import 宿主 `Theme`，`ArcTheme` 是包内私有解析器，两者不同源不联动；§5 给出仅供适配层的语义对照表与单向 `Theme.dark → setDark()` 建议。字体 `.xlf` **归宿主**（Qt `QTranslator`/`.qm`），本包只出 `qsTr()`=54 / `Accessible`=26 + `ArcDisplay.js` 平台回退，不捆绑字体。上游 42 个 `.xlf` 与下游 `.4` 新增 3 个都不落本包。 | §1 末两行、§5、`ArcDisplay.js` |
| B2 | Qt 6.12.0 / MSVC 2022 实测：125 个 QML 的 import 去重只有 `QtQuick 2.15` / `QtQuick.Window 2.15` / 相对 JS。**零 QtQuick.Controls、零 `ScrollBar`**，所以「ScrollBar is not a type 让整块面板空白」在本包内不成立。`SlideToConfirm`（上游 .4 的 8–9 新文件）**尚未移植**，进 `port/v0.2.0` 前必须过 `tools/check.mjs` import 白名单 + 真机加载，不开 Controls 例外。`qmldir` 无 `prefer`/`classname`，不存在插件加载面。 | §7、`tools/check.mjs` |
| B3 | `LICENSE` = 上游 MIT 全文逐字 + 移植层 MIT；`THIRD-PARTY-NOTICES.md` 只列真正流入的 TKCode.Arc/ARC(MIT) 与 Lucide 158 path(ISC)，**Arc Pro 未使用**、Qt 为运行时依赖不重分发、字体不捆绑、上游 C#/.NET 依赖不适用。新版若新增第三方资源，按 `tools/gen_tokens.mjs` 同轮补 NOTICES。 | `LICENSE`、`THIRD-PARTY-NOTICES.md` |
| B4 | 最小机器判据（全绿才晋级）：`node tools/check.mjs`=`CHECK_OK` + `node tools/golden.mjs --check`=`GOLDEN_OK` + `qml -I <parent-of-arc> Demo.qml` 零 QML 错 + 下游真 GUI 探针零错。回滚 = 把消费端 PIN 指回上一 `port/<semver>` tag、还原目录、重跑同一组判据；**tag 不可变，禁止就地改已部署副本**。 | `INTEGRATION.md` §Canary rollback |

### C · 节奏 3

| # | 答复 | 落点 |
| --- | --- | --- |
| C1 | 出件形态 = **git tag + 推送**（不追 main、不按日历、不发 zip）。可观测信号 = `https://github.com/WuMengAA/arc` 出现 `port/v0.1.0` tag + `PIN` 变更 + `GOLDEN.json`。下游按事件触发重对。 | `PIN`、`CHANGELOG.md` |
| C2 | **9 条全归移植方（本包）修，已在 `port/v0.1.0` 关闭**：qmldir 2/125→125、ArcBadge 动态 ct 缺键、ThemeSwitcher 受控、字体硬编码、qsTr/Accessible、Undo/Redo/ScrollIntoView、ArcActionSwap 动态键、SampleData 假数据默认注入、PageDashboard 写死文案。逐条证据见 `CHANGELOG.md` §0.1.0 与 `README.md` §8。**没有一条留给上游**，也不是「待适配」——是本库自身未完成项。 | `CHANGELOG.md`、`README.md` §8 |
| C3 | 给**文本/数据 golden**：`GOLDEN.json` = `DashboardPage.axaml` 7 条上游原文拼接 SHA-256 + `SampleData.js` 的 64 客户 / 4 KPI / 30 天 revenue / previous / context 的逐项 SHA-256，`node tools/golden.mjs --check` 机器判漂移。**不提供像素 SHA**：截图像素回归属消费端视觉基线（其 ARCLAB_RENDER 44/0），库只钉文本与数据，不把下游截图搬进样式真源。 | `GOLDEN.json`、`tools/golden.mjs` |

> 口径：**只发不改下游**。本仓库不碰 `qml/arclab/`、不改 `ArcLabShell.qml`、不动星集控任何文件、不替下游提交/重启/发版。对照页串味（#5 §3）由下游点头后自行处理。
