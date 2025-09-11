# 🎯 BookletCore Package Index

**Foundation utilities package for BookletPDF ecosystem**

---

## 📦 Package Overview

BookletCore is a lightweight Swift package providing essential utilities for the BookletPDF application ecosystem. Originally extracted from YuzPay and adapted for BookletPDF, it was renamed from "Core" to "BookletCore" to avoid naming conflicts with system frameworks and provide clear project identity.

### Package Identity
- **Name**: BookletCore
- **Previous Name**: Core (renamed to avoid conflicts)
- **Swift Version**: 6.1+
- **Bundle ID**: `uz.sbd.bookletPdf`
- **Origin**: Extracted from YuzPay, adapted for BookletPDF
- **Purpose**: Foundation utilities and cross-platform abstractions

---

## 📁 Package Structure

```
BookletCore/
├── 📦 Package.swift                      # Swift Package Manager manifest
├── 🗂️ .swiftpm/                          # Xcode project configuration
│   └── xcode/xcshareddata/xcschemes/
│       └── BookletCore.xcscheme         # Build scheme
├── 📝 .gitignore                        # Git ignore rules
└── 📚 Sources/BookletCore/               # Main library code
    ├── 📄 BookletCore.swift             # Package entry point
    ├── 🛠️ Utils/                         # Core utilities (4 files)
    │   ├── Logging.swift                # Debug logging system
    │   ├── UserSettings.swift           # Persistent user preferences
    │   ├── Language.swift               # Multi-language support
    │   └── CodableWrapper.swift         # UserDefaults property wrapper
    └── 🔧 Extensions/                    # Type extensions (1 file)
        └── String+.swift                # String utilities & JSON handling
```

---

## 🎯 Core Components

### 1. Logging System (`Logging.swift`)
**Purpose**: Debug-only logging with tag support
```swift
final public class Logging {
    public static func l(tag: @autoclosure () -> String = "Log", _ message: @autoclosure () -> Any)
}
```
- ✅ Compile-time optimization (debug-only)
- ✅ Autoclosure for performance
- ✅ Tagged categorization

### 2. Settings Management (`UserSettings.swift`)
**Purpose**: Type-safe persistent user preferences
```swift
public struct UserSettings {
    static public var language: Language? { get set }
}
```
- ✅ Property wrapper integration
- ✅ Codable type safety
- ✅ App group sharing

### 3. Language Support (`Language.swift`)
**Purpose**: Multi-language enumeration with localization
```swift
public enum Language: Int, Codable {
    case english = 0, france, germany, uzbek
}
```
- ✅ 4 supported languages
- ✅ ISO code mapping
- ✅ Human-readable names

### 4. Property Wrapper (`CodableWrapper.swift`)
**Purpose**: Generic Codable storage for UserDefaults
```swift
@propertyWrapper public struct codableWrapper<Value: Codable> {
    public let key: String
    public var wrappedValue: Value? { get set }
}
```
- ✅ Generic Codable constraint
- ✅ JSON serialization
- ✅ App suite storage

### 5. String Extensions (`String+.swift`)
**Purpose**: JSON handling and localization utilities
```swift
extension String {
    var nilIfEmpty: String?
    func asObject<T: Decodable>() -> T?
    var localize: String
}
```
- ✅ JSON parsing utilities
- ✅ Localization integration
- ✅ Type-safe conversions

---

## 🔄 Component Relationships

### Internal Dependencies
```
UserSettings → codableWrapper → Language
     ↓              ↓             ↓
String.localize ← Language.code ← UserDefaults Storage
```

### Usage Patterns
1. **Settings Flow**: `UserSettings.language` → `@codableWrapper` → `UserDefaults`
2. **Localization Flow**: `String.localize` → `UserSettings.language` → `Language.code`
3. **JSON Flow**: `String.asObject<T>()` → `JSONDecoder` → `T`
4. **Logging Flow**: `Logging.l(tag:_:)` → Debug build only

---

## 📊 API Surface

### Public Classes
| Class | Purpose | Methods |
|-------|---------|---------|
| `Logging` | Debug logging | `l(tag:_:)` |

