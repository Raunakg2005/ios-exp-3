# Book Library — Experiment 03

SwiftUI application for **Semester VII · Mobile Application Development**.
Built for Xcode 26, iOS 18.0+, iPhone and iPad.

```bash
open "exp 3/exp 3.xcodeproj"
```

Press ⌘R. No dependencies, no package resolution, nothing to install.

---

## What the experiment is about

The brief asks for a real demonstration of SwiftUI's reactive data flow using
the four property wrappers `@StateObject`, `@ObservedObject`,
`@EnvironmentObject` and `@Environment`. The application matches the shape of
the data-flow diagram in the manual:

```
                LibraryModel  (ObservableObject)
                ┌────────────────────────────┐
                │ favoriteBooks              │
                │ readingList                │
                │ completedBooks             │
                │ preferences                │
                │ userName                   │
                └───────────────┬────────────┘
                                │  @EnvironmentObject
       ┌────────────┬───────────┼───────────┬────────────┐
       ▼            ▼           ▼           ▼            ▼
   HomeView   BookListView  BookDetail  MyLibrary    Profile / Settings
```

- **`@StateObject`** — `exp_3App` owns exactly one `LibraryModel`. Only place
  the object is created.
- **`.environmentObject`** — `RootView` places that instance in the
  environment.
- **`@EnvironmentObject`** — every screen reads and mutates it. Toggling a
  favourite in the catalogue changes the dashboard counter, the "My library"
  shelf and the profile statistics instantly, without any of those views
  knowing about each other.
- **`@Environment`** — used to read the system colour scheme, the current
  locale, the dynamic-type size and `dismiss()`. Settings then writes to
  `library.preferences.appearance` and `library.preferences.textScale`, and
  `RootView` applies them with `.preferredColorScheme` and
  `.dynamicTypeSize`, re-rendering the whole application at once.

`@ObservedObject` is deliberately not used: with a single shared model, it
would be the wrong tool. The write-up covers this.

---

## Screens

Five tabs, each with its own `NavigationStack`.

**Home / Dashboard** — greeting from `library.userName`, three live counters
(favourites, reading list, completed), "Continue reading" that jumps back to
whichever book is furthest along, four shelf tiles, a horizontal recommender
scroller that follows the favourite genre chosen in Settings.

**Book catalogue** — every book in the library, adaptive grid, search over
title / author / ISBN, filter by genre, sort by title / author / rating / year.

**Book detail** — an inverted plate header with a generated cover, three
action buttons (favourite, reading list, completed), a progress `Slider` that
writes pages read straight into the model, a preview `.sheet` that uses
`@Environment(\.dismiss)` to close itself.

**My library** — segmented picker across Reading / Favourites / Completed.
The reading list is a `List` with swipe-to-remove and long-press-to-reorder.

**Profile** — the reader's name, statistics derived from the model, a monthly
goal dial, a genre breakdown of completed reads, a recently-completed timeline.

**Settings** — appearance (System / Light / Dark), text size (Compact /
Standard / Large), monthly goal `Stepper`, favourite-genre `Picker`, a toggle
for book covers, a read-only mirror of the system values coming out of
`@Environment`, and two reset buttons.

---

## Covers

Every book cover is **drawn**, not photographed. `BookCoverView` reads the
book's ISBN as a seed, picks one of six layouts and lays out title, author,
shelf mark and genre in the house style — so the app ships with zero image
assets and no missing-image state. Turning off "Show book covers" in Settings
switches the whole app to spine plates instead.

---

## Design

Same design system as [Experiment 1](https://github.com/Raunakg2005/ios-exp-1)
and [Experiment 2](https://github.com/Raunakg2005/ios-exp-2): paper, ink and
one electric lime accent, hairline rules instead of shadows, heavy display
type, 10pt letterspaced caps for every label and monospace for anything that
reads as data.

---

## Experiment checklist

| Requirement | Where |
|---|---|
| `@StateObject` | `exp_3App` — one instance of `LibraryModel` |
| `@EnvironmentObject` | Every feature view reads `library` this way |
| `@Environment` | Colour scheme, locale, dynamic type, `dismiss` |
| Reactive updates | Counters on Home reflect writes from any tab, live |
| `NavigationStack` | One per tab; catalogue pushes `BookDetailView` |
| `TabView` | `RootView` with five peers |
| Search and filter | `BookListView` calls `LibraryModel.search` |
| Favourites and reading list | Model methods, called from the detail screen |
| Preferences | Encoded to `UserDefaults` on every write |
| Adaptive layouts | `LazyVGrid(.adaptive)` for the catalogue, library shelves and dashboard tiles |
| Animations | Counters use `contentTransition(.numericText())`; results animate on filter change |
| HIG | System type scale, 44pt targets, dynamic light/dark, haptics, standard tab / push / sheet |

---

## Making it yours

The catalogue lives in `exp 3/exp 3/Model/LibraryData.swift` — 14 real books
with genuine ISBNs. Swap in your own list, and every screen reflects the
change on next launch. The greeting name is editable in the app itself, on
the Profile tab, and is persisted to `UserDefaults`.

---

## Layout

```
exp 3/exp 3/
├── exp_3App.swift             @main — creates the LibraryModel
├── Design/                    palette, typography, components, shapes
├── Model/
│   ├── Book.swift             Book, Genre, Preferences
│   ├── LibraryModel.swift     ObservableObject, the source of truth
│   └── LibraryData.swift      ← edit this
└── Features/
    ├── RootView.swift         TabView, applies preferences to whole app
    ├── HomeView.swift
    ├── BookListView.swift     catalogue
    ├── BookDetailView.swift
    ├── MyLibraryView.swift    reading / favourites / completed
    ├── ProfileView.swift
    ├── SettingsView.swift
    ├── BookCoverView.swift    drawn covers, house style
    └── TickerView.swift       notice marquee
```

The project uses a file-system synchronized group, so any file added inside
`exp 3/exp 3/` joins the target automatically — no `.pbxproj` edits.
