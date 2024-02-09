//
//  LoadingView.swift
//  bookletPdf
//
//  Created by applebro on 14/10/23.
//

import SwiftUI

struct LoadingView: View {
    let title: String
    var message: String = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ProgressView(title)
            Text(message)
                .font(.system(size: 14))
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.init(uiColor: .secondarySystemBackground))
        }
    }
}

#Preview {
    LoadingView(title: "Loading", message: "Converting to something")
}
