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

private func makeSourcePDF(images: [OSImage], name: String) throws -> URL {
    let document = PDFDocument()

    for (index, image) in images.enumerated() {
        guard let page = PDFPage(image: image) else {
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

private func makeTopBottomImage(
    top: OSColor,
    bottom: OSColor,
    size: CGSize = .init(width: 160, height: 240)
) -> OSImage {
    #if canImport(UIKit)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        top.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height / 2))
        bottom.setFill()
        context.fill(CGRect(x: 0, y: size.height / 2, width: size.width, height: size.height / 2))
    }
    #elseif canImport(AppKit)
    let image = NSImage(size: size)
    image.lockFocus()
    bottom.setFill()
    NSBezierPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height / 2)).fill()
    top.setFill()
    NSBezierPath(rect: CGRect(x: 0, y: size.height / 2, width: size.width, height: size.height / 2)).fill()
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

// MARK: - MergedTwoInOneGenerator Tests

@Test func mergedTwoUpHalvesPageCountForAlignedInput() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange],
        name: "merged-4p.pdf"
    )

    let outputURL = try await MergedTwoInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(doc.pageCount == 2)
}

@Test func mergedTwoUpPadsToMultipleOfFour() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange, .testPink],
        name: "merged-5p.pdf"
    )

    let outputURL = try await MergedTwoInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(doc.pageCount == 4)
}

@Test func mergedTwoUpHandlesSinglePageInput() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed],
        name: "merged-1p.pdf"
    )

    let outputURL = try await MergedTwoInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(doc.pageCount == 2)
}

@Test func mergedTwoUpHandlesTwoPageInput() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen],
        name: "merged-2p.pdf"
    )

    let outputURL = try await MergedTwoInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(doc.pageCount == 2)
}

@Test func mergedTwoUpHandlesThreePageInput() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue],
        name: "merged-3p.pdf"
    )

    let outputURL = try await MergedTwoInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(doc.pageCount == 2)
}

@Test func mergedTwoUpOutputIsLandscape() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange],
        name: "merged-landscape.pdf"
    )

    guard let sourceDoc = PDFDocument(url: sourceURL),
          let sourcePage = sourceDoc.page(at: 0) else {
        throw TestError.documentCreationFailed
    }
    let sourceSize = sourcePage.bounds(for: .mediaBox).size

    let outputURL = try await MergedTwoInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL),
          let outputPage = doc.page(at: 0) else {
        throw TestError.documentCreationFailed
    }
    let outputSize = outputPage.bounds(for: .mediaBox).size

    #expect(abs(outputSize.width - sourceSize.width * 2) < 1)
    #expect(abs(outputSize.height - sourceSize.height) < 1)
}

@Test func mergedTwoUpPlacesLastAndFirstOnOuterSheet() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange],
        name: "merged-outer.pdf"
    )

    let outputURL = try await MergedTwoInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(try mergedSheet(at: 0, in: doc, leftMatches: .testOrange, rightMatches: .testRed))
}

@Test func mergedTwoUpPlacesInnerPagesOnInnerSheet() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange],
        name: "merged-inner.pdf"
    )

    let outputURL = try await MergedTwoInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(try mergedSheet(at: 1, in: doc, leftMatches: .testGreen, rightMatches: .testBlue))
}

// MARK: - MergedTwoInOneGenerator Split Tests (iOS manual-simplex flow)

@Test func splitBookletProducesFrontAndBackForFourPageInput() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange],
        name: "split-4p.pdf"
    )

    let split = try await MergedTwoInOneGeneratorUseCaseImpl().makeSplitBookletPDFs(url: sourceURL)

    guard let frontDoc = PDFDocument(url: split.front),
          let backDoc = PDFDocument(url: split.back) else {
        throw TestError.documentCreationFailed
    }

    // 4-page input → 2 merged sheets → 1 front + 1 back
    #expect(frontDoc.pageCount == 1)
    #expect(backDoc.pageCount == 1)
}

@Test func splitBookletEightPageInputHasTwoFrontsAndTwoBacks() async throws {
    // 5-page source is padded to 8 → 4 merged sheets → 2 fronts + 2 backs
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange, .testPink],
        name: "split-5p.pdf"
    )

    let split = try await MergedTwoInOneGeneratorUseCaseImpl().makeSplitBookletPDFs(url: sourceURL)

    guard let frontDoc = PDFDocument(url: split.front),
          let backDoc = PDFDocument(url: split.back) else {
        throw TestError.documentCreationFailed
    }

    #expect(frontDoc.pageCount == 2)
    #expect(backDoc.pageCount == 2)
}

