// TKCode.Arc 令牌解析器（真实值来自 arc/Tokens.js，链路：ArcDesignToken.cs / *Token.cs → 基线 JSON）。
// 用法：ArcTheme { id: th; dark: true; accentIndex: 1 } —— 由根组件创建一次，按 th 传给子组件。
import QtQuick 2.15
import "Tokens.js" as Tk
import "ControlTokens.js" as Ct
import "ArcPresets.js" as Pr
import "ArcMotion.js" as Mo
import "ArcOklch.js" as Ok
import "ArcDisplay.js" as Dp

QtObject {
    id: th

    property bool dark: false
    property int accentIndex: 0
    // 字体令牌（issue 4）：按平台给等价族；宿主可用 *Override 覆盖（如随包分发字体）。
    // 不能整体赋值 Qt.application.font（Qt 6.12 实测 "Cannot assign to read-only property \"font\""）。
    property string fontFamilyOverride: ""
    property string monoFamilyOverride: ""
    readonly property string fontFamily: fontFamilyOverride !== "" ? fontFamilyOverride : Dp.fontFamily(Qt.platform.os)
    readonly property string monoFamily: monoFamilyOverride !== "" ? monoFamilyOverride : Dp.monoFamily(Qt.platform.os)

    // 主题预设 slot（真源码 ArcThemePreset.Slot：ArcStyle / ArcCorners，一个 state 每 slot 一个 preset）
    // 合法值：stylePreset ∈ "" | "pixel"；cornerPreset ∈ "" | "corner-square" | "corner-half" | "corner-double"
    property string stylePreset: ""
    property string cornerPreset: ""
    // ArcMotionLevel：0=Off（无动画）/ 1=Reduced（仅颜色与透明度）/ 2=Full
    property int motionLevel: 2

    readonly property var data: Tk.DATA
    readonly property var acc: Tk.DATA.accents[Math.max(0, Math.min(7, accentIndex))]
    readonly property var accNow: acc ? acc[dark ? "dark" : "light"] : null

    // 设计令牌：颜色类返回 {light,dark} 形态，标量/四元数组直接返回
    function design(key) {
        var v = data.numbers.design[key];
        if (v === undefined) { console.warn("Arc token missing: " + key); return "#FF000000"; }
        var base = v;
        if (v && typeof v === "object" && !Array.isArray(v) && v.light !== undefined)
            base = dark ? v.dark : v.light;
        var out = _override("ArcDesign." + key, base);
        out = Dp.type(out, key);                 // 字阶放大（仅 Type* 键）
        return Dp.readable(dark, key, out);       // 浅色文本对比度适配
    }

    // 颜色快捷方式（同一个函数名，专供颜色键）
    function c(key) { return design(key); }

    // 强调色字段：accent / strong / subtle / foreground / controlOn / thumbOn / glyph / fill
    function a(key) {
        // Pixel 预设直接覆盖 ArcDesign.Accent* 等键；default 仍走 accents 解析表。
        if (stylePreset === "pixel") {
            var m = { accent: "Accent", strong: "AccentStrong", subtle: "AccentSubtle",
                      foreground: "AccentForeground", controlOn: "ControlOn", glyph: "ControlGlyph" };
            if (m[key]) return c(m[key]);
        }
        return accNow ? accNow[key] : "#FF000000";
    }

    // 组件域数值：n("button","HoverOpacity")
    function n(domain, key) {
        var o = data.numbers[domain];
        if (!o) { console.warn("Arc number domain missing: " + domain); return 0; }
        var v = o[key];
        if (v === undefined) { console.warn("Arc number missing: " + domain + "." + key); return 0; }
        return Dp.fontish(v, key);
    }

    // 控件规格令牌：th.ct("Checkbox", "BoxSize") —— 域名与真源码 <Control>Token.cs 一致。
    // 数据源 ControlTokens.js（494 identity 基线）。DARK 只存与 LIGHT 不同的键，故先查覆盖再回落。
    // 返回类型与基线一致：标量 / 四元数组（配 pad()、t4() 用）/ #AARRGGBB 颜色 / 时长字符串。
    function ct(domain, key) {
        var v;
        var d = dark ? Ct.DARK[domain] : null;
        if (d && d[key] !== undefined) v = d[key];
        else {
            var l = Ct.LIGHT[domain];
            if (!l) { console.warn("Arc control token domain missing: " + domain); return 0; }
            v = l[key];
        }
        if (v === undefined) { console.warn("Arc control token missing: " + domain + "." + key); return 0; }
        return Dp.fontish(_override(domain + "." + key, v), key);
    }

    // 内边距/圆角：令牌若是四元数组取首个分量（Arc 的 Padding 四边同值时等价）
    function pad(v) { return Array.isArray(v) ? v[0] : (v || 0); }

    // 四元厚度 → 各边
    function t4(v, i) { return Array.isArray(v) ? v[i] : (v || 0); }

    // 组件级主题色（Badge/Table/Card/SettingsPage/Drawer/Sidebar 里随明暗变的那些键）
    function part(domain, key) {
        var p = data.parts[dark ? "dark" : "light"];
        var d = p ? p[domain] : null;
        if (!d || d[key] === undefined) { console.warn("Arc part missing: " + domain + "." + key); return "#00000000"; }
        return d[key];
    }

    // 侧栏填充（随主题变的三键）
    function sidebar(key) {
        var s = data.sidebar[dark ? "dark" : "light"];
        return s ? s[key] : "#00000000";
    }

    // 序列色（图表）
    function series(i) {
        if (stylePreset === "pixel") {
            var ov = _override("ArcDesign.Series" + ((i || 0) % 4 + 1), c("Series1"));
            return ov;
        }
        var name = acc ? acc.name : "neutral";
        var s = data.series[name];
        var arr = s ? s[dark ? "dark" : "light"] : null;
        if (!arr) return c("Series1");
        return arr[(i || 0) % arr.length];
    }

    // ── 主题预设覆盖（源：ArcThemePreset / ArcCornerPresets / ArcPixelPresets）──
    // 应用顺序：stylePreset 先、cornerPreset 后（后者覆盖前者，真源码「后加的 preset 赢」）。
    function _override(flatKey, base) {
        var side = dark ? "dark" : "light";
        // 后加的 preset 赢：Pixel 自带 Square，之后显式加的 corner style 要能改回圆角。
        var sets = [Pr.ArcPresets[stylePreset], Pr.ArcPresets[cornerPreset]];
        var txt;
        for (var i = 0; i < sets.length; i++) {
            var s = sets[i];
            if (s && s[side] && s[side][flatKey] !== undefined) txt = s[side][flatKey];
        }
        if (txt === undefined) return base;
        return _coerce(txt, base);
    }
    // 基线里值恒为字符串；按基值形态还原成 QML 需要的类型（ArcTokenValueParser 的等价物）
    function _coerce(txt, base) {
        if (Array.isArray(base)) {
            var p = String(txt).split(",");
            var a = [];
            for (var i = 0; i < p.length; i++) a.push(parseFloat(p[i]) || 0);
            if (a.length === 1) return [a[0], a[0], a[0], a[0]];
            while (a.length < 4) a.push(a[a.length - 1]);
            return a;
        }
        if (typeof base === "number") {
            if (txt === "Normal") return 400;   // Pixel: WeightMedium = Normal
            var n = parseFloat(txt);
            return isNaN(n) ? base : n;
        }
        var s = String(txt);
        // ArcTokenValueParser.TryParseColor 兼容 #RRGGBB / #AARRGGBB；统一补成 8 位，
        // 否则 fade() 会把 6 位当成 "AARRGGBB" 砍掉两位通道。
        if (s.charAt(0) === "#" && s.length === 7) return "#FF" + s.substring(1);
        if (s.charAt(0) === "#" && s.length === 4)
            return "#FF" + s.charAt(1)+s.charAt(1)+s.charAt(2)+s.charAt(2)+s.charAt(3)+s.charAt(3);
        return txt;   // 字符串令牌
    }

    // ── 动效引擎（源：Core/Motion/Springs.cs · ArcMotionLevel.cs · ApplyMotion）──
    function dur(name) { return Mo.ArcMotion.duration(Mo.ArcMotion.Dur[name] || 120, motionLevel); }
    function stagger(name) { return Mo.ArcMotion.Stagger[name] || 0; }
    function ease(name) { return Mo.ArcMotion.bezier(name); }
    function spring(name) { return Mo.ArcMotion.presets[name] || Mo.ArcMotion.presets.Smooth; }
    function springSettle(name) { return Mo.ArcMotion.springSettleMs(spring(name)); }
    function springEase(name, p) { return Mo.ArcMotion.springEasing(spring(name), p); }
    function pulseHalf() { return Mo.ArcMotion.pulseHalfMs(); }
    function busyOpacity(sec) { return Mo.ArcMotion.busyOpacity(sec); }
    function presencePose(mode, p, scale, offset) { return Mo.ArcMotion.presenceApply(p, mode, scale, offset); }
    function popupEnter(origin, offset, scale, fadeOnly, ms) { return Mo.ArcMotion.popupEnter(origin, offset, scale, fadeOnly, ms); }
    function popupExit(origin, scale, fadeOnly, ms) { return Mo.ArcMotion.popupExit(origin, scale, fadeOnly, ms); }
    function rubberClamp(v, min, max, dim) { return Mo.ArcMotion.rubberClamp(v, min, max, dim); }
    function contentSwapOffset(mode, dir, dist) { return Mo.ArcMotion.contentSwapOffset(mode, dir, dist); }
    function rollingShortest(from, to) { return Mo.ArcMotion.rollingShortest(from, to); }
    function springAnim(name) { return Mo.ArcMotion.springAnim(spring(name)); }
    function motion() { return Mo.ArcMotion; }

    // ── Oklch 颜色数学（源：Core/Theme/Oklch.cs）──
    function oklch() { return Ok.ArcOklch; }
    function mixOklab(a, b, t) { return Ok.ArcOklch.mixOklab(a, b, t); }
    function contrast(a, b) { return Ok.ArcOklch.contrast(a, b); }

    // 颜色套不透明度：把 "#AARRGGBB" 乘上 alpha
    function fade(hex, alpha) {
        // hex 可能是 JS string，也可能是 QML color 对象（property color 传给函数时）；
        // 统一转字符串再取字符，避免 "Property 'charAt' of object #cd1526 is not a function"。
        if (hex === null || hex === undefined) return hex;
        var s = String(hex);
        if (!s || s.charAt(0) !== "#") return hex;
        var h = s.substring(1);
        if (h.length === 8) h = h.substring(2);
        var a = Math.round(Math.max(0, Math.min(1, alpha)) * 255);
        var ah = a.toString(16).toUpperCase();
        if (ah.length < 2) ah = "0" + ah;
        return "#" + ah + h;
    }

    // 字体族（Arc 用系统 UI 字体，此处沿用属性默认，仅提供字重常量）
    readonly property int weightRegular: 400
    readonly property int weightMedium: 500
    readonly property int weightSemibold: 600
}
