import Foundation

public enum ScannerCameraError: Error, Sendable {
    case notAuthorized
    case deviceUnavailable
    case cannotAddInput
    case captureFailed
}
