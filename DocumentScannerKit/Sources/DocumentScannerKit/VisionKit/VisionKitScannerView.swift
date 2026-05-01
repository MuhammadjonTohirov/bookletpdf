#if os(iOS)
import SwiftUI
import VisionKit

public struct VisionKitScannerView: UIViewControllerRepresentable {
    public typealias Completion = (Result<[ScannedPage], Error>) -> Void

    private let onCancel: () -> Void
    private let onComplete: Completion

    public init(
        onCancel: @escaping () -> Void,
        onComplete: @escaping Completion
    ) {
        self.onCancel = onCancel
        self.onComplete = onComplete
    }

    public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    public func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(onCancel: onCancel, onComplete: onComplete)
    }

    public final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let onCancel: () -> Void
        private let onComplete: Completion

        init(onCancel: @escaping () -> Void, onComplete: @escaping Completion) {
            self.onCancel = onCancel
            self.onComplete = onComplete
        }

        public func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            let pages = (0..<scan.pageCount).map {
                ScannedPage(image: scan.imageOfPage(at: $0))
            }
            onComplete(.success(pages))
        }

        public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            onCancel()
        }

        public func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            onComplete(.failure(error))
        }
    }
}
#endif
