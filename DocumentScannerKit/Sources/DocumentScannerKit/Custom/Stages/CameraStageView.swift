#if os(iOS)
import SwiftUI
import UIKit

struct CameraStageView: View {
    @StateObject private var coordinator = CustomScannerCoordinator()

    let onCancel: () -> Void
    let onCaptured: (UIImage) -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScannerCameraPreviewView(session: coordinator.session.session)
                .ignoresSafeArea()

            VStack {
                topBar
                Spacer()
                shutterButton
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .task { await coordinator.start() }
        .onDisappear { coordinator.stop() }
    }

    private var topBar: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(Circle().fill(Color.black.opacity(0.4)))
            }
            Spacer()
        }
        .padding(.top, 8)
    }

    private var shutterButton: some View {
        Button {
            Task {
                if let raw = await coordinator.captureRaw() {
                    onCaptured(raw)
                }
            }
        } label: {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.7), lineWidth: 4)
                    .frame(width: 84, height: 84)
                Circle()
                    .fill(Color.white)
                    .frame(width: 68, height: 68)
            }
        }
        .disabled(coordinator.isCapturing)
        .opacity(coordinator.isCapturing ? 0.5 : 1)
    }
}
#endif
