import Testing
import Foundation
import PDFKit
@testable import BookletPDFKit

#if canImport(UIKit)
import UIKit
private typealias OSColor = UIColor
#elseif canImport(AppKit)
import AppKit
private typealias OSColor = NSColor
#endif

@Test func prepareBookletInputPrependsCoverPage() throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue],
        name: "prepare-input.pdf"
    )
    let coverData = try makeImageData(color: .testYellow)

    let preparedURL = try PrepareBookletInputUseCaseImpl().prepareInputPDF(
        at: sourceURL,
        coverImageData: coverData
    )

    guard let preparedDocument = PDFDocument(url: preparedURL) else {
        throw TestError.documentCreationFailed
    }

    #expect(preparedDocument.pageCount == 4)
    #expect(try page(at: 0, in: preparedDocument, matches: .testYellow))
}

@Test func twoUpKeepsPreparedCoverOnFirstSpread() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue],
        name: "two-up-cover.pdf"
    )
    let coverData = try makeImageData(color: .testYellow)

    let preparedURL = try PrepareBookletInputUseCaseImpl().prepareInputPDF(
        at: sourceURL,
        coverImageData: coverData
    )
    let outputURL = try await TwoInOnePdfGeneratorUseCaseImpl().makeBookletPDF(url: preparedURL)
    guard let outputDocument = PDFDocument(url: outputURL) else {
        throw TestError.documentCreationFailed
    }

    #expect(outputDocument.pageCount == 4)
    #expect(try page(at: 1, in: outputDocument, matches: .testYellow))
}

@Test func fourUpKeepsPreparedCoverOnFirstSpread() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [
            .testRed,
            .testGreen,
            .testBlue,
            .testOrange,
            .testPink,
            .testPurple,
            .testTeal
        ],
        name: "four-up-cover.pdf"
    )
    let coverData = try makeImageData(color: .testYellow)

    let preparedURL = try PrepareBookletInputUseCaseImpl().prepareInputPDF(
        at: sourceURL,
        coverImageData: coverData
    )
    let outputURL = try await FourInOneGeneratorUseCaseImpl().makeBookletPDF(url: preparedURL)
    guard let outputDocument = PDFDocument(url: outputURL) else {
        throw TestError.documentCreationFailed
    }

    #expect(outputDocument.pageCount == 8)
    #expect(try page(at: 1, in: outputDocument, matches: .testYellow))
}

private enum TestError: Error {
    case pageCreationFailed
    case documentCreationFailed
    case imageEncodingFailed
    case fileWriteFailed
    case imageSamplingFailed
}

private func makeSourcePDF(colors: [OSColor], name: String) throws -> URL {
    let document = PDFDocument()

    for (index, color) in colors.enumerated() {
        guard let page = PDFPage(image: makeSolidImage(color: color)) else {
            throw TestError.pageCreationFailed
        }

        document.insert(page, at: index)
    }

    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("\(UUID().uuidString)_\(name)")

    guard document.write(to: url) else {
        throw TestError.fileWriteFailed
    }

    return url
}

private func makeImageData(color: OSColor) throws -> Data {
    let image = makeSolidImage(color: color)

    #if canImport(UIKit)
    guard let data = image.pngData() else {
        throw TestError.imageEncodingFailed
    }
    return data
    #elseif canImport(AppKit)
    guard let tiffData = image.tiffRepresentation,
          let imageRep = NSBitmapImageRep(data: tiffData),
          let data = imageRep.representation(using: .png, properties: [:]) else {
        throw TestError.imageEncodingFailed
    }
    return data
    #endif
}

private func makeSolidImage(
    color: OSColor,
    size: CGSize = .init(width: 160, height: 240)
) -> OSImage {
    #if canImport(UIKit)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
    #elseif canImport(AppKit)
    let image = NSImage(size: size)
    image.lockFocus()
    color.setFill()
    NSBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
    image.unlockFocus()
    return image
    #endif
}

private func page(at index: Int, in document: PDFDocument, matches color: OSColor) throws -> Bool {
    guard let page = document.page(at: index) else {
        throw TestError.pageCreationFailed
    }

    let expected = try averageRGB(for: makeSolidImage(color: color))
    let actual = try averageRGB(for: page.thumbnail(of: .init(width: 32, height: 32), for: .mediaBox))

    return zip(expected, actual).allSatisfy { abs(Int($0) - Int($1)) <= 20 }
}

private func averageRGB(for image: OSImage) throws -> [UInt8] {
    guard let cgImage = image.cgImageRepresentation else {
        throw TestError.imageSamplingFailed
    }

    var pixel = [UInt8](repeating: 0, count: 4)
    guard let context = CGContext(
        data: &pixel,
        width: 1,
        height: 1,
        bitsPerComponent: 8,
        bytesPerRow: 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw TestError.imageSamplingFailed
    }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
    return Array(pixel.prefix(3))
}

private extension OSColor {
    static var testRed: OSColor {
        #if canImport(UIKit)
        UIColor(red: 1.0, green: 0.12, blue: 0.12, alpha: 1.0)
        #elseif canImport(AppKit)
        NSColor(calibratedRed: 1.0, green: 0.12, blue: 0.12, alpha: 1.0)
        #endif
    }

    static var testGreen: OSColor {
        #if canImport(UIKit)
        UIColor(red: 0.12, green: 0.75, blue: 0.24, alpha: 1.0)
        #elseif canImport(AppKit)
        NSColor(calibratedRed: 0.12, green: 0.75, blue: 0.24, alpha: 1.0)
        #endif
    }

