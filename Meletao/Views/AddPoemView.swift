import SwiftUI
import CoreData

struct AddPoemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let poemToEdit: Poem?
    
    @State private var title = ""
    @State private var author = ""
    @State private var text = ""
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(poemToEdit: Poem? = nil) {
        self.poemToEdit = poemToEdit
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(poemToEdit == nil ? "Add New Poem" : "Edit Poem")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Button(poemToEdit == nil ? "Save" : "Update") {
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        TextEditor(text: $notes)
                            .font(.system(.body, design: .default))
                            .frame(minHeight: 100)
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
        .onAppear {
            if let poem = poemToEdit {
                title = poem.title
                author = poem.author
                text = poem.fullText
                notes = poem.notes
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func savePoem() {
        let poem: Poem
        
        if let existingPoem = poemToEdit {
            // Editing existing poem
            poem = existingPoem
        } else {
            // Creating new poem
            poem = Poem(context: viewContext)
            poem.id = UUID()
            poem.dateAdded = Date()
            poem.isInLibrary = false
            poem.notes = ""
        }
        
        poem.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        poem.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
        poem.fullText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        poem.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        poem.wordCount = Int32(TextSectioningService.shared.wordCount(for: poem.fullText))
        
        // Only recreate sections if text changed or it's a new poem
        if poemToEdit == nil || poemToEdit?.fullText != poem.fullText {
            TextSectioningService.shared.createSectionsForPoem(poem, context: viewContext)
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            alertMessage = "Failed to save poem: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}