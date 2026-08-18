//
//  Components.swift
//  exp 3
//
//  The shared furniture: bordered blocks, hairline rules, tags and
//  section headings. No drop shadows anywhere — separation comes from
//  1px rules, the way it does on a printed page.
//

import SwiftUI

// MARK: - Block

/// A bordered panel. `filled` inverts it for the loud moments.
struct BlockModifier: ViewModifier {
    var padding: CGFloat = 16
    var filled: Bool = false
    var corner: CGFloat = 6

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(filled ? Ink.reverse : Ink.surface)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(filled ? .clear : Ink.line, lineWidth: 1)
            }
    }
}

extension View {
    func block(padding: CGFloat = 16, filled: Bool = false, corner: CGFloat = 6) -> some View {
        modifier(BlockModifier(padding: padding, filled: filled, corner: corner))
    }
}

// MARK: - Rule

/// A hairline. `Rule()` horizontally, `Rule(.vertical)` between columns.
struct Rule: View {
    enum Axis { case horizontal, vertical }
    var axis: Axis = .horizontal
    var color: Color = Ink.line

    init(_ axis: Axis = .horizontal, color: Color = Ink.line) {
        self.axis = axis
        self.color = color
    }

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(
                width:  axis == .vertical ? 1 : nil,
                height: axis == .horizontal ? 1 : nil
            )
    }
}

// MARK: - Section heading

/// `01 — OVERVIEW ──────────────`
struct SectionHeading: View {
    let index: String
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Text(index)
                .font(Typo.mono(10, .bold))
                .foregroundStyle(Ink.ink)
                .padding(.horizontal, 5)
                .padding(.vertical, 3)
                .background(Ink.lime)
            Text(title).microLabel(Ink.ink)
            Rule()
        }
    }
}

// MARK: - Tag

/// Small outlined chip. `solid` fills it with ink.
struct Tag: View {
    let text: String
    var solid: Bool = false
    var accent: Bool = false

    var body: some View {
        Text(text)
            .font(Typo.mono(10, .semibold))
            .tracking(0.6)
            .foregroundStyle(accent ? Ink.onLime : (solid ? Ink.paper : Ink.ink))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background {
                if accent {
                    RoundedRectangle(cornerRadius: 3).fill(Ink.lime)
                } else if solid {
                    RoundedRectangle(cornerRadius: 3).fill(Ink.ink)
                } else {
                    RoundedRectangle(cornerRadius: 3).strokeBorder(Ink.line, lineWidth: 1)
                }
            }
    }
}

// MARK: - Tag cloud

/// Wrapping row of tags, built on an adaptive grid.
///
/// Deliberately not a custom `Layout`: a hand-rolled flow layout reports the
/// single-line width when SwiftUI probes it with an unbounded proposal, and
/// that width then stretches every ancestor. An adaptive `LazyVGrid` can only
/// ever be as wide as the space it is given.
struct TagCloud: View {
    let items: [String]
    var minWidth: CGFloat = 104
    var accentFirst: Bool = false

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: minWidth), spacing: 6, alignment: .leading)],
            alignment: .leading,
            spacing: 6
        ) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Tag(text: item, accent: accentFirst && index == 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Stat column

/// One cell of the newspaper-style stats table.
struct StatColumn: View {
    let value: String
    let unit: String?
    let label: String
    var accent: Bool = false

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value)
                    .font(Typo.display(32))
                    .foregroundStyle(accent ? Ink.signal : Ink.ink)
                    .monospacedDigit()
                if let unit {
                    Text(unit)
                        .font(Typo.condensed(15, .bold))
                        .foregroundStyle(Ink.mute)
                }
            }
            Text(label).microLabel(size: 9)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) { appeared = true }
        }
    }
}

// MARK: - Key/value row

struct DataRow: View {
    let key: String
    let value: String
    var mono: Bool = true

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(key).microLabel(size: 9)
            Spacer(minLength: 12)
            Text(value)
                .font(mono ? Typo.mono(12, .medium) : Typo.body(13, .medium))
                .foregroundStyle(Ink.ink)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Button style

/// Presses press. Nothing bounces for no reason.
struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Code plate

/// The square mono plate that carries a department or facility code. Filled
/// with the accent when it marks the reader's own department.
struct CodePlate: View {
    let code: String
    var accent: Bool = false
    var size: CGFloat = 46

