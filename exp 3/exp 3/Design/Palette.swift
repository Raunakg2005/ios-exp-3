//
//  Palette.swift
//  exp 3
//
//  Paper-and-ink palette with a single electric accent.
//  Everything else in the app is monochrome, so the accent always means
//  "this is the number you came here for".
//

import SwiftUI
import UIKit

enum Ink {

    // MARK: Surfaces
    /// The page itself — warm newsprint in light, near-black in dark.
    static let paper   = dynamic(light: 0xF3F1EC, dark: 0x0B0B0C)
    /// Raised blocks sitting on the page.
    static let surface = dynamic(light: 0xFFFFFF, dark: 0x151517)
    /// Inverted block — used for the one or two "loud" moments per screen.
    static let reverse = dynamic(light: 0x121213, dark: 0xF2F0EA)

    // MARK: Type
    static let ink  = dynamic(light: 0x121213, dark: 0xF2F0EA)
    static let mute = ink.opacity(0.45)
    static let line = ink.opacity(0.13)

    // MARK: Accents
    /// Electric lime. Used for exactly one thing at a time.
    static let lime   = dynamic(light: 0xC9F23A, dark: 0xD8FE45)
    /// Reserved for warnings / shortfalls (attendance below the bar).
    static let signal = dynamic(light: 0xE0400E, dark: 0xFF5C22)

    /// Text colour that stays legible on top of `lime`.
    static let onLime = Color(red: 0.07, green: 0.07, blue: 0.08)

    // MARK: - Helper

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension UIColor {
    /// 0xRRGGBB convenience initialiser.
    fileprivate convenience init(rgb: UInt32) {
        self.init(
            red:   CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue:  CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}
