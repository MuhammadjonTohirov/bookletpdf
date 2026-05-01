#if os(iOS)
import Vision
import CoreImage
import UIKit

public final class DocumentDetector: @unchecked Sendable {
    public init() {}

    public func detect(
        in pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation = .up
    ) -> DetectedQuad? {
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: orientation,
            options: [:]
        )
        return performDetection(handler: handler)
    }

    public func detect(in image: UIImage) -> DetectedQuad? {
        if let cgImage = image.cgImage {
            let handler = VNImageRequestHandler(
                cgImage: cgImage,
                orientation: image.dskCGOrientation,
                options: [:]
            )
            return performDetection(handler: handler)
        }
        guard let ciImage = CIImage(image: image) else { return nil }
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        return performDetection(handler: handler)
    }

    private func performDetection(handler: VNImageRequestHandler) -> DetectedQuad? {
        let request = VNDetectDocumentSegmentationRequest()
        do {
            try handler.perform([request])
        } catch {
            return nil
        }
        guard let observation = request.results?.first else { return nil }
        return DetectedQuad(
            topLeft: observation.topLeft,
            topRight: observation.topRight,
            bottomRight: observation.bottomRight,
            bottomLeft: observation.bottomLeft
        )
    }
}
#endif
