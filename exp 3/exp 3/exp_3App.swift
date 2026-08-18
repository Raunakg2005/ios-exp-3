//
//  exp_3App.swift
//  exp 3
//
//  Experiment 03 - Develop a SwiftUI application: Book Library App.
//  Semester VII, Mobile Application Development
//
//  @StateObject is used here and nowhere else. The App owns exactly one
//  LibraryModel for the lifetime of the process; every screen reads that same
//  instance out of the environment.
//

import SwiftUI

@main
struct exp_3App: App {

    /// Created once. @StateObject, not @ObservedObject: the App owns it.
    @StateObject private var library = LibraryModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(library)
        }
    }
}
