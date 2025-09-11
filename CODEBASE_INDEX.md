# PDF Booklet Maker - Codebase Index

**Project Overview**: Cross-platform (macOS/iOS) PDF booklet creation utility built with SwiftUI and a custom PDF processing library.

## 📱 Project Structure

```
bookletpdf/
├── 📱 bookletPdf/                    # Main application
│   ├── 🚀 bookletPdfApp.swift        # App entry point & configuration
│   ├── 💾 Cache/                     # Caching system
│   ├── 🛠️ Utils/                     # Utilities & services
│   └── 🎨 Views/                     # SwiftUI interface
├── 📦 BookletPDFKit/                 # Core PDF processing library
│   ├── 🔧 Sources/BookletPDFKit/     # Library implementation
│   └── 🧪 Tests/                     # Unit tests
└── 🏗️ bookletPdf.xcodeproj/          # Xcode project
```

---

## 🏗️ Architecture Overview

### Core Modules

| Module | Purpose | Platform Support |
|--------|---------|------------------|
| **BookletPDFKit** | PDF processing & transformation | macOS 15+, iOS 16+ |
| **bookletPdf** | SwiftUI application layer | macOS 12+, iOS 16+ |

### Design Patterns
- **MVVM**: View-ViewModel architecture with ObservableObject
- **Protocol-Oriented**: Dependency injection via protocols
- **Clean Architecture**: Use cases separate from UI concerns

---

## 📦 BookletPDFKit Library

### 🎯 Core Protocols

| Protocol | Location | Purpose |
|----------|----------|---------|
| `BookletPDFGeneratorUseCase` | UseCase/TwoInOnePdfGeneratorUseCaseImpl.swift:11 | PDF generation contract |
| `FImageProtocol` | Image/FImage.swift:19 | Cross-platform image handling |
| `DublicateFileUseCase` | UseCase/DublicateFileUseCase.swift:10 | File duplication operations |

### ⚙️ Use Cases

| Class | Purpose | Implementation |
|-------|---------|----------------|
| `TwoInOnePdfGeneratorUseCaseImpl` | 2-page booklet generation | Core PDF layout algorithm |
| `FourInOneGeneratorUseCaseImpl` | 4-page booklet generation | Advanced page arrangement |
| `DublicateFileUseCaseImpl` | File management operations | Document handling utilities |

### 🎨 Utilities

| Component | Purpose | Features |
|-----------|---------|----------|
| `Theme` | Design system | Colors, styling constants |
| `BooketUtils` | PDF operations | BookletType enum, utilities |
| `FImage` | Image handling | Cross-platform image wrapper |

### 🔧 Extensions

| Extension | Platform | Purpose |
|-----------|----------|---------|
| `Color+Extensions` | Universal | Color utilities |
| `Image+Extensions` | Universal | Image processing |
| `PDFDocument+Extensions` | Universal | PDF manipulation |
| `View+Extensions` | SwiftUI | UI helpers |
| `String+Extensions` | Universal | String utilities |
| `ProcessInfo+Extensions` | Universal | System info |
| `ToolbarItem+` | Universal | Toolbar customization |

---

## 📱 Application Layer

### 🎯 Core Architecture

| Component | Type | Purpose |
|-----------|------|---------|
| `bookletPdfApp` | App | Main application entry point |
| `AppDelegate` | NSObject | Platform-specific setup |
| `ContentView` | View | Root UI container |

### 🧠 ViewModels

| ViewModel | Purpose | State Management |
|-----------|---------|------------------|
| `DocumentConvertViewModel` | PDF processing workflow | `@StateObject` main state |
| `SettingsViewModel` | App preferences | User configuration |
| `PDFThumbnailViewModel` | PDF preview system | Thumbnail generation |

### 🎨 Views & Components

#### Main Interface
| Component | Purpose | Platform |
|-----------|---------|----------|
| `DocumentConvertView` | Primary conversion UI | Universal |
| `LoadingView` | Progress indication | Universal |
| `PrintButton` | Printing workflow | Universal |

