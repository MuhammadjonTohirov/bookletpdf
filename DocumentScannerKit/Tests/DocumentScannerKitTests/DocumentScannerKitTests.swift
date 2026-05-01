import Testing
import CoreGraphics
@testable import DocumentScannerKit

@Test func detectedQuadStoresFourCorners() {
    let quad = DetectedQuad(
        topLeft: CGPoint(x: 0, y: 1),
        topRight: CGPoint(x: 1, y: 1),
        bottomRight: CGPoint(x: 1, y: 0),
        bottomLeft: .zero
    )
    #expect(quad.topLeft == CGPoint(x: 0, y: 1))
    #expect(quad.bottomLeft == .zero)
    #expect(quad == quad)
}
