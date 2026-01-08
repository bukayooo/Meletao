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
    
    var filteredPoems: [Poem] {
        if searchText.isEmpty {
            return Array(poems)
        } else {
            return poems.filter { poem in
                poem.title.localizedCaseInsensitiveContains(searchText) ||
                poem.author.localizedCaseInsensitiveContains(searchText) ||
                poem.fullText.localizedCaseInsensitiveContains(searchText)
            }
        }
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