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
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

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
                    Text("Poem")
                        .font(.headline)

                    Text(poem.fullText)
                        .font(.system(.body, design: .serif))
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .textSelection(.enabled)
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                }

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
                        navigationCoordinator.path.append(poem)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.staticMeletaoPrimary)
                    .controlSize(.large)
                    Spacer()
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .navigationTitle("Notes")
    }
}
