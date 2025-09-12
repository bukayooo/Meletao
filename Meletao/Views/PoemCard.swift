import SwiftUI

struct PoemCard: View {
    let poem: Poem
    let isInCatalog: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAlert = false
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(poem.title)
                            .font(.headline)
                            .lineLimit(2)
                            .foregroundColor(.primary)
                        
                        Text("by \(poem.author)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if poem.shouldReview {
                        Image(systemName: "clock.badge.exclamationmark")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
                
                HStack {
                    Label("\(poem.wordCount) words", systemImage: "textformat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label("\(poem.sectionCount) sections", systemImage: "list.number")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(poem.fullText.prefix(100) + (poem.fullText.count > 100 ? "..." : ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    if isInCatalog {
                        Button("Add to Library") {
                            addToLibrary()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.staticMeletaoPrimary)
                        .controlSize(.small)
                        .onTapGesture { }
                    } else {
                        NavigationLink("Study", value: poem)
                            .buttonStyle(.borderedProminent)
                            .tint(Color.staticMeletaoPrimary)
                            .controlSize(.small)
                        
                        Button("Remove") {
                            showingAlert = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .foregroundColor(.red)
                        .onTapGesture { }
                    }
                    
                    Spacer()
                    
                    Text(DateFormatter.short.string(from: poem.dateAdded))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(width: 350, height: 200) // Fixed card size
            .background(Color.staticMeletaoCardBackground)
            .cornerRadius(12)
            .shadow(color: Color.staticMeletaoPrimary.opacity(0.1), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetail) {
            PoemDetailView(poem: poem, isInCatalog: isInCatalog)
        }
        .alert("Remove from Library", isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                removeFromLibrary()
            }
        } message: {
            Text("Are you sure you want to remove this poem from your library?")
        }
    }
    
    private func addToLibrary() {
        poem.isInLibrary = true
        
        do {
            try viewContext.save()
        } catch {
            print("Error adding poem to library: \(error)")
        }
    }
    
    private func removeFromLibrary() {
        poem.isInLibrary = false
        
        do {
            try viewContext.save()
        } catch {
            print("Error removing poem from library: \(error)")
        }
    }
}

extension DateFormatter {
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}