
.pragma library
// TKCode.Arc 颜色数学精确移植（源：TKCode.Arc.Core/Theme/Oklch.cs，CSS Color 4 gamut mapping）。
// 颜色统一用 "#RRGGBB" / "#AARRGGBB" 字符串；内部拆成 {a,r,g,b}（0..255）。

var ArcOklch = (function () {
    function clamp01(x) { return x < 0 ? 0 : (x > 1 ? 1 : x); }
    function square(x) { return x * x; }
    function toByte(unit) { return Math.round(clamp01(unit) * 255); }
    function cbrt(x) { return x < 0 ? -Math.pow(-x, 1 / 3) : Math.pow(x, 1 / 3); }
    function decode(x) { return x <= 0.04045 ? x / 12.92 : Math.pow((x + 0.055) / 1.055, 2.4); }
    function encode(x) { x = clamp01(x); return x <= 0.0031308 ? 12.92 * x : 1.055 * Math.pow(x, 1 / 2.4) - 0.055; }
    function hex2(v) { var h = Math.round(clamp01(v / 255) * 255).toString(16).toUpperCase(); return h.length < 2 ? "0" + h : h; }

    function parse(hex) {
        var s = String(hex).replace("#", "");
        if (s.length === 6) return { a: 255, r: parseInt(s.substring(0,2),16), g: parseInt(s.substring(2,4),16), b: parseInt(s.substring(4,6),16) };
        if (s.length === 8) return { a: parseInt(s.substring(0,2),16), r: parseInt(s.substring(2,4),16), g: parseInt(s.substring(4,6),16), b: parseInt(s.substring(6,8),16) };
        return { a: 255, r: 0, g: 0, b: 0 };
    }
    function rgba(c) { return "#" + hex2(c.a) + hex2(c.r) + hex2(c.g) + hex2(c.b); }
    function rgb(c) { return "#" + hex2(c.r) + hex2(c.g) + hex2(c.b); }
    function fromArgb(a, r, g, b) { return { a: toByte(a), r: toByte(r), g: toByte(g), b: toByte(b) }; }

    // OklabToLinearSrgb(l,a,b) → [R,G,B] linear
    function oklabToLinearSrgb(l, a, b) {
        var l_ = l + 0.3963377774 * a + 0.2158037573 * b;
        var m_ = l - 0.1055613458 * a - 0.0638541728 * b;
        var s_ = l - 0.0894841775 * a - 1.2914855480 * b;
        var ll = l_ * l_ * l_, mm = m_ * m_ * m_, ss = s_ * s_ * s_;
        return [4.0767416621 * ll - 3.3077115913 * mm + 0.2309699292 * ss,
                -1.2684380046 * ll + 2.6097574011 * mm - 0.3413193965 * ss,
                -0.0041960863 * ll - 0.7034186147 * mm + 1.7076147010 * ss];
    }
    // LinearSrgbToOklab(r,g,b) → [L,A,B]
    function linearSrgbToOklab(r, g, b) {
        var l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
        var m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
        var s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
        return [0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
                1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
                0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s];
    }
    function oklchToOklab(l, c, h) { var hr = h * Math.PI / 180.0; return [l, c * Math.cos(hr), c * Math.sin(hr)]; }
    function oklchToLinear(l, c, h) { var p = oklchToOklab(l, c, h); return oklabToLinearSrgb(p[0], p[1], p[2]); }
    function inGamut(v) { var e = 1e-6; return v[0] >= -e && v[0] <= 1+e && v[1] >= -e && v[1] <= 1+e && v[2] >= -e && v[2] <= 1+e; }

    // CSS Color 4 gamut mapping：二分降 chroma 直到入色域，JND=0.02 / eps=0.0001
    function gamutMap(l, c, h) {
        if (l >= 1) return [1, 1, 1];
        if (l <= 0) return [0, 0, 0];
        var rgbv = oklchToLinear(l, c, h);
        if (inGamut(rgbv)) return rgbv;
        var jnd = 0.02, eps = 0.0001, lo = 0, hi = c, minInGamut = true, clipped = null;
        while (hi - lo > eps) {
            var mid = (lo + hi) / 2;
            var cur = oklchToLinear(l, mid, h);
            if (minInGamut && inGamut(cur)) { lo = mid; continue; }
            var clip = [clamp01(cur[0]), clamp01(cur[1]), clamp01(cur[2])];
            clipped = clip;
            var target = oklchToOklab(l, mid, h);
            var actual = linearSrgbToOklab(clip[0], clip[1], clip[2]);
            var e = Math.sqrt(square(target[0]-actual[0]) + square(target[1]-actual[1]) + square(target[2]-actual[2]));
            if (e < jnd) {
                if (jnd - e < eps) return clip;
                minInGamut = false; lo = mid;
            } else hi = mid;
        }
        return clipped || [clamp01(rgbv[0]), clamp01(rgbv[1]), clamp01(rgbv[2])];
    }

    // FromColor(Color) → {L,C,H}
    function fromColor(hex) {
        var c = parse(hex);
        var lab = linearSrgbToOklab(decode(c.r / 255), decode(c.g / 255), decode(c.b / 255));
        var ch = Math.sqrt(square(lab[1]) + square(lab[2]));
        var h = Math.atan2(lab[2], lab[1]) * 180.0 / Math.PI;
        if (h < 0) h += 360;
        return { L: lab[0], C: ch, H: h };
    }
    // ToColor(l,c,h,alpha=1) → "#AARRGGBB"
    function toColor(l, c, h, alpha) {
        alpha = alpha === undefined ? 1.0 : alpha;
        var v = gamutMap(l, c, h);
        return rgba(fromArgb(alpha, encode(v[0]), encode(v[1]), encode(v[2])));
    }
    function toRgb(l, c, h) {
        var v = gamutMap(l, c, h);
        return rgb(fromArgb(1, encode(v[0]), encode(v[1]), encode(v[2])));
    }
    // WithAlpha(Color, alpha)
    function withAlpha(hex, alpha) {
        var c = parse(hex);
        return rgba(fromArgb(alpha, c.r / 255, c.g / 255, c.b / 255));
    }
    function relativeLuminance(hex) {
        var c = parse(hex);
        return 0.2126 * decode(c.r/255) + 0.7152 * decode(c.g/255) + 0.0722 * decode(c.b/255);
    }
    // Contrast(Color a, Color b)：WCAG2
    function contrast(hexA, hexB) {
        var la = relativeLuminance(hexA), lb = relativeLuminance(hexB);
        var hi = Math.max(la, lb), lo = Math.min(la, lb);
        return (hi + 0.05) / (lo + 0.05);
    }
    // MixOklab(a,b,t)
    function mixOklab(hexA, hexB, t) {
        var a = parse(hexA), b = parse(hexB);
        var l1 = linearSrgbToOklab(decode(a.r/255), decode(a.g/255), decode(a.b/255));
        var l2 = linearSrgbToOklab(decode(b.r/255), decode(b.g/255), decode(b.b/255));
        var v = oklabToLinearSrgb(l1[0]+(l2[0]-l1[0])*t, l1[1]+(l2[1]-l1[1])*t, l1[2]+(l2[2]-l1[2])*t);
        var alpha = a.a/255 + (b.a/255 - a.a/255) * t;
        return rgba(fromArgb(alpha, encode(clamp01(v[0])), encode(clamp01(v[1])), encode(clamp01(v[2]))));
    }

    return {
        fromColor: fromColor, toColor: toColor, toRgb: toRgb, withAlpha: withAlpha,
        relativeLuminance: relativeLuminance, contrast: contrast, mixOklab: mixOklab,
        parse: parse, rgba: rgba, rgb: rgb
    };
})();