### Public Structures
| Structure | Purpose | Properties |
|-----------|---------|------------|
| `UserSettings` | User preferences | `language: Language?` |
| `codableWrapper<T>` | Property wrapper | `wrappedValue: T?` |

### Public Enumerations
| Enum | Purpose | Cases |
|------|---------|-------|
| `Language` | Language support | `english`, `france`, `germany`, `uzbek` |

### Extension APIs
| Extension | Methods | Properties |
|-----------|---------|------------|
| `String` | `asObject<T>()`, `localize(language:bundle:)` | `nilIfEmpty`, `asJson`, `asDict`, `localize` |
| `Encodable` | `asDictionary()` | `asString`, `asData` |
| `Substring` | - | `asString`, `asData` |

---

## 🏗️ Package Ecosystem

### BookletPDF Project Structure
```
bookletpdf/
├── 📱 bookletPdf/              # Main application
├── 📦 BookletPDFKit/           # PDF processing library  
├── 🎯 BookletCore/             # Foundation utilities (this package)
└── 🏗️ bookletPdf.xcodeproj/    # Xcode project
```

### Package Dependencies
```
BookletCore (Foundation layer)
    ↑
BookletPDFKit (PDF processing)
    ↑  
bookletPdf (Main app)
```

### Integration Patterns
```swift
// Main app
import BookletCore
import BookletPDFKit

// BookletPDFKit (recommended)
import BookletCore  // For logging and utilities

// Usage example
UserSettings.language = .germany
Logging.l(tag: "PDF", "Starting conversion")
let generator = TwoInOnePdfGeneratorUseCaseImpl()
```

---

## 🎨 Design Patterns

### Property Wrapper Pattern
```swift
@codableWrapper(key: "language", Language.english)
var language: Language?
```
- **Benefits**: Type safety, automatic persistence, default values
- **Usage**: User preferences, configuration storage

### Protocol-Oriented JSON
```swift
extension Encodable {
    var asString: String { /* JSON encoding */ }
}

extension String {
    func asObject<T: Decodable>() -> T? { /* JSON decoding */ }
}
```
- **Benefits**: Type-safe serialization, protocol extension reuse

### Conditional Compilation
```swift
#if DEBUG
print("\(tag()): \(message())")
#endif
```
- **Benefits**: Zero overhead in release, full debugging in development

---

## 🌍 Localization Architecture

### Language Configuration
- **Supported**: English, French, German, Uzbek
- **Default**: English fallback
- **Storage**: Persistent via `UserSettings.language`
- **Usage**: `"key".localize` automatic lookup

### Bundle Integration
```swift
func localize(language: Language, bundle: Bundle = .main) -> String {
    let path = bundle.path(forResource: language.code, ofType: "lproj")
    // Bundle-based localization lookup
}
```

### PDF-Specific Localization
```swift
// Example usage in BookletPDF context
"pdf_pages_count".localize(arguments: pageCount)  // "24 pages"
"booklet_type_2in1".localize                      // "2-in-1 Booklet"
"conversion_progress".localize(arguments: 75)      // "75% complete"
```

---

## ⚡ Performance Profile

### Logging System
- **Debug**: Minimal overhead with autoclosure
- **Release**: Zero overhead (compiled out)
- **Memory**: No persistent storage

### Settings Storage
- **Read**: UserDefaults + JSON decode
- **Write**: JSON encode + UserDefaults
- **Cache**: UserDefaults native caching

### JSON Processing
- **Parsing**: Foundation JSONDecoder optimizations
- **Serialization**: Foundation JSONEncoder
- **Memory**: Minimal intermediate allocations

---

## 🔗 Integration Examples

### BookletPDFKit Integration
```swift
// In BookletPDFKit use cases
import BookletCore

public final class TwoInOnePdfGeneratorUseCaseImpl: BookletPDFGeneratorUseCase {
    public func makeBookletPDF(url: URL, completion: @escaping (URL?) -> Void) {
        Logging.l(tag: "PDF_2IN1", "Starting conversion: \(url.lastPathComponent)")
        
        DispatchQueue.global(qos: .utility).async {
            // PDF processing with logging
            Logging.l(tag: "PDF_2IN1", "Pages padded, starting reorder")
            // ... implementation
            
            Logging.l(tag: "PDF_2IN1", "Conversion completed successfully")
            completion(resultURL)
        }
    }
}
```

