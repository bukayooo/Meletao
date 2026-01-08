import Foundation
import CoreData

class TextSectioningService {
    static let shared = TextSectioningService()
    
    private init() {}
    
    func createSectionsForPoem(_ poem: Poem, context: NSManagedObjectContext) {
        let wordCount = Int(poem.wordCount)
        let sectionSize = calculateSectionSize(wordCount: wordCount)
        let lines = poem.fullText.components(separatedBy: .newlines)

        var sections: [String] = []
        var currentSectionLines: [String] = []
        var currentWordCount = 0

        for line in lines {
            let lineWords = line.components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
            let lineWordCount = lineWords.count

            // If adding this line would exceed the section size and we already have content,
            // save the current section and start a new one
            if currentWordCount > 0 && currentWordCount + lineWordCount > sectionSize {
                sections.append(currentSectionLines.joined(separator: "\n"))
                currentSectionLines = []
                currentWordCount = 0
            }

            // Add the line to the current section
            currentSectionLines.append(line)
            currentWordCount += lineWordCount
        }

        // Add the last section if it has content
        if !currentSectionLines.isEmpty {
            sections.append(currentSectionLines.joined(separator: "\n"))
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