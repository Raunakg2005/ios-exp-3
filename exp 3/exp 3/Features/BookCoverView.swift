//
//  BookCoverView.swift
//  exp 3
//
//  Covers are drawn, not photographed. Each one is generated from the book's
//  ISBN, so a given title always gets the same cover, and the application
//  ships with no image assets at all.
//
//  Six layouts are cycled through by the seed, in the house style: ink,
//  paper and one lime accent.
//

import SwiftUI

struct BookCoverView: View {
    let book: Book
    var width: CGFloat = 92

    /// Settings can turn covers off entirely; then a spine plate is drawn.
    @EnvironmentObject private var library: LibraryModel

    private var height: CGFloat { width * 1.5 }

    var body: some View {
        Group {
            if library.preferences.showCovers {
                cover
            } else {
                spinePlate
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .strokeBorder(Ink.ink.opacity(0.35), lineWidth: 1)
        }
        .overlay(alignment: .leading) {
            // The spine: every printed cover has one.
            Rectangle()
                .fill(Ink.ink.opacity(0.18))
                .frame(width: 1)
                .padding(.leading, width * 0.09)
        }
    }

    // MARK: Drawn cover

    private var cover: some View {
        ZStack(alignment: .topLeading) {
            background

            VStack(alignment: .leading, spacing: 0) {
                Text(book.genre.mark)
                    .font(Typo.mono(7, .bold))
                    .tracking(0.8)
                    .foregroundStyle(isInverted ? Ink.paper.opacity(0.7) : Ink.mute)

                Spacer(minLength: 4)

                Text(book.title.uppercased())
                    .font(Typo.display(width * 0.15))
                    .tracking(-0.3)
                    .foregroundStyle(isInverted ? Ink.paper : Ink.ink)
                    .lineLimit(4)
                    .minimumScaleFactor(0.5)
                    .fixedSize(horizontal: false, vertical: true)

                Rectangle()
                    .fill(Ink.lime)
                    .frame(width: width * 0.34, height: 3)
                    .padding(.top, 6)

                Text(book.author.uppercased())
                    .font(Typo.mono(width * 0.062, .bold))
                    .foregroundStyle(isInverted ? Ink.paper.opacity(0.75) : Ink.mute)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .padding(.top, 6)
            }
            .padding(.horizontal, width * 0.15)
            .padding(.vertical, width * 0.11)
        }
    }

    private var isInverted: Bool { book.coverSeed % 3 == 1 }

    @ViewBuilder
    private var background: some View {
        switch book.coverSeed {
        case 0:
            Ink.surface
            WaveLines(lines: 14, amplitude: 5, cycles: 1.8)
                .stroke(Ink.ink.opacity(0.10), lineWidth: 0.6)
        case 1:
            Ink.reverse
            WaveLines(lines: 20, amplitude: 6, cycles: 2.4)
                .stroke(Ink.lime.opacity(0.22), lineWidth: 0.6)
        case 2:
            Ink.surface
            VStack(spacing: 0) {
                Ink.lime.frame(height: height * 0.18)
                Spacer(minLength: 0)
            }
        case 3:
            Ink.surface
            Circle()
                .strokeBorder(Ink.ink.opacity(0.12), lineWidth: 14)
                .frame(width: width * 1.1, height: width * 1.1)
                .offset(x: width * 0.42, y: height * 0.36)
        case 4:
            Ink.reverse
            VStack(spacing: height * 0.055) {
                ForEach(0..<7, id: \.self) { _ in
                    Rectangle().fill(Ink.paper.opacity(0.10)).frame(height: 1)
                }
            }
            .padding(.top, height * 0.42)
        default:
            Ink.surface
            Rectangle()
                .fill(Ink.lime)
                .frame(width: 5)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    // MARK: Covers-off fallback

    private var spinePlate: some View {
        ZStack {
            Ink.surface
            VStack(spacing: 6) {
                Text(book.genre.mark)
                    .font(Typo.mono(9, .bold))
                    .foregroundStyle(Ink.onLime)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Ink.lime)
                Text(book.shelf)
                    .font(Typo.mono(7, .semibold))
                    .foregroundStyle(Ink.mute)
            }
        }
    }
}

// MARK: - Rating

/// Five marks, filled to the rating. Squares rather than stars, to stay
/// inside the house style.
struct RatingMarks: View {
    let rating: Double
    var size: CGFloat = 7

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(Double(index) < rating.rounded() ? Ink.ink : Ink.line)
                    .frame(width: size, height: size)
            }
            Text(String(format: "%.1f", rating))
                .font(Typo.mono(9, .semibold))
                .foregroundStyle(Ink.mute)
                .padding(.leading, 2)
        }
    }
}

#Preview {
    HStack {
        ForEach(Book.catalogue.prefix(4)) { book in
            BookCoverView(book: book, width: 80)
        }
    }
    .padding()
    .background(Ink.paper)
    .environmentObject(LibraryModel())
}
