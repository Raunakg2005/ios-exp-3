//
//  Typography.swift
//  exp 3
//
//  Three voices only:
//    • Display — compressed black. Names, grades, big numbers.
//    • Micro   — 10pt letterspaced uppercase. Every label in the app.
//    • Mono    — codes, roll numbers, anything that should read as data.
//
//  ⚠️ Do not reach for narrow system faces here. Two routes to a compressed
//  SF Pro were tried and both rendered nothing on device:
//
//    • `Font.system(...).width(.compressed)` — no glyphs drawn.
//    • `UIFont(descriptor:size:)` with a width trait added to the *system*
//      font's descriptor — the system descriptor points at Apple's private
//      .SFUI faces, so the result lays out but draws nothing.
//
//  Everything below is plain `Font.system`, which always renders. The
//  editorial feel comes from weight and negative tracking instead of width.
//  If you want true compressed type, bundle a real font file (Archivo,
//  Oswald, Anton) and load it by PostScript name.
//

import SwiftUI

enum Typo {

    /// Editorial headline. Set it big or don't set it at all.
    static func display(_ size: CGFloat, _ weight: Font.Weight = .black) -> Font {
        .system(size: size, weight: weight)
    }

    /// Subhead weight — for titles that need to hold their own.
    static func condensed(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight)
    }

    /// Data type: course codes, roll numbers, percentages.
    static func mono(_ size: CGFloat, _ weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    static func body(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
}

// MARK: - View modifiers

/// The letterspaced uppercase caption used for every label on every screen.
struct MicroLabel: ViewModifier {
    var color: Color = Ink.mute
    var size: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .bold))
            .tracking(1.5)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }
}

/// Tightens the tracking on large display type, the way a print designer would.
struct DisplayType: ViewModifier {
    var size: CGFloat
    var weight: Font.Weight = .black

    func body(content: Content) -> some View {
        content
            .font(Typo.display(size, weight))
            .tracking(size * -0.030)
            .foregroundStyle(Ink.ink)
    }
}

extension View {
    func microLabel(_ color: Color = Ink.mute, size: CGFloat = 10) -> some View {
        modifier(MicroLabel(color: color, size: size))
    }

    func displayType(_ size: CGFloat, weight: Font.Weight = .black) -> some View {
        modifier(DisplayType(size: size, weight: weight))
    }
}
