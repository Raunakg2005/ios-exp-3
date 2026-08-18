//
//  SettingsView.swift
//  exp 3
//
//  Every control on this screen writes to library.preferences. The root view
//  reads that same struct and applies .preferredColorScheme and
//  .dynamicTypeSize, so tapping "Dark" here re-renders the whole application
//  immediately. That is the reactive data flow the experiment asks for.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var library: LibraryModel

    /// System values worth surfacing to the reader.
    @Environment(\.colorScheme) private var systemScheme
    @Environment(\.dynamicTypeSize) private var systemType

    @State private var showResetConfirm = false
    @State private var showResetAllConfirm = false

    private var preferences: Binding<Preferences> {
        Binding(get: { library.preferences }, set: { library.preferences = $0 })
    }

    var body: some View {
        NavigationStack {
            LibraryPage {
                TabHeader(
                    index: "05",
                    title: "Settings",
                    caption: "Preferences apply across every screen"
                )

                appearanceBlock.padding(.top, 22)
                typeBlock.padding(.top, 22)
                readingBlock.padding(.top, 22)
                displayBlock.padding(.top, 22)
                environmentBlock.padding(.top, 22)
                dangerBlock.padding(.top, 22)
                aboutBlock.padding(.top, 26)
            }
        }
        .confirmationDialog("Reset all reading progress?",
                            isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("Clear favourites, list and completed", role: .destructive) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    library.resetLibrary()
                }
            }
        }
        .confirmationDialog("Restore defaults for every setting?",
                            isPresented: $showResetAllConfirm, titleVisibility: .visible) {
            Button("Restore defaults", role: .destructive) {
                withAnimation(.easeOut(duration: 0.25)) {
                    library.preferences = Preferences()
                }
            }
        }
    }

    // MARK: Blocks

    private var appearanceBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(index: "A", title: "Appearance")
            VStack(alignment: .leading, spacing: 10) {
                Picker("Appearance", selection: preferences.appearance) {
                    ForEach(Preferences.Appearance.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                Text("Choose \u{201C}System\u{201D} to follow the phone, "
                    + "or force light or dark for the whole application.")
                    .font(Typo.body(12))
                    .foregroundStyle(Ink.mute)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .block(padding: 16)
        }
    }

    private var typeBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(index: "T", title: "Text size")
            VStack(alignment: .leading, spacing: 10) {
                Picker("Text size", selection: preferences.textScale) {
                    ForEach(Preferences.TextScale.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                Text("Applied through .dynamicTypeSize on the root view, "
                    + "so it changes every screen at once.")
                    .font(Typo.body(12))
                    .foregroundStyle(Ink.mute)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .block(padding: 16)
        }
    }

    private var readingBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(index: "R", title: "Reading")

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Monthly goal").microLabel(Ink.ink)
                        Text("Books to finish each month")
                            .font(Typo.body(11))
                            .foregroundStyle(Ink.mute)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Stepper(value: preferences.monthlyGoal, in: 1...20) {
                            EmptyView()
                        }
                        .labelsHidden()
                        Text("\(library.preferences.monthlyGoal)")
                            .font(Typo.display(22))
                            .foregroundStyle(Ink.ink)
                            .monospacedDigit()
                            .frame(minWidth: 32, alignment: .trailing)
                    }
                }

                Rule()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Favourite genre").microLabel(Ink.ink)
                        Spacer()
                    }
                    Picker("Favourite genre", selection: preferences.favouriteGenre) {
                        Text("None").tag(Optional<Genre>.none)
                        ForEach(Genre.allCases) { option in
                            Text(option.rawValue).tag(Optional(option))
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Ink.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(Ink.line, lineWidth: 1)
                    }
                    Text("The dashboard recommends more of this genre.")
                        .font(Typo.body(11))
                        .foregroundStyle(Ink.mute)
                }
            }
            .block(padding: 16)
        }
    }

    private var displayBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(index: "D", title: "Display")
            VStack(spacing: 12) {
                Toggle(isOn: preferences.showCovers) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Show book covers").microLabel(Ink.ink)
                        Text("Turn off to see only shelf marks and codes")
                            .font(Typo.body(11))
                            .foregroundStyle(Ink.mute)
                    }
                }
                .tint(Ink.lime)
            }
            .block(padding: 16)
        }
    }

    /// Read-only mirror of a few values coming out of @Environment.
    private var environmentBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(index: "E", title: "System values")
            VStack(spacing: 10) {
                DataRow(key: "Colour scheme",
                        value: systemScheme == .dark ? "Dark" : "Light", mono: false)
                Rule()
                DataRow(key: "Dynamic Type",
                        value: describe(systemType), mono: false)
                Rule()
                DataRow(key: "Locale",
                        value: Locale.current.identifier, mono: true)
            }
            .block(padding: 16)

            Text("These values are read straight from @Environment. They reflect "
                + "the phone's own settings and change without a restart.")
                .font(Typo.body(11))
                .foregroundStyle(Ink.mute)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var dangerBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(index: "X", title: "Reset")
            VStack(spacing: 10) {
                Button {
                    showResetAllConfirm = true
                } label: {
                    resetRow(title: "Restore default preferences",
                             subtitle: "Appearance, text size, goal and display")
                }
                .buttonStyle(PressStyle())

                Rule()

                Button {
                    showResetConfirm = true
                } label: {
                    resetRow(title: "Clear reading history",
                             subtitle: "Favourites, reading list and completed books",
                             warning: true)
                }
                .buttonStyle(PressStyle())
            }
            .block(padding: 16)
        }
    }

    private func resetRow(title: String, subtitle: String, warning: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: warning ? "trash" : "arrow.uturn.backward")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(warning ? Ink.signal : Ink.ink)
                .frame(width: 30, height: 30)
                .background {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(Ink.line, lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Typo.condensed(14, .bold))
                    .foregroundStyle(Ink.ink)
                Text(subtitle)
                    .font(Typo.body(11))
                    .foregroundStyle(Ink.mute)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Ink.mute)
        }
        .contentShape(Rectangle())
    }

    private var aboutBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rule()
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Book Library").microLabel(Ink.ink, size: 9)
                    Text("Experiment 03 · Property wrappers and data flow")
                        .font(Typo.mono(9))
                        .foregroundStyle(Ink.mute)
                }
                Spacer()
                Text("v1.0")
                    .font(Typo.mono(10, .bold))
                    .foregroundStyle(Ink.line)
            }
        }
    }

    private func describe(_ size: DynamicTypeSize) -> String {
        switch size {
        case .xSmall:       return "Extra small"
        case .small:        return "Small"
        case .medium:       return "Medium"
        case .large:        return "Large (default)"
        case .xLarge:       return "Extra large"
        case .xxLarge:      return "XXL"
        case .xxxLarge:     return "XXXL"
        case .accessibility1: return "Accessibility 1"
        case .accessibility2: return "Accessibility 2"
        case .accessibility3: return "Accessibility 3"
        case .accessibility4: return "Accessibility 4"
        case .accessibility5: return "Accessibility 5"
        @unknown default:   return "Unknown"
        }
    }
}

#Preview {
    SettingsView().environmentObject(LibraryModel())
}
