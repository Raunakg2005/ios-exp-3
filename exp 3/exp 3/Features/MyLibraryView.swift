//
//  MyLibraryView.swift
//  exp 3
//
//  Reading list, favourites and completed books, on one screen with a
//  segmented picker. The reading list is editable inline: swipe to remove
//  and drag to reorder, both mutating the shared model.
//

import SwiftUI

struct MyLibraryView: View {

    @EnvironmentObject private var library: LibraryModel

    enum Shelf: String, CaseIterable, Identifiable {
        case reading = "Reading"
        case favourites = "Favourites"
        case completed = "Completed"
        var id: String { rawValue }

        var caption: String {
            switch self {
            case .reading:    return "In progress, in order"
            case .favourites: return "Titles you keep coming back to"
            case .completed:  return "Finished reads"
            }
        }
    }

    @State private var shelf: Shelf = .reading

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                LibraryPage {
                    TabHeader(
                        index: "03",
                        title: "My library",
                        caption: shelf.caption
                    )

                    picker.padding(.top, 20)

                    Group {
                        switch shelf {
                        case .reading:    readingList
                        case .favourites: favourites
                        case .completed:  completed
                        }
                    }
                    .padding(.top, 18)
                }
            }
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book)
            }
        }
    }

    // MARK: Picker

    private var picker: some View {
        HStack(spacing: 6) {
            ForEach(Shelf.allCases) { option in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        shelf = option
                    }
                } label: {
                    let count = countFor(option)
                    HStack(spacing: 6) {
                        Text(option.rawValue)
                            .font(Typo.condensed(13, .bold))
                        Text("\(count)")
                            .font(Typo.mono(10, .bold))
                            .foregroundStyle(shelf == option ? Ink.paper.opacity(0.7) : Ink.mute)
                    }
                    .foregroundStyle(shelf == option ? Ink.paper : Ink.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity)
                    .background(shelf == option ? Ink.reverse : Ink.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .overlay {
                        if shelf != option {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .strokeBorder(Ink.line, lineWidth: 1)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func countFor(_ option: Shelf) -> Int {
        switch option {
        case .reading:    return library.readingList.count
        case .favourites: return library.favoriteBooks.count
        case .completed:  return library.completedBooks.count
        }
    }

    // MARK: Reading list

    @ViewBuilder
    private var readingList: some View {
        if library.readingList.isEmpty {
            EmptyNote(text: "Nothing queued. Add a book from the catalogue.")
                .padding(.top, 30)
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text("Swipe to remove, or long press and drag to reorder.")
                    .font(Typo.body(11))
                    .foregroundStyle(Ink.mute)

                List {
                    ForEach(library.readingList) { book in
                        NavigationLink(value: book) {
                            ReadingRow(book: book)
                        }
                        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                        .listRowSeparator(.visible)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete { library.removeFromReadingList(at: $0) }
                    .onMove { library.moveInReadingList(from: $0, to: $1) }
                }
                .listStyle(.plain)
                .scrollDisabled(true)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(height: rowHeight * CGFloat(library.readingList.count))
                .environment(\.editMode, .constant(.inactive))
            }
        }
    }

    private var rowHeight: CGFloat { 108 }

    // MARK: Favourites and completed

    @ViewBuilder
    private var favourites: some View {
        if library.favoriteBooks.isEmpty {
            EmptyNote(text: "No favourites yet. Tap the heart on a book to mark one.")
                .padding(.top, 30)
        } else {
            grid(books: library.favoriteBooks)
        }
    }

    @ViewBuilder
    private var completed: some View {
        if library.completedBooks.isEmpty {
            EmptyNote(text: "No completed books yet.")
                .padding(.top, 30)
        } else {
            grid(books: library.completedBooks)
        }
    }

    private func grid(books: [Book]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
            ForEach(books) { book in
                NavigationLink(value: book) {
                    ShelfCard(book: book)
                }
                .buttonStyle(PressStyle())
            }
        }
    }
}

// MARK: - Rows

private struct ReadingRow: View {
    @EnvironmentObject private var library: LibraryModel
    let book: Book

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            BookCoverView(book: book, width: 58)

            VStack(alignment: .leading, spacing: 5) {
                Text(book.title.uppercased())
                    .font(Typo.condensed(15, .bold))
                    .foregroundStyle(Ink.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(book.author)
                    .font(Typo.body(11))
                    .foregroundStyle(Ink.mute)

                Spacer(minLength: 5)

                Text("\(library.pagesRead(for: book)) / \(book.pages) pp")
                    .font(Typo.mono(9, .semibold))
                    .foregroundStyle(Ink.mute)
                ProgressLine(value: library.progress(for: book))
                    .padding(.top, 1)
            }

            if library.isCompleted(book) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Ink.onLime)
                    .padding(4)
                    .background(Ink.lime)
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

private struct ShelfCard: View {
    @EnvironmentObject private var library: LibraryModel
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BookCoverView(book: book, width: 128)
                .frame(maxWidth: .infinity)

            Text(book.title)
                .font(Typo.condensed(14, .bold))
                .foregroundStyle(Ink.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)

            Text(book.author)
                .font(Typo.body(11))
                .foregroundStyle(Ink.mute)
                .lineLimit(1)
                .padding(.top, 2)

            Spacer(minLength: 6)

            HStack {
                RatingMarks(rating: book.rating, size: 6)
                Spacer()
                if library.isCompleted(book) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Ink.ink)
                }
            }
        }
        .frame(height: 260, alignment: .topLeading)
        .block(padding: 14)
    }
}

#Preview {
    MyLibraryView().environmentObject(LibraryModel())
}
