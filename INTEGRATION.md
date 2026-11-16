# Integration guide

This repository is the **source of truth** for the TKCode.Arc → Qt/QML port. Consuming applications should treat
the library as read-only and adapt pages outside it. The package directory must be named `arc` for
`import arc 1.0` to resolve; a mismatched module URI fails with `module "..." is not installed`.

## Requirements

- Qt 6 with `QtQuick 2.15` and `QtQuick.Window 2.15`.
- No QtQuick.Controls, QtQuick.Layouts, QtShadcn, C++ plugin, network access or binary assets.
- System UI font; override through `ArcTheme.fontFamilyOverride` / `monoFamilyOverride` if needed.

## Three ways to consume

1. **Directory import** — copy `arc/` into the consumer QML tree and use `import "." as Arc` (or the relative directory).
   Keep the directory self-contained; do not edit library files for page-specific content.
2. **Module import** — place `arc/` under any import root and add that root to `QML_IMPORT_PATH` / `qml -I`;
   then `import arc 1.0`. `qmldir` registers all 125 QML types.
3. **Standalone preview** — run `qml Demo.qml` from this repository. `Demo.qml` injects synthetic `SampleData.js`;
   production hosts should leave the four data sources empty unless they supply real data.

## Data and copy bridges

`ArcAdminApp.qml` exposes four nullable data sources:

```qml
Arc.ArcAdminApp {
    anchors.fill: parent
    customersData: hostCustomers   // null = empty state
    dashboardData: hostDashboard   // null = no KPI cards / no revenue chart
    workspaceData: hostWorkspace
    billingData: hostBilling
    strings: ({ dashboardTitle: qsTr("Device overview"),
               revenueTitle: qsTr("Online trend"),
               seriesCurrent: qsTr("Current"),
               seriesPrevious: qsTr("Previous") })
    visibleSections: ["dashboard", "settings"]
}
```

Use `strings` for visible copy, `visibleSections` to trim navigation, and the four data properties for real models.
Do not inject demo data into a production comparison page: it creates mixed upstream/downstream content.

## Version pinning

Pin an exact `port/<semver>` tag and record the upstream commit in the consumer's dependency ledger.
`port/v0.1.0` pins upstream `695a85d727772490c03ff6586455796d6f4af16f` and closes the nine integration issues
listed in `CHANGELOG.md`. Upstream upgrades are delivered as new port tags, never as in-place edits to a consumer copy.

## Validation before updating a consumer

```bash
node tools/check.mjs
node tools/gen_qmldir.mjs .     # only after adding/removing a QML file
qml -I <parent-of-arc> Demo.qml
```

Add a real-GUI render check in the consuming application after updating the copy.

## Licensing

MIT; upstream MIT notice and Lucide ISC notice are retained in `LICENSE` and `THIRD-PARTY-NOTICES.md`.
Arc Pro components, copy and assets are not used.


## Porting contract and public API

The translation contract between upstream .NET files and this QML package is `PORTING-MAP.md`:
path classes, component naming, property/method renames, `ct()` token keys, and the Theme/Md3 boundary.
`public-api.json` is the machine-readable public surface for all 125 types; `BREAKING.md` is the
change list consumers must read before switching port tags.

The package does **not** import the host's `Theme` singleton and does **not** provide an Md3 mapping layer.
They are two independent style sources. A host may link only the boolean dark flag in its own adapter:

```qml
Arc.ArcAdminApp {
    id: app
    startDark: Theme.dark
    // do not pass Theme.color.* into arc/
}
```

## PIN, two-endpoint cmp and canary rollback

`PIN` contains the port tag, upstream commit, file count, aggregate SHA-256 over `SHA256SUMS`,
and a short cmp manifest. A consumer copy is identical only when its `SHA256SUMS` is byte-for-byte equal.

```bash
# after copying ui/arc/<tag>/ to both endpoints
cmp endpointA/SHA256SUMS endpointB/SHA256SUMS
(cd endpointA && sha256sum -c SHA256SUMS)
(cd endpointB && sha256sum -c SHA256SUMS)
```

**Minimum machine gate before promoting a canary**: `node tools/check.mjs` = `CHECK_OK`,
`node tools/golden.mjs --check` = `GOLDEN_OK`, `qml -I <parent-of-arc> Demo.qml` loads,
and the consumer's real-GUI probe reports zero QML errors. `GOLDEN.json` is a text/data SHA golden,
not a pixel SHA: it pins upstream dashboard copy plus `SampleData.js` expectations. If a consumer needs
pixel regression, keep the screenshot hash in the consumer repository, not in this library.

**Rollback**: change the consumer's port pin back to the previous `port/<semver>` tag, restore the previous
copied directory and rerun the same `cmp` / `check` / `golden --check` / real-GUI gate. The port repository
itself is immutable per tag; never patch a deployed copy in place.

## Upstream changes are not applied by diffing files

97 upstream changed files contain zero QML. To follow a new upstream tag, start from `PORTING-MAP.md` §6:
classify each changed file, regenerate control tokens, map new properties/methods, then cut a new port tag.