@Test func splitBookletFrontContainsOutermostSheet() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange],
        name: "split-front.pdf"
    )

    let split = try await MergedTwoInOneGeneratorUseCaseImpl().makeSplitBookletPDFs(url: sourceURL)
    guard let frontDoc = PDFDocument(url: split.front) else {
        throw TestError.documentCreationFailed
    }

    // Outermost front sheet = [last page, first page] = [orange, red]
    #expect(try mergedSheet(at: 0, in: frontDoc, leftMatches: .testOrange, rightMatches: .testRed))
}

@Test func splitBookletBackContainsInnerSheet() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange],
        name: "split-back.pdf"
    )

    let split = try await MergedTwoInOneGeneratorUseCaseImpl().makeSplitBookletPDFs(url: sourceURL)
    guard let backDoc = PDFDocument(url: split.back) else {
        throw TestError.documentCreationFailed
    }

    // Outermost back sheet = [green, blue] (simplex-flip layout)
    #expect(try mergedSheet(at: 0, in: backDoc, leftMatches: .testGreen, rightMatches: .testBlue))
}

@Test func splitBookletOutputMatchesMergedInTotal() async throws {
    // Merged page count should equal front + back combined.
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange, .testPink],
        name: "split-total.pdf"
    )

    let generator = MergedTwoInOneGeneratorUseCaseImpl()
    let mergedURL = try await generator.makeBookletPDF(url: sourceURL)
    let split = try await generator.makeSplitBookletPDFs(url: sourceURL)

    guard let mergedDoc = PDFDocument(url: mergedURL),
          let frontDoc = PDFDocument(url: split.front),
          let backDoc = PDFDocument(url: split.back) else {
        throw TestError.documentCreationFailed
    }

    #expect(mergedDoc.pageCount == frontDoc.pageCount + backDoc.pageCount)
}

@Test func splitBookletOutputIsLandscape() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange],
        name: "split-landscape.pdf"
    )

    guard let sourceDoc = PDFDocument(url: sourceURL),
          let sourcePage = sourceDoc.page(at: 0) else {
        throw TestError.documentCreationFailed
    }
    let sourceSize = sourcePage.bounds(for: .mediaBox).size

    let split = try await MergedTwoInOneGeneratorUseCaseImpl().makeSplitBookletPDFs(url: sourceURL)
    guard let frontDoc = PDFDocument(url: split.front),
          let frontPage = frontDoc.page(at: 0),
          let backDoc = PDFDocument(url: split.back),
          let backPage = backDoc.page(at: 0) else {
        throw TestError.documentCreationFailed
    }

    let frontSize = frontPage.bounds(for: .mediaBox).size
    let backSize = backPage.bounds(for: .mediaBox).size

    #expect(abs(frontSize.width - sourceSize.width * 2) < 1)
    #expect(abs(frontSize.height - sourceSize.height) < 1)
    #expect(abs(backSize.width - sourceSize.width * 2) < 1)
    #expect(abs(backSize.height - sourceSize.height) < 1)
}

// MARK: - MergedFourInOneGenerator Tests

@Test func mergedFourUpQuartersPageCountForAlignedInput() async throws {
    // 8 pages → 1 sheet → 2 output pages (front + back)
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange,
                 .testPink, .testPurple, .testTeal, .testYellow],
        name: "merged4-8p.pdf"
    )

    let outputURL = try await MergedFourInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(doc.pageCount == 2)
}

@Test func mergedFourUpPadsToMultipleOfEight() async throws {
    // 5 pages → padded to 8 → 2 output pages
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange, .testPink],
        name: "merged4-5p.pdf"
    )

    let outputURL = try await MergedFourInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(doc.pageCount == 2)
}

@Test func mergedFourUpHandlesSinglePageInput() async throws {
    let sourceURL = try makeSourcePDF(colors: [.testRed], name: "merged4-1p.pdf")
    let outputURL = try await MergedFourInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }
    #expect(doc.pageCount == 2)
}

@Test func mergedFourUpHandlesNinePageInput() async throws {
    // 9 pages → padded to 16 → 2 sheets → 4 output pages
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange,
                 .testPink, .testPurple, .testTeal, .testYellow, .testRed],
        name: "merged4-9p.pdf"
    )

    let outputURL = try await MergedFourInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(doc.pageCount == 4)
}

