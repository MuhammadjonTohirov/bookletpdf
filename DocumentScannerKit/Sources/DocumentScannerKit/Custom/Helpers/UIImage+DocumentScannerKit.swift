#if os(iOS)
import UIKit
import ImageIO

extension UIImage {
    var dskCGOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }

    func dskDownsized(toLongestSide longestSide: CGFloat) -> UIImage {
        let longest = Swift.max(size.width, size.height)
        guard longest > longestSide else { return self }
        let factor = longestSide / longest
        let newSize = CGSize(width: size.width * factor, height: size.height * factor)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
#endif
