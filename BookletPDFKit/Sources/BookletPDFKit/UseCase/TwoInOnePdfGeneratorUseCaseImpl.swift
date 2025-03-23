//
//  File.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 24/02/25.
//

import Foundation
import PDFKit

public protocol BookletPDFGeneratorUseCase {
    func makeBookletPDF(url: URL, completion: @Sendable @escaping (URL?) -> Void)
}

public struct TwoInOnePdfGeneratorUseCaseImpl: BookletPDFGeneratorUseCase {
    public init() {}
    
    public func makeBookletPDF(url: URL, completion: @Sendable @escaping (URL?) -> Void) {
        makeDocumentAsBooklet(url, completion: completion)
    }

    private func makeDocumentAsBooklet(_ url: URL, completion: @Sendable @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            autoreleasepool {
                if let originalPDF = PDFDocument(url: url) {
                    originalPDF.converTo(booklet: .type2, completion: completion)
                }
            }
        }
    }
}
