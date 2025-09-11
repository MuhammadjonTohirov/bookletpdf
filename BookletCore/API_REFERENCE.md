# 🎯 BookletCore Package API Reference

**Version**: Swift 6.1+  
**Purpose**: Foundation utilities for BookletPDF ecosystem  
**Bundle ID**: `uz.sbd.bookletPdf`

---

## 📋 Overview

BookletCore is a lightweight Swift package providing essential utilities for the BookletPDF application ecosystem, including logging, user settings, localization, and JSON handling. Originally extracted from YuzPay, now specifically adapted and renamed for the BookletPDF project to avoid naming conflicts.

### Package Structure
```
BookletCore/
├── 📦 Package.swift                    # Swift Package Manager configuration
└── 📚 Sources/BookletCore/             # Main library code
    ├── 📄 BookletCore.swift            # Package entry point
    ├── 🛠️ Utils/                       # Core utilities
    │   ├── Logging.swift               # Debug logging system
    │   ├── UserSettings.swift          # Persistent user preferences
    │   ├── Language.swift             # Multi-language support
    │   └── CodableWrapper.swift       # UserDefaults property wrapper
    └── 🔧 Extensions/                  # Type extensions
        └── String+.swift              # String utilities & JSON handling
```

---

## 🛠️ Core Utilities

### Logging System

**Location**: `Utils/Logging.swift:10`

Debug-only logging utility for development and testing.

```swift
final public class Logging {
    public static func l(tag: @autoclosure () -> String = "Log", _ message: @autoclosure () -> Any)
}
```

#### Features
- ✅ **Debug-only**: Automatically disabled in release builds
- ✅ **Autoclosure**: Lazy evaluation for performance
- ✅ **Tagged**: Optional tags for categorization

#### Usage
```swift
import BookletCore

// Basic logging
Logging.l("User login successful")

// Tagged logging
Logging.l(tag: "PDF", "Processing document with 24 pages")

// Object logging
Logging.l(tag: "Settings", userSettings)
```

#### Performance
- **Debug**: Full logging with tags and messages
- **Release**: Zero overhead (compiled out)

---

### User Settings System

**Location**: `Utils/UserSettings.swift:10`

Persistent user preferences using property wrapper pattern.

```swift
public struct UserSettings {
    static public var language: Language? { get set }
}
```

#### Implementation
Uses `@codableWrapper` for automatic JSON encoding/decoding to UserDefaults.

```swift
@codableWrapper(key: "language", Language.english)
var language: Language?
```

#### Features
- ✅ **Type-Safe**: Codable constraint ensures type safety
- ✅ **Persistent**: Automatic UserDefaults storage
- ✅ **Default Values**: Fallback to English if not set
- ✅ **App Group**: Shared storage via suite name

---

### Multi-Language Support

**Location**: `Utils/Language.swift:10`

Comprehensive language support with localization utilities.

```swift
public enum Language: Int, Codable {
    case english = 0
    case france
    case germany
    case uzbek
}
```

#### API Surface
```swift
// Static factory method
public static func language(_ code: String) -> Language

// Properties
public var name: String      // Human-readable name
public var code: String      // Language code (ISO)
```

#### Supported Languages
| Language | Code | Display Name |
|----------|------|--------------|
| English | `en` | English |
| French | `fr` | Français |
| German | `de` | Deutsch |
| Uzbek | `uz-UZ` | O'zbekcha |

#### Usage
```swift
// From language code
let lang = Language.language("de")  // .germany

// Properties
print(lang.name)  // "Deutsch"
print(lang.code)  // "de"

// Default fallback
let unknown = Language.language("xx")  // .english
```

---

### Property Wrapper for Codable Storage

**Location**: `Utils/CodableWrapper.swift:10`

Generic property wrapper for persistent Codable storage.

