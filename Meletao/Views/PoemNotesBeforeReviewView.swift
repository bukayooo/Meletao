import SwiftUI

struct PoemForNotesReview: Hashable {
    let poem: Poem

    func hash(into hasher: inout Hasher) {
        hasher.combine(poem.objectID)
    }

    static func == (lhs: PoemForNotesReview, rhs: PoemForNotesReview) -> Bool {
        lhs.poem.objectID == rhs.poem.objectID
    }
}

struct PoemNotesBeforeReviewView: View {
    let poem: Poem
    @State private var navigateToReview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(poem.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("by \(poem.author)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)

                    Text(poem.notes)
                        .font(.system(.body))
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .textSelection(.enabled)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(8)
                }

                HStack {
                    Spacer()
                    Button("Review") {
                        navigateToReview = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.staticMeletaoPrimary)
                    .controlSize(.large)
                    Spacer()
                }
                .padding(.top, 8)

                NavigationLink(destination: MemorizationView(poem: poem), isActive: $navigateToReview) { EmptyView() }
                    .frame(width: 0, height: 0)
                    .hidden()
            }
            .padding(24)
        }
        .navigationTitle("Notes")
    }
}
