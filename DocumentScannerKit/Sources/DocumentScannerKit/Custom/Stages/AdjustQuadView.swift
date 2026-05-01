#if os(iOS)
import SwiftUI
import UIKit

struct AdjustQuadView: View {
    let rawImage: UIImage
    let initialQuad: DetectedQuad?
    let onRetake: () -> Void
    let onConfirm: (DetectedQuad) -> Void

    @State private var quad: DetectedQuad
    @State private var draggingCorner: Corner?

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var anchorScale: CGFloat = 1.0
    @State private var anchorOffset: CGSize = .zero

    private let detector = DocumentDetector()
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0

    init(
        rawImage: UIImage,
        initialQuad: DetectedQuad?,
        onRetake: @escaping () -> Void,
        onConfirm: @escaping (DetectedQuad) -> Void
    ) {
        self.rawImage = rawImage
        self.initialQuad = initialQuad
        self.onRetake = onRetake
        self.onConfirm = onConfirm
        _quad = State(initialValue: initialQuad ?? Self.defaultQuad)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.black
                imageWithHandles
                    .scaleEffect(scale, anchor: .center)
                    .offset(offset)
                    .padding(16)
            }
            .clipped()
            .frame(maxHeight: .infinity)
            .gesture(zoomGesture.simultaneously(with: panGesture))

            toolbar
        }
        .background(Color.black)
    }

    private var imageWithHandles: some View {
        GeometryReader { geo in
            let imageRect = aspectFitRect(imageSize: rawImage.size, in: geo.size)
            ZStack {
                Image(uiImage: rawImage)
                    .resizable()
                    .scaledToFit()

                QuadShape(quad: quad, imageRect: imageRect)
                    .stroke(Color.yellow, lineWidth: 2 / scale)
                    .background(
                        QuadShape(quad: quad, imageRect: imageRect)
                            .fill(Color.yellow.opacity(0.10))
                    )

                handle(for: .topLeft, in: imageRect)
                handle(for: .topRight, in: imageRect)
                handle(for: .bottomRight, in: imageRect)
                handle(for: .bottomLeft, in: imageRect)
            }
        }
    }

    private func handle(for corner: Corner, in rect: CGRect) -> some View {
        let normalized = quad.point(for: corner)
        let position = viewPoint(from: normalized, in: rect)
        let visualSize = 28 / scale
        let hitSize = visualSize * 2
        return Circle()
            .fill(Color.yellow)
            .overlay(Circle().stroke(Color.white, lineWidth: 2 / scale))
            .frame(width: visualSize, height: visualSize)
            .scaleEffect(draggingCorner == corner ? 1.25 : 1.0)
            .animation(.easeOut(duration: 0.12), value: draggingCorner == corner)
            .frame(width: hitSize, height: hitSize)
            .contentShape(Circle())
            .position(position)
            .gesture(
                DragGesture(coordinateSpace: .local)
                    .onChanged { value in
                        draggingCorner = corner
                        quad.set(corner: corner, to: normalizedPoint(from: value.location, in: rect))
                    }
                    .onEnded { _ in draggingCorner = nil }
            )
    }

    private var toolbar: some View {
        HStack(spacing: 20) {
            Button("Retake", action: onRetake)
                .foregroundStyle(.white)
            Spacer()
            Button("Auto", action: autoDetectAgain)
                .foregroundStyle(.white)
            if scale > 1.02 {
                Spacer()
                Button("1x", action: resetZoom)
                    .foregroundStyle(.white)
            }
            Spacer()
            Button("Use Photo") { onConfirm(quad) }
                .bold()
                .foregroundStyle(Color.yellow)
        }
        .font(.headline)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(Color.black)
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { newScale in
                scale = min(max(anchorScale * newScale, minScale), maxScale)
            }
            .onEnded { _ in
                anchorScale = scale
            }
    }

    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: anchorOffset.width + value.translation.width,
                    height: anchorOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                anchorOffset = offset
            }
    }

    private func resetZoom() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 1.0
            offset = .zero
        }
        anchorScale = 1.0
        anchorOffset = .zero
    }

    private func viewPoint(from normalized: CGPoint, in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + normalized.x * rect.width,
            y: rect.minY + (1 - normalized.y) * rect.height
        )
    }

    private func normalizedPoint(from viewPoint: CGPoint, in rect: CGRect) -> CGPoint {
        let x = ((viewPoint.x - rect.minX) / rect.width).clamped(to: 0...1)
        let yFlipped = ((viewPoint.y - rect.minY) / rect.height).clamped(to: 0...1)
        return CGPoint(x: x, y: 1 - yFlipped)
    }

    private func aspectFitRect(imageSize: CGSize, in containerSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height
        let width: CGFloat
        let height: CGFloat
        if imageAspect > containerAspect {
            width = containerSize.width
            height = width / imageAspect
        } else {
            height = containerSize.height
            width = height * imageAspect
        }
        return CGRect(
            x: (containerSize.width - width) / 2,
            y: (containerSize.height - height) / 2,
            width: width,
            height: height
        )
    }

    private func autoDetectAgain() {
        if let detected = detector.detect(in: rawImage) {
            withAnimation(.easeOut(duration: 0.18)) {
                quad = detected
            }
        }
    }

    private static var defaultQuad: DetectedQuad {
        DetectedQuad(
            topLeft: CGPoint(x: 0.05, y: 0.95),
            topRight: CGPoint(x: 0.95, y: 0.95),
            bottomRight: CGPoint(x: 0.95, y: 0.05),
            bottomLeft: CGPoint(x: 0.05, y: 0.05)
        )
    }
}

enum Corner {
    case topLeft, topRight, bottomRight, bottomLeft
}

private extension DetectedQuad {
    func point(for corner: Corner) -> CGPoint {
        switch corner {
        case .topLeft: return topLeft
        case .topRight: return topRight
        case .bottomRight: return bottomRight
        case .bottomLeft: return bottomLeft
        }
    }

    mutating func set(corner: Corner, to point: CGPoint) {
        switch corner {
        case .topLeft: topLeft = point
        case .topRight: topRight = point
        case .bottomRight: bottomRight = point
        case .bottomLeft: bottomLeft = point
        }
    }
}

private struct QuadShape: Shape {
    let quad: DetectedQuad
    let imageRect: CGRect

    func path(in _: CGRect) -> Path {
        var path = Path()
        path.move(to: mapped(quad.topLeft))
        path.addLine(to: mapped(quad.topRight))
        path.addLine(to: mapped(quad.bottomRight))
        path.addLine(to: mapped(quad.bottomLeft))
        path.closeSubpath()
        return path
    }

    private func mapped(_ p: CGPoint) -> CGPoint {
        CGPoint(
            x: imageRect.minX + p.x * imageRect.width,
            y: imageRect.minY + (1 - p.y) * imageRect.height
        )
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
#endif
