//
//  Book.swift
//  exp 3
//
//  Value types. The library's books never change, so Book is a plain struct;
//  everything the reader does to a book (favouriting it, shelving it,
//  finishing it) is state held by LibraryModel, not by the book itself.
//

import SwiftUI

// MARK: - Genre

enum Genre: String, CaseIterable, Identifiable, Codable, Hashable {
    case fiction      = "Fiction"
    case science      = "Science"
    case technology   = "Technology"
    case history      = "History"
    case philosophy   = "Philosophy"
    case biography    = "Biography"

    var id: String { rawValue }

    /// Two-letter shelf mark, in the manner of a library classification.
    var mark: String {
        switch self {
        case .fiction:    return "FN"
        case .science:    return "SC"
        case .technology: return "TC"
        case .history:    return "HS"
        case .philosophy: return "PH"
        case .biography:  return "BG"
        }
    }

    var symbol: String {
        switch self {
        case .fiction:    return "books.vertical"
        case .science:    return "atom"
        case .technology: return "cpu"
        case .history:    return "building.columns"
        case .philosophy: return "brain.head.profile"
        case .biography:  return "person.text.rectangle"
        }
    }
}

// MARK: - Book

struct Book: Identifiable, Hashable {
    let id: String              // the ISBN doubles as the identifier
    let title: String
    let author: String
    let genre: Genre
    let year: Int
    let pages: Int
    let rating: Double          // out of 5
    let copies: Int
    let shelf: String
    let blurb: String

    var isbn: String { id }

    var ratingStars: Int { Int(rating.rounded()) }

    /// A deterministic number in 0..<6 used to vary the drawn cover, so a
    /// given book always gets the same one.
    var coverSeed: Int {
        var total = 0
        for scalar in id.unicodeScalars { total = (total &+ Int(scalar.value)) % 997 }
        return total % 6
    }
}

// MARK: - Preferences

/// Reading preferences. Persisted by LibraryModel, and read by the root view
/// so a change here re-renders every screen in the application.
struct Preferences: Codable, Equatable {

    enum Appearance: String, CaseIterable, Codable, Identifiable {
        case system, light, dark
        var id: String { rawValue }

        var label: String { rawValue.capitalized }

        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light:  return .light
            case .dark:   return .dark
            }
        }
    }

    enum TextScale: String, CaseIterable, Codable, Identifiable {
        case compact, standard, large
        var id: String { rawValue }

        var label: String { rawValue.capitalized }

        var dynamicTypeSize: DynamicTypeSize {
            switch self {
            case .compact:  return .small
            case .standard: return .large
            case .large:    return .xxLarge
            }
        }
    }

    var appearance: Appearance = .system
    var textScale: TextScale = .standard
    var showCovers: Bool = true
    var favouriteGenre: Genre? = nil
    var monthlyGoal: Int = 4
}