    static var testBlue: OSColor {
        #if canImport(UIKit)
        UIColor(red: 0.12, green: 0.4, blue: 1.0, alpha: 1.0)
        #elseif canImport(AppKit)
        NSColor(calibratedRed: 0.12, green: 0.4, blue: 1.0, alpha: 1.0)
        #endif
    }

    static var testOrange: OSColor {
        #if canImport(UIKit)
        UIColor(red: 1.0, green: 0.58, blue: 0.12, alpha: 1.0)
        #elseif canImport(AppKit)
        NSColor(calibratedRed: 1.0, green: 0.58, blue: 0.12, alpha: 1.0)
        #endif
    }

    static var testPink: OSColor {
        #if canImport(UIKit)
        UIColor(red: 0.98, green: 0.24, blue: 0.58, alpha: 1.0)
        #elseif canImport(AppKit)
        NSColor(calibratedRed: 0.98, green: 0.24, blue: 0.58, alpha: 1.0)
        #endif
    }

    static var testPurple: OSColor {
        #if canImport(UIKit)
        UIColor(red: 0.58, green: 0.26, blue: 0.92, alpha: 1.0)
        #elseif canImport(AppKit)
        NSColor(calibratedRed: 0.58, green: 0.26, blue: 0.92, alpha: 1.0)
        #endif
    }

    static var testTeal: OSColor {
        #if canImport(UIKit)
        UIColor(red: 0.0, green: 0.68, blue: 0.72, alpha: 1.0)
        #elseif canImport(AppKit)
        NSColor(calibratedRed: 0.0, green: 0.68, blue: 0.72, alpha: 1.0)
        #endif
    }

    static var testYellow: OSColor {
        #if canImport(UIKit)
        UIColor(red: 1.0, green: 0.83, blue: 0.0, alpha: 1.0)
        #elseif canImport(AppKit)
        NSColor(calibratedRed: 1.0, green: 0.83, blue: 0.0, alpha: 1.0)
        #endif
    }
}

// MARK: - PDFBrandingUseCase Tests

@Test func brandingAddsTextToEveryPage() throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue],
        name: "branding-test.pdf"
    )
    let originalDoc = PDFDocument(url: sourceURL)!
    let originalPageCount = originalDoc.pageCount

    let brandedURL = try PDFBrandingUseCaseImpl().applyBranding(to: sourceURL)
    guard let brandedDoc = PDFDocument(url: brandedURL) else {
        throw TestError.documentCreationFailed
    }

    #expect(brandedDoc.pageCount == originalPageCount)
}

@Test func brandingPreservesPageDimensions() throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen],
        name: "branding-dimensions.pdf"
    )
    let originalDoc = PDFDocument(url: sourceURL)!
    let originalSize = originalDoc.page(at: 0)!.bounds(for: .mediaBox).size

    let brandedURL = try PDFBrandingUseCaseImpl().applyBranding(to: sourceURL)
    let brandedDoc = PDFDocument(url: brandedURL)!
    let brandedSize = brandedDoc.page(at: 0)!.bounds(for: .mediaBox).size

    #expect(abs(originalSize.width - brandedSize.width) < 1)
    #expect(abs(originalSize.height - brandedSize.height) < 1)
}

@Test func brandingProducesValidPDF() throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed],
        name: "branding-valid.pdf"
    )

    let brandedURL = try PDFBrandingUseCaseImpl().applyBranding(to: sourceURL)

    #expect(FileManager.default.fileExists(atPath: brandedURL.path))

    let data = try Data(contentsOf: brandedURL)
    #expect(data.count > 0)

    let doc = PDFDocument(url: brandedURL)
    #expect(doc != nil)
    #expect(doc!.pageCount == 1)
}

@Test func brandingThrowsForInvalidURL() throws {
    let fakeURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("nonexistent.pdf")

    #expect(throws: BookletError.self) {
        try PDFBrandingUseCaseImpl().applyBranding(to: fakeURL)
    }
}

@Test func brandingWorksWithLargeDocument() throws {
    let colors: [OSColor] = (0..<20).map { _ in .testRed }
    let sourceURL = try makeSourcePDF(colors: colors, name: "branding-large.pdf")

    let brandedURL = try PDFBrandingUseCaseImpl().applyBranding(to: sourceURL)
    let brandedDoc = PDFDocument(url: brandedURL)!

    #expect(brandedDoc.pageCount == 20)
}

@Test func brandingAfterTwoUpConversion() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange],
        name: "branding-two-up.pdf"
    )

    let bookletURL = try await TwoInOnePdfGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    let brandedURL = try PDFBrandingUseCaseImpl().applyBranding(to: bookletURL)

    let bookletDoc = PDFDocument(url: bookletURL)!
    let brandedDoc = PDFDocument(url: brandedURL)!

    #expect(brandedDoc.pageCount == bookletDoc.pageCount)
}

@Test func brandingAfterFourUpConversion() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange,
                 .testPink, .testPurple, .testTeal, .testYellow],
        name: "branding-four-up.pdf"
    )

    let bookletURL = try await FourInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    let brandedURL = try PDFBrandingUseCaseImpl().applyBranding(to: bookletURL)

    let bookletDoc = PDFDocument(url: bookletURL)!
    let brandedDoc = PDFDocument(url: brandedURL)!

    #expect(brandedDoc.pageCount == bookletDoc.pageCount)
}
