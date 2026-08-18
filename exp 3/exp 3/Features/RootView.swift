//
//  RootView.swift
//  exp 3
//
//  Five tabs, each with its own NavigationStack.
//
//  This is also where the reader's preferences take effect for the whole
//  application: the appearance and text-scale settings chosen on the Settings
//  screen are applied here with .preferredColorScheme and .dynamicTypeSize,
//  so changing either one re-renders every screen at once. That is the
//  clearest demonstration of the shared-model idea the experiment asks for.
//

import SwiftUI

enum AppTab: String, CaseIterable, Hashable {
    case home, catalogue, library, profile, settings
}

struct RootView: View {

    /// Read, not owned. The instance was created by exp_3App.
    @EnvironmentObject private var library: LibraryModel

    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "square.grid.2x2", value: AppTab.home) {
                HomeView(selection: $selection)
            }

            Tab("Catalogue", systemImage: "books.vertical", value: AppTab.catalogue) {
                BookListView()
            }

            Tab("Library", systemImage: "bookmark", value: AppTab.library) {
                MyLibraryView()
            }

            Tab("Profile", systemImage: "person.crop.square", value: AppTab.profile) {
                ProfileView()
            }

            Tab("Settings", systemImage: "slider.horizontal.3", value: AppTab.settings) {
                SettingsView()
            }
        }
        .tint(Ink.ink)
        .preferredColorScheme(library.preferences.appearance.colorScheme)
        .dynamicTypeSize(library.preferences.textScale.dynamicTypeSize)
        .sensoryFeedback(.selection, trigger: selection)
    }
}

// MARK: - Shared page chrome

/// Every tab is the same shape: a paper page, no navigation bar, content
/// clamped to the container width so an oversized child can never stretch
/// the scroll view and push its siblings off-screen.
struct LibraryPage<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .containerRelativeFrame(.horizontal)
        }
        .background(Ink.paper.ignoresSafeArea())
        .scrollIndicators(.hidden)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    RootView()
        .environmentObject(LibraryModel())
}
