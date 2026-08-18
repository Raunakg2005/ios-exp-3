//
//  HomeView.swift
//  exp 3
//
//  The dashboard. Everything on this screen is derived from the shared
//  LibraryModel, so favouriting a book two tabs away changes the counters
//  here without this file knowing anything about the catalogue screen.
//

import SwiftUI

struct HomeView: View {

    /// Read out of the environment. HomeView does not own the model.
    @EnvironmentObject private var library: LibraryModel

    @Binding var selection: AppTab

    /// System values, read straight from the environment.
    @Environment(\.colorScheme) private var colorScheme

    @State private var appeared = false

    var body: some View {
        NavigationStack {
            LibraryPage {
                masthead
                TickerView(items: LibraryNotice.items).padding(.top, 18)
                counters.padding(.top, 22)
                continueReading.padding(.top, 26)
                shelves.padding(.top, 26)
                recommended.padding(.top, 26)
                colophon.padding(.top, 34)
            }
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book)
            }
        }
    }

    // MARK: Masthead

    private var masthead: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text("KJSCE").microLabel(Ink.ink, size: 9)
                Rule()
                Text("Central Library").microLabel(size: 9)
                Rule()
                Text(colorScheme == .dark ? "Dark" : "Light").microLabel(size: 9)
            }
            .padding(.top, 12)

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: -10) {
                    Text("BOOK")
                        .displayType(50)
                        .lineLimit(1)
                    Text("LIBRARY")
                        .displayType(50)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .offset(x: appeared ? 0 : -18)
                .opacity(appeared ? 1 : 0)

                Spacer(minLength: 0)

                readerPlate
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.86, anchor: .bottomTrailing)
            }
            .padding(.top, 20)

            // The name is edited on the Profile screen and appears here.
            Text("Good to see you, \(library.userName).")
                .font(Typo.condensed(14, .bold))
                .foregroundStyle(Ink.ink)
                .padding(.top, 14)

            Text("\(library.books.count) titles on the shelves, "
                 + "\(library.totalPagesRead) pages read so far.")
                .font(Typo.body(12))
                .foregroundStyle(Ink.mute)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 3)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.82)) { appeared = true }
        }
    }

    private var readerPlate: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(Ink.ink.opacity(0.55), lineWidth: 1)
                .frame(width: 92, height: 92)
                .offset(x: 8, y: 8)

            ZStack {
                Ink.lime
                WaveLines(lines: 9, amplitude: 4, cycles: 2.2)
                    .stroke(Ink.onLime.opacity(0.20), lineWidth: 0.7)
                VStack(spacing: 2) {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 24, weight: .bold))
                    Text("\(library.completedIDs.count) READ")
                        .font(Typo.mono(8, .bold))
                        .tracking(0.8)
                }
                .foregroundStyle(Ink.onLime)
            }
            .frame(width: 92, height: 92)
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(Ink.ink, lineWidth: 1)
            }
        }
        .frame(width: 100, height: 100, alignment: .topLeading)
    }

    // MARK: Counters

    /// These three numbers are the proof the experiment asks for: they are
    /// written on other screens and read here.
    private var counters: some View {
        HStack(alignment: .top, spacing: 0) {
            StatColumn(value: "\(library.favoriteBooks.count)", unit: nil, label: "Favourites")
                .padding(.trailing, 14)
            Rule(.vertical).frame(height: 52)
            StatColumn(value: "\(library.readingList.count)", unit: nil, label: "Reading list")
                .padding(.horizontal, 14)
            Rule(.vertical).frame(height: 52)
            StatColumn(value: "\(library.completedBooks.count)", unit: nil, label: "Completed")
                .padding(.leading, 14)
        }
        .block(padding: 16)
        .animation(.spring(response: 0.4, dampingFraction: 0.85),
                   value: library.favoriteBooks.count + library.readingList.count
                        + library.completedBooks.count)
    }

    // MARK: Continue reading

    @ViewBuilder
    private var continueReading: some View {
        if let book = library.currentlyReading {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeading(index: "A", title: "Continue reading")

                NavigationLink(value: book) {
                    HStack(alignment: .top, spacing: 14) {
                        BookCoverView(book: book, width: 78)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(book.title.uppercased())
                                .font(Typo.condensed(18, .bold))
                                .foregroundStyle(Ink.ink)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(book.author)
                                .font(Typo.body(12))
                                .foregroundStyle(Ink.mute)

                            Spacer(minLength: 6)

                            Text("\(library.pagesRead(for: book)) of \(book.pages) pages")
                                .font(Typo.mono(10, .semibold))
                                .foregroundStyle(Ink.mute)

                            ProgressLine(value: library.progress(for: book))
                                .padding(.top, 2)
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Ink.mute)
                            .padding(.top, 4)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressStyle())
            }
            .block(padding: 16)
        }
    }

    // MARK: Shelves

    private var shelves: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(index: "B", title: "Your shelves")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                ShelfTile(symbol: "bookmark.fill", title: "Reading list",
                          count: library.readingList.count) { selection = .library }
                ShelfTile(symbol: "heart.fill", title: "Favourites",
                          count: library.favoriteBooks.count) { selection = .library }
                ShelfTile(symbol: "checkmark.seal.fill", title: "Completed",
                          count: library.completedBooks.count) { selection = .library }
                ShelfTile(symbol: "books.vertical.fill", title: "Catalogue",
                          count: library.books.count) { selection = .catalogue }
            }
        }
    }

    // MARK: Recommended

    private var recommended: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(
                index: "C",
                title: library.preferences.favouriteGenre.map { "More \($0.rawValue.lowercased())" }
                    ?? "Highly rated"
            )

            // A horizontal scroller is self-contained: it takes the width it
            // is offered and scrolls its own overflow.
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(recommendations) { book in
                        NavigationLink(value: book) {
                            VStack(alignment: .leading, spacing: 7) {
                                BookCoverView(book: book, width: 96)
                                Text(book.title)
                                    .font(Typo.condensed(13, .bold))
                                    .foregroundStyle(Ink.ink)
                                    .lineLimit(2)
                                    .frame(width: 96, alignment: .leading)
                                RatingMarks(rating: book.rating, size: 6)
                            }
                        }
                        .buttonStyle(PressStyle())
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var recommendations: [Book] {
        let pool = library.preferences.favouriteGenre
            .map { genre in library.books.filter { $0.genre == genre } } ?? library.books
        return Array(pool.sorted { $0.rating > $1.rating }.prefix(6))
    }

    // MARK: Colophon

    private var colophon: some View {
        VStack(alignment: .leading, spacing: 10) {
            Rule()
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("K. J. Somaiya College of Engineering")
                        .microLabel(Ink.ink, size: 9)
                    Text("Experiment 03 · Property wrappers and data flow")
                        .font(Typo.mono(9))
                        .foregroundStyle(Ink.mute)
                }
                Spacer()
                Text("EXP 03")
                    .font(Typo.display(28))
                    .foregroundStyle(Ink.line)
            }
        }
    }
}

// MARK: - Shelf tile

private struct ShelfTile: View {
    let symbol: String
    let title: String
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: symbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Ink.ink)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Ink.mute)
                }

                Spacer(minLength: 14)

                Text("\(count)")
                    .font(Typo.display(30))
                    .foregroundStyle(Ink.ink)
                    .monospacedDigit()
                    .contentTransition(.numericText())

                Text(title.uppercased())
                    .microLabel(size: 9)
                    .padding(.top, 1)
            }
            .frame(height: 104, alignment: .topLeading)
            .block(padding: 14)
        }
        .buttonStyle(PressStyle())
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: count)
    }
}

#Preview {
    RootView().environmentObject(LibraryModel())
}
