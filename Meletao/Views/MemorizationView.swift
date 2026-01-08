import SwiftUI

struct MemorizationView: View {
    let poem: Poem
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentSectionIndex = 0
    @State private var currentStage = 0
    @State private var isShowingFullPoem = false
    @State private var showingCompletionAlert = false
    @State private var hiddenIndicesCache: [String: Set<Int>] = [:]
    @State private var processedTextCache: [String: String] = [:]
    
    private let stages = [
        "Read and recite this section out loud 3 times",
        "Fill in the missing words (first letters shown)",
        "Fill in more missing words", 
        "Fill in even more missing words",
        "Complete the section from memory"
    ]
    
    var currentSection: PoemSection? {
        let sections = poem.sectionsArray
        guard currentSectionIndex < sections.count else { return nil }
        return sections[currentSectionIndex]
    }
    
    var isLastSection: Bool {
        currentSectionIndex == poem.sectionsArray.count - 1
    }
    
    var body: some View {
        VStack(spacing: 20) {
                if isShowingFullPoem {
                    fullPoemView
                } else if let section = currentSection {
                    sectionView(section)
                } else {
                    completionView
                }
        }
        .padding()
        .background(Color.staticMeletaoBackground)
        .navigationTitle(poem.title)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Exit") {
                    dismiss()
                }
            }
        }
        .alert("Memorization Complete!", isPresented: $showingCompletionAlert) {
            Button("Finish") {
                completeMemorization()
                dismiss()
            }
        } message: {
            Text("Great job! You've completed memorizing this poem.")
        }
    }
    
    @ViewBuilder
    private func sectionView(_ section: PoemSection) -> some View {
        VStack(spacing: 20) {
            ProgressView(value: Double(currentSectionIndex * 5 + currentStage), 
                        total: Double(poem.sectionsArray.count * 5))
                .progressViewStyle(.linear)
            
            Text("Section \(currentSectionIndex + 1) of \(poem.sectionsArray.count)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Stage \(currentStage + 1): \(stages[currentStage])")
                .font(.subheadline)
                .foregroundColor(Color.staticMeletaoPrimary)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            
            ScrollView {
                VStack(spacing: 16) {
                    if currentSectionIndex > 0 {
                        previousSectionsView
                    }
                    
                    Text(processedSectionText(section))
                        .font(.title2)
                        .lineSpacing(8)
                        .padding()
                        .background(Color.staticMeletaoCardBackground)
                        .cornerRadius(12)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                if currentStage >= 1 && currentStage <= 4 {
                    Button("Reshuffle") {
                        reshuffleWords()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                
                Button(nextButtonTitle) {
                    nextStage()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.staticMeletaoPrimary)
                .controlSize(.large)
            }
        }
    }
    
    @ViewBuilder
    private var fullPoemView: some View {
        VStack(spacing: 20) {
            Text("Final Challenge")
                .font(.title)
                .foregroundColor(Color.staticMeletaoPrimary)
            
            Text("Recite the complete poem 3 times using only these hints:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Text(processedFullPoem)
                .font(.title3)
                .lineSpacing(8)
                .padding()
                .background(Color.staticMeletaoCardBackground)
                .cornerRadius(12)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("Complete Memorization") {
                showingCompletionAlert = true
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.staticMeletaoAccent)
            .controlSize(.large)
        }
    }
    
    @ViewBuilder
    private var previousSectionsView: some View {
        VStack(spacing: 12) {
            ForEach(0..<currentSectionIndex, id: \.self) { index in
                let previousSection = poem.sectionsArray[index]
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Section \(index + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    Text(previousSection.text)
                        .font(.footnote)
                        .lineSpacing(4)
                        .foregroundColor(.secondary)
                        .opacity(0.7)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color.staticMeletaoCardBackground.opacity(0.5))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    @ViewBuilder
    private var completionView: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color.staticMeletaoPrimary)
            
            Text("All sections completed!")
                .font(.title)
            
            Text("Now let's try the full poem")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Continue to Full Poem") {
                isShowingFullPoem = true
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.staticMeletaoSecondary)
            .controlSize(.large)
        }
    }
    
    private var nextButtonTitle: String {
        if currentStage == 4 {
            return isLastSection ? "All Sections Complete!" : "Next Section"
        } else {
            return "Next"
        }
    }
    
    private func processedSectionText(_ section: PoemSection) -> String {
        let cacheKey = "section-\(currentSectionIndex)-\(currentStage)"
        
        // Return cached result if available
        if let cached = processedTextCache[cacheKey] {
            return cached
        }
        
        let result: String
        switch currentStage {
        case 0:
            result = section.text
        case 1:
            result = hideWordsWithFirstLetter(section.text, hideRatio: 0.3)
        case 2:
            result = hideWordsWithFirstLetter(section.text, hideRatio: 0.5)
        case 3:
            result = hideWordsWithFirstLetter(section.text, hideRatio: 0.7)
        case 4:
            result = hideAllWords(section.text)
        default:
            result = section.text
        }
        
        // Cache the result using a dispatch to avoid state mutation during view update
        DispatchQueue.main.async {
            self.processedTextCache[cacheKey] = result
        }
        return result
    }
    
    private var processedFullPoem: String {
        return hideAllWords(poem.fullText)
    }
    
    private func hideWordsWithFirstLetter(_ text: String, hideRatio: Double) -> String {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        let wordsToHide = Int(Double(words.count) * hideRatio)
        let cacheKey = "\(currentSectionIndex)-\(currentStage)-\(hideRatio)"
        
        // Use cached indices if they exist
        let hiddenIndices: Set<Int>
        if let cached = hiddenIndicesCache[cacheKey] {
            hiddenIndices = cached
        } else {
            var newHiddenIndices = Set<Int>()
            while newHiddenIndices.count < wordsToHide && newHiddenIndices.count < words.count {
                let randomIndex = Int.random(in: 0..<words.count)
                let word = words[randomIndex]
                let cleanWord = cleanWordForChecking(word)
                if !cleanWord.isEmpty && cleanWord.count > 1 {
                    newHiddenIndices.insert(randomIndex)
                }
            }
            hiddenIndices = newHiddenIndices
            
            // Cache the result using a dispatch to avoid state mutation during view update
            DispatchQueue.main.async {
                self.hiddenIndicesCache[cacheKey] = hiddenIndices
            }
        }
        
        return words.enumerated().map { index, word in
            if hiddenIndices.contains(index) && !word.isEmpty {
                let (cleanWord, punctuation) = separateWordFromPunctuation(word)
                if cleanWord.count > 1 {
                    let firstLetter = String(cleanWord.first!)
                    let underlines = String(repeating: "_", count: cleanWord.count - 1)
                    return firstLetter + underlines + punctuation
                }
            }
            return word
        }.joined(separator: " ")
    }
    
    private func hideAllWords(_ text: String) -> String {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.map { word in
            let (cleanWord, punctuation) = separateWordFromPunctuation(word)
            if cleanWord.isEmpty || cleanWord.count <= 2 {
                return word
            }
            let underlines = String(repeating: "_", count: cleanWord.count)
            return underlines + punctuation
        }.joined(separator: " ")
    }
    
    private func separateWordFromPunctuation(_ word: String) -> (word: String, punctuation: String) {
        let punctuationChars = CharacterSet.punctuationCharacters
        var cleanWord = word
        var punctuation = ""
        
        // Remove punctuation from the end
        while let lastChar = cleanWord.last, String(lastChar).rangeOfCharacter(from: punctuationChars) != nil {
            punctuation = String(lastChar) + punctuation
            cleanWord.removeLast()
        }
        
        return (cleanWord, punctuation)
    }
    
    private func cleanWordForChecking(_ word: String) -> String {
        return separateWordFromPunctuation(word).word
    }
    
    private func reshuffleWords() {
        let sectionCacheKey = "\(currentSectionIndex)-\(currentStage)"
        let textCacheKey = "section-\(currentSectionIndex)-\(currentStage)"
        
        // Clear both caches for the current section/stage
        hiddenIndicesCache = hiddenIndicesCache.filter { key, _ in 
            !key.hasPrefix(sectionCacheKey) 
        }
        processedTextCache.removeValue(forKey: textCacheKey)
    }
    
    private func nextStage() {
        if currentStage < 4 {
            currentStage += 1
        } else {
            if isLastSection {
                currentSectionIndex += 1
            } else {
                currentSectionIndex += 1
                currentStage = 0
            }
        }
        
        // Clear caches when advancing to ensure fresh content
        let textCacheKey = "section-\(currentSectionIndex)-\(currentStage)"
        processedTextCache.removeValue(forKey: textCacheKey)
    }
    
    private func completeMemorization() {
        SpacedRepetitionService.shared.scheduleNextReview(for: poem, context: viewContext)
        
        do {
            try viewContext.save()
            NotificationService.shared.updateNotificationsAfterMemorization(context: viewContext)
            CalendarService.shared.updateCalendarEvents(context: viewContext)
        } catch {
            print("Error saving memorization session: \(error)")
        }
    }
}