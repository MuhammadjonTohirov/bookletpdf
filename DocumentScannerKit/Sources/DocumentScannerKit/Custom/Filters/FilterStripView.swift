#if os(iOS)
import SwiftUI
import UIKit

struct FilterStripView: View {
    let baseImage: UIImage
    @Binding var selected: ScanFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ScanFilter.allCases) { filter in
                    Button {
                        selected = filter
                    } label: {
                        FilterThumbnail(
                            filter: filter,
                            baseImage: baseImage,
                            isSelected: filter == selected
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

private struct FilterThumbnail: View {
    let filter: ScanFilter
    let baseImage: UIImage
    let isSelected: Bool

    @State private var thumbnail: UIImage?

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                if let thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle().fill(Color.gray.opacity(0.25))
                }
            }
            .frame(width: 64, height: 84)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.yellow : Color.white.opacity(0.2), lineWidth: 2)
            )
            Text(filter.displayName)
                .font(.caption2)
                .foregroundStyle(isSelected ? Color.yellow : Color.white.opacity(0.8))
        }
        .task(id: filter) {
            await renderThumbnail()
        }
    }

    private func renderThumbnail() async {
        let downsized = baseImage.dskDownsized(toLongestSide: 220)
        let filter = self.filter
        let result = await Task.detached(priority: .userInitiated) {
            filter.apply(to: downsized)
        }.value
        thumbnail = result
    }
}
#endif
