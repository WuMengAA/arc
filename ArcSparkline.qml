// arc:MetricCard 内的迷你折线（96x36），趋势色取 Success / Danger。
import QtQuick 2.15

Canvas {
    id: root

    property var th: null
    property var values: []
    property bool up: true

    width: th ? th.n("metricCard","SparklineWidth") : 96
    height: th ? th.n("metricCard","SparklineHeight") : 36
    antialiasing: true

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        if (!values || values.length < 2) return;
        var lo = Math.min.apply(null, values), hi = Math.max.apply(null, values);
        var span = (hi - lo) || 1;
        var pad = 3;
        var w = width, h = height - pad * 2;
        ctx.beginPath();
        for (var i = 0; i < values.length; i++) {
            var x = (w * i) / (values.length - 1);
            var y = pad + h - ((values[i] - lo) / span) * h;
            if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
        }
        ctx.strokeStyle = root.th.c(root.up ? "Success" : "Danger");
        ctx.lineWidth = 1.6;
        ctx.lineJoin = "round";
        ctx.lineCap = "round";
        ctx.stroke();
    }

    onValuesChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    Connections {
        target: root.th
        function onDarkChanged() { root.requestPaint() }
    }
}
