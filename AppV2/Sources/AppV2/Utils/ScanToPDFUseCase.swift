#if os(iOS)
import Foundation
import UIKit
import PDFKit
import BookletCore
import BookletPDFKit

protocol ScanToPDFUseCase: Sendable {
    func makePDF(from images: [UIImage], fileName: String) throws -> URL
}

struct ScanToPDFUseCaseImpl: ScanToPDFUseCase {
    private static let pageSize = CGSize(width: 595, height: 842) // A4 @ 72 dpi
    private static let jpegQuality: CGFloat = 0.85

    func makePDF(from images: [UIImage], fileName: String) throws -> URL {
        guard !images.isEmpty else { throw BookletError.invalidDocument }

        let format = UIGraphicsPDFRendererFormat()
        let bounds = CGRect(origin: .zero, size: Self.pageSize)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds, format: format)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)

        try renderer.writePDF(to: url) { context in
            for image in images {
                context.beginPage()
                let compressed = image.compressedForScan(quality: Self.jpegQuality) ?? image
                let drawRect = compressed.size.aspectFit(in: bounds)
                compressed.draw(in: drawRect)
            }
        }
        return url
    }
}

private extension UIImage {
    func compressedForScan(quality: CGFloat) -> UIImage? {
        guard let data = jpegData(compressionQuality: quality) else { return nil }
        return UIImage(data: data)
    }
}

private extension CGSize {
    func aspectFit(in container: CGRect) -> CGRect {
        guard width > 0, height > 0 else { return container }
        let scale = min(container.width / width, container.height / height)
        let fitted = CGSize(width: width * scale, height: height * scale)
        let origin = CGPoint(
            x: container.midX - fitted.width / 2,
            y: container.midY - fitted.height / 2
        )
        return CGRect(origin: origin, size: fitted)
    }
}
#endif
