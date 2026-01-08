import SwiftUI
import CoreData

struct LibraryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Poem.dateAdded, ascending: false)],
        predicate: NSPredicate(format: "isInLibrary == true"),
        animation: .default)
    private var poems: FetchedResults<Poem>
    
    @State private var searchText = ""
    @State private var selectedFilter: FilterType = .all
    
    enum FilterType: String, CaseIterable {
        case all = "All"
        case needsReview = "Needs Review"
        case recent = "Recently Added"
        
        var systemImage: String {
            switch self {
            case .all: return "books.vertical"
            case .needsReview: return "clock.badge.exclamationmark"
            case .recent: return "clock"
            }
        }
    }
    
    var filteredPoems: [Poem] {
        var filtered = Array(poems)
        
        if !searchText.isEmpty {
            filtered = filtered.filter { poem in
                poem.title.localizedCaseInsensitiveContains(searchText) ||
                poem.author.localizedCaseInsensitiveContains(searchText) ||
                poem.fullText.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch selectedFilter {
        case .all:
            break
        case .needsReview:
            filtered = filtered.filter { $0.shouldReview }
        case .recent:
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            filtered = filtered.filter { $0.dateAdded >= oneWeekAgo }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack {
                HStack {
                    TextField("Search library...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            Label(filter.rawValue, systemImage: filter.systemImage)
                                .tag(filter)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding()
                
                if filteredPoems.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 60))
                            .foregroundColor(Color.staticMeletaoSecondary)
                        Text("Your library is empty")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Add poems from the catalog to start memorizing")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.fixed(350)),
                            GridItem(.fixed(350)),
                            GridItem(.fixed(350))
                        ], spacing: 50) {
                            ForEach(filteredPoems, id: \.id) { poem in
                                PoemCard(poem: poem, isInCatalog: false)
                            }
                        }
                        .padding()
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                // Refresh is automatic due to @FetchRequest, but this ensures immediate update
            }
    }
}