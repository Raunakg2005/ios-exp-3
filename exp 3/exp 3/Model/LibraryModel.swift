//
//  LibraryModel.swift
//  exp 3
//
//  The single source of truth for the whole application.
//
//  It is created once, as a @StateObject on the App, and injected into the
//  view hierarchy with .environmentObject(). Every screen then reads it with
//  @EnvironmentObject, so favouriting a book in the catalogue updates the
//  dashboard counter, the library shelves and the profile statistics at the
//  same instant, without any of those views knowing about each other.
//
//      @StateObject        exp_3App      owns it, exactly one instance
//      .environmentObject  RootView      places it in the environment
//      @EnvironmentObject  every screen  reads and mutates it
//
//  Each stored property is @Published, so any write sends objectWillChange
//  and SwiftUI re-renders the views that actually read it.
//

import SwiftUI
import Combine

@MainActor
final class LibraryModel: ObservableObject {

    // MARK: Published state

    @Published var userName: String {
        didSet { defaults.set(userName, forKey: Keys.userName) }
    }

    /// The catalogue itself. Read-only to the views.
    @Published private(set) var books: [Book]

    @Published private(set) var favouriteIDs: Set<String> {
        didSet { defaults.set(Array(favouriteIDs), forKey: Keys.favourites) }
    }

    /// Ordered, because a reading list is a queue.
    @Published private(set) var readingListIDs: [String] {
        didSet { defaults.set(readingListIDs, forKey: Keys.readingList) }
    }

    @Published private(set) var completedIDs: Set<String> {
        didSet { defaults.set(Array(completedIDs), forKey: Keys.completed) }
    }

    /// Pages read per book, keyed by ISBN.
    @Published private(set) var pagesReadByBook: [String: Int] {
        didSet { defaults.set(pagesReadByBook, forKey: Keys.pagesRead) }
    }

    @Published var preferences: Preferences {
        didSet { persistPreferences() }
    }

    // MARK: Storage

    private let defaults: UserDefaults

    private enum Keys {
        static let userName    = "library.userName"
        static let favourites  = "library.favourites"
        static let readingList = "library.readingList"
        static let completed   = "library.completed"
        static let pagesRead   = "library.pagesRead"
        static let preferences = "library.preferences"
    }

    // MARK: Init

    init(books: [Book] = Book.catalogue, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.books = books

        self.userName = defaults.string(forKey: Keys.userName) ?? "Raunak Gupta"
        self.favouriteIDs = Set(defaults.stringArray(forKey: Keys.favourites) ?? [])
        self.readingListIDs = defaults.stringArray(forKey: Keys.readingList) ?? []
        self.completedIDs = Set(defaults.stringArray(forKey: Keys.completed) ?? [])
        self.pagesReadByBook = (defaults.dictionary(forKey: Keys.pagesRead) as? [String: Int]) ?? [:]

        if let data = defaults.data(forKey: Keys.preferences),
           let decoded = try? JSONDecoder().decode(Preferences.self, from: data) {
            self.preferences = decoded
        } else {
            self.preferences = Preferences()
        }

        if favouriteIDs.isEmpty && readingListIDs.isEmpty && completedIDs.isEmpty {
            seedFirstRun()
        }
    }

    /// A brand new install opens on something rather than five empty shelves.
    private func seedFirstRun() {
        guard books.count >= 6 else { return }
        let ids = books.map(\.id)
        favouriteIDs = [ids[0], ids[4]]
        readingListIDs = [ids[2], ids[5], ids[1]]
        completedIDs = [ids[3]]
        pagesReadByBook = [
            ids[2]: Int(Double(books[2].pages) * 0.62),
            ids[5]: Int(Double(books[5].pages) * 0.24),
            ids[1]: Int(Double(books[1].pages) * 0.08),
            ids[3]: books[3].pages
        ]
    }

    private func persistPreferences() {
        if let data = try? JSONEncoder().encode(preferences) {
            defaults.set(data, forKey: Keys.preferences)
        }
    }

    // MARK: Derived collections
    //
    // Named to match the data-flow diagram for this experiment.

    var favoriteBooks: [Book] {
        books.filter { favouriteIDs.contains($0.id) }
    }

    /// Kept in the order the reader queued them.
    var readingList: [Book] {
        readingListIDs.compactMap { identifier in
            books.first { $0.id == identifier }
        }
    }

    var completedBooks: [Book] {
        books.filter { completedIDs.contains($0.id) }
    }