#### PDF Viewing System
| Component | Purpose | Features |
|-----------|---------|----------|
| `PDFViewer` (Custom) | PDF display | Custom implementation |
| `PDFViewerView` (Native) | System PDF viewer | Native integration |
| `PDFPageView` | Individual page display | Page rendering |
| `PDFPageThumbnail` | Thumbnail generation | Preview system |
| `PagePreview` | Page preview UI | User interface |

#### Navigation & Settings
| Component | Purpose | Features |
|-----------|---------|----------|
| `SideBarView` | Navigation menu | MenuOption enum |
| `SettingsView` | Configuration UI | App preferences |
| `InfoView` | About/info display | Cross-platform web view |

### 🛠️ Utilities & Services

| Service | Purpose | Features |
|---------|---------|----------|
| `PrinterService` | Print management | Cross-platform printing |
| `AppCache` | Performance optimization | Document caching |
| `AppMenuCommand` | Menu system | Application commands |

---

## 🗂️ Key Enumerations

| Enum | Location | Purpose |
|------|----------|---------|
| `BookletType` | BookletPDFKit/Utils/BooketUtils.swift:10 | PDF layout options |
| `ContentViewState` | Views/Main/DocumentConvertView.swift:13 | UI state management |
| `MenuOption` | Views/Sidebar/SideBarView.swift:11 | Navigation options |
| `Theme.Colors` | BookletPDFKit/Utils/Theme.swift:12 | Design system colors |

---

## 🔄 Data Flow

```
User Input → DocumentConvertViewModel → BookletPDFKit Use Cases → PDF Output
     ↓              ↓                           ↓                    ↓
  UI Events    State Management          Core Processing        File System
```

### Processing Pipeline
1. **Import**: User selects PDF via DocumentConvertView
2. **Configuration**: BookletType selection (2-in-1 or 4-in-1)
3. **Processing**: Use case implementations handle PDF transformation
4. **Preview**: Custom PDF viewer displays results
5. **Output**: PrinterService handles printing/saving

---

## 🧪 Testing Structure

| Test Suite | Coverage | Purpose |
|------------|----------|---------|
| `BookletPDFKitTests` | Core library | Unit testing for PDF operations |

---

## 🎯 Cross-Platform Strategy

### Platform Differentiation
```swift
#if os(macOS)
    // macOS-specific implementations
#endif

#if os(iOS)
    // iOS-specific implementations  
#endif
```

### Shared Components
- **BookletPDFKit**: 100% shared PDF processing
- **Core Views**: SwiftUI enables high code reuse
- **ViewModels**: Shared business logic across platforms

---

## 📋 File Organization Patterns

### Naming Conventions
- **Views**: `[Component]View.swift`
- **ViewModels**: `[Component]ViewModel.swift`
- **Use Cases**: `[Function]UseCaseImpl.swift`
- **Extensions**: `[Type]+Extensions.swift`

### Folder Structure
- **Feature-based**: Views organized by functionality
- **Layer separation**: Clear boundaries between UI, business logic, and data
- **Platform-specific**: Conditional compilation for platform differences

---

## 🚀 Key Features Implementation

| Feature | Implementation | Components |
|---------|----------------|------------|
| **2-in-1 Booklets** | TwoInOnePdfGeneratorUseCaseImpl | PDF page rearrangement |
| **4-in-1 Booklets** | FourInOneGeneratorUseCaseImpl | Advanced page layout |
| **PDF Preview** | Custom PDFViewer + PDFPageThumbnail | Thumbnail system |
| **Cross-Platform UI** | SwiftUI + conditional compilation | Universal components |
| **Print Integration** | PrinterService + platform-specific | Native print dialogs |
| **Performance** | AppCache + efficient rendering | Caching system |

---

## 📄 Documentation Status

| Component | Documentation | Status |
|-----------|---------------|--------|
| README.md | ✅ Complete | User-facing documentation |
| Code Comments | ⚠️ Partial | Inline documentation present |
| API Documentation | ❌ Missing | Needs comprehensive API docs |
| Architecture Guide | ❌ Missing | This document serves as foundation |

---

**Generated**: 2025-09-11  
**Framework**: SwiftUI, Swift Package Manager  
**Platforms**: macOS 15+, iOS 16+  
**Architecture**: MVVM + Clean Architecture + Protocol-Oriented Design