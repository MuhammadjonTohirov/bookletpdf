# 📦 BookletPDFKit API Reference

**Version**: Swift 6.0+  
**Platforms**: macOS 15+, iOS 16+  
**Framework**: Swift Package Manager

---

## 📋 Overview

BookletPDFKit is a cross-platform Swift package for creating PDF booklets from standard PDF documents. It provides two main layout options: 2-in-1 and 4-in-1 page arrangements optimized for printing and folding.

### Package Structure
```
BookletPDFKit/
├── 📦 Package.swift              # Swift Package Manager configuration
├── 🧪 Tests/BookletPDFKitTests/  # Unit tests
└── 📚 Sources/BookletPDFKit/     # Main library code
    ├── 🎯 UseCase/               # Core business logic
    ├── 🛠️ Utils/                 # Utilities and enums
    ├── 🖼️ Image/                 # Cross-platform image handling
    └── 🔧 Extensions/            # Type extensions
```

---

## 🎯 Core Protocols

### BookletPDFGeneratorUseCase

**Location**: `UseCase/TwoInOnePdfGeneratorUseCaseImpl.swift:11`

Primary protocol for PDF booklet generation operations.

```swift
public protocol BookletPDFGeneratorUseCase: Sendable {
    func makeBookletPDF(url: URL, completion: @Sendable @escaping (URL?) -> Void)
}
```

#### Parameters
- `url`: Source PDF file URL
- `completion`: Async callback with result URL (nil on failure)

#### Thread Safety
- ✅ `Sendable` protocol compliance
- ✅ Background queue processing
- ✅ Thread-safe completion callbacks

### FImageProtocol

**Location**: `Image/FImage.swift:19`

Cross-platform image handling abstraction.

```swift
public protocol FImageProtocol {
    // Protocol definition for cross-platform image operations
}
```

---

## 🏭 Use Case Implementations

### TwoInOnePdfGeneratorUseCaseImpl

**Purpose**: Creates 2-page booklet layouts (standard booklet format)

```swift
public struct TwoInOnePdfGeneratorUseCaseImpl: BookletPDFGeneratorUseCase {
    public init() {}
    
    public func makeBookletPDF(url: URL, completion: @Sendable @escaping (URL?) -> Void)
}
```

#### Algorithm
1. **Padding**: Adds blank pages to make total divisible by 4
2. **Reordering**: Arranges pages for booklet printing:
   - Front: `[last, first, last-2, third, ...]`
   - Back: `[second, last-1, fourth, last-3, ...]`
3. **Output**: Saves to Documents directory with `booklet_` prefix

#### Performance
- ✅ Background processing (`DispatchQueue.global(qos: .utility)`)
- ✅ Memory management (`autoreleasepool`)
- ✅ Automatic cleanup of source file

### FourInOneGeneratorUseCaseImpl

**Purpose**: Creates 4-page layouts (advanced booklet format)

```swift
public final class FourInOneGeneratorUseCaseImpl: BookletPDFGeneratorUseCase {
    public init() {}
    
    public func makeBookletPDF(url: URL, completion: @Sendable @escaping (URL?) -> Void)
}
```

#### Algorithm
1. **Collection**: Extracts all pages from source PDF
2. **Padding**: Adds blank pages to make total divisible by 8
3. **Blank Page Generation**: Creates platform-specific white pages
4. **Reordering**: Complex 4-in-1 layout calculation:
   ```swift
   // For each sheet k:
   let fSeq = [h1, l1, h3, l3]  // Front sequence
   let bSeq = [h2, l2, h4, l4]  // Back sequence
   ```
5. **Output**: Saves with `four_in_one_booklet_` prefix

#### Cross-Platform Support
```swift
#if canImport(UIKit)
    // iOS implementation using UIGraphicsImageRenderer
#elseif canImport(AppKit)
    // macOS implementation using NSImage
#endif
```

---

## 🛠️ Utilities

### BookletType Enum

**Location**: `Utils/BooketUtils.swift:10`

Defines available booklet layout types.

```swift
public enum BookletType {
    case type2    // 2 pages per sheet (booklet format)
    case type4    // 4 pages per sheet (4-in-1 format)
}
```

### Theme System

**Location**: `Utils/Theme.swift:11`

Provides design system constants.

```swift
public enum Theme {
    public enum Colors {
        public static let background = Color.gray.opacity(0.05)
    }
}
```

---

## 🖼️ Image Handling

### FImage Structure

**Location**: `Image/FImage.swift:10`

Cross-platform image wrapper with data-based initialization.

```swift
public struct FImage {
    private var _imageData: Data?
    
    public init?(data: Data? = nil)
}
```

#### Platform Extensions
```swift
#if canImport(UIKit)
extension FImage {
    var image: UIImage? { /* iOS implementation */ }
}
#endif

#if canImport(AppKit)
extension FImage {
    var image: NSImage? { /* macOS implementation */ }
}
#endif
```

---

## 🔧 Extensions

