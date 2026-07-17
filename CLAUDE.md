# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Meletao is a native macOS SwiftUI app (target: macOS 15.5+) for memorizing poems, book excerpts, speeches, and other text via spaced repetition. Single Xcode project, no external package dependencies (no SPM/CocoaPods/Carthage) — just system frameworks (SwiftUI, CoreData, UserNotifications, EventKit, AppKit).

Bundle ID: `Reflective-Technologies.Meletao`. This directory (`Meletao/`) is the git repo root — the parent folder is not part of the repo.

## Commands

Build (from `Meletao/`, the directory containing `Meletao.xcodeproj`):
```
xcodebuild -project Meletao.xcodeproj -scheme Meletao -configuration Debug -destination 'platform=macOS' build
```

Run tests (`MeletaoTests` uses the new Swift `Testing` framework with `@Test`, not XCTest; `MeletaoUITests` is XCUITest):
```
xcodebuild -project Meletao.xcodeproj -scheme Meletao -destination 'platform=macOS' test
```
To run a single test, add `-only-testing:MeletaoTests/MeletaoTests/example` (adjust suite/test name).

There's a `buildServer.json` (xcode-build-server) and `.vscode/settings.json` (sweetpad) — this project is also edited/built from VS Code via SweetPad, not just Xcode.app.

Launching the built app after a build:
```
open /Users/bukayoodedele/Library/Developer/Xcode/DerivedData/Meletao-*/Build/Products/Debug/Meletao.app
```

There is no lint configuration (no SwiftLint/SwiftFormat config files) in the repo.

## Architecture

**Persistence**: Core Data, single model `DataModel.xcdatamodeld` with three entities: `Poem` (root object), `PoemSection` (a poem split into memorization chunks, cascade-deletes with its poem), `MemorizationSession` (one per completed review, cascade-deletes with its poem). `Persistence.swift` sets up `PersistenceController.shared` with automatic lightweight migration and `automaticallyMergesChangesFromParent = true`; the entity classes in `Models/` are hand-written (not codegen'd), each declaring `@NSManaged` properties directly rather than a separate `+CoreDataProperties` file.

**Important Core Data/SwiftUI gotcha**: Model `id` fields are non-optional `UUID` (`@NSManaged public var id: UUID`). Reading `.id` (or any non-optional `@NSManaged` attribute) on an object that has just been deleted+saved will crash, because Core Data turns it into a fault and the generated accessor force-bridges `nil` into the non-optional type. Any `ForEach` over Core Data objects should key on `\.objectID` (safe even on faulted/deleted objects), not `\.id` or other modeled attributes — see `LibraryView.swift` and `CatalogView.swift`. Similarly, defer `context.delete(...)` + `context.save()` off the current call stack (`DispatchQueue.main.async`) when it's triggered from inside a SwiftUI `.alert`/sheet dismissal, since AppKit forces a synchronous layout pass mid-dismissal that can touch the about-to-be-invalidated object.

**Navigation**: `ContentView` hosts a custom tab bar (not `TabView`) switching between `CatalogView` / `LibraryView` / `ReviewView`, wrapped in one `NavigationStack`. Programmatic push (e.g. into `MemorizationView` or `PoemNotesBeforeReviewView`) goes through `NavigationCoordinator` (`@EnvironmentObject`, holds the shared `NavigationPath`), using `.navigationDestination(for:)` on two types: `Poem` and the wrapper `PoemForNotesReview`.

**Poem lifecycle / screens**:
- `CatalogView` — browsable list of all poems (`isInCatalog: true` on `PoemCard`); "Add to Library" sets `isInLibrary = true`.
- `LibraryView` — `@FetchRequest` filtered to `isInLibrary == true`; `PoemCard` here exposes "Remove from Library" (just flips `isInLibrary`) and "Delete Permanently" (actually deletes the Core Data object — see the gotcha above).
- `AddPoemView` — create or edit (`poemToEdit`) a poem; on save, calls `TextSectioningService` to (re)generate `PoemSection`s.
- `PoemNotesBeforeReviewView` — shown before memorization if the poem has notes.
- `MemorizationView` — the actual study flow, section-by-section, progressing through 5 fill-in-the-blank "stages" (`stages` array) of increasing difficulty; on completion calls `SpacedRepetitionService.scheduleNextReview` to create a `MemorizationSession`.
- `ReviewView` — poems due today, loaded via `SpacedRepetitionService.getPoemsForReview`.

**Services/** (all singletons, `.shared`):
- `TextSectioningService` — splits a poem's `fullText` into `PoemSection`s sized by word count (bigger poems get bigger sections, up to a cap), using ICU sentence-boundary detection to avoid splitting mid-sentence.
- `SpacedRepetitionService` — fixed interval ladder (1 day → 3 months) per poem, advanced on each completed session; missed/overdue reviews shrink the next interval (steeper decay the more days missed, floor of 30% of the base interval).
- `NotificationService` — schedules local notifications grouped by calendar day (one notification per day, not per poem) plus escalating overdue reminders, updates the dock badge count, and debounces rescheduling (1s `DispatchWorkItem`) since multiple Core Data saves can trigger it in quick succession.
- `CalendarService` — adds upcoming review dates to the system Calendar via EventKit.

Both `Poem` (`shouldReview`, `nextReviewDate`, `tagsArray`, `sectionsArray`) and its relationships expose computed convenience properties as extensions in `Models/`, rather than storing derived data.

`ColorScheme.swift` defines the app's palette twice: asset-catalog-backed `Color.meletao*` and a parallel set of `Color.staticMeletao*` built from `NSColor(dynamicProvider:)` for cases needing an explicit light/dark branch (e.g. text color against a colored button background) that the asset catalog approach doesn't cover well in this codebase.
