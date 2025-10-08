# 🧭 Codebase Navigation Guide

Quick reference for navigating the PDF Booklet Maker codebase.

## 🎯 Quick Access

### Entry Points
- **App Launch**: [`bookletPdf/bookletPdfApp.swift:36`](bookletPdf/bookletPdfApp.swift#L36)
- **Main UI**: [`bookletPdf/Views/ContentView.swift:10`](bookletPdf/Views/ContentView.swift#L10)
- **Core Logic**: [`BookletPDFKit/Sources/BookletPDFKit/BookletPDFKit.swift`](BookletPDFKit/Sources/BookletPDFKit/BookletPDFKit.swift)

### Key Features
- **PDF Processing**: [`BookletPDFKit/Sources/BookletPDFKit/UseCase/`](BookletPDFKit/Sources/BookletPDFKit/UseCase/)
- **Main Conversion**: [`bookletPdf/Views/Main/DocumentConvertView.swift:19`](bookletPdf/Views/Main/DocumentConvertView.swift#L19)
- **PDF Viewer**: [`bookletPdf/Views/Main/PDFViewer/`](bookletPdf/Views/Main/PDFViewer/)

---

## 📂 Directory Reference

```
📱 Project Root
├── 🚀 App Layer
│   ├── bookletPdfApp.swift           → App entry point
│   ├── Views/ContentView.swift       → Root UI container
│   └── Cache/AppCache.swift          → Performance caching
├── 🧠 Business Logic
│   ├── Views/Main/ViewModel/         → Core view models
│   ├── Utils/Services/               → App services
│   └── Utils/AppMenuCommand.swift    → Menu system
├── 🎨 User Interface
│   ├── Views/Main/                   → Primary UI components
│   ├── Views/Settings/               → Configuration UI
│   └── Views/Sidebar/                → Navigation UI
└── 📦 Core Library (BookletPDFKit)
    ├── UseCase/                      → PDF processing logic
    ├── Utils/                        → Shared utilities
    ├── Extensions/                   → Type extensions
    └── Image/                        → Image handling
```

---

## 🔍 Component Finder

### By Functionality

#### PDF Processing
| Component | Location | Purpose |
|-----------|----------|---------|
| 2-in-1 Generator | `BookletPDFKit/UseCase/TwoInOnePdfGeneratorUseCaseImpl.swift` | Creates 2-page booklets |
| 4-in-1 Generator | `BookletPDFKit/UseCase/FourInOneGeneratorUseCaseImpl.swift` | Creates 4-page booklets |
| File Management | `BookletPDFKit/UseCase/DublicateFileUseCase.swift` | File operations |

#### User Interface
| Component | Location | Purpose |
|-----------|----------|---------|
| Main Converter | `bookletPdf/Views/Main/DocumentConvertView.swift` | Primary conversion UI |
| PDF Viewer | `bookletPdf/Views/Main/PDFViewer/Custom/PDFViewer.swift` | Custom PDF display |
| Thumbnails | `bookletPdf/Views/Main/PDFViewer/Custom/PDFPageThumbnail/` | PDF preview system |
| Settings | `bookletPdf/Views/Settings/SettingsView.swift` | App configuration |

#### State Management
| Component | Location | Purpose |
|-----------|----------|---------|
| Main ViewModel | `bookletPdf/Views/Main/ViewModel/DocumentConvertViewModel.swift` | Core app state |
| Settings ViewModel | `bookletPdf/Views/Settings/SettingsViewModel.swift` | User preferences |
| Thumbnail ViewModel | `bookletPdf/Views/Main/PDFViewer/Custom/PDFPageThumbnail/PDFPageThumbnailViewModel.swift` | PDF preview state |

### By Platform

#### Cross-Platform Components
```swift
// Universal (iOS + macOS)
BookletPDFKit/                        // Core library
Views/Main/DocumentConvertView.swift   // Main UI
Views/Settings/                        // Configuration
Utils/Services/PrinterService.swift   // Printing
```

#### Platform-Specific Code
```swift
// macOS-specific
#if os(macOS)
    bookletPdfApp.swift:19-25         // macOS app delegate
    Views/InfoView/InfoView.swift:50  // macOS info view
#endif

// iOS-specific  
#if os(iOS)
    bookletPdfApp.swift:27-33         // iOS app delegate
    Views/InfoView/InfoView.swift:22  // iOS info view
#endif
```

---

## 🔗 Cross-References

### Protocol → Implementation
| Protocol | Implementation | Location |
|----------|----------------|----------|
| `BookletPDFGeneratorUseCase` | `TwoInOnePdfGeneratorUseCaseImpl` | `UseCase/TwoInOnePdfGeneratorUseCaseImpl.swift:16` |
| `BookletPDFGeneratorUseCase` | `FourInOneGeneratorUseCaseImpl` | `UseCase/FourInOneGeneratorUseCaseImpl.swift:18` |
| `FImageProtocol` | Platform-specific implementations | `Image/FImage.swift` |
| `PrinterServiceProtocol` | `PrinterService` | `Utils/Services/PrinterService.swift:20` |

### Data Flow Connections
```
DocumentConvertView → DocumentConvertViewModel → BookletPDFGeneratorUseCase → PDF Output
       ↓                      ↓                           ↓                     ↓
   User Input            State Management           Core Processing        File System
```

### View → ViewModel Bindings
| View | ViewModel | Binding |
|------|-----------|---------|
| `DocumentConvertView` | `DocumentConvertViewModel` | `@StateObject` |
| `SettingsView` | `SettingsViewModel` | `@StateObject` |
| `PDFPageThumbnail` | `PDFThumbnailViewModel` | `@StateObject` |

---

## 🛠️ Developer Workflows

### Adding New PDF Processing Feature
1. **Protocol**: Define in `BookletPDFKit/UseCase/`
2. **Implementation**: Create `[Feature]UseCaseImpl.swift`
3. **Integration**: Add to `DocumentConvertViewModel`
4. **UI**: Update `DocumentConvertView` or create new view
5. **Testing**: Add tests in `BookletPDFKitTests/`

### Modifying UI Components
1. **View**: Edit in `bookletPdf/Views/[Section]/`
2. **ViewModel**: Update corresponding ViewModel if needed
3. **State**: Check `DocumentConvertViewModel` for shared state
4. **Platform**: Consider `#if os()` for platform-specific code

### Adding Cross-Platform Features
1. **Core Logic**: Implement in `BookletPDFKit`
2. **UI Abstraction**: Use SwiftUI's cross-platform APIs
3. **Platform Differences**: Use conditional compilation
4. **Testing**: Test on both macOS and iOS

---

## 📊 Architecture Layers

### Layer 1: Presentation (Views)
```
Views/
├── ContentView.swift              → Root container
├── Main/DocumentConvertView.swift → Primary interface
├── Settings/SettingsView.swift    → Configuration
└── Sidebar/SideBarView.swift      → Navigation
```

### Layer 2: Application (ViewModels)
```
ViewModels/
├── DocumentConvertViewModel.swift → Core state
├── SettingsViewModel.swift        → User preferences  
└── PDFThumbnailViewModel.swift    → PDF preview
```

### Layer 3: Domain (Use Cases)
```
BookletPDFKit/UseCase/
├── BookletPDFGeneratorUseCase     → PDF generation contract
├── TwoInOnePdfGeneratorUseCaseImpl → 2-page implementation
└── FourInOneGeneratorUseCaseImpl  → 4-page implementation
```

### Layer 4: Infrastructure (Services)
```
Utils/Services/
├── PrinterService.swift          → Printing operations
└── Cache/AppCache.swift           → Performance optimization
```

---

## 🔍 Search Patterns

### Finding Components by Type
```bash
# All view models
find . -name "*ViewModel.swift"

# All use cases  
find BookletPDFKit -name "*UseCase*.swift"

# All extensions
find . -name "*+*.swift"

# Platform-specific code
grep -r "#if os(" bookletPdf/
```

### Finding by Functionality
```bash
# PDF processing
grep -r "PDF" BookletPDFKit/

# UI components
find bookletPdf/Views -name "*.swift"

# Cross-references
grep -r "BookletPDFGeneratorUseCase" .
```

---

## 📋 File Naming Conventions

| Pattern | Purpose | Example |
|---------|---------|---------|
| `[Component]View.swift` | SwiftUI views | `DocumentConvertView.swift` |
| `[Component]ViewModel.swift` | View models | `SettingsViewModel.swift` |
| `[Feature]UseCaseImpl.swift` | Use case implementations | `TwoInOnePdfGeneratorUseCaseImpl.swift` |
| `[Type]+Extensions.swift` | Type extensions | `PDFDocument+Extensions.swift` |
| `[Component]Service.swift` | Services | `PrinterService.swift` |

---

**Quick Tips:**
- 🔍 Use Xcode's "Open Quickly" (⌘⇧O) with file names
- 📁 Project navigator shows folder structure
- 🔗 Hold ⌘ and click to jump to definitions
- 🔍 Use Find Navigator (⌘⇧F) for project-wide search

**Last Updated**: 2025-09-11