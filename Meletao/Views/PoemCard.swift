import SwiftUI

struct PoemCard: View {
    let poem: Poem
    let isInCatalog: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAlert = false
    @State private var showingDetail = false
    @State private var navigateToStudy = false
    
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
                
                HStack {
                    Text(poem.category)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    if !poem.tagsArray.isEmpty {
                        ForEach(poem.tagsArray.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        if poem.tagsArray.count > 3 {
                            Text("+\(poem.tagsArray.count - 3)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
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
                        Button("Study") {
                            navigateToStudy = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.staticMeletaoPrimary)
                        .controlSize(.small)
                        // Hidden programmatic navigation trigger used by both the card button
                        // and the detail view's Study button (via the onStudy callback)
                        NavigationLink(destination: MemorizationView(poem: poem), isActive: $navigateToStudy) { EmptyView() }
                            .frame(width: 0, height: 0)
                            .hidden()
                        
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
            PoemDetailView(poem: poem, isInCatalog: isInCatalog, onStudy: {
                // Small delay lets the sheet dismiss animation finish before navigating
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    navigateToStudy = true
                }
            })
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
            NotificationService.shared.updateAppBadge(context: viewContext)
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

extension DateFormatter {
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}