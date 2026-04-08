import Foundation
import PDFKit
import CoreGraphics
import CoreText

public protocol PDFBrandingUseCase: Sendable {
    func applyBranding(to url: URL) throws -> URL
}

public struct PDFBrandingUseCaseImpl: PDFBrandingUseCase {
    private let storage = BookletFileStorage()
    private static let brandText = "BookletPDF"
    private static let fontSize: CGFloat = 8
    private static let textBottomMargin: CGFloat = 6

    public init() {}

    public func applyBranding(to url: URL) throws -> URL {
        guard let document = PDFDocument(url: url) else {
            throw BookletError.invalidDocument
        }

        let pdfData = NSMutableData()

        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData) else {
            throw BookletError.exportFailed
        }

        var initialBox = document.page(at: 0)?.bounds(for: .mediaBox) ?? .zero

        guard let context = CGContext(consumer: consumer, mediaBox: &initialBox, nil) else {
            throw BookletError.exportFailed
        }

        for pageIndex in 0..<document.pageCount {
            autoreleasepool {
                guard let page = document.page(at: pageIndex),
                      let pageRef = page.pageRef else { return }

                var pageBox = page.bounds(for: .mediaBox)
                let boxData = NSData(bytes: &pageBox, length: MemoryLayout<CGRect>.size)

                context.beginPDFPage([
                    kCGPDFContextMediaBox: boxData
                ] as NSDictionary)

                context.drawPDFPage(pageRef)
                Self.drawBrandText(in: context, pageRect: pageBox)
                context.endPDFPage()
            }
        }

        context.closePDF()

        guard let brandedDoc = PDFDocument(data: pdfData as Data) else {
            throw BookletError.exportFailed
        }

        return try storage.saveToTemporary(
            document: brandedDoc,
            prefix: "branded",
            originalName: url.lastPathComponent
        )
    }

    private static func drawBrandText(in context: CGContext, pageRect: CGRect) {
        let font = CTFontCreateWithName("Helvetica" as CFString, fontSize, nil)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: CGColor(gray: 0.6, alpha: 0.8)
        ]

        let attributedString = NSAttributedString(string: brandText, attributes: attributes)
        let line = CTLineCreateWithAttributedString(attributedString)
        let textBounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)

        let x = (pageRect.width - textBounds.width) / 2
        let y = textBottomMargin

        context.saveGState()
        context.textMatrix = .identity
        context.textPosition = CGPoint(x: x, y: y)
        CTLineDraw(line, context)
        context.restoreGState()
    }
}