```swift
@propertyWrapper public struct codableWrapper<Value: Codable> {
    public let key: String
    public var storage: UserDefaults
    
    public init(key: String, _ default: Value? = nil)
    public var wrappedValue: Value? { get set }
}
```

#### Features
- ✅ **Generic**: Works with any Codable type
- ✅ **App Group**: Uses shared UserDefaults suite
- ✅ **JSON Encoding**: Automatic serialization/deserialization
- ✅ **Default Values**: Optional default value support
- ✅ **Nil Handling**: Graceful nil value management

#### Configuration
```swift
public var storage: UserDefaults {
    UserDefaults(suiteName: "uz.sbd.bookletPdf") ?? .standard
}
```

#### Usage Examples
```swift
// Basic usage
@codableWrapper(key: "user_theme", Theme.light)
var theme: Theme?

// Custom types
@codableWrapper(key: "pdf_settings")
var pdfSettings: PDFConfiguration?

// With defaults
@codableWrapper(key: "language", Language.english)
var language: Language?
```

---

## 🔧 Extensions

### String Extensions

**Location**: `Extensions/String+.swift:10`

Comprehensive string utilities for JSON handling and localization.

#### Utility Properties
```swift
var nilIfEmpty: String?           // Returns nil for empty strings
var asJson: Any?                 // Parse as JSON object
var asDict: [String: Any]?       // Parse as dictionary
var asData: Data?                // Convert to Data
var localize: String             // Localize using current language
```

#### Generic Methods
```swift
func asObject<T: Decodable>() -> T?                    // Parse as specific type
func localize(language: Language, bundle: Bundle) -> String  // Custom localization
func placeholder(_ text: String) -> String             // Fallback text
func localize(arguments: CVarArg...) -> String         // Format with arguments
```

#### JSON Handling Examples
```swift
// Parse JSON string
let jsonString = """
{"name": "John", "age": 30}
"""

let dict = jsonString.asDict
let person: Person? = jsonString.asObject()
```

#### Localization Examples
```swift
// Basic localization
let title = "pdf_title".localize

// Custom language
let germanTitle = "pdf_title".localize(language: .germany)

// With formatting
let message = "pages_count".localize(arguments: 24)
```

---

## 🔄 Integration Patterns

### BookletCore Integration
```swift
import BookletCore

// Set user language
UserSettings.language = .germany

// Read current language
let currentLang = UserSettings.language ?? .english

// Use in localization
let localizedText = "welcome".localize(language: currentLang)
```

### Logging Integration
```swift
// Development debugging
Logging.l(tag: "PDF", "Starting conversion process")
Logging.l(tag: "Settings", "Language changed to \(UserSettings.language?.name ?? "unknown")")

// Conditional logging
if complexCondition {
    Logging.l(tag: "Debug", "Complex condition met: \(complexObject)")
}
```

### JSON Processing Pipeline
```swift
// Parse incoming JSON
let response: APIResponse? = jsonString.asObject()

// Process and store
if let config = response?.configuration {
    @codableWrapper(key: "app_config")
    var appConfig: Configuration?
    appConfig = config
}

// Serialize for output
let outputJSON = processedData.asString
```

---

## ⚡ Performance Characteristics

### Logging System
- **Debug Build**: Full feature logging with minimal overhead
- **Release Build**: Zero overhead (code elimination)
- **Memory**: No persistent storage, immediate output

### UserDefaults Storage
- **Read Performance**: Fast dictionary lookup + JSON decode
- **Write Performance**: JSON encode + UserDefaults write
- **Memory**: Minimal footprint, automatic cleanup
- **Persistence**: Automatic across app launches

### JSON Processing
- **String → Object**: JSONDecoder with Foundation optimizations
- **Object → String**: JSONEncoder with UTF-8 conversion
- **Error Handling**: Graceful failure with nil returns
- **Memory**: Minimal intermediate allocations

---

## 🚨 Error Handling

