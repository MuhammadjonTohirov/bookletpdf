//
//  FourInOneGeneratorUseCaseImpl.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 24/03/25.
//

import Foundation
import PDFKit

public protocol FourInOneGeneratorUseCase {
    func makeFourInOnePDF(url: URL, completion: @Sendable @escaping (URL?) -> Void)
}

public final class FourInOneGeneratorUseCaseImpl: FourInOneGeneratorUseCase {
    public init() {}
    
    public func makeFourInOnePDF(url: URL, completion: @Sendable @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            autoreleasepool {
                if let originalPDF = PDFDocument(url: url) {
                    originalPDF.converTo(booklet: .type4, completion: completion)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