    /// What the dashboard offers first: furthest along but not yet finished.
    var currentlyReading: Book? {
        let started = readingList.filter { !completedIDs.contains($0.id) && progress(for: $0) > 0 }
        if let furthest = started.max(by: { progress(for: $0) < progress(for: $1) }) {
            return furthest
        }
        return readingList.first { !completedIDs.contains($0.id) }
    }

    var totalPagesRead: Int {
        pagesReadByBook.values.reduce(0, +)
    }

    /// Progress towards the monthly goal set in Settings.
    var goalProgress: Double {
        guard preferences.monthlyGoal > 0 else { return 0 }
        return min(Double(completedIDs.count) / Double(preferences.monthlyGoal), 1)
    }

    func genreBreakdown() -> [GenreCount] {
        Genre.allCases
            .map { genre in
                GenreCount(genre: genre, count: books.filter {
                    $0.genre == genre && completedIDs.contains($0.id)
                }.count)
            }
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
    }

    struct GenreCount: Identifiable {
        let genre: Genre
        let count: Int
        var id: String { genre.rawValue }
    }

    // MARK: Queries

    func isFavourite(_ book: Book) -> Bool { favouriteIDs.contains(book.id) }
    func isInReadingList(_ book: Book) -> Bool { readingListIDs.contains(book.id) }
    func isCompleted(_ book: Book) -> Bool { completedIDs.contains(book.id) }

    func pagesRead(for book: Book) -> Int {
        min(pagesReadByBook[book.id] ?? 0, book.pages)
    }

    func progress(for book: Book) -> Double {
        guard book.pages > 0 else { return 0 }
        return Double(pagesRead(for: book)) / Double(book.pages)
    }

    /// Search and filter live in the model so the list view stays a
    /// presentation layer.
    func search(_ query: String, genre: Genre?, sort: SortOrder) -> [Book] {
        var results = books

        if let genre {
            results = results.filter { $0.genre == genre }
        }

        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            results = results.filter {
                $0.title.localizedCaseInsensitiveContains(trimmed)
                    || $0.author.localizedCaseInsensitiveContains(trimmed)
                    || $0.isbn.contains(trimmed)
            }
        }

        switch sort {
        case .title:  return results.sorted { $0.title < $1.title }
        case .author: return results.sorted { $0.author < $1.author }
        case .rating: return results.sorted { $0.rating > $1.rating }
        case .year:   return results.sorted { $0.year > $1.year }
        }
    }

    enum SortOrder: String, CaseIterable, Identifiable {
        case title = "Title"
        case author = "Author"
        case rating = "Rating"
        case year = "Year"
        var id: String { rawValue }
    }

    // MARK: Mutations
    //
    // Each of these is called from a different screen, and each is seen by
    // all of them.

    func toggleFavourite(_ book: Book) {
        if favouriteIDs.contains(book.id) {
            favouriteIDs.remove(book.id)
        } else {
            favouriteIDs.insert(book.id)
        }
    }

    func toggleReadingList(_ book: Book) {
        if let index = readingListIDs.firstIndex(of: book.id) {
            readingListIDs.remove(at: index)
        } else {
            readingListIDs.append(book.id)
        }
    }

    func removeFromReadingList(at offsets: IndexSet) {
        readingListIDs.remove(atOffsets: offsets)
    }

    func moveInReadingList(from source: IndexSet, to destination: Int) {
        readingListIDs.move(fromOffsets: source, toOffset: destination)
    }

    func toggleCompleted(_ book: Book) {
        if completedIDs.contains(book.id) {
            completedIDs.remove(book.id)
            pagesReadByBook[book.id] = 0
        } else {
            completedIDs.insert(book.id)
            pagesReadByBook[book.id] = book.pages
            if !readingListIDs.contains(book.id) {
                readingListIDs.append(book.id)
            }
        }
    }

    func setPagesRead(_ pages: Int, for book: Book) {
        let clamped = max(0, min(pages, book.pages))
        pagesReadByBook[book.id] = clamped

        if clamped == book.pages {
            completedIDs.insert(book.id)
        } else {
            completedIDs.remove(book.id)
        }
        if clamped > 0 && !readingListIDs.contains(book.id) {
            readingListIDs.append(book.id)
        }
    }

    /// Clears everything the reader has done, for the Settings reset.
    func resetLibrary() {
        favouriteIDs = []
        readingListIDs = []
        completedIDs = []
        pagesReadByBook = [:]
    }
}
