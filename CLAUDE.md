# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PDF Booklet Maker is a cross-platform (macOS/iOS) SwiftUI application that converts standard PDF documents into printable booklet formats. The app supports 2-in-1 and 4-in-1 page arrangements with preview capabilities.

## Architecture

### Core Components
- **BookletPDFKit**: Swift Package containing PDF conversion logic and utilities
- **bookletPdf**: Main SwiftUI application with platform-specific UI implementations
- **DocumentConvertViewModel**: Central state management for PDF conversion workflow

### Key Patterns
- **Use Case Pattern**: PDF generation implemented via `BookletPDFGeneratorUseCase` protocol
- **Platform Abstraction**: Separate iOS/macOS view implementations using conditional compilation
- **MVVM Architecture**: ViewModels handle business logic, Views handle presentation
- **Dependency Injection**: Environment objects pass shared state through view hierarchy

### PDF Generation Pipeline
1. Import PDF via file picker
2. Duplicate file to temporary location (`DublicateFileUseCase`)
3. Select booklet type (2-in-1 or 4-in-1)
4. Generate booklet using appropriate use case implementation
5. Display preview with thumbnail grid
6. Export or print final booklet

## Build Commands

### Xcode Project
```bash
# Open project
open bookletPdf.xcodeproj

# Build via command line
xcodebuild -project bookletPdf.xcodeproj -scheme bookletPdf -configuration Release
```

### Swift Package (BookletPDFKit)
```bash
# Build package
cd BookletPDFKit
swift build

# Run tests
swift test
```

### Testing
Tests use Swift Testing framework (`@Test` annotations). Run tests via:
- Xcode: Cmd+U
- Command line: `swift test` (in BookletPDFKit directory)

## Project Structure

### BookletPDFKit Package
- `Sources/BookletPDFKit/UseCase/`: PDF conversion algorithms
- `Sources/BookletPDFKit/Extensions/`: Platform extensions and utilities
- `Sources/BookletPDFKit/Utils/`: Shared utilities and themes

### Main App (bookletPdf)
- `Views/Main/`: Core conversion UI and PDF viewer
- `Views/Sidebar/`: Navigation sidebar with menu options
- `Views/Settings/`: Application preferences
- `Cache/`: Application state caching
- `Utils/`: App-specific utilities and services

## Development Notes

### Platform Considerations
- Uses conditional compilation (`#if os(macOS)`) for platform-specific code
- Image handling differs between UIKit (`UIImage`) and AppKit (`NSImage`)
- Navigation patterns adapted for each platform (NavigationSplitView)

### PDF Processing
- Uses PDFKit for document manipulation
- Memory management with `autoreleasepool` for large documents
- Background processing for conversion operations
- Temporary file management for converted documents

### State Management
- `ContentViewState` enum tracks conversion workflow stages
- `BookletType` enum defines available conversion types
- Observable objects propagate state changes through UI hierarchy