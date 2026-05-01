#if os(iOS)
import SwiftUI
import UIKit

@MainActor
final class CustomScannerCoordinator: ObservableObject {
    let session = ScannerCameraSession()

    @Published var isCapturing = false
    @Published var startupError: ScannerCameraError?

    func start() async {
        do {
            try await session.start()
        } catch let error as ScannerCameraError {
            startupError = error
        } catch {
            startupError = .captureFailed
        }
    }

    func stop() {
        session.stop()
    }

    func captureRaw() async -> UIImage? {
        guard !isCapturing else { return nil }
        isCapturing = true
        defer { isCapturing = false }
        do {
            return try await session.capturePhoto()
        } catch {
            return nil
        }
    }
}
#endif
