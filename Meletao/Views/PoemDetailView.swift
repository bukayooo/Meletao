import SwiftUI

struct PoemDetailView: View {
    let poem: Poem
    let isInCatalog: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = false
    @State private var showingEditSheet = false
    @State private var shouldNavigateToStudy = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(poem.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("by \(poem.author)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Close") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    if isInCatalog {
                        Button("Add to Library") {
                            addToLibrary()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Study") {
                            shouldNavigateToStudy = true
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Remove") {
                            showingAlert = true
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            // Poem metadata
            HStack(spacing: 20) {
                Label("\(poem.wordCount) words", systemImage: "textformat")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(poem.sectionCount) sections", systemImage: "list.number")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !isInCatalog && poem.shouldReview {
                    Label("Review due", systemImage: "clock.badge.exclamationmark")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Text("Added \(poem.dateAdded, style: .date)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.controlBackgroundColor))
            
            // Full poem text and notes
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Poem")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Text(poem.fullText)
                            .font(.system(.body, design: .serif))
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .textSelection(.enabled)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    
                    if !poem.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text(poem.notes)
                                .font(.system(.body))
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .textSelection(.enabled)
                                .background(Color(.controlBackgroundColor))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .sheet(isPresented: $showingEditSheet) {
            AddPoemView(poemToEdit: poem)
        }
        .sheet(isPresented: $shouldNavigateToStudy) {
            NavigationStack {
                MemorizationView(poem: poem)
            }
        }
        .alert("Remove from Library", isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                removeFromLibrary()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to remove this poem from your library?")
        }
    }
    
    private func addToLibrary() {
        poem.isInLibrary = true
        
        do {
            try viewContext.save()
            NotificationService.shared.updateAppBadge(context: viewContext)
            dismiss()
        } catch {
            print("Error adding poem to library: \(error)")
        }
    }
    
    private func removeFromLibrary() {
        poem.isInLibrary = false
        
        do {
            try viewContext.save()
            NotificationService.shared.updateAppBadge(context: viewContext)
        } catch {
            print("Error removing poem from library: \(error)")
        }
    }
}