#if os(iOS)
@preconcurrency import AVFoundation
import UIKit

public final class ScannerCameraSession: NSObject, @unchecked Sendable {
    public let session = AVCaptureSession()

    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "documentscannerkit.session")

    private let lock = NSLock()
    private var photoContinuation: CheckedContinuation<UIImage, Error>?

    public override init() { super.init() }

    public func start() async throws {
        guard await Self.requestAuthorization() else { throw ScannerCameraError.notAuthorized }
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            sessionQueue.async {
                do {
                    try self.configureIfNeeded()
                    if !self.session.isRunning { self.session.startRunning() }
                    cont.resume()
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }

    public func stop() {
        sessionQueue.async { [session] in
            if session.isRunning { session.stopRunning() }
        }
    }

    public func capturePhoto() async throws -> UIImage {
        try await withCheckedThrowingContinuation { cont in
            lock.lock()
            photoContinuation = cont
            lock.unlock()
            sessionQueue.async {
                let settings = AVCapturePhotoSettings()
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
    }

    private func configureIfNeeded() throws {
        guard session.inputs.isEmpty else { return }
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            session.commitConfiguration()
            throw ScannerCameraError.deviceUnavailable
        }
        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else {
            session.commitConfiguration()
            throw ScannerCameraError.cannotAddInput
        }
        session.addInput(input)

        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }

        Self.lockToPortrait(connection: photoOutput.connection(with: .video))

        session.commitConfiguration()
    }

    private static func lockToPortrait(connection: AVCaptureConnection?) {
        guard let connection else { return }
        if #available(iOS 17.0, *) {
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
        } else if connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }
    }

    private static func requestAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return true
        case .notDetermined: return await AVCaptureDevice.requestAccess(for: .video)
        default: return false
        }
    }
}

extension ScannerCameraSession: AVCapturePhotoCaptureDelegate {
    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        lock.lock()
        let cont = photoContinuation
        photoContinuation = nil
        lock.unlock()
        if let error {
            cont?.resume(throwing: error)
            return
        }
        guard
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else {
            cont?.resume(throwing: ScannerCameraError.captureFailed)
            return
        }
        cont?.resume(returning: image)
    }
}
#endif
