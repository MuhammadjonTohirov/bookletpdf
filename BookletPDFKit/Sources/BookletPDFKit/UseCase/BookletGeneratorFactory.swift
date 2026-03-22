//
//  BookletGeneratorFactory.swift
//  BookletPDFKit
//
//  Created by Gemini on 24/02/25.
//

import Foundation

public protocol BookletGeneratorFactory {
    func makeGenerator(for type: BookletType) -> any BookletPDFGeneratorUseCase
}

public struct BookletGeneratorFactoryImpl: BookletGeneratorFactory {
    private let generators: [BookletType: any BookletPDFGeneratorUseCase]

    public init(generators: [BookletType: any BookletPDFGeneratorUseCase] = [
        .type2: TwoInOnePdfGeneratorUseCaseImpl(),
        .type4: FourInOneGeneratorUseCaseImpl()
    ]) {
        self.generators = generators
    }

    public func makeGenerator(for type: BookletType) -> any BookletPDFGeneratorUseCase {
        guard let generator = generators[type] else {
            fatalError("No generator registered for \(type)")
        }
        return generator
    }
}
