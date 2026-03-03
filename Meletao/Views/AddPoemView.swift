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
    @State private var category = "Poem"
    @State private var selectedTags: Set<String> = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingTagPicker = false
    
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
                        Text("Category")
                            .font(.headline)
                        Picker("Category", selection: $category) {
                            ForEach(Poem.categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: 200, alignment: .leading)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                        
                        if !selectedTags.isEmpty {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                                ForEach(Array(selectedTags).sorted(), id: \.self) { tag in
                                    HStack {
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(12)
                                        
                                        Button(action: {
                                            selectedTags.remove(tag)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        
                        Button(action: { showingTagPicker.toggle() }) {
                            HStack(spacing: 4) {
                                Text("Add Tags")
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.bordered)
                        .popover(isPresented: $showingTagPicker, arrowEdge: .bottom) {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(Poem.availableTags, id: \.self) { tag in
                                        Button(action: {
                                            if selectedTags.contains(tag) {
                                                selectedTags.remove(tag)
                                            } else {
                                                selectedTags.insert(tag)
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: selectedTags.contains(tag) ? "checkmark.square.fill" : "square")
                                                    .foregroundColor(selectedTags.contains(tag) ? .blue : .secondary)
                                                Text(tag)
                                                Spacer()
                                            }
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .frame(minWidth: 160, maxHeight: 300)
                        }
                        .frame(maxWidth: 150, alignment: .leading)
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
                            .frame(height: 200)
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
                            .frame(height: 100)
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
                category = poem.category
                selectedTags = Set(poem.tagsArray)
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
            poem.category = "Poem"
            poem.tags = ""
        }
        
        poem.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        poem.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
        poem.fullText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        poem.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        poem.category = category
        poem.setTags(Array(selectedTags))
        poem.wordCount = Int32(TextSectioningService.shared.wordCount(for: poem.fullText))

        // Always recreate sections to ensure newlines are preserved
        // Delete old sections first if editing
        if poemToEdit != nil {
            poem.sectionsArray.forEach { section in
                viewContext.delete(section)
            }
        }
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