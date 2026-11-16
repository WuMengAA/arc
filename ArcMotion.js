
.pragma library
// TKCode.Arc 动效引擎精确移植（源：TKCode.Arc.Core/Motion/Springs.cs, SpringTransitions.cs,
// TKCode.Arc.Foundation/Motion/ArcMotionLevel.cs, TKCode.Arc.Core/Theme/ArcDesignToken.cs::ApplyMotion）。
// ES5 写法以兼容 Qt 6.12 QJSEngine；Math.cbrt/cosh/sinh/clamp 手写，避免引擎差异。

var ArcMotion = (function () {
    function clamp(x, lo, hi) { return x < lo ? lo : (x > hi ? hi : x); }
    function sinh(x) { return (Math.exp(x) - Math.exp(-x)) / 2; }
    function cosh(x) { return (Math.exp(x) + Math.exp(-x)) / 2; }

    // SpringSpec(double Stiffness, double Damping, double Mass = 1.0)
    function SpringSpec(stiffness, damping, mass) {
        this.Stiffness = stiffness; this.Damping = damping;
        this.Mass = (mass === undefined) ? 1.0 : mass;
    }
    // FromVisual: root = 2π/(1.2·visualDuration); k = root²; ζ = clamp(1−bounce,0.05,1); c = 2ζ√k
    SpringSpec.FromVisual = function (visualDuration, bounce) {
        if (visualDuration <= 0) throw new Error("visualDuration must be positive");
        var root = 2 * Math.PI / (1.2 * visualDuration);
        var k = root * root;
        var zeta = clamp(1 - bounce, 0.05, 1);
        return new SpringSpec(k, 2 * zeta * Math.sqrt(k));
    };
    SpringSpec.FromPhysical = function (stiffness, damping, mass) {
        if (stiffness <= 0 || damping <= 0 || (mass !== undefined && mass <= 0))
            throw new Error("Spring parameters must be positive.");
        return new SpringSpec(stiffness, damping, mass === undefined ? 1.0 : mass);
    };
    SpringSpec.prototype.NaturalFrequency = function () { return Math.sqrt(this.Stiffness / this.Mass); };
    SpringSpec.prototype.DampingRatio = function () { return this.Damping / (2 * Math.sqrt(this.Stiffness * this.Mass)); };
    // SpringSolver.Evaluate(in SpringSpec spec, double x0, double v0, double t) → [x, v]
    var SpringSolver = {
        Evaluate: function (spec, x0, v0, t) {
            var w0 = spec.NaturalFrequency();
            var zeta = spec.DampingRatio();
            if (Math.abs(zeta - 1) < 1e-6) {
                var e = Math.exp(-w0 * t), b = v0 + w0 * x0;
                return [e * (x0 + b * t), e * (b - w0 * (x0 + b * t))];
            }
            if (zeta < 1) {
                var wd = w0 * Math.sqrt(1 - zeta * zeta);
                var eu = Math.exp(-zeta * w0 * t);
                var bu = (v0 + zeta * w0 * x0) / wd;
                var co = Math.cos(wd * t), si = Math.sin(wd * t);
                return [eu * (x0 * co + bu * si),
                        eu * ((bu * wd - zeta * w0 * x0) * co - (x0 * wd + zeta * w0 * bu) * si)];
            }
            var wh = w0 * Math.sqrt(zeta * zeta - 1);
            var eo = Math.exp(-zeta * w0 * t);
            var bo = (v0 + zeta * w0 * x0) / wh;
            var ch = cosh(wh * t), sh = sinh(wh * t);
            return [eo * (x0 * ch + bo * sh),
                    eo * ((bo * wh - zeta * w0 * x0) * ch + (x0 * wh - zeta * w0 * bo) * sh)];
        }
    };

    // EstimateSettle(restDelta=0.005, restSpeed=0.01)：采样闭式解直到稳定 0.25s
    SpringSpec.prototype.EstimateSettle = function (restDelta, restSpeed) {
        restDelta = restDelta === undefined ? 0.005 : restDelta;
        restSpeed = restSpeed === undefined ? 0.01 : restSpeed;
        var dt = 1.0 / 240.0, t = 0, lastOutside = 0;
        while (t < 10) {
            var ev = SpringSolver.Evaluate(this, -1, 0, t);
            if (Math.abs(ev[0]) > restDelta || Math.abs(ev[1]) > restSpeed) lastOutside = t;
            else if (t - lastOutside > 0.25) break;
            t += dt;
        }
        return Math.max(lastOutside, dt);
    };

    // ArcSpring 枚举
    var ArcSpring = { Smooth: 0, Snappy: 1, Morph: 2, Responsive: 3, Gentle: 4, Quick: 5, Settle: 6 };

    // ArcMotionPresets（单位：时长 ms / 弹簧秒）
    var presets = {
        Smooth: SpringSpec.FromVisual(0.4, 0),
        Snappy: SpringSpec.FromVisual(0.26, 0.12),
        Morph: SpringSpec.FromVisual(0.42, 0.16),
        Responsive: SpringSpec.FromPhysical(520, 38),
        Gentle: SpringSpec.FromPhysical(340, 34),
        Quick: SpringSpec.FromVisual(0.25, 0),
        Settle: SpringSpec.FromVisual(0.33, 0)
    };
    var byEnum = [presets.Smooth, presets.Snappy, presets.Morph, presets.Responsive,
                  presets.Gentle, presets.Quick, presets.Settle];
    function Get(spring) { return byEnum[spring] || presets.Smooth; }

    // Duration / Stagger（ArcDesignToken.ApplyMotion 与 ArcMotionPresets）
    var Dur = { Instant: 120, Fast: 160, Exit: 180, Standard: 240, Considered: 480, CssSpring: 580 };
    var Stagger = { Char: 16, Word: 40, Line: 80, Item: 35 };

    // ArcEasings：cubic-bezier 控制点 → QML easing.bezierCurve 六值 [c1x,c1y,c2x,c2y,1,1]
    var Easings = {
        Enter:    [0.16, 1, 0.3, 1],
        Exit:     [0.7, 0, 0.84, 0],
        Standard: [0.22, 1, 0.36, 1],
        InOut:    [0.65, 0, 0.35, 1]
    };
    // CSS --ease-spring linear() 36 段（ArcEasings.CssSpring）
    var CssSpringStops = [
        0, 0.0258, 0.09, 0.1763, 0.2732, 0.3724, 0.4683, 0.5573, 0.6376, 0.7082, 0.7689, 0.8202, 0.8628, 0.8976,
        0.9256, 0.9476, 0.9648, 0.9778, 0.9875, 0.9945, 0.9994, 1.0026, 1.0047, 1.0058, 1.0062, 1.0062, 1.0059,
        1.0055, 1.0049, 1.0043, 1.0036, 1.0031, 1.0025, 1.002, 1.0016, 1.0013, 1
    ];
    // ArcLinearEasing.Ease(progress)
    function LinearEase(stops, p) {
        if (p <= 0) return stops[0];
        if (p >= 1) return stops[stops.length - 1];
        var scaled = p * (stops.length - 1);
        var i = Math.floor(scaled), frac = scaled - i;
        return stops[i] + (stops[i + 1] - stops[i]) * frac;
    }
    // ArcSpringEasing：把弹簧烘成缓动曲线，时长 = EstimateSettle
    function springEasing(spec, p) {
        if (p <= 0) return 0;
        if (p >= 1) return 1;
        var settle = spec.EstimateSettle();
        var ev = SpringSolver.Evaluate(spec, -1, 0, p * settle);
        return 1 + ev[0];
    }
    function springSettleMs(spec) { return spec.EstimateSettle() * 1000; }

    // TKCode.Arc/Progress/Skeleton/SkeletonBlocks.cs 真常量（脉动只在 opacity 上跑，reduced motion 也保留）
    var Skeleton = { PulsePeriod: 1.8, PulseStagger: 0.09, PulseIterations: 11, PulseLow: 0.52,
                     AvatarDiameter: 44, AvatarGap: 16, FirstLineHeight: 16, LineHeight: 12, LineGap: 12 };
    function pulseHalfMs() { return Skeleton.PulsePeriod * 1000 / 2; }

    // ArcMotionLevel：Off=0 / Reduced=1 / Full=2
    var MotionLevel = { Off: 0, Reduced: 1, Full: 2 };

    // QML 便捷：把 cubic-bezier 控制点补成 Qt 的 easing.bezierCurve 六值
    function bezier(name) {
        var c = Easings[name] || Easings.Standard;
        return [c[0], c[1], c[2], c[3], 1, 1];
    }
    // 动效等级作用于时长：Off→0，Reduced 仅颜色/透明度（此处调用方自行判断），Full→原值
    function duration(ms, level) {
        if (level === MotionLevel.Off) return 0;
        return ms;
    }


    // ===== 第五批：动画系统真源码移植（Core/Motion + Core/Primitives + Core/Gestures） =====
    // Core/Motion/ArcBusyPulse.cs：Period=1.8 / MinOpacity=0.45，正弦呼吸，reduced motion 用它替代位移。
    var BusyPulse = { Period: 1.8, MinOpacity: 0.45 };
    function busyAdvance(phase, seconds) {
        var next = (phase + Math.max(0, seconds)) % BusyPulse.Period;
        return isFinite(next) ? next : 0;
    }
    function busyOpacity(seconds) {
        if (!(seconds > 0) || !isFinite(seconds)) return 1;
        var phase = (seconds % BusyPulse.Period) / BusyPulse.Period;
        var half = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
        return 1 - (1 - BusyPulse.MinOpacity) * (1 - Math.cos(Math.PI * half)) / 2;
    }
    // Core/Gestures/RubberBand.cs：iOS 阻尼曲线 (1 - 1/(x*factor/d + 1))*d，DefaultFactor=0.55。
    var Rubber = { DefaultFactor: 0.55 };
    function _sign(v) { return v < 0 ? -1 : (v > 0 ? 1 : 0); }
    function rubberApply(overflow, dimension, factor) {
        factor = factor || Rubber.DefaultFactor;
        if (dimension <= 0 || factor <= 0 || overflow === 0 || isNaN(overflow)) return 0;
        var x = Math.abs(overflow);
        var stretch = (1 - 1 / (x * factor / dimension + 1)) * dimension;
        return _sign(overflow) * stretch;
    }
    function rubberInvert(stretch, dimension, factor) {
        factor = factor || Rubber.DefaultFactor;
        if (dimension <= 0 || factor <= 0 || stretch === 0 || isNaN(stretch)) return 0;
        var s = Math.min(Math.abs(stretch), dimension * (1 - 1e-6));
        var x = (1 / (1 - s / dimension) - 1) * dimension / factor;
        return _sign(stretch) * x;
    }
    function rubberClamp(value, min, max, dimension, factor) {
        if (value < min) return min + rubberApply(value - min, dimension, factor);
        if (value > max) return max + rubberApply(value - max, dimension, factor);
        return value;
    }
    function rubberSqrt(overflow) { return overflow === 0 ? 0 : _sign(overflow) * Math.sqrt(Math.abs(overflow)); }
    // Core/Primitives/Popups/ArcPopupMotions.cs：enter scale 0.97 / Fast(160) + ArcEasings.Enter；
    // exit scale 0.98 / Instant(120) + ArcEasings.Standard；Origin 默认 (0.5, 0)。
    var PopupMotion = { EnterScale: 0.97, ExitScale: 0.98, EnterDuration: 160, ExitDuration: 120, OriginX: 0.5, OriginY: 0 };
    function popupEnter(origin, offset, scale, fadeOnly, duration) {
        return { origin: origin || [PopupMotion.OriginX, PopupMotion.OriginY],
                 offset: offset || [0, 0], scale: scale || PopupMotion.EnterScale,
                 fadeOnly: !!fadeOnly, fades: true,
                 opacitySpec: { duration: duration || PopupMotion.EnterDuration, easing: "Enter" },
                 transformSpec: { duration: duration || PopupMotion.EnterDuration, easing: "Enter" } };
    }
    function popupExit(origin, scale, fadeOnly, duration) {
        return { origin: origin || [PopupMotion.OriginX, PopupMotion.OriginY],
                 offset: [0, 0], scale: scale || PopupMotion.ExitScale,
                 fadeOnly: !!fadeOnly, fades: true,
                 opacitySpec: { duration: duration || PopupMotion.ExitDuration, easing: "Standard" },
                 transformSpec: { duration: duration || PopupMotion.ExitDuration, easing: "Standard" } };
    }
    // Core/Primitives/PresenceHost.cs：PresenceMode + Apply(p) 的 Lerp(opacity/scale/offset)。
    var PresenceMode = { Fade: 0, Scale: 1, Slide: 2, Pop: 3 };
    function _lerp(a, b, t) { return a + (b - a) * t; }
    function presenceApply(p, mode, enterScale, offset, originY) {
        p = Math.max(0, Math.min(1, p));
        var out = { opacity: p, scale: 1, x: 0, y: 0 };
        if (mode === PresenceMode.Scale || mode === PresenceMode.Pop) out.scale = _lerp(enterScale || 0.92, 1, p);
        if (mode === PresenceMode.Slide || mode === PresenceMode.Pop) out.y = _lerp(offset || 12, 0, p);
        if (mode === PresenceMode.Pop) out.x = _lerp(-(offset || 12) * 0.5, 0, p);
        if (originY) out.originY = originY;
        return out;
    }
    // Core/Primitives/ArcContentSwap.cs：ContentSwapMode + 方向（±1）与 enter/exit 偏移。
    var ContentSwapMode = { Fade: 0, Slide: 1, Scale: 2, Blur: 3, Flip: 4 };
    function contentSwapOffset(mode, direction, distance) {
        var d = (direction || 1) >= 0 ? 1 : -1;
        var dist = distance || 24;
        if (mode === ContentSwapMode.Slide) return { x: d * dist, y: 0, scale: 1 };
        if (mode === ContentSwapMode.Scale) return { x: 0, y: 0, scale: 0.94 };
        if (mode === ContentSwapMode.Flip) return { x: d * dist * 0.5, y: 0, scale: 0.96 };
        return { x: 0, y: 0, scale: 1 };
    }
    // Core/Motion/MotionTimeline.cs：RunValue = _from + (1 - _from) * timer.Progress。
    function timelineRunValue(from, progress) { return from + (1 - from) * Math.max(0, Math.min(1, progress)); }
    // Core/Primitives/RollingDigits.cs：IsShortestTurn —— 数字轮走最短路径。
    function rollingShortest(from, to) {
        var delta = to - from;
        if (delta > 5) delta -= 10;
        if (delta < -5) delta += 10;
        return from + delta;
    }
    // 弹簧 → QtQuick SpringAnimation 的参数映射（Stiffness/Damping/Mass 直接对应 spring/damping/mass）。
    function springAnim(spec) {
        return { spring: spec.Stiffness, damping: spec.Damping, mass: spec.Mass || 1 };
    }
    // Core/Motion/ArcMotion.cs + ArcMotionLevel：给定 level 决定该动画是否允许位移。
    function allowsMovement(level) { return level === MotionLevel.Full; }
    function allowsPulse(level) { return level >= MotionLevel.Reduced; }
    return {
        SpringSpec: SpringSpec, SpringSolver: SpringSolver, ArcSpring: ArcSpring,
        presets: presets, Get: Get, Dur: Dur, Stagger: Stagger, Easings: Easings,
        CssSpringStops: CssSpringStops, LinearEase: LinearEase,
        springEasing: springEasing, springSettleMs: springSettleMs, Skeleton: Skeleton,
        pulseHalfMs: pulseHalfMs, MotionLevel: MotionLevel, bezier: bezier, duration: duration,
        BusyPulse: BusyPulse, busyAdvance: busyAdvance, busyOpacity: busyOpacity,
        Rubber: Rubber, rubberApply: rubberApply, rubberInvert: rubberInvert,
        rubberClamp: rubberClamp, rubberSqrt: rubberSqrt,
        PopupMotion: PopupMotion, popupEnter: popupEnter, popupExit: popupExit,
        PresenceMode: PresenceMode, presenceApply: presenceApply,
        ContentSwapMode: ContentSwapMode, contentSwapOffset: contentSwapOffset,
        timelineRunValue: timelineRunValue, rollingShortest: rollingShortest,
        springAnim: springAnim, allowsMovement: allowsMovement, allowsPulse: allowsPulse
    };
})();
