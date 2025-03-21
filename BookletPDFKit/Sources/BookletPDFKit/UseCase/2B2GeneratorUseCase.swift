//
//  File.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 24/02/25.
//

import Foundation
import PDFKit

public protocol PDF2B2GeneratorUseCase {
    func makeBookletPDF(url: URL, completion: @Sendable @escaping (URL?) -> Void)
}

public final class PDF2B2GeneratorUseCaseImpl: PDF2B2GeneratorUseCase {
    public init() {}
    public func makeBookletPDF(url: URL, completion: @Sendable @escaping (URL?) -> Void) {
        makeDocumentAsBooklet(url, completion: completion)
    }

    private func makeDocumentAsBooklet(_ url: URL, completion: @Sendable @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            autoreleasepool {
                if let originalPDF = PDFDocument(url: url) {
                    originalPDF.converTo(booklet: .type2B2, completion: completion)
                }
            }
        }
    }
}
