#if os(iOS)
import SwiftUI
import UIKit

public struct CustomScannerView: View {
    private let onCancel: () -> Void
    private let onCapture: (ScannedPage) -> Void

    @State private var stage: Stage = .camera

    public init(
        onCancel: @escaping () -> Void,
        onCapture: @escaping (ScannedPage) -> Void
    ) {
        self.onCancel = onCancel
        self.onCapture = onCapture
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            content
                .transition(.opacity)
        }
        .animation(.easeInOut(duration: 0.18), value: stageId)
    }

    @ViewBuilder
    private var content: some View {
        switch stage {
        case .camera:
            CameraStageView(
                onCancel: onCancel,
                onCaptured: { raw in
                    stage = .adjust(raw: raw)
                }
            )

        case .adjust(let raw):
            AdjustQuadView(
                rawImage: raw,
                initialQuad: nil,
                onRetake: { stage = .camera },
                onConfirm: { quad in
                    let corrected = PerspectiveCorrector.correct(image: raw, quad: quad) ?? raw
                    stage = .filter(raw: raw, quad: quad, corrected: corrected)
                }
            )

        case .filter(let raw, let quad, let corrected):
            FilterStageView(
                correctedImage: corrected,
                onBack: { stage = .adjust(raw: raw) },
                onDone: { final, _ in
                    onCapture(ScannedPage(image: final, detectedQuad: quad))
                }
            )
        }
    }

    private var stageId: String {
        switch stage {
        case .camera: return "camera"
        case .adjust: return "adjust"
        case .filter: return "filter"
        }
    }

    private enum Stage {
        case camera
        case adjust(raw: UIImage)
        case filter(raw: UIImage, quad: DetectedQuad, corrected: UIImage)
    }
}
#endif
