//
//  InfoView.swift
//  bookletPdf
//
//  Created by applebro on 29/09/23.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        List {
            Text("Welcome to Booklet Generator! 📚")
            Section(header: Text("About the app")) {
                Text("Transform regular PDFs into booklets effortlessly. Select your PDF, and our app rearranges pages into a neat booklet format, ready for printing. Simplify your printing tasks with our intuitive interface. Download now and experience the magic! 🚀")
                
            }
            
            Section(header: Text("Generating Booklet")) {
                Text("Click button \"Select pdf file\"")
                Text("Pick a PDF document")
                Text("Click button \"Convert to booklet\"")
                Text("Wait a while till the process finishes")
                Text("The pdf document should be visible by reordering pages from original PDF document")
            }
            
            Section(header: Text("Printing")) {
                HStack {
                    Text("Click button")
                    Image(systemName: "square.and.arrow.up")
                    Text("to save the document")
                }
                
                Text("Open generated document")
                
                HStack {
                    Text("Click")
                    Image(systemName: "command")
                    Text("+  P")
                }
                
                Text("In layout section change value of \"Pages per sheet\" into 2")
                
                Text("In Paper handling section change value of \"Sheets to print\" into \"Odd only\"")
                
                Text("Click button \"Print\"")
                
                Text("After printing only odd pages turn around the papers and repeat the same proccess")
                
                Text("Except")
                
                Text("In layout section select second option from \"Layout direction\"")
                
                Text("In Paper handling section change value of \"Sheets to print\" into \"Even only\"")
            }
        }
        .navigationTitle("Info")
    }
}

#Preview {
    InfoView()
}
