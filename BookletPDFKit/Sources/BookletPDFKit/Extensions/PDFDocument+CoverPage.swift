import Foundation
import PDFKit
import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension PDFDocument {
    /// Inserts a cover page at index 0, created from the provided image data.
    /// The image is aspect-fit onto a white page matching the first page's size.
    public func insertCoverPage(imageData: Data) throws {
        guard let firstPage = page(at: 0) else {
            throw BookletError.invalidDocument
        }

        let pageSize = firstPage.bounds(for: .mediaBox).size
        guard let osImage = OSImage(data: imageData),
              let cgImage = osImage.cgImageRepresentation else {
            throw BookletError.exportFailed
        }

        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        let drawRect = aspectFitRect(for: imageSize, in: pageSize)

        let pdfData = NSMutableData()
        var mediaBox = CGRect(origin: .zero, size: pageSize)

        guard let context = CGContext(consumer: CGDataConsumer(data: pdfData as CFMutableData)!,
                                      mediaBox: &mediaBox, nil) else {
            throw BookletError.exportFailed
        }

        context.beginPDFPage(nil)
        // White background
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(mediaBox)
        // Draw image aspect-fit
        context.draw(cgImage, in: drawRect)
        context.endPDFPage()
        context.closePDF()

        guard let coverDoc = PDFDocument(data: pdfData as Data),
              let coverPage = coverDoc.page(at: 0) else {
            throw BookletError.exportFailed
        }

        insert(coverPage, at: 0)
    }

    private func aspectFitRect(for imageSize: CGSize, in containerSize: CGSize) -> CGRect {
        let widthRatio = containerSize.width / imageSize.width
        let heightRatio = containerSize.height / imageSize.height
        let scale = min(widthRatio, heightRatio)

        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        let x = (containerSize.width - scaledWidth) / 2
        let y = (containerSize.height - scaledHeight) / 2

        return CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
    }
}

extension OSImage {
    var cgImageRepresentation: CGImage? {
        #if canImport(UIKit)
        return cgImage
        #elseif canImport(AppKit)
        return cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
    }
}
