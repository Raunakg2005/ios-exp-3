//
//  ProfileView.swift
//  exp 3
//
//  The reader's profile: name, statistics derived from the shared model, and
//  a breakdown of completed reads by genre. Editing the name here changes
//  the greeting on the dashboard and the byline on the settings screen.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var library: LibraryModel

    @State private var editingName = false
    @State private var draftName = ""

    var body: some View {
        NavigationStack {
            LibraryPage {
                header
                figures.padding(.top, 20)
                goalBlock.padding(.top, 22)
                genreBlock.padding(.top, 22)
                readingHistory.padding(.top, 22)
            }
        }
        .alert("Change your name", isPresented: $editingName) {
            TextField("Name", text: $draftName)
                .textInputAutocapitalization(.words)
            Button("Save") {
                let trimmed = draftName.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty { library.userName = trimmed }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This is the name shown on the dashboard greeting.")
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text("04").microLabel(Ink.ink, size: 9)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 3)
                    .background(Ink.lime)
                Rule()
            }
            .padding(.top, 14)

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: -6) {
                    Text(library.userName.uppercased())
                        .displayType(38)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                Spacer(minLength: 0)

                InitialsPlate(initials: initials, accent: true, size: 60)
            }
            .padding(.top, 16)

            HStack(spacing: 8) {
                Button {
                    draftName = library.userName
                    editingName = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Edit name")
                            .font(Typo.condensed(13, .bold))
                    }
                    .foregroundStyle(Ink.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .strokeBorder(Ink.line, lineWidth: 1)
                    }
                }
                .buttonStyle(PressStyle())

                Tag(text: "Reader since 2023")
            }
            .padding(.top, 14)
        }
    }

    private var initials: String {
        let parts = library.userName.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    // MARK: Figures

    private var figures: some View {
        HStack(alignment: .top, spacing: 0) {
            StatColumn(value: "\(library.completedIDs.count)", unit: nil, label: "Books read")
                .padding(.trailing, 14)
            Rule(.vertical).frame(height: 52)
            StatColumn(value: "\(library.readingList.count)", unit: nil, label: "In progress")
                .padding(.horizontal, 14)
            Rule(.vertical).frame(height: 52)
            StatColumn(value: "\(library.totalPagesRead)", unit: "PP", label: "Pages")
                .padding(.leading, 14)
        }
        .block(padding: 16)
    }

    // MARK: Goal

    private var goalBlock: some View {
        HStack(spacing: 18) {
            DialView(progress: library.goalProgress, caption: "%")
                .frame(width: 88, height: 88)

            VStack(alignment: .leading, spacing: 8) {
                Text("Monthly goal").microLabel(Ink.ink)
                Text("\(library.completedIDs.count) of \(library.preferences.monthlyGoal) books")
                    .font(Typo.condensed(15, .bold))
                    .foregroundStyle(Ink.ink)
                Text("Set your target in Settings, adjust it any time.")
                    .font(Typo.body(12))
                    .foregroundStyle(Ink.mute)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .block(padding: 16)
    }

    // MARK: Genre breakdown

    private var genreBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(index: "G", title: "By genre")

            let breakdown = library.genreBreakdown()
            if breakdown.isEmpty {
                EmptyNote(text: "Finish a book to see a breakdown here.")
                    .padding(.vertical, 20)
            } else {
                let total = max(breakdown.reduce(0) { $0 + $1.count }, 1)
                VStack(spacing: 12) {
                    ForEach(breakdown) { entry in
                        HStack(spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: entry.genre.symbol)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(Ink.mute)
                                Text(entry.genre.rawValue.uppercased())
                                    .font(Typo.condensed(12, .bold))
                                    .foregroundStyle(Ink.ink)
                            }
                            .frame(width: 116, alignment: .leading)

                            ProgressLine(value: Double(entry.count) / Double(total))

                            Text("\(entry.count)")
                                .font(Typo.mono(12, .bold))
                                .foregroundStyle(Ink.ink)
                                .monospacedDigit()
                        }
                    }
                }
                .block(padding: 16)
            }
        }
    }

    // MARK: History

    @ViewBuilder
    private var readingHistory: some View {
        if !library.completedBooks.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeading(index: "H", title: "Recently completed")
                VStack(spacing: 0) {
                    Rule(color: Ink.ink.opacity(0.35))
                    ForEach(library.completedBooks) { book in
                        HStack(spacing: 12) {
                            BookCoverView(book: book, width: 44)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(book.title)
                                    .font(Typo.condensed(14, .bold))
                                    .foregroundStyle(Ink.ink)
                                Text(book.author)
                                    .font(Typo.body(11))
                                    .foregroundStyle(Ink.mute)
                            }
                            Spacer(minLength: 0)
                            Text("\(book.pages) PP")
                                .font(Typo.mono(9, .bold))
                                .foregroundStyle(Ink.mute)
                        }
                        .padding(.vertical, 12)
                        Rule()
                    }
                }
            }
        }
    }
}

// MARK: - Initials plate

struct InitialsPlate: View {
    let initials: String
    var accent: Bool = false
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(accent ? Ink.lime : Ink.surface)
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(Ink.ink.opacity(accent ? 0.9 : 0.35), lineWidth: 1)
            Text(initials)
                .font(Typo.display(size * 0.42))
                .foregroundStyle(accent ? Ink.onLime : Ink.ink)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ProfileView().environmentObject(LibraryModel())
}
