#if os(iOS)
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

public enum ScanFilter: String, CaseIterable, Sendable, Identifiable {
    case original
    case enhanced
    case grayscale
    case blackAndWhite

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .original: return "Original"
        case .enhanced: return "Enhance"
        case .grayscale: return "Grayscale"
        case .blackAndWhite: return "B&W"
        }
    }

    public func apply(to image: UIImage, context: CIContext = CIContext()) -> UIImage {
        guard self != .original, let ciImage = CIImage(image: image) else { return image }
        guard let processed = pipeline(input: ciImage) else { return image }
        guard let cgImage = context.createCGImage(processed, from: processed.extent) else { return image }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    private func pipeline(input: CIImage) -> CIImage? {
        switch self {
        case .original:
            return input
        case .enhanced:
            let controls = CIFilter.colorControls()
            controls.inputImage = input
            controls.contrast = 1.10
            controls.saturation = 1.05
            controls.brightness = 0.04
            return controls.outputImage
        case .grayscale:
            let mono = CIFilter.photoEffectMono()
            mono.inputImage = input
            return mono.outputImage
        case .blackAndWhite:
            let controls = CIFilter.colorControls()
            controls.inputImage = input
            controls.contrast = 1.9
            controls.saturation = 0
            controls.brightness = 0.05
            guard let stage1 = controls.outputImage else { return nil }
            let exposure = CIFilter.exposureAdjust()
            exposure.inputImage = stage1
            exposure.ev = 0.4
            return exposure.outputImage
        }
    }
}
#endif
