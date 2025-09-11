# 📦 BookletPDFKit Package Structure

**Swift Package for PDF Booklet Creation**

---

## 📁 Directory Structure

```
BookletPDFKit/
├── 📦 Package.swift                           # Swift Package Manager manifest
├── 🧪 Tests/
│   └── BookletPDFKitTests/
│       └── BookletPDFKitTests.swift          # Unit test suite
└── 📚 Sources/
    └── BookletPDFKit/
        ├── 📄 BookletPDFKit.swift             # Package entry point (minimal)
        ├── 🎯 UseCase/                        # Core business logic
        │   ├── TwoInOnePdfGeneratorUseCaseImpl.swift    # 2-in-1 booklet generator
        │   ├── FourInOneGeneratorUseCaseImpl.swift      # 4-in-1 booklet generator
        │   └── DublicateFileUseCase.swift               # File duplication utilities
        ├── 🛠️ Utils/                          # Shared utilities
        │   ├── BooketUtils.swift              # BookletType enum & utilities
        │   └── Theme.swift                    # Design system constants
        ├── 🖼️ Image/                          # Cross-platform image handling
        │   └── FImage.swift                   # Image wrapper with platform support
        └── 🔧 Extensions/                     # Type extensions
            ├── Color+Extensions.swift         # Color utilities
            ├── Image+Extensions.swift         # Image processing
            ├── PDFDocument+Extensions.swift   # PDF manipulation & Transferable
            ├── ProcessInfo+Extensions.swift   # System information
            ├── String+Extensions.swift        # String utilities
            ├── ToolbarItem+.swift            # Toolbar customization
            └── View+Extensions.swift         # SwiftUI view helpers
```

---

## 🎯 Core Components

### Package Configuration
| File | Purpose | Dependencies |
|------|---------|--------------|
| `Package.swift` | SPM manifest, platform requirements | Swift 6.0+ |
| `BookletPDFKit.swift` | Package entry point | Foundation |

### Use Cases (Business Logic)
| Component | Purpose | Key Features |
|-----------|---------|--------------|
| `TwoInOnePdfGeneratorUseCaseImpl` | Standard booklet creation | Page reordering, padding, async processing |
| `FourInOneGeneratorUseCaseImpl` | Advanced 4-page layout | Complex page arrangement, cross-platform image generation |
| `DublicateFileUseCase` | File management | File operations and utilities |

### Utilities & Configuration
| Component | Purpose | Exports |
|-----------|---------|---------|
| `BooketUtils.swift` | Core enums | `BookletType` enum (type2, type4) |
| `Theme.swift` | Design system | Color constants, UI styling |

### Cross-Platform Support
| Component | Purpose | Platform Support |
|-----------|---------|------------------|
| `FImage.swift` | Image abstraction | iOS (UIKit) + macOS (AppKit) |

---

## 🔧 Extensions Catalog

### PDF & Document Extensions
| Extension | Purpose | Key Methods |
|-----------|---------|-------------|
| `PDFDocument+Extensions` | PDF manipulation | `addBlankPages(count:)`, `Transferable` conformance |

### UI & View Extensions
| Extension | Purpose | Platform |
|-----------|---------|----------|
| `Color+Extensions` | Color utilities | Universal |
| `Image+Extensions` | Image processing | Universal |
| `View+Extensions` | SwiftUI helpers | Universal |
| `ToolbarItem+` | Toolbar customization | Universal |

### System Extensions
| Extension | Purpose | Use Case |
|-----------|---------|----------|
| `ProcessInfo+Extensions` | System information | Platform detection, capabilities |
| `String+Extensions` | String utilities | File handling, text processing |

---

## 📊 Dependency Graph

```
BookletPDFKit (Package Root)
├── Foundation (System)
├── PDFKit (System)
├── SwiftUI (System)
├── UIKit (iOS only)
└── AppKit (macOS only)

Internal Dependencies:
BookletPDFGeneratorUseCase (Protocol)
├── TwoInOnePdfGeneratorUseCaseImpl
└── FourInOneGeneratorUseCaseImpl

Cross-Platform:
FImage
├── UIKit extension (iOS)
└── AppKit extension (macOS)
```

