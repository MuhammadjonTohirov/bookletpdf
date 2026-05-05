import Foundation
import BookletCore
import PDFKit

public enum ContentViewState: Equatable {
    case initial
    case selectedPdf
    case configuringLayout
    case converting
    case convertedPdf
}

public struct PDFDocumentObject {
    public var document: PDFDocument
    public var name: String
    public var url: URL?
}

enum RecentItemKind: String, Codable {
    case booklet
    case scan
}

enum RecentItemOrigin: String, Codable {
    case pdfImport
    case scan
}

struct RecentConversion: Codable, Identifiable {
    let id: UUID
    let fileName: String
    let pageCount: Int
    let bookletType: String?
    let date: Date
    let fileURL: URL?
    let kind: RecentItemKind
    let origin: RecentItemOrigin

    init(
        fileName: String,
        pageCount: Int,
        bookletType: String?,
        fileURL: URL? = nil,
        date: Date = .now,
        kind: RecentItemKind = .booklet,
        origin: RecentItemOrigin = .pdfImport
    ) {
        self.id = UUID()
        self.fileName = fileName
        self.pageCount = pageCount
        self.bookletType = bookletType
        self.fileURL = fileURL
        self.date = date
        self.kind = kind
        self.origin = origin
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.fileName = try container.decode(String.self, forKey: .fileName)
        self.pageCount = try container.decode(Int.self, forKey: .pageCount)
        self.bookletType = try container.decodeIfPresent(String.self, forKey: .bookletType)
        self.date = try container.decode(Date.self, forKey: .date)
        self.fileURL = try container.decodeIfPresent(URL.self, forKey: .fileURL)
        self.kind = try container.decodeIfPresent(RecentItemKind.self, forKey: .kind) ?? .booklet
        self.origin = try container.decodeIfPresent(RecentItemOrigin.self, forKey: .origin) ?? .pdfImport
    }

    var fileExists: Bool {
        guard let url = fileURL else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }

    var formattedDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "str.today".localize + ", " + date.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(date) {
            return "str.yesterday".localize
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
}
