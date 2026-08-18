//
//  Shapes.swift
//  exp 3
//
//  Custom Shape types and the small data displays built from them. Carried
//  over from Experiment 1 so both applications share one visual language.
//

import SwiftUI

// MARK: - Guilloché

/// Interfering sine waves, the security-print pattern used on the inverted
/// plates so a solid black panel still has texture in it.
struct WaveLines: Shape {
    var lines: Int = 16
    var amplitude: CGFloat = 9
    var cycles: CGFloat = 3.2
    var phase: CGFloat = 0

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard rect.width > 0, lines > 0 else { return path }

        for line in 0..<lines {
            let baseY = rect.height * CGFloat(line + 1) / CGFloat(lines + 1)
            let drift = CGFloat(line) * 0.55
            path.move(to: CGPoint(x: rect.minX, y: baseY))

            var x: CGFloat = 0
            while x <= rect.width {
                let t = x / rect.width
                let y = baseY
                    + sin(t * .pi * 2 * cycles + phase + drift) * amplitude
                    + sin(t * .pi * 2 * (cycles * 1.7) - phase * 0.6) * (amplitude * 0.35)
                path.addLine(to: CGPoint(x: rect.minX + x, y: y))
                x += 2.5
            }
        }
        return path
    }
}

// MARK: - Arc

/// A stroked arc that sweeps as its progress animates.
struct ArcShape: Shape {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(-90 + 360 * max(0, min(1, progress))),
            clockwise: false
        )
        return path
    }
}

/// Arc dial with the percentage set in the middle.
struct DialView: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var caption: String?

    @State private var shown: Double = 0

    var body: some View {
        ZStack {
            ArcShape(progress: 1)
                .stroke(Ink.line, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
            ArcShape(progress: shown)
                .stroke(Ink.ink, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
            VStack(spacing: -2) {
                Text("\(Int((progress * 100).rounded()))")
                    .font(Typo.display(26))
                    .foregroundStyle(Ink.ink)
                    .monospacedDigit()
                Text(caption ?? "%").microLabel(size: 8)
            }
        }
        .padding(lineWidth / 2)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.15)) { shown = progress }
        }
    }
}

// MARK: - Tick meter

/// A row of ticks that fills like a studio EQ. The leading tick is taller and
/// lime, so the eye lands on the current value.
struct TickMeter: View {
    let value: Double            // 0...1
    var ticks: Int = 26
    var tickWidth: CGFloat = 3
    var delay: Double = 0

    @State private var filled: Double = 0

    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(0..<ticks, id: \.self) { index in
                let position = Double(index) / Double(max(ticks - 1, 1))
                let isOn = position <= filled
                let isHead = isOn && position + (1.0 / Double(max(ticks - 1, 1))) > filled

                Capsule()
                    .fill(isHead ? Ink.lime : (isOn ? Ink.ink : Ink.line))
                    .frame(width: tickWidth, height: isHead ? 20 : (isOn ? 13 : 7))
            }
        }
        .frame(height: 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.85).delay(delay)) { filled = value }
        }
    }
}

// MARK: - Slot grid

/// A grid of squares used for weekly occupancy. Filled squares are lime,
/// free squares are knocked out. Reveals with a staggered spring.
struct SlotGrid: View {
    let slots: [Bool]
    var columns: Int = 8
    var spacing: CGFloat = 5

    @State private var revealed = false

    var body: some View {
        let grid = Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)

        LazyVGrid(columns: grid, spacing: spacing) {
            ForEach(slots.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(slots[index] ? Ink.lime : Ink.ink.opacity(0.10))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        if !slots[index] {
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .strokeBorder(Ink.ink.opacity(0.16), lineWidth: 1)
                        }
                    }
                    .scaleEffect(revealed ? 1 : 0.1)
                    .opacity(revealed ? 1 : 0)
                    .animation(
                        .spring(response: 0.42, dampingFraction: 0.7)
                        .delay(Double(index) * 0.012),
                        value: revealed
                    )
            }
        }
        .onAppear { revealed = true }
    }
}

// MARK: - Progress rule

/// A 2pt rule that fills to a fraction, used on list rows.
struct ProgressLine: View {
    let value: Double
    var height: CGFloat = 2

    @State private var fill: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle().fill(Ink.line)
                Rectangle().fill(Ink.ink).frame(width: proxy.size.width * fill)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.1)) { fill = CGFloat(value) }
        }
    }
}
