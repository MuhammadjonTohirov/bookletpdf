//
//  ProBadgeView.swift
//  bookletPdf
//

import SwiftUI

struct ProBadgeView: View {
    var body: some View {
        Text(verbatim: "PRO")
            .font(.system(size: 9, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.yellow],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: Capsule()
            )
    }
}

#Preview {
    ProBadgeView()
}
