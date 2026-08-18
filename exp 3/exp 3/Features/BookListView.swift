//
//  BookListView.swift
//  exp 3
//
//  The catalogue. Search, genre filter and sort order live as @State on this
//  view; the actual filtering is delegated to LibraryModel.search so the view
//  does not know anything about how the shelves are stored.
//

import SwiftUI

struct BookListView: View {
    @EnvironmentObject private var library: LibraryModel

    @State private var query = ""
    @State private var genre: Genre? = nil
    @State private var sort: LibraryModel.SortOrder = .title

    private var results: [Book] {
        library.search(query, genre: genre, sort: sort)
    }

    var body: some View {
        NavigationStack {
            LibraryPage {
                TabHeader(
                    index: "02",
                    title: "Catalogue",
                    caption: "\(library.books.count) titles across \(Genre.allCases.count) genres"
                )

                SearchField(text: $query, prompt: "Title, author or ISBN")
                    .padding(.top, 20)

                genreRail.padding(.top, 12)
                sortRow.padding(.top, 14)

                if results.isEmpty {
                    EmptyNote(text: "No book matches those filters.")
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)],
                              spacing: 12) {
                        ForEach(results) { book in
                            NavigationLink(value: book) {
                                CatalogueCard(book: book)
                            }
                            .buttonStyle(PressStyle())
                        }
                    }
                    .padding(.top, 18)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: results.count)
                }
            }
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book)
            }
        }
    }

    // MARK: Rails

    private var genreRail: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { genre = nil }
                } label: {
                    Tag(text: "All", solid: genre == nil)
                }
                .buttonStyle(.plain)

                ForEach(Genre.allCases) { option in
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            genre = genre == option ? nil : option
                        }
                    } label: {
                        Tag(text: option.rawValue, solid: genre == option)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }

    private var sortRow: some View {
        HStack(spacing: 6) {
            Text("Sort").microLabel(size: 9)
            ForEach(LibraryModel.SortOrder.allCases) { option in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        sort = option
                    }
                } label: {
                    Tag(text: option.rawValue, solid: sort == option)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
}

// MARK: - Catalogue card

/// Reads @EnvironmentObject itself so the heart mark on the card updates the
/// moment the state changes on the detail screen, without props being
/// threaded through.
private struct CatalogueCard: View {
    @EnvironmentObject private var library: LibraryModel
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                BookCoverView(book: book, width: 128)
                    .frame(maxWidth: .infinity)

                if library.isFavourite(book) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Ink.onLime)
                        .padding(5)
                        .background(Ink.lime)
                        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                        .padding(6)
                }
            }

            Text(book.title)
                .font(Typo.condensed(15, .bold))
                .foregroundStyle(Ink.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)

            Text(book.author)
                .font(Typo.body(11))
                .foregroundStyle(Ink.mute)
                .lineLimit(1)
                .padding(.top, 2)

            Spacer(minLength: 8)

            HStack(alignment: .center) {
                RatingMarks(rating: book.rating, size: 6)
                Spacer()
                Text(book.genre.mark)
                    .font(Typo.mono(9, .bold))
                    .foregroundStyle(Ink.mute)
            }
        }
        .frame(height: 268, alignment: .topLeading)
        .block(padding: 14)
    }
}

#Preview {
    BookListView().environmentObject(LibraryModel())
}
