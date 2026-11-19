# Changelog

All notable changes to the TKCode.Arc → Qt/QML port are documented here.
Versions use the `port/<semver>` tag scheme. The upstream pin is recorded in every release.

## [port/v0.2.0] — 2026-11-20

Full-coverage port: every upstream component that ships both `<Name>.cs` and `Themes/<Name>Theme.axaml`
now has an `Arc<Name>.qml` counterpart. No upstream behaviour was re-specified — tokens are read through
`th.ct("<Domain>", "<Key>")` with the exact domains/keys from the baseline JSON.

- **Coverage**: upstream 146 complete components → **80 newly ported**, package now **213 QML types**
  (was 125). Verified by directory scan of `src/TKCode.Arc/**` against this package's file names.
- **New types (80)**: AnimatedCounter, TextMorph, TextShimmer, SlotText, TextReveal, InViewTitle,
  ExpandableText, Gauge, WaffleChart, ActivityHeatmap, Ridgeline, SlopeChart, Streamgraph, Treemap,
  SplitBar, BrushChart, AvatarGroup, PresenceStack, BackToTop, TilePanel, WaterfallPanel, CyclicPanel,
  MetricTicker, TreeView, TreeTable (+TreeTableHeader/Row), JsonViewer, CodeBlock, FilterToolbar,
  ReorderableList, NumberFilterBox, TextFilterBox, Form, FormItem, TokenTextEditor, TagInput, MorphSelect,
  Cascader, TreeSelect (+TreeSelectValueRow/Row), TransferBox, SearchField, PasswordField,
  PasswordStrength, ExpandingSearch, NumberField, MoneyInput, Countdown, UsageMeter, CookieConsent,
  ToastStack, Carousel, CardStack, ImageCompare, ArcWindow, ColorPicker (+ColorPickerPanel),
  DateRangePicker (+DayCell/MonthPane), TimePicker, FluidTabControl, OnboardingChecklist, ScrubInput,
  ShortcutRecorder, OnScreenKeyboard, ElasticSlider, RangeHistogramSlider, RulerSlider, PhoneInput,
  MentionInput, FileDropzone, SignaturePad, Markdown, ChatThread, CommentThread (+CommentThreadItem),
  Timeline, AvatarUpload, PropertyGrid, DataFlow, MultiRegionFailover, PaymentFlow, VectorSearch,
  RichTextEditor, PageViewer.
- **Generated contract**: `tools/gen_public_api.mjs` regenerates `public-api.json` (213 types:
  191 stable + 22 preview) from the QML sources, so the contract cannot drift from the code.
- **Gates**: `tools/check.mjs` → `CHECK qml=213 js=10 qmldir=213 fail=0 warn=0`;
  `tools/golden.mjs --check` unchanged (`GOLDEN_OK`, same upstream-text and sample-data SHAs);
  `tools/pin.mjs` → `PIN_OK`.
- **Load probe**: all 209 `th`-bearing types instantiated in one offscreen window → zero QML errors.

## [port/v0.1.0] — 2026-11-16

First standalone, pinnable release of the independent third-party port.

- **Upstream pin**: `695a85d727772490c03ff6586455796d6f4af16f` (`v1.1.0-6-g695a85d7`).
  Upstream `main` at the time of packaging was `57e42d28dd56` (`v1.1.1-preview.2`), 17 commits / 65 files ahead;
  those changes are tracked for a later port release, not mixed into this baseline.
- **Package**: 125 QML types, 10 JavaScript token/data libraries, 2 generator scripts, MIT + ISC notices.
- **Split from the consumer repository**: this repository is the port's source of truth.
  The downstream `qml/arclab/` copies and `ArcAdminPage.qml` adapter are deliberately outside this package.

### Closed integration issues

| # | Issue | Resolution |
|---|---|---|
| 1 | `qmldir` registered only 2 of 125 types | Full generated registry; `tools/gen_qmldir.mjs` keeps it in sync. |
| 2 | `ArcBadge.qml` built dynamic `th.ct()` keys | Static token tables; no missing Neutral/Info/Accent keys. |
| 3 | `ArcThemeSwitcher.qml` mutated its own `dark` state | Controlled component: emits `changeRequested(nextDark)` only. |
| 4 | Hard-coded `Segoe UI` / `Consolas` | `ArcDisplay.js` selects platform equivalents; `ArcTheme` exposes family overrides. |
| 5 | No `qsTr()` / `Accessible` coverage | 54 `qsTr()` call sites and 26 accessibility declarations added. |
| 6 | Undo / Redo / ScrollIntoView documented but absent | `ArcWorkflow.qml` implements `undo()`, `redo()`, `scrollIntoView(i, animate)` with snapshots and canvas translation. |
| 7 | `ArcActionSwap.qml` built dynamic `th.ct()` keys | Static Fill/Edge/EdgeHover ternary tables; related `_padKey` uses removed. |
| 8 | Commercial demo data injected by default | `ArcAdminApp.qml` data sources default to `null`; only `Demo.qml` injects `SampleData.js`. |
| 9 | Hard-coded commercial copy / empty chart frame | `strings` bridge, `visibleSections`, `PageDashboard` title/subtitle/chart properties and `_hasChart` gate. |

### Interaction and display fixes carried into the baseline

- Workflow drag is 1:1: global cursor frame deltas plus in-place node mutation; real-GUI 150 px drag moved the node 150 px, monotonically and uniformly.
- Vertical drags inside controls no longer flick the parent page: 9 drag `MouseArea`s use `preventStealing: true`.
- Type scale ×1.25, light-theme contrast boost, `Text.NativeRendering` and platform font fallback.
- Sidebar grouped against upstream `MainView.axaml` / `AppPages.cs` / `BlockCatalog.cs`; QML function names are camelCase with upstream PascalCase mapped in README §3.

### Verification evidence

- Three-way loading: `qml Demo.qml` with no import path, isolated copy, and `import arc 1.0 -I <parent-of-arc>`.
- Full static audit: 125 QML / 10 JS; every QML ≤ 200 lines, balanced braces, zero `XMLHttpRequest` / `WebSocket` / `fetch` / `JSON.parse`, qmldir 125/125, zero dynamic `th.ct()` keys, zero hard-coded font families.
- Offscreen functional probe covers all 17 sections, empty/injected data, strings bridge, section filtering, controlled theme switcher, six badge/swap tones, font fallback and Workflow undo/redo/scroll/zoom: 34 checks passed, 0 failed.
- Real-GUI checks: controlled switcher, empty-data dashboard, strings bridge, visible-section filter, Workflow 1:1 drag / Undo / Redo / Arrange; zero QML errors.
- `node tools/check.mjs` added as a dependency-free package self-check.