@Test func mergedFourUpDistributesTenPageBlanksAcrossTwoSheets() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange,
                 .testPink, .testPurple, .testTeal, .testYellow,
                 .testRed, .testGreen],
        name: "merged4-10p.pdf"
    )

    let outputURL = try await MergedFourInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(doc.pageCount == 4)
    #expect(try mergedQuadSheet(
        at: 0, in: doc,
        topLeft: .white, topRight: .testRed,
        bottomLeft: .white, bottomRight: .testPink
    ))
    #expect(try mergedQuadSheet(
        at: 1, in: doc,
        topLeft: .testGreen, topRight: .white,
        bottomLeft: .testPurple, bottomRight: .white
    ))
    #expect(try mergedQuadSheet(
        at: 2, in: doc,
        topLeft: .white, topRight: .testBlue,
        bottomLeft: .testGreen, bottomRight: .testTeal
    ))
    #expect(try mergedQuadSheet(
        at: 3, in: doc,
        topLeft: .testOrange, topRight: .white,
        bottomLeft: .testYellow, bottomRight: .testRed
    ))
}

@Test func mergedFourUpOutputIsDoubleBothDimensions() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange,
                 .testPink, .testPurple, .testTeal, .testYellow],
        name: "merged4-size.pdf"
    )

    guard let sourceDoc = PDFDocument(url: sourceURL),
          let sourcePage = sourceDoc.page(at: 0) else {
        throw TestError.documentCreationFailed
    }
    let sourceSize = sourcePage.bounds(for: .mediaBox).size

    let outputURL = try await MergedFourInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL),
          let outputPage = doc.page(at: 0) else {
        throw TestError.documentCreationFailed
    }
    let outputSize = outputPage.bounds(for: .mediaBox).size

    #expect(abs(outputSize.width - sourceSize.width * 2) < 1)
    #expect(abs(outputSize.height - sourceSize.height * 2) < 1)
}

@Test func mergedFourUpPlacesOuterSheetQuadrants() async throws {
    // 8-page input. Sheet 0 front should carry [8, 1, 6, 3]
    // in 2x2 grid as TL, TR, BL, BR respectively.
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange,
                 .testPink, .testPurple, .testTeal, .testYellow],
        name: "merged4-outer-front.pdf"
    )

    let outputURL = try await MergedFourInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(try mergedQuadSheet(
        at: 0, in: doc,
        topLeft: .testYellow, topRight: .testRed,
        bottomLeft: .testPurple, bottomRight: .testBlue
    ))
}

@Test func mergedFourUpPlacesOuterSheetBackQuadrants() async throws {
    // Sheet 0 back should carry [2, 7, 4, 5].
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange,
                 .testPink, .testPurple, .testTeal, .testYellow],
        name: "merged4-outer-back.pdf"
    )

    let outputURL = try await MergedFourInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(try mergedQuadSheet(
        at: 1, in: doc,
        topLeft: .testGreen, topRight: .testTeal,
        bottomLeft: .testOrange, bottomRight: .testPink
    ))
}

@Test func mergedFourUpFourPageInputUsesOneCutStrip() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange],
        name: "merged4-4p-one-strip.pdf"
    )

    let outputURL = try await MergedFourInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL) else { throw TestError.documentCreationFailed }

    #expect(try mergedQuadSheet(
        at: 0, in: doc,
        topLeft: .white, topRight: .testRed,
        bottomLeft: .white, bottomRight: .testBlue
    ))
    #expect(try mergedQuadSheet(
        at: 1, in: doc,
        topLeft: .testGreen, topRight: .white,
        bottomLeft: .testOrange, bottomRight: .white
    ))
}

@Test func mergedFourUpKeepsHorizontalCutStripsUpright() async throws {
    let marker = makeTopBottomImage(top: .testRed, bottom: .testBlue)
    let sourceURL = try makeSourcePDF(
        images: Array(repeating: marker, count: 8),
        name: "merged4-rotation.pdf"
    )

    let outputURL = try await MergedFourInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    guard let doc = PDFDocument(url: outputURL),
          let frontPage = doc.page(at: 0),
          let backPage = doc.page(at: 1) else {
        throw TestError.documentCreationFailed
    }

    let front = frontPage.thumbnail(of: .init(width: 64, height: 64), for: .mediaBox)
    let back = backPage.thumbnail(of: .init(width: 64, height: 64), for: .mediaBox)
    let expectedTop = try averageRGB(for: makeSolidImage(color: .testRed))
    let tolerance = 40

    let frontTopRight = try sampleRGB(of: front, cropTo: CGRect(x: 40, y: 2, width: 8, height: 8))
    let frontBottomRight = try sampleRGB(of: front, cropTo: CGRect(x: 40, y: 34, width: 8, height: 8))
    let backTopRight = try sampleRGB(of: back, cropTo: CGRect(x: 40, y: 2, width: 8, height: 8))
    let backBottomRight = try sampleRGB(of: back, cropTo: CGRect(x: 40, y: 34, width: 8, height: 8))

    #expect(zip(expectedTop, frontTopRight).allSatisfy { abs(Int($0) - Int($1)) <= tolerance })
    #expect(zip(expectedTop, frontBottomRight).allSatisfy { abs(Int($0) - Int($1)) <= tolerance })
    #expect(zip(expectedTop, backTopRight).allSatisfy { abs(Int($0) - Int($1)) <= tolerance })
    #expect(zip(expectedTop, backBottomRight).allSatisfy { abs(Int($0) - Int($1)) <= tolerance })
}

