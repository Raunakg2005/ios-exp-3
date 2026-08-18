//
//  LibraryData.swift
//  exp 3
//
//  THIS IS THE ONLY FILE YOU NEED TO EDIT to change the catalogue.
//  Fourteen real books with genuine ISBNs; page counts, ratings and copy
//  numbers are illustrative shelf data for the experiment.
//

import SwiftUI

extension Book {

    static let catalogue: [Book] = [
        Book(
            id: "9780132350884",
            title: "Clean Code",
            author: "Robert C. Martin",
            genre: .technology, year: 2008, pages: 464, rating: 4.4,
            copies: 6, shelf: "TC-004-A",
            blurb: "A handbook of agile software craftsmanship. Argues that code is "
                 + "read far more often than it is written, and sets out the naming, "
                 + "function design and formatting habits that follow from that."
        ),
        Book(
            id: "9780201616224",
            title: "The Pragmatic Programmer",
            author: "Hunt and Thomas",
            genre: .technology, year: 1999, pages: 352, rating: 4.6,
            copies: 4, shelf: "TC-004-B",
            blurb: "Seventy short essays on the craft of programming, from tracer "
                 + "bullets and rubber-duck debugging to the broken window theory of "
                 + "software decay."
        ),
        Book(
            id: "9780262033848",
            title: "Introduction to Algorithms",
            author: "Cormen and others",
            genre: .technology, year: 2009, pages: 1312, rating: 4.5,
            copies: 12, shelf: "TC-001-A",
            blurb: "The standard reference. Rigorous, comprehensive coverage of "
                 + "algorithms and data structures, with proofs of correctness and "
                 + "analysis of running time throughout."
        ),
        Book(
            id: "9780143127741",
            title: "Sapiens",
            author: "Yuval Noah Harari",
            genre: .history, year: 2015, pages: 464, rating: 4.4,
            copies: 8, shelf: "HS-012-C",
            blurb: "A brief history of humankind, from the cognitive revolution to the "
                 + "present, arguing that shared fictions are what let large numbers of "
                 + "strangers cooperate."
        ),
        Book(
            id: "9780553380163",
            title: "A Brief History of Time",
            author: "Stephen Hawking",
            genre: .science, year: 1998, pages: 212, rating: 4.3,
            copies: 5, shelf: "SC-002-A",
            blurb: "Cosmology without a single equation beyond one: black holes, the "
                 + "big bang, the arrow of time and the search for a unified theory, "
                 + "explained for the general reader."
        ),
        Book(
            id: "9780374533557",
            title: "Thinking, Fast and Slow",
            author: "Daniel Kahneman",
            genre: .science, year: 2013, pages: 499, rating: 4.2,
            copies: 7, shelf: "SC-008-B",
            blurb: "Two systems drive the way we think: one fast, intuitive and "
                 + "emotional, the other slower and deliberate. A summary of a career "
                 + "spent mapping where the fast one goes wrong."
        ),
        Book(
            id: "9780451524935",
            title: "Nineteen Eighty-Four",
            author: "George Orwell",
            genre: .fiction, year: 1949, pages: 328, rating: 4.7,
            copies: 10, shelf: "FN-019-D",
            blurb: "A civil servant in a totalitarian state begins, quietly, to keep a "
                 + "diary. The novel that gave English the words doublethink, newspeak "
                 + "and thoughtcrime."
        ),
        Book(
            id: "9780061120084",
            title: "To Kill a Mockingbird",
            author: "Harper Lee",
            genre: .fiction, year: 1960, pages: 336, rating: 4.6,
            copies: 9, shelf: "FN-005-A",
            blurb: "A lawyer defends a Black man falsely accused in a small Alabama "
                 + "town, told through the eyes of his six-year-old daughter."
        ),
        Book(
            id: "9780679783268",
            title: "Pride and Prejudice",
            author: "Jane Austen",
            genre: .fiction, year: 1813, pages: 480, rating: 4.5,
            copies: 6, shelf: "FN-001-B",
            blurb: "Elizabeth Bennet, five daughters, an entailed estate and a "
                 + "gentleman of ten thousand a year. Still the sharpest comedy of "
                 + "manners in the language."
        ),
        Book(
            id: "9780140449136",
            title: "Meditations",
            author: "Marcus Aurelius",
            genre: .philosophy, year: 180, pages: 254, rating: 4.5,
            copies: 4, shelf: "PH-003-A",
            blurb: "Private notes written by a Roman emperor on campaign, never "
                 + "intended for publication, on duty, mortality and keeping one's "
                 + "judgement in order."
        ),
        Book(
            id: "9780140449198",
            title: "The Republic",
            author: "Plato",
            genre: .philosophy, year: -375, pages: 416, rating: 4.1,
            copies: 5, shelf: "PH-001-A",
            blurb: "A dialogue on justice that becomes a blueprint for the ideal city, "
                 + "and contains the allegory of the cave."
        ),
        Book(
            id: "9781451648539",
            title: "Steve Jobs",
            author: "Walter Isaacson",
            genre: .biography, year: 2011, pages: 656, rating: 4.3,
            copies: 6, shelf: "BG-011-C",
            blurb: "Built from more than forty interviews with Jobs himself and a "
                 + "hundred more with those around him. Unsparing about the man and "
                 + "clear about the work."
        ),
        Book(
            id: "9780307887894",
            title: "The Innovators",
            author: "Walter Isaacson",
            genre: .biography, year: 2014, pages: 542, rating: 4.2,
            copies: 3, shelf: "BG-011-D",
            blurb: "How a group of hackers, geniuses and geeks created the digital "
                 + "revolution, from Ada Lovelace to the founding of the web."
        ),
        Book(
            id: "9780393609394",
            title: "Astrophysics for People in a Hurry",
            author: "Neil deGrasse Tyson",
            genre: .science, year: 2017, pages: 224, rating: 4.1,
            copies: 5, shelf: "SC-002-C",
            blurb: "The universe in short chapters: dark matter, dark energy, the "
                 + "periodic table and why the cosmic perspective is worth having."
        )
    ]
}

// MARK: - Notices

/// Library announcements, used by the dashboard marquee.
enum LibraryNotice {
    static let items: [String] = [
        "NEW ARRIVAL · ASTROPHYSICS FOR PEOPLE IN A HURRY",
        "RENEWALS NOW OPEN ONLINE",
        "READING ROOM OPEN UNTIL MIDNIGHT DURING EXAMS",
        "IEEE AND ACM DIGITAL LIBRARIES AVAILABLE ON CAMPUS",
        "RETURN OVERDUE TITLES TO COUNTER THREE"
    ]
}