---

## 🎯 API Surface

### Public Protocols
```swift
// Core abstraction
public protocol BookletPDFGeneratorUseCase: Sendable
public protocol FImageProtocol

// Protocol Implementations
public struct TwoInOnePdfGeneratorUseCaseImpl: BookletPDFGeneratorUseCase
public final class FourInOneGeneratorUseCaseImpl: BookletPDFGeneratorUseCase
```

### Public Enums
```swift
public enum BookletType {
    case type2    // 2 pages per sheet
    case type4    // 4 pages per sheet  
}

public enum Theme {
    public enum Colors { /* Design constants */ }
}
```

### Public Structures
```swift
public struct FImage {
    public init?(data: Data? = nil)
}
```

---

## 🧪 Testing Structure

### Test Organization
```
Tests/BookletPDFKitTests/
└── BookletPDFKitTests.swift    # Main test suite
```

### Test Coverage Areas
- ✅ PDF generation use cases
- ✅ Booklet type handling
- ✅ Cross-platform image support
- ✅ File management operations

---

## 🚀 Platform Strategy

### Cross-Platform Code Sharing
- **100% Shared**: Use cases, utilities, protocols
- **Platform-Specific**: Image rendering, UI components
- **Conditional Compilation**: `#if canImport(UIKit/AppKit)`

### Platform-Specific Features
```swift
// iOS-specific
#if canImport(UIKit)
import UIKit
typealias OSImage = UIImage
// UIGraphicsImageRenderer usage
#endif

// macOS-specific  
#if canImport(AppKit)
import AppKit
typealias OSImage = NSImage
// NSImage.lockFocus() usage
#endif
```

---

## 📋 Code Organization Patterns

### Naming Conventions
| Pattern | Purpose | Example |
|---------|---------|---------|
| `[Feature]UseCase` | Protocol definitions | `BookletPDFGeneratorUseCase` |
| `[Feature]UseCaseImpl` | Implementation classes | `TwoInOnePdfGeneratorUseCaseImpl` |
| `[Type]+Extensions` | Type extensions | `PDFDocument+Extensions` |
| `[Feature]Utils` | Utility collections | `BooketUtils` |

### File Organization
- **Feature-Based**: Related functionality grouped together
- **Layer Separation**: Clean boundaries between use cases, utils, extensions
- **Platform Isolation**: Platform-specific code clearly marked

---

## ⚡ Performance Characteristics

### Use Case Performance
| Component | Complexity | Memory Usage | Threading |
|-----------|------------|--------------|-----------|
| `TwoInOnePdfGeneratorUseCaseImpl` | O(n) | Single PDF | Background queue |
| `FourInOneGeneratorUseCaseImpl` | O(n) | All pages + images | Background queue |

### Optimization Features
- ✅ `autoreleasepool` for memory management
- ✅ Background queue processing
- ✅ Automatic file cleanup
- ✅ Sendable protocol compliance

---

## 🔗 Integration Points

### App Integration
```swift
// From main app
import BookletPDFKit

// Usage
let generator = TwoInOnePdfGeneratorUseCaseImpl()
generator.makeBookletPDF(url: pdfURL) { result in
    // Handle result
}
```

### Dependency Injection
```swift
// Protocol-based dependency injection
class DocumentProcessor {
    private let generator: BookletPDFGeneratorUseCase
    
    init(generator: BookletPDFGeneratorUseCase) {
        self.generator = generator
    }
}
```

---

## 🚨 Design Decisions

### Architecture Choices
1. **Protocol-Oriented**: Enables testability and flexibility
2. **Struct vs Class**: Structs for stateless operations, classes for complex state
3. **Async Callbacks**: Completion handlers over async/await for broader compatibility
4. **Cross-Platform**: Shared business logic with platform-specific rendering

### File Organization Rationale
1. **UseCase Separation**: Clear business logic boundaries
2. **Extension Grouping**: Related extensions in dedicated directory
3. **Utility Isolation**: Shared utilities in separate namespace
4. **Test Mirroring**: Test structure mirrors source structure

---

**Package Maintainer**: SBD LLC  
**Swift Version**: 6.0+  
**Last Updated**: 2025-09-11