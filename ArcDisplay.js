.pragma library
// 显示适配层（Qt 侧新增，真源码无此文件）：官方令牌基线 Tokens.js 保持逐字不变，
// 仅针对本机 150% DPI 桌面预览放大字阶、增强浅色文本对比度、指定清晰字体族。
var TypeScale = 1.25;
var FontFamily = "Segoe UI";
var MonoFamily = "Consolas";
// 平台等价族：Qt.fontFamilies() 在不同 OS 不同名；Qt 缺失时自带 fallback，故只需一个主族。
var FontFallback = { windows: "Segoe UI", osx: "Helvetica Neue", ios: "Helvetica Neue",
    linux: "Noto Sans", android: "Roboto", unix: "DejaVu Sans", wasm: "Noto Sans" };
var MonoFallback = { windows: "Consolas", osx: "Menlo", ios: "Menlo",
    linux: "DejaVu Sans Mono", android: "monospace", unix: "DejaVu Sans Mono", wasm: "monospace" };
function fontFamily(os) { return FontFallback[os] || FontFamily; }
function monoFamily(os) { return MonoFallback[os] || MonoFamily; }
var LightBoost = {
    "Foreground": "#FF000000",
    "TextSecondary": "#FF3A3A3A",
    "TextMuted": "#FF545454",
    "Border": "#FFD9D9D9",
    "BorderSubtle": "#FFE7E7E7",
    "BorderStrong": "#FF9E9E9E"
};
function type(raw, key) {
    if (typeof raw !== "number" || key.indexOf("Type") !== 0) return raw;
    return Math.round(raw * TypeScale);
}
// ct()/n() 里以 FontSize/TextSize 命名的数值同样是字号，需同步放大；尺寸/圆角类不动。
function fontish(v, key) {
    if (typeof v !== "number" || !/(FontSize|TextSize|TypeSize|LabelSize|TitleSize)/i.test(key)) return v;
    return Math.round(v * TypeScale);
}
function readable(dark, key, v) {
    if (dark || typeof v !== "string" || v.charAt(0) !== "#") return v;
    return LightBoost[key] !== undefined ? LightBoost[key] : v;
}
