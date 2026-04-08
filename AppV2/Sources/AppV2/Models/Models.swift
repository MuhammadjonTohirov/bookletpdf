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

struct RecentConversion: Codable, Identifiable {
    let id: UUID
    let fileName: String
    let pageCount: Int
    let bookletType: String
    let date: Date
    let fileURL: URL?

    init(fileName: String, pageCount: Int, bookletType: String, fileURL: URL? = nil, date: Date = .now) {
        self.id = UUID()
        self.fileName = fileName
        self.pageCount = pageCount
        self.bookletType = bookletType
        self.fileURL = fileURL
        self.date = date
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
