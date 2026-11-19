# Breaking changes · port/v0.1.0

相对下游 `qml/arclab/` 里那份**整改前的实验副本**。下游 `qml/arclab/` 的 135 件库本体（v0.1.0 时 125 QML + 10 JS；本包现 213 QML）中，本表涉及的整改文件已变；页面适配层需按此表重对。

| # | 变更 | 旧（arclab 副本） | 新（port/v0.1.0） | 下游要做什么 |
|---|---|---|---|---|
| 1 | `qmldir` | 只注册 2 个类型 | `module arc` + 213 行全量注册 | `import arc 1.0` 才可用；目录名必须 `arc` |
| 2 | 四数据源默认值 | `Sample.customers()` 等商业假数据自动注入 | `customersData/dashboardData/workspaceData/billingData` 默认 `null`（空态） | **必须显式注入**，否则 Dashboard 空白；见 `INTEGRATION.md` |
| 3 | `ArcThemeSwitcher` | 单击自己翻 `dark` | 受控：只发 `changeRequested(nextDark)` | 调用方必须回填 `dark`，否则视觉不变 |
| 4 | `PageDashboard` | 写死 `Dashboard`/`Revenue`/商业文案 + 空折线框 | `title/subtitle/chartTitle/chartDescription/chartVisible` + `strings` 桥；`_hasChart` 为假时整块不显示 | 文案走 `strings`，不要改库文件 |
| 5 | 字体 | 345 处硬编码 `Segoe UI` / 3 处 `Consolas` | `th.fontFamily` / `th.monoFamily` 平台回退 + override | 不要给 `Text` 直写 `font.family: "..."` |
| 6 | `ct()` 键 | 动态拼 `_toneKey + 后缀` | 静态字面量键表 | 任何新 tone 都要先确认基线里有该键 |
| 7 | `ArcWorkflow` 方法 | 无 undo/redo/scrollIntoView；拖动换数组引用 | `undo()/redo()/scrollIntoView(i,animate)`；`updateDrag` 原地改对象 + 全局坐标增量 | 拖动 1:1；旧调用 `_move()` 已不存在 |
| 8 | 公开命名 | 混用官方 PascalCase 与内部名 | 对外一律 camelCase（`arrangeNodes`/`deleteSelection`/…） | 按 `PORTING-MAP.md` §3.3 改调用 |
| 9 | 文案 / 无障碍 | `qsTr`=0 / `Accessible`=0 | `qsTr`=54 / `Accessible`=26 | 宿主翻译体系接 `.qm`，库不发 `.xlf` |
| 10 | 依赖 | 可能存在隐式宿主引用 | 零 `QtQuick.Controls`/`Layouts`/`QtShadcn`/`backendRef`/`ctx.window`/网络 API | 下游适配层放库外 |

**非 breaking（新增，不破坏旧调用）**：`strings` 桥、`visibleSections`、`fontFamilyOverride`、`monoFamilyOverride`、`PORTING-MAP.md`、`public-api.json`、`PIN`、`SHA256SUMS`、`GOLDEN.json`、`tools/check.mjs`、`tools/golden.mjs`。

**未追的上游**：本地仍钉 `695a85d7`；下游 #5 钉 `v1.1.1-preview.4 @ 66627fcda4d4`（ahead 21 / 97 files）。
那 21 个提交（SlideToConfirm / ArcWindow.UnavailableCaptionButtons / ExpandableCard 阴影 / UserMenu 多语言 / ColorPicker morphing header / 3 个 .xlf）
**仍未跟进**——`port/v0.2.0` 补的是「钉住的那个 commit 里 146 个完整组件的类位缺失」，
不是那 21 个提交的行为改动。两件事不要混为一谈：本次是**补齐覆盖面**，不是**升级上游基线**。
