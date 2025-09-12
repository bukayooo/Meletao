import Foundation
import CoreData

class TextSectioningService {
    static let shared = TextSectioningService()
    
    private init() {}
    
    func createSectionsForPoem(_ poem: Poem, context: NSManagedObjectContext) {
        let wordCount = Int(poem.wordCount)
        let sectionSize = calculateSectionSize(wordCount: wordCount)
        let words = poem.fullText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        var sections: [String] = []
        var currentSection = ""
        var currentWordCount = 0
        
        for word in words {
            if currentWordCount >= sectionSize && !currentSection.isEmpty {
                sections.append(currentSection.trimmingCharacters(in: .whitespacesAndNewlines))
                currentSection = ""
                currentWordCount = 0
            }
            
            currentSection += (currentSection.isEmpty ? "" : " ") + word
            currentWordCount += 1
        }
        
        if !currentSection.isEmpty {
            sections.append(currentSection.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        poem.sectionCount = Int32(sections.count)
        
        for (index, sectionText) in sections.enumerated() {
            let section = PoemSection(context: context)
            section.id = UUID()
            section.sectionNumber = Int32(index)
            section.text = sectionText
            section.wordCount = Int32(sectionText.components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }.count)
            section.poem = poem
        }
    }
    
    private func calculateSectionSize(wordCount: Int) -> Int {
        switch wordCount {
        case 0...20:
            return wordCount
        case 21...50:
            return 15
        case 51...100:
            return 20
        case 101...200:
            return 25
        case 201...400:
            return 30
        default:
            return 35
        }
    }
    
    func wordCount(for text: String) -> Int {
        return text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
    }
}