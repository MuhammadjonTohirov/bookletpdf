//
//  File.swift
//  BookletKit
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation
import SwiftUI

#if os(iOS)
struct CustomLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.blue)
            .underline()
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}
#endif

struct ButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        content
        #else
        content
            .buttonStyle(.link)
        #endif
    }
}

public extension View {
    func buttonStyleModifier() -> some View {
        modifier(ButtonStyleModifier())
    }
}
