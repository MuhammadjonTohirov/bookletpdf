//
//  LoadingView.swift
//  bookletPdf
//
//  Created by applebro on 14/10/23.
//

import SwiftUI
import BookletPDFKit

struct LoadingView: View {
    let title: String
    var message: String = ""
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .center, spacing: Theme.Spacing.md) {
            // Custom animated progress indicator
            ZStack {
                Circle()
                    .stroke(Theme.Colors.border.opacity(0.3), lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        AngularGradient(
                            colors: [Theme.Colors.primary.opacity(0.3), Theme.Colors.primary],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            VStack(spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.primaryText)
                
                if !message.isEmpty {
                    Text(message)
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
        }
        .padding(Theme.Spacing.lg)
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.large))
        .onAppear {
            isAnimating = true
        }
        .smoothTransition()
    }
}

#Preview {
    LoadingView(title: "Loading", message: "Converting to something")
}