@Test func mergedFourUpSplitProducesFrontAndBack() async throws {
    let sourceURL = try makeSourcePDF(
        colors: [.testRed, .testGreen, .testBlue, .testOrange,
                 .testPink, .testPurple, .testTeal, .testYellow],
        name: "merged4-split.pdf"
    )

    let mergedURL = try await MergedFourInOneGeneratorUseCaseImpl().makeBookletPDF(url: sourceURL)
    let split = try await MergedPDFSplitter().split(mergedURL: mergedURL)

    guard let frontDoc = PDFDocument(url: split.front),
          let backDoc = PDFDocument(url: split.back) else {
        throw TestError.documentCreationFailed
    }

    // 1 sheet → 1 front + 1 back.
    #expect(frontDoc.pageCount == 1)
    #expect(backDoc.pageCount == 1)
}

private func mergedQuadSheet(
    at index: Int,
    in document: PDFDocument,
    topLeft: OSColor,
    topRight: OSColor,
    bottomLeft: OSColor,
    bottomRight: OSColor
) throws -> Bool {
    guard let page = document.page(at: index) else {
        throw TestError.pageCreationFailed
    }

    let thumbnail = page.thumbnail(of: .init(width: 64, height: 64), for: .mediaBox)
    // Image coords are top-left origin: low Y is the top of the image.
    let tl = try sampleRGB(of: thumbnail, cropTo: CGRect(x: 8,  y: 8,  width: 16, height: 16))
    let tr = try sampleRGB(of: thumbnail, cropTo: CGRect(x: 40, y: 8,  width: 16, height: 16))
    let bl = try sampleRGB(of: thumbnail, cropTo: CGRect(x: 8,  y: 40, width: 16, height: 16))
    let br = try sampleRGB(of: thumbnail, cropTo: CGRect(x: 40, y: 40, width: 16, height: 16))

    let samples: [(OSColor, [UInt8])] = [
        (topLeft, tl), (topRight, tr),
        (bottomLeft, bl), (bottomRight, br)
    ]

    let tolerance = 50
    for (expectedColor, actual) in samples {
        let expected = try averageRGB(for: makeSolidImage(color: expectedColor))
        let ok = zip(expected, actual).allSatisfy { abs(Int($0) - Int($1)) <= tolerance }
        if !ok { return false }
    }
    return true
}

private func mergedSheet(
    at index: Int,
    in document: PDFDocument,
    leftMatches leftColor: OSColor,
    rightMatches rightColor: OSColor
) throws -> Bool {
    guard let page = document.page(at: index) else {
        throw TestError.pageCreationFailed
    }

    let thumbnail = page.thumbnail(of: .init(width: 64, height: 32), for: .mediaBox)
    let leftActual = try sampleRGB(of: thumbnail, cropTo: CGRect(x: 8, y: 8, width: 16, height: 16))
    let rightActual = try sampleRGB(of: thumbnail, cropTo: CGRect(x: 40, y: 8, width: 16, height: 16))

    let leftExpected = try averageRGB(for: makeSolidImage(color: leftColor))
    let rightExpected = try averageRGB(for: makeSolidImage(color: rightColor))

    let tolerance = 40
    let leftOK = zip(leftExpected, leftActual).allSatisfy { abs(Int($0) - Int($1)) <= tolerance }
    let rightOK = zip(rightExpected, rightActual).allSatisfy { abs(Int($0) - Int($1)) <= tolerance }

    return leftOK && rightOK
}

private func sampleRGB(of image: OSImage, cropTo rect: CGRect) throws -> [UInt8] {
    guard let cgImage = image.cgImageRepresentation,
          let cropped = cgImage.cropping(to: rect) else {
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

    context.draw(cropped, in: CGRect(x: 0, y: 0, width: 1, height: 1))
    return Array(pixel.prefix(3))
}
