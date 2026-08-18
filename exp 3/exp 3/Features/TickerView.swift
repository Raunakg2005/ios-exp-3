//
//  TickerView.swift
//  exp 3
//
//  A departure-board marquee of this semester's course codes. Two copies of
//  the strip slide left forever, so the seam never shows.
//
//  ⚠️ The marquee must live in an `.overlay` on a flexible `Color.clear`,
//  never directly in the layout. The strip is ~2,800pt wide; placed inline
//  that intrinsic width propagates all the way up and stretches the whole
//  scroll view to ten screens across, centring every sibling off-screen.
//  An overlay never contributes to its host's size, so the row stays exactly
//  as wide as the screen no matter how long the strip gets.
//

import SwiftUI

struct TickerView: View {
    let items: [String]
    var speed: Double = 34          // points per second

    @State private var stripWidth: CGFloat = 0
    @State private var running = false

    private let gap: CGFloat = 28
    private let rowHeight: CGFloat = 14

    var body: some View {
        VStack(spacing: 0) {
            Rule()

            Color.clear
                .frame(height: rowHeight)
                .overlay(alignment: .leading) { marquee }
                .clipped()
                .padding(.vertical, 9)

            Rule()
        }
        .allowsHitTesting(false)
    }

    // MARK: - Marquee

    private var marquee: some View {
        HStack(spacing: gap) {
            strip
            strip
        }
        .fixedSize()
        .background {
            GeometryReader { proxy in
                Color.clear.onAppear {
                    // One full period = half the doubled content, plus one gap.
                    let period = (proxy.size.width + gap) / 2
                    guard period > 0, stripWidth == 0 else { return }
                    stripWidth = period
                    withAnimation(.linear(duration: period / speed).repeatForever(autoreverses: false)) {
                        running = true
                    }
                }
            }
        }
        .offset(x: running ? -stripWidth : 0)
    }

    private var strip: some View {
        HStack(spacing: gap) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(spacing: gap) {
                    Text(item)
                        .font(Typo.mono(10, .semibold))
                        .tracking(1.1)
                        .foregroundStyle(Ink.mute)
                    Rectangle()
                        .fill(Ink.lime)
                        .frame(width: 4, height: 4)
                }
            }
        }
        .fixedSize()
    }
}