### PDFDocument Extensions

**Location**: `Extensions/PDFDocument+Extensions.swift:12`

#### Transferable Support
```swift
extension PDFDocument: @retroactive Transferable {
    public static var transferRepresentation: some TransferRepresentation
}
```

#### Utility Methods
```swift
public func addBlankPages(count: Int) {
    // Adds specified number of blank pages to document
}
```

### Additional Extensions

| Extension | Purpose | Platform |
|-----------|---------|----------|
| `Color+Extensions` | Color utilities | Universal |
| `Image+Extensions` | Image processing helpers | Universal |
| `String+Extensions` | String manipulation | Universal |
| `View+Extensions` | SwiftUI view helpers | Universal |
| `ProcessInfo+Extensions` | System information | Universal |
| `ToolbarItem+` | Toolbar customization | Universal |

---

## 🧪 Testing

### BookletPDFKitTests

**Location**: `Tests/BookletPDFKitTests/BookletPDFKitTests.swift`

Unit test suite for core functionality validation.

```swift
import XCTest
@testable import BookletPDFKit

final class BookletPDFKitTests: XCTestCase {
    // Test implementations
}
```

---

## 📖 Usage Examples

### Basic 2-in-1 Booklet

```swift
import BookletPDFKit

let generator = TwoInOnePdfGeneratorUseCaseImpl()
let sourceURL = // Your PDF URL

generator.makeBookletPDF(url: sourceURL) { resultURL in
    if let bookletURL = resultURL {
        print("Booklet created: \(bookletURL)")
    } else {
        print("Failed to create booklet")
    }
}
```

### Advanced 4-in-1 Layout

```swift
import BookletPDFKit

let generator = FourInOneGeneratorUseCaseImpl()
let sourceURL = // Your PDF URL

generator.makeBookletPDF(url: sourceURL) { resultURL in
    if let bookletURL = resultURL {
        print("4-in-1 booklet created: \(bookletURL)")
    } else {
        print("Failed to create 4-in-1 booklet")
    }
}
```

### Type Selection Pattern

```swift
import BookletPDFKit

func createBooklet(type: BookletType, url: URL, completion: @escaping (URL?) -> Void) {
    let generator: BookletPDFGeneratorUseCase
    
    switch type {
    case .type2:
        generator = TwoInOnePdfGeneratorUseCaseImpl()
    case .type4:
        generator = FourInOneGeneratorUseCaseImpl()
    }
    
    generator.makeBookletPDF(url: url, completion: completion)
}
```

---

## ⚡ Performance Characteristics

### 2-in-1 Generator
- **Time Complexity**: O(n) where n = page count
- **Memory Usage**: Single PDF document in memory
- **Thread Safety**: Full async processing
- **File Handling**: Automatic cleanup of source

### 4-in-1 Generator
- **Time Complexity**: O(n) with additional image generation overhead
- **Memory Usage**: All pages + blank page generation
- **Cross-Platform**: Platform-specific image rendering
- **Debug Output**: Console logging of page ordering

### General Performance
- ✅ Background queue processing
- ✅ Memory management with `autoreleasepool`
- ✅ Automatic file cleanup
- ✅ Non-blocking operations

---

## 🚨 Error Handling

### Common Failure Cases
1. **Invalid PDF**: Source URL doesn't contain valid PDF
2. **File System**: Unable to write to Documents directory
3. **Memory**: Insufficient memory for large documents
4. **Platform**: Image generation failure on specific platforms

### Error Handling Pattern
```swift
generator.makeBookletPDF(url: sourceURL) { resultURL in
    guard let bookletURL = resultURL else {
        // Handle failure case
        return
    }
    // Process successful result
}
```

---

## 🔗 Dependencies

### System Frameworks
- **Foundation**: Core functionality
- **PDFKit**: PDF document manipulation
- **SwiftUI**: UI components and extensions

### Platform-Specific
- **UIKit** (iOS): Image rendering and UI components
- **AppKit** (macOS): Image rendering and UI components

### Package Dependencies
- None (self-contained package)

---

## 📋 Requirements

### Minimum Versions
- **Swift**: 6.0+
- **macOS**: 15.0+
- **iOS**: 16.0+

### Build Configuration
```swift
// Package.swift
platforms: [
    .macOS(.v15),
    .iOS(.v16)
]
```

---

## 🏗️ Architecture Notes

### Design Patterns
- **Protocol-Oriented**: Core functionality defined via protocols
- **Cross-Platform**: Conditional compilation for platform differences
- **Async Processing**: Non-blocking operations with completion handlers
- **Clean Architecture**: Clear separation of concerns

### File Organization
- **Feature-Based**: Grouped by functionality (UseCase, Utils, Extensions)
- **Platform-Agnostic**: Shared code with platform-specific extensions
- **Testing**: Dedicated test directory structure

---

**Generated**: 2025-09-11  
**Package Version**: Swift 6.0  
**Maintainer**: SBD LLC