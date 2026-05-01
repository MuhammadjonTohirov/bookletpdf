#if os(iOS)
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

public enum PerspectiveCorrector {
    public static func correct(image: UIImage, quad: DetectedQuad) -> UIImage? {
        guard let oriented = orientedCIImage(from: image) else { return nil }
        let extent = oriented.extent
        guard extent.width > 0, extent.height > 0 else { return nil }

        let filter = CIFilter.perspectiveCorrection()
        filter.inputImage = oriented
        filter.topLeft = denormalize(quad.topLeft, in: extent)
        filter.topRight = denormalize(quad.topRight, in: extent)
        filter.bottomRight = denormalize(quad.bottomRight, in: extent)
        filter.bottomLeft = denormalize(quad.bottomLeft, in: extent)

        guard
            let output = filter.outputImage,
            output.extent.width > 0,
            output.extent.height > 0
        else { return nil }

        let context = CIContext()
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
    }

    // CIImage(image:) doesn't reliably apply UIImage.imageOrientation across iOS versions.
    // Building from cgImage + .oriented() guarantees the extent matches the upright,
    // user-visible image — which is the space the quad coords were authored in.
    private static func orientedCIImage(from image: UIImage) -> CIImage? {
        if let cgImage = image.cgImage {
            return CIImage(cgImage: cgImage).oriented(image.dskCGOrientation)
        }
        return CIImage(image: image)
    }

    private static func denormalize(_ point: CGPoint, in extent: CGRect) -> CGPoint {
        CGPoint(
            x: extent.origin.x + point.x * extent.width,
            y: extent.origin.y + point.y * extent.height
        )
    }
}
#endif
