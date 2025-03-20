//
//  HomeView.swift
//  BookLet
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation
#if canImport(BookletKit)
import BookletKit
#endif

import SwiftUI

struct HomeView: View {
    let recentProjects: [String] = ["Project1.pdf", "Booklet2.pdf", "Manual3.pdf"] // Example data
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Welcome Section
            Text("Welcome to PDF Booklet Maker!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Easily create, customize, and print your booklets in just a few steps.")
                .font(.headline)
                .foregroundStyle(.secondary)

            // Quick Actions
            HStack(spacing: 15) {
                Button("Create New Booklet") {
                    // Create project logic
                }
                .buttonStyle(.borderedProminent)

                Button("Open Existing Project") {
                    // Open file logic
                }
                .buttonStyle(.bordered)
            }

            // Recent Projects
            if !recentProjects.isEmpty {
                VStack(alignment: .leading) {
                    Text("Recent Projects")
                        .font(.title2)
                        .fontWeight(.semibold)

                    List(recentProjects, id: \.self) { project in
                        HStack {
                            Text(project)
                            Spacer()
                            Button("Open") {
                                // Open project logic
                            }
                            .buttonStyleModifier()
                        }
                    }
                }
            }

            Spacer()

            // Footer
            Text("Version 1.0.0")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
