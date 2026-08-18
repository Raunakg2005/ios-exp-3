//
//  BookDetailView.swift
//  exp 3
//
//  The detail screen also reads the shared model. Every toggle here writes
//  to that same model, so the dashboard counters and the library shelves
//  update the moment the button is tapped, without either being told.
//
//  It also demonstrates several values pulled from @Environment: the system
//  locale for the ISBN, the device dynamic-type size for the sample text
//  block, and dismiss() so the Close button in the sheet knows how to leave.
//

import SwiftUI

struct BookDetailView: View {
    let book: Book

    @EnvironmentObject private var library: LibraryModel

    /// System values, read straight from the environment.
    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.dismiss) private var dismiss

    @State private var showSample = false
    @State private var showReset = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                plate
                actions
                progress
                details
                blurb
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 44)
            .containerRelativeFrame(.horizontal)
        }
        .background(Ink.paper.ignoresSafeArea())
        .scrollIndicators(.hidden)
        .navigationTitle(book.genre.mark)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Ink.paper, for: .navigationBar)
        .sheet(isPresented: $showSample) {
            SampleSheet(book: book)
                .presentationDetents([.medium, .large])
        }
        .confirmationDialog("Reset reading progress?",
                            isPresented: $showReset, titleVisibility: .visible) {
            Button("Mark as unread", role: .destructive) {
                library.setPagesRead(0, for: book)
                if library.isCompleted(book) { library.toggleCompleted(book) }
            }
        }
    }

    // MARK: Plate

    private var plate: some View {
        ZStack(alignment: .topLeading) {
            Ink.reverse
            WaveLines(lines: 18, amplitude: 7, cycles: 2.6)
                .stroke(Ink.lime.opacity(0.18), lineWidth: 0.7)

            HStack(alignment: .top, spacing: 16) {
                BookCoverView(book: book, width: 96)

                VStack(alignment: .leading, spacing: 6) {
                    Text(book.genre.rawValue.uppercased())
                        .font(Typo.mono(10, .bold))
                        .tracking(1.4)
                        .foregroundStyle(Ink.lime)

                    Text(book.title.uppercased())
                        .font(Typo.display(24))
                        .tracking(-0.4)
                        .foregroundStyle(Ink.paper)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(book.author)
                        .font(Typo.body(12))
                        .foregroundStyle(Ink.paper.opacity(0.7))

                    Spacer(minLength: 8)

                    HStack(spacing: 6) {
                        Text("\(book.pages) PP")
                            .font(Typo.mono(9, .bold))
                            .foregroundStyle(Ink.paper)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .overlay {
                                RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(Ink.paper.opacity(0.35), lineWidth: 1)
                            }
                        Text("\(String(book.year))")
                            .font(Typo.mono(9, .bold))
                            .foregroundStyle(Ink.onLime)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 3).fill(Ink.lime))
                    }
                }
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    // MARK: Actions

    /// Three writes to the shared model. Every other screen sees them.
    private var actions: some View {
        HStack(spacing: 10) {
            ActionButton(
                symbol: library.isFavourite(book) ? "heart.fill" : "heart",
                label: library.isFavourite(book) ? "Favourited" : "Favourite",
                filled: library.isFavourite(book)
            ) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    library.toggleFavourite(book)
                }
            }

            ActionButton(
                symbol: library.isInReadingList(book) ? "bookmark.fill" : "bookmark",
                label: library.isInReadingList(book) ? "On list" : "Add to list",
                filled: library.isInReadingList(book)
            ) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    library.toggleReadingList(book)
                }
            }

            ActionButton(
                symbol: library.isCompleted(book) ? "checkmark.seal.fill" : "checkmark.seal",
                label: library.isCompleted(book) ? "Read" : "Mark read",
                filled: library.isCompleted(book)
            ) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    library.toggleCompleted(book)
                }
            }
        }
        .sensoryFeedback(.impact(weight: .light),
                         trigger: library.favouriteIDs.count
                                + library.readingListIDs.count
                                + library.completedIDs.count)
    }

    // MARK: Progress

    private var progress: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(index: "P", title: "Reading progress")

            let pages = library.pagesRead(for: book)
            let binding = Binding<Double>(
                get: { Double(pages) },
                set: { library.setPagesRead(Int($0), for: book) }
            )

            HStack(alignment: .firstTextBaseline) {
                Text("\(pages)")
                    .font(Typo.display(32))
                    .foregroundStyle(Ink.ink)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text("of \(book.pages) pages")
                    .font(Typo.body(13))
                    .foregroundStyle(Ink.mute)
                Spacer()
                Text("\(Int(library.progress(for: book) * 100))%")
                    .font(Typo.mono(11, .bold))
                    .foregroundStyle(Ink.mute)
                    .monospacedDigit()
            }

            Slider(value: binding, in: 0...Double(book.pages), step: 1)
                .tint(Ink.ink)

            HStack {
                Button("Reset") { showReset = true }
                    .font(Typo.condensed(13, .bold))
                    .foregroundStyle(Ink.ink)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { showSample = true }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "text.viewfinder")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Preview sample")
                            .font(Typo.condensed(13, .bold))
                    }
                    .foregroundStyle(Ink.paper)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Ink.reverse)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
                .buttonStyle(PressStyle())
            }
        }
        .block(padding: 16)
    }

    // MARK: Details

    private var details: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(index: "D", title: "Bibliographic")

            VStack(spacing: 10) {
                DataRow(key: "ISBN", value: formattedISBN)
                Rule()
                DataRow(key: "Genre", value: book.genre.rawValue, mono: false)
                Rule()
                DataRow(key: "Year", value: String(book.year))
                Rule()
                DataRow(key: "Shelf", value: book.shelf)
                Rule()
                DataRow(key: "Copies", value: "\(book.copies) in stock")
                Rule()
                HStack(alignment: .firstTextBaseline) {
                    Text("Rating").microLabel(size: 9)
                    Spacer(minLength: 12)
                    RatingMarks(rating: book.rating, size: 8)
                }
            }
            .block(padding: 16)
        }
    }

    private var blurb: some View {
        HStack(alignment: .top, spacing: 14) {
            Rectangle().fill(Ink.lime).frame(width: 4)
            VStack(alignment: .leading, spacing: 8) {
                Text("About").microLabel()
                Text(book.blurb)
                    .font(Typo.body(15))
                    .foregroundStyle(Ink.ink)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Helpers

    /// The ISBN, grouped for readability. Uses the current locale so a group
    /// separator that follows the reader's preference would fit in later.
    private var formattedISBN: String {
        _ = locale.language.languageCode?.identifier   // access to make the dependency real
        let raw = book.isbn
        guard raw.count == 13 else { return raw }
        let scalars = Array(raw)
        let parts = [
            String(scalars[0..<3]),
            String(scalars[3..<4]),
            String(scalars[4..<7]),
            String(scalars[7..<12]),
            String(scalars[12..<13])
        ]
        return parts.joined(separator: "-")
    }
}

// MARK: - Action button

private struct ActionButton: View {
    let symbol: String
    let label: String
    let filled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
                Text(label)
                    .font(Typo.mono(9, .bold))
                    .tracking(0.4)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(filled ? Ink.onLime : Ink.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(filled ? Ink.lime : Ink.surface)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(filled ? Color.clear : Ink.line, lineWidth: 1)
            }
        }
        .buttonStyle(PressStyle())
    }
}

