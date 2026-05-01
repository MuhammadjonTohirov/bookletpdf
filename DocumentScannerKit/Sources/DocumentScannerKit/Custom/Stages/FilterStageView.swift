#if os(iOS)
import SwiftUI
import UIKit

struct FilterStageView: View {
    let correctedImage: UIImage
    let onBack: () -> Void
    let onDone: (UIImage, ScanFilter) -> Void

    @State private var selected: ScanFilter
    @State private var preview: UIImage

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var anchorScale: CGFloat = 1.0
    @State private var anchorOffset: CGSize = .zero

    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0

    init(
        correctedImage: UIImage,
        defaultFilter: ScanFilter = .enhanced,
        onBack: @escaping () -> Void,
        onDone: @escaping (UIImage, ScanFilter) -> Void
    ) {
        self.correctedImage = correctedImage
        self.onBack = onBack
        self.onDone = onDone
        _selected = State(initialValue: defaultFilter)
        _preview = State(initialValue: defaultFilter.apply(to: correctedImage))
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.black
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFit()
                    .padding(16)
                    .scaleEffect(scale, anchor: .center)
                    .offset(offset)
            }
            .clipped()
            .frame(maxHeight: .infinity)
            .gesture(zoomGesture.simultaneously(with: panGesture))

            FilterStripView(baseImage: correctedImage, selected: $selected)
                .background(Color.black)

            toolbar
        }
        .background(Color.black)
        .onChange(of: selected) { newValue in
            applyAsync(newValue)
        }
    }

    private var toolbar: some View {
        HStack(spacing: 20) {
            Button("Back", action: onBack)
                .foregroundStyle(.white)
            Spacer()
            if scale > 1.02 {
                Button("1x", action: resetZoom)
                    .foregroundStyle(.white)
                Spacer()
            }
            Button("Done") {
                let final = selected.apply(to: correctedImage)
                onDone(final, selected)
            }
            .bold()
            .foregroundStyle(Color.yellow)
        }
        .font(.headline)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(Color.black)
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { newScale in
                scale = min(max(anchorScale * newScale, minScale), maxScale)
            }
            .onEnded { _ in
                anchorScale = scale
            }
    }

    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: anchorOffset.width + value.translation.width,
                    height: anchorOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                anchorOffset = offset
            }
    }

    private func resetZoom() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 1.0
            offset = .zero
        }
        anchorScale = 1.0
        anchorOffset = .zero
    }

    private func applyAsync(_ filter: ScanFilter) {
        let source = correctedImage
        Task {
            let result = await Task.detached(priority: .userInitiated) {
                filter.apply(to: source)
            }.value
            preview = result
        }
    }
}
#endif