    var body: some View {
        Text(code)
            .font(Typo.mono(11, .bold))
            .tracking(0.4)
            .foregroundStyle(accent ? Ink.onLime : Ink.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 5)
            .frame(width: size, height: size)
            .background {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(accent ? Ink.lime : Color.clear)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(accent ? Color.clear : Ink.ink.opacity(0.35), lineWidth: 1)
            }
    }
}

// MARK: - Status pill

/// Open / closed marker for facilities.
struct StatusPill: View {
    let isOpen: Bool

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(isOpen ? Ink.onLime : Ink.paper)
                .frame(width: 5, height: 5)
            Text(isOpen ? "Open now" : "Closed")
                .font(Typo.mono(9, .bold))
        }
        .foregroundStyle(isOpen ? Ink.onLime : Ink.paper)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(isOpen ? Ink.lime : Ink.ink.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
    }
}

// MARK: - Inverted plate

/// The one loud surface per detail screen: black panel, guilloché texture,
/// lime eyebrow and a large title.
struct PlateHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String?
    let symbol: String
    var tags: [String] = []

    var body: some View {
        ZStack(alignment: .topLeading) {
            Ink.reverse

            WaveLines(lines: 18, amplitude: 7, cycles: 2.6)
                .stroke(Ink.lime.opacity(0.18), lineWidth: 0.7)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(eyebrow)
                        .font(Typo.mono(10, .bold))
                        .tracking(1.4)
                        .foregroundStyle(Ink.lime)
                    Spacer()
                    Image(systemName: symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Ink.paper.opacity(0.7))
                }

                Text(title.uppercased())
                    .font(Typo.display(31))
                    .tracking(-0.6)
                    .foregroundStyle(Ink.paper)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 14)

                if let subtitle {
                    Text(subtitle)
                        .font(Typo.body(12))
                        .foregroundStyle(Ink.paper.opacity(0.6))
                        .padding(.top, 8)
                }

                if !tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag.uppercased())
                                .font(Typo.mono(9, .bold))
                                .foregroundStyle(Ink.paper)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 3)
                                        .strokeBorder(Ink.paper.opacity(0.35), lineWidth: 1)
                                }
                        }
                    }
                    .padding(.top, 16)
                }
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: - Numbered list

/// `01  Version control workflows` with hairlines between the rows.
struct NumberedList: View {
    let items: [String]
    var startDelay: Double = 0.1

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 14) {
                    Text(String(format: "%02d", index + 1))
                        .font(Typo.mono(10, .bold))
                        .foregroundStyle(Ink.mute)
                        .padding(.top, 3)
                    Text(item)
                        .font(Typo.body(15))
                        .foregroundStyle(Ink.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 12)
                .opacity(appeared ? 1 : 0)
                .offset(x: appeared ? 0 : -12)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.85)
                    .delay(startDelay + Double(index) * 0.05),
                    value: appeared
                )

                if index < items.count - 1 { Rule() }
            }
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Tab header

/// Numbered plate and a large title, so tabs without a masthead still open
/// on something with weight.
struct TabHeader: View {
    let index: String
    let title: String
    let caption: String

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text(index)
                    .font(Typo.mono(10, .bold))
                    .foregroundStyle(Ink.ink)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 3)
                    .background(Ink.lime)
                Rule()
            }
            .padding(.top, 14)

            Text(title.uppercased())
                .displayType(44)
                .padding(.top, 16)

            Text(caption)
                .font(Typo.condensed(13, .semibold))
                .foregroundStyle(Ink.mute)
                .padding(.top, 2)
        }
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -14)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) { appeared = true }
        }
    }
}

// MARK: - Search field

/// A bordered search field. The navigation bar is hidden on every tab, so
/// SwiftUI's stock `.searchable` has nowhere to draw; this keeps the look of
/// the rest of the page.
struct SearchField: View {
    @Binding var text: String
    let prompt: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Ink.mute)

            TextField(prompt, text: $text)
                .font(Typo.body(14))
                .foregroundStyle(Ink.ink)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    withAnimation(.easeOut(duration: 0.18)) { text = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Ink.mute)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Ink.surface)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(Ink.line, lineWidth: 1)
        }
    }
}

// MARK: - Empty note

/// The muted placeholder shown when a list or search has no results.
struct EmptyNote: View {
    let text: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "questionmark.square.dashed")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(Ink.mute)
            Text(text)
                .font(Typo.body(13))
                .foregroundStyle(Ink.mute)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
