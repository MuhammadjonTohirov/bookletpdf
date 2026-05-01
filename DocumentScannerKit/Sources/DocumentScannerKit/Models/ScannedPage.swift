#if os(iOS)
import UIKit

public struct ScannedPage {
    public let image: UIImage
    public let detectedQuad: DetectedQuad?

    public init(image: UIImage, detectedQuad: DetectedQuad? = nil) {
        self.image = image
        self.detectedQuad = detectedQuad
    }
}
#endif
