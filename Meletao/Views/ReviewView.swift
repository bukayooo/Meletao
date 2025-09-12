import SwiftUI
import CoreData

struct ReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var poemsForReview: [Poem] = []
    
    var body: some View {
        VStack {
                if poemsForReview.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(Color.staticMeletaoPrimary)
                        Text("All caught up!")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("No poems need review today")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    Text("You have \(poemsForReview.count) poem(s) ready for review")
                        .font(.headline)
                        .padding()
                    
                    LazyVGrid(columns: [
                        GridItem(.fixed(350)),
                        GridItem(.fixed(350))
                    ], spacing: 20) {
                        ForEach(poemsForReview, id: \.id) { poem in
                            ReviewCard(poem: poem)
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                loadPoemsForReview()
            }
    }
    
    private func loadPoemsForReview() {
        poemsForReview = SpacedRepetitionService.shared.getPoemsForReview(context: viewContext)
    }
}

struct ReviewCard: View {
    let poem: Poem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(poem.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text("by \(poem.author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "clock.badge.exclamationmark")
                    .foregroundColor(Color.staticMeletaoAccent)
                    .font(.title2)
            }
            
            if let nextReview = poem.nextReviewDate {
                Text("Due: \(nextReview, style: .relative)")
                    .font(.caption)
                    .foregroundColor(Color.staticMeletaoAccent)
            }
            
            HStack {
                Label("\(poem.wordCount) words", systemImage: "textformat")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label("\(poem.memorizationSessionsArray.count) reviews", systemImage: "arrow.clockwise")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            NavigationLink("Start Review", value: poem)
                .buttonStyle(.borderedProminent)
                .tint(Color.staticMeletaoPrimary)
                .controlSize(.small)
        }
        .padding()
        .frame(width: 350, height: 200) // Fixed card size
        .background(Color.staticMeletaoCardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.staticMeletaoAccent.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}