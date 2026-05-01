#if os(iOS)
import SwiftUI
import UIKit

public struct DocumentScannerTestView: View {
    @State private var presented: ScannerKind?
    @State private var pages: [ScannedPage] = []
    @State private var errorMessage: String?

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                launcher
                Divider().padding(.top, 8)
                results
            }
            .navigationTitle("Scanner Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !pages.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") { pages.removeAll() }
                    }
                }
            }
            .alert("Scan Failed", isPresented: errorBinding) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .fullScreenCover(item: $presented) { kind in
                scannerCover(for: kind)
            }
        }
    }

    private var launcher: some View {
        VStack(spacing: 12) {
            Text("Pick a scanner to evaluate.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            launcherRow(
                title: "VisionKit (stock)",
                subtitle: "Apple's built-in scanner. Multi-page.",
                systemImage: "doc.viewfinder",
                kind: .visionKit
            )
            launcherRow(
                title: "Custom (Vision + AVFoundation)",
                subtitle: "Live quad overlay. Single capture.",
                systemImage: "viewfinder",
                kind: .custom
            )
        }
        .padding(20)
    }

    private func launcherRow(
        title: String,
        subtitle: String,
        systemImage: String,
        kind: ScannerKind
    ) -> some View {
        Button {
            presented = kind
        } label: {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.tertiary)
            }
            .padding()
            .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var results: some View {
        if pages.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "tray")
                    .font(.system(size: 36))
                    .foregroundStyle(.tertiary)
                Text("No scans yet")
                    .font(.headline)
                Text("Tap a scanner above to capture a page.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        } else {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 140), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        thumbnail(image: page.image, index: index)
                    }
                }
                .padding(16)
            }
        }
    }

    private func thumbnail(image: UIImage, index: Int) -> some View {
        VStack(spacing: 6) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text("Page \(index + 1)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func scannerCover(for kind: ScannerKind) -> some View {
        switch kind {
        case .visionKit:
            VisionKitScannerView(
                onCancel: { presented = nil },
                onComplete: { result in
                    presented = nil
                    switch result {
                    case .success(let scanned):
                        pages.append(contentsOf: scanned)
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
            )
            .ignoresSafeArea()

        case .custom:
            CustomScannerView(
                onCancel: { presented = nil },
                onCapture: { page in
                    presented = nil
                    pages.append(page)
                }
            )
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }
}

private enum ScannerKind: String, Identifiable {
    case visionKit
    case custom
    var id: String { rawValue }
}
#endif