### JSON Parsing
```swift
// Safe parsing with nil returns
let parsed: MyType? = jsonString.asObject()
if parsed == nil {
    Logging.l(tag: "JSON", "Failed to parse: \(jsonString)")
}

// Exception handling for dictionary conversion
do {
    let dict = try object.asDictionary()
    // Process dictionary
} catch {
    Logging.l(tag: "Serialize", "Serialization failed: \(error)")
}
```

### UserDefaults Storage
- **Encoding Failures**: Silent failure, no storage
- **Decoding Failures**: Returns nil, preserves existing data
- **Suite Access**: Falls back to standard UserDefaults

### Language Support
- **Unknown Codes**: Automatic fallback to English
- **Missing Localizations**: Returns original key
- **Bundle Issues**: Graceful fallback to main bundle

---

## 🔗 Package Ecosystem Integration

### With BookletPDFKit
```swift
// BookletPDFKit can import BookletCore for utilities
import BookletCore

public final class TwoInOnePdfGeneratorUseCaseImpl: BookletPDFGeneratorUseCase {
    public func makeBookletPDF(url: URL, completion: @escaping (URL?) -> Void) {
        Logging.l(tag: "PDF", "Starting 2-in-1 conversion for \(url.lastPathComponent)")
        // ... implementation
    }
}
```

### Main App Integration
```swift
// Main app imports both packages
import BookletCore
import BookletPDFKit

// Configure settings
UserSettings.language = .germany

// Use localized strings
let title = "app_title".localize

// Create PDF generator with logging
let generator = TwoInOnePdfGeneratorUseCaseImpl()
```

---

## 📋 Requirements

### Minimum Versions
- **Swift**: 6.1+
- **Platforms**: Universal (iOS, macOS, watchOS, tvOS)

### Package Configuration
```swift
// Package.swift
name: "BookletCore"
products: [.library(name: "BookletCore", targets: ["BookletCore"])]
```

---

## 🎯 Usage Recommendations

### Best Practices
1. **Naming**: BookletCore prefix avoids conflicts with system Core frameworks
2. **Logging**: Use meaningful tags for easy filtering during development
3. **Settings**: Define clear key names for UserDefaults storage
4. **Localization**: Implement fallbacks for missing translations
5. **JSON**: Handle parsing failures gracefully

### Integration Tips
```swift
// Centralized settings access
extension UserSettings {
    static var preferredLanguage: Language {
        return language ?? Language.language(Locale.current.languageCode ?? "en")
    }
}

// Structured logging for PDF operations
enum PDFLogTag {
    case conversion, viewer, export, settings
    var name: String { "PDF_\(String(describing: self).uppercased())" }
}

Logging.l(tag: PDFLogTag.conversion.name, "Starting booklet conversion")
```

### Recommended Project Structure
```swift
// In main app or BookletPDFKit
import BookletCore

// Extend UserSettings for PDF-specific needs
extension UserSettings {
    static var defaultBookletType: BookletType {
        @codableWrapper(key: "default_booklet_type", BookletType.type2)
        var type: BookletType?
        return type ?? .type2
    }
    
    static var pdfQuality: Float {
        @codableWrapper(key: "pdf_quality", 1.0)
        var quality: Float?
        return quality ?? 1.0
    }
}
```

---

## 🔄 Migration from Core

### Package Rename Benefits
- ✅ **No Conflicts**: Avoids naming collision with Core frameworks
- ✅ **Clear Identity**: Explicitly BookletPDF-related
- ✅ **Namespace**: Better organization in multi-package projects

### Import Changes
```swift
// Before
import Core

// After  
import BookletCore
```

### API Compatibility
- ✅ **Full Compatibility**: All APIs remain unchanged
- ✅ **Same Functionality**: Identical behavior and performance
- ✅ **Zero Migration**: Only import statement changes

---

**Generated**: 2025-09-11  
**Package Version**: Swift 6.1  
**Renamed**: Core → BookletCore (avoid naming conflicts)  
**Maintainer**: SBD LLC