### Main App Settings
```swift
// Extend UserSettings for PDF-specific preferences
extension UserSettings {
    static var defaultBookletType: BookletType {
        @codableWrapper(key: "default_booklet_type", BookletType.type2)
        var type: BookletType?
        return type ?? .type2
    }
    
    static var rememberLastSettings: Bool {
        @codableWrapper(key: "remember_last_settings", true)
        var remember: Bool?
        return remember ?? true
    }
    
    static var outputQuality: Float {
        @codableWrapper(key: "output_quality", 1.0)
        var quality: Float?
        return quality ?? 1.0
    }
}
```

---

## 🚨 Naming Conflict Resolution

### Why BookletCore?
- **Avoided Conflicts**: No collision with Core frameworks (Core Animation, Core Data, etc.)
- **Clear Identity**: Explicitly BookletPDF-related
- **Better Organization**: Namespace clarity in multi-package projects
- **Future-Proof**: Room for additional Booklet-prefixed packages

### Migration from Core
```swift
// Before (conflicted with system frameworks)
import Core

// After (clear and specific)
import BookletCore

// All APIs remain identical - only import changes
UserSettings.language = .germany
Logging.l(tag: "PDF", "message")
```

---

## 🧪 Testing Strategy

### Current State
- **Tests**: Not yet implemented
- **Recommended**: Unit tests for each utility component
- **Coverage Areas**: JSON parsing, settings persistence, localization

### Recommended Test Structure
```
Tests/BookletCoreTests/
├── LoggingTests.swift          # Debug vs release behavior
├── UserSettingsTests.swift     # Persistence and defaults
├── LanguageTests.swift         # Code mapping and names
├── CodableWrapperTests.swift   # Generic storage behavior
└── StringExtensionTests.swift  # JSON and localization
```

### Test Examples
```swift
// Example test cases
func testLanguageCodeMapping() {
    XCTAssertEqual(Language.language("de"), .germany)
    XCTAssertEqual(Language.language("unknown"), .english)
}

func testCodableWrapperPersistence() {
    @codableWrapper(key: "test_key", "default")
    var testValue: String?
    
    testValue = "new_value"
    XCTAssertEqual(testValue, "new_value")
}
```

---

## 📋 Package Metadata

| Property | Value |
|----------|-------|
| **Package Name** | BookletCore |
| **Previous Name** | Core |
| **Swift Version** | 6.1+ |
| **Platforms** | Universal (iOS, macOS, watchOS, tvOS) |
| **Dependencies** | Foundation only |
| **Bundle Suite** | `uz.sbd.bookletPdf` |
| **File Count** | 6 Swift files |
| **API Surface** | 1 class, 2 structs, 1 enum, 3 extensions |
| **Origin** | YuzPay (adapted) |
| **Rename Date** | 2025-09-11 |

---

## 🚀 Future Enhancements

### Planned Additions
- **PDF-Specific Settings**: More granular PDF processing preferences
- **Additional Languages**: Expand language support based on user needs
- **Enhanced Logging**: Log levels, persistence options, filtering
- **Performance Metrics**: Timing and memory usage tracking

### Potential Extensions
```swift
// Future UserSettings additions
extension UserSettings {
    static var autoSaveEnabled: Bool { get set }
    static var defaultOutputDirectory: URL? { get set }
    static var compressionLevel: Float { get set }
    static var watermarkSettings: WatermarkConfig? { get set }
}

// Enhanced logging with levels
enum LogLevel { case debug, info, warning, error }
Logging.l(level: .info, tag: "PDF", "Processing complete")
```

---

**Generated**: 2025-09-11  
**Package Status**: Active development  
**Renamed**: Core → BookletCore (avoid naming conflicts)  
**Maintainer**: SBD LLC  
**Documentation**: Complete API reference available