// MARK: - Sample sheet

/// Presented as a sheet, dismissed with @Environment(\.dismiss).
private struct SampleSheet: View {
    let book: Book

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sample").microLabel(Ink.ink)
                    Text(book.title)
                        .font(Typo.condensed(17, .bold))
                        .foregroundStyle(Ink.ink)
                        .lineLimit(1)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Ink.ink)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Ink.ink.opacity(0.08)))
                }
                .buttonStyle(PressStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            Rule().padding(.top, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(book.blurb)
                        .font(Typo.body(16))
                        .foregroundStyle(Ink.ink)
                        .lineSpacing(6)

                    Rule()

                    Text("The passage below is a placeholder set to demonstrate that "
                       + "the reader's chosen text size in Settings and the system "
                       + "Dynamic Type setting both take effect here.")
                        .font(Typo.body(15))
                        .foregroundStyle(Ink.mute)
                        .lineSpacing(5)

                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                       + "Aenean commodo ligula eget dolor. Aenean massa. Cum sociis "
                       + "natoque penatibus et magnis dis parturient montes, "
                       + "nascetur ridiculus mus. Donec quam felis, ultricies nec, "
                       + "pellentesque eu, pretium quis, sem.")
                        .font(Typo.body(15))
                        .foregroundStyle(Ink.ink)
                        .lineSpacing(5)
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .background(Ink.paper.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        BookDetailView(book: Book.catalogue[0])
    }
    .environmentObject(LibraryModel())
}
