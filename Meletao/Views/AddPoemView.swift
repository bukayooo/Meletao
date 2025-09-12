import SwiftUI
import CoreData

struct AddPoemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var author = ""
    @State private var text = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add New Poem")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Button("Save") {
                        savePoem()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(title.isEmpty || author.isEmpty || text.isEmpty)
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            // Form Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                        TextField("Enter poem title", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Author")
                            .font(.headline)
                        TextField("Enter author name", text: $author)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Text")
                                .font(.headline)
                            
                            Spacer()
                            
                            if !text.isEmpty {
                                Text("\(TextSectioningService.shared.wordCount(for: text)) words")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        TextEditor(text: $text)
                            .font(.system(.body, design: .default))
                            .frame(minHeight: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func savePoem() {
        let poem = Poem(context: viewContext)
        poem.id = UUID()
        poem.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        poem.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
        poem.fullText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        poem.wordCount = Int32(TextSectioningService.shared.wordCount(for: poem.fullText))
        poem.dateAdded = Date()
        poem.isInLibrary = false
        
        TextSectioningService.shared.createSectionsForPoem(poem, context: viewContext)
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            alertMessage = "Failed to save poem: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}