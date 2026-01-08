import SwiftUI
import CoreData

struct CatalogView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Poem.dateAdded, ascending: false)],
        predicate: NSPredicate(format: "isInLibrary == false"),
        animation: .default)
    private var poems: FetchedResults<Poem>
    
    @State private var showingAddPoem = false
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var selectedTags: Set<String> = []
    
    var filteredPoems: [Poem] {
        let filtered = poems.filter { poem in
            // Text search filter
            let matchesSearch = searchText.isEmpty || 
                poem.title.localizedCaseInsensitiveContains(searchText) ||
                poem.author.localizedCaseInsensitiveContains(searchText) ||
                poem.fullText.localizedCaseInsensitiveContains(searchText) ||
                poem.category.localizedCaseInsensitiveContains(searchText) ||
                poem.tagsArray.contains { $0.localizedCaseInsensitiveContains(searchText) }
            
            // Category filter
            let matchesCategory = selectedCategory == "All" || poem.category == selectedCategory
            
            // Tags filter
            let matchesTags = selectedTags.isEmpty || !Set(poem.tagsArray).intersection(selectedTags).isEmpty
            
            return matchesSearch && matchesCategory && matchesTags
        }
        
        return Array(filtered)
    }
    
    var body: some View {
        VStack {
                HStack {
                    TextField("Search poems...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Add Poem") {
                        showingAddPoem = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.staticMeletaoAccent)
                }
                .padding()
                
                // Filters
                HStack(spacing: 16) {
                    // Category filter
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Category")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("Category", selection: $selectedCategory) {
                            Text("All").tag("All")
                            ForEach(Poem.categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 140)
                    }
                    
                    // Tag filter
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tags")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Menu(selectedTags.isEmpty ? "All Tags" : "\(selectedTags.count) selected") {
                            Button(action: {
                                selectedTags.removeAll()
                            }) {
                                HStack {
                                    Text("Clear All")
                                    if selectedTags.isEmpty {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Divider()
                            
                            ForEach(Poem.availableTags, id: \.self) { tag in
                                Button(action: {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                }) {
                                    HStack {
                                        Text(tag)
                                        if selectedTags.contains(tag) {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: 140)
                    }
                    
                    Spacer()
                    
                    // Clear all filters button
                    if selectedCategory != "All" || !selectedTags.isEmpty {
                        Button("Clear Filters") {
                            selectedCategory = "All"
                            selectedTags.removeAll()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                if filteredPoems.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(Color.staticMeletaoSecondary)
                        Text("No poems in catalog")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Add your first poem to get started")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.fixed(350)),
                            GridItem(.fixed(350))
                        ], spacing: 20) {
                            ForEach(filteredPoems, id: \.id) { poem in
                                PoemCard(poem: poem, isInCatalog: true)
                            }
                        }
                        .padding()
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                // Refresh is automatic due to @FetchRequest, but this ensures immediate update
            }
            .sheet(isPresented: $showingAddPoem) {
                AddPoemView(poemToEdit: nil)
            }
    }
}