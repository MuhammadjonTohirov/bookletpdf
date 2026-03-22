import Foundation
import PDFKit

public protocol PrepareBookletInputUseCase: Sendable {
    func prepareInputPDF(at url: URL, coverImageData: Data?) throws -> URL
}

public struct PrepareBookletInputUseCaseImpl: PrepareBookletInputUseCase {
    private let storage: BookletFileStorage

    public init(storage: BookletFileStorage = .init()) {
        self.storage = storage
    }

    public func prepareInputPDF(at url: URL, coverImageData: Data?) throws -> URL {
        guard let coverImageData else {
            return url
        }

        guard let document = PDFDocument(url: url) else {
            throw BookletError.invalidDocument
        }

        try document.insertCoverPage(imageData: coverImageData)

        return try storage.saveToTemporary(
            document: document,
            prefix: "booklet_input",
            originalName: url.lastPathComponent
        )
    }
}
