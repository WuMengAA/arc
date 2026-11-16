# Third-party notices — TKCode.Arc → Qt/QML port

This directory is a **QML reimplementation** of design tokens, sample data,
component APIs and free blocks published by **TKCode.Arc v1.1.0**
(upstream commit `695a85d727772490c03ff6586455796d6f4af16f`, `git describe v1.1.0-6-g695a85d7`).
It is not a fork of the upstream C#/Avalonia source: no upstream source file is
copied verbatim. Everything here is QML/JavaScript written for Qt 6.

The complete upstream notice file is
[THIRD-PARTY-NOTICES.md](https://github.com/AIDotNet/TKCode.Arc/blob/main/THIRD-PARTY-NOTICES.md).
Only the items that actually flow into this port are reproduced below.

## 1. TKCode.Arc — MIT

`Tokens.js` / `ControlTokens.js` port the upstream token baselines
(`tests/Baselines/tokens/{light,dark}-default.json`, 494 identity values);
`ArcShowcaseData.js` ports sample CSV from
`Blocks/Developer/ImportWizard/ImportWizardDefaults.cs`; `SampleData.js` /
`AnalyticsData.js` replay the template sample services; component APIs in
`ArcWorkflow.qml`, `ArcImportWizard.qml`, `ArcSpreadsheet.qml`,
`ArcKanbanBoard.qml`, `ArcDockLayout.qml` follow the upstream method names
(documented per-file in README.md §3). Sidebar classification follows
`AppPages.cs` / `MainView.axaml` / `BlockCatalog.cs` / `templates/README.md`.

License text: see `LICENSE` (first block, verbatim upstream MIT).

```
MIT License

Copyright (c) 2026 TKCode.Arc contributors
```

Upstream also credits **Arc (uiarc.dev)** free components/blocks, which are MIT:

```
MIT License

Copyright (c) 2026 Elia Kuratli
```

Full MIT text is in `LICENSE`. Arc Pro components/blocks are **not** used:
upstream `THIRD-PARTY-NOTICES.md:10-26` states that Pro-named items
(data grid / import wizard / sheet stack / control center / projects blocks …)
are independent TKCode designs; this port follows that same public design
reference only. No Arc Pro code, copy, assets or previews were copied.

## 2. Lucide icons — ISC

`Icons.js` contains **158 SVG path geometries** derived from Lucide
(lucide-static), via `TKCode.Arc` `ArcIcons.g.cs` / `LucidePaths.txt`.
No icon raster files are bundled; paths are rendered as data-URI SVGs.

```
ISC License

Copyright (c) for portions of Lucide are held by Cole Bemis 2013-2026 as part of Feather (MIT).
All other copyright (c) for Lucide are held by Lucide Contributors 2026.

Permission to use, copy, modify, and/or distribute this software for any purpose with or
without fee is hereby granted, provided that the above copyright notice and this permission
notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE
OR PERFORMANCE OF THIS SOFTWARE.
```

## 3. Not bundled / not applicable

- **Qt** (LGPL/GPL/commercial): a runtime dependency of the consumer, not
  redistributed here. This package ships only `.qml` / `.js` / text files.
- **Fonts** (Inter / Geist / Silkscreen / VT323 / Noto Sans SC, all OFL):
  **not bundled**. `ArcDisplay.js` selects an equivalent system family by
  `Qt.platform.os` (Windows → Segoe UI, macOS/iOS → Helvetica Neue, Linux/wasm →
  Noto Sans, Android → Roboto, unix → DejaVu Sans; mono has its own table) and
  uses `Text.NativeRendering`. Consumers may override `ArcTheme.fontFamilyOverride` /
  `monoFamilyOverride`. No font binary is in this directory.
- **Avalonia, AtomUI, StreamMark, TextMateSharp, Oniguruma, Markdig,
  miniaudio, PDFium, pdf.js, Natural Earth, Unicode emoji data**: upstream
  C#/.NET dependencies and assets that do **not** appear in this QML port.
  No binary assets (png/jpg/svg file/ttf/otf/dll) are shipped here.
- **Sample data**: all names, emails (`*.example`), companies and numbers are
  synthetic upstream demos; no personal data is embedded.

## 4. Port-layer additions

`ArcDisplay.js` (TypeScale 1.25, platform font fallback, light-theme contrast boost) and
`ArcGridCell.qml` / `ArcGridToolbar.qml` / `ArcKanbanDrawer.qml` etc. are
original QML written for this port. They are covered by the second MIT block
in `LICENSE`.
