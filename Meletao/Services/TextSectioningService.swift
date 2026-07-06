import Foundation
import CoreData

class TextSectioningService {
    static let shared = TextSectioningService()
    
    private init() {}
    
    func createSectionsForPoem(_ poem: Poem, context: NSManagedObjectContext) {
        let wordCount = Int(poem.wordCount)
        let sectionSize = calculateSectionSize(wordCount: wordCount)
        let rawLines = poem.fullText.components(separatedBy: .newlines)

        // Long lines (e.g. prose paragraphs) can't be broken on newlines alone,
        // so split them further at sentence boundaries before sectioning.
        let lines = rawLines.flatMap { line -> [String] in
            guard self.wordCount(for: line) > sectionSize else { return [line] }
            return splitLongLineIntoChunks(line, maxWords: sectionSize)
        }

        var sections: [String] = []
        var currentSectionLines: [String] = []
        var currentWordCount = 0

        for line in lines {
            let lineWordCount = self.wordCount(for: line)

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
    
    /// Splits a long line into smaller chunks, packing whole sentences up to
    /// `maxWords` per chunk. A single sentence longer than `maxWords` is kept
    /// intact rather than split mid-sentence.
    private func splitLongLineIntoChunks(_ line: String, maxWords: Int) -> [String] {
        let sentences = splitIntoSentences(line)
        guard sentences.count > 1 else { return [line] }

        var chunks: [String] = []
        var currentSentences: [String] = []
        var currentWordCount = 0

        for sentence in sentences {
            let sentenceWordCount = wordCount(for: sentence)

            if currentWordCount > 0 && currentWordCount + sentenceWordCount > maxWords {
                chunks.append(currentSentences.joined(separator: " "))
                currentSentences = []
                currentWordCount = 0
            }

            currentSentences.append(sentence)
            currentWordCount += sentenceWordCount
        }

        if !currentSentences.isEmpty {
            chunks.append(currentSentences.joined(separator: " "))
        }

        return chunks
    }

    /// Uses ICU's locale-aware sentence boundary detection so abbreviations,
    /// decimals, etc. aren't mistaken for sentence endings.
    private func splitIntoSentences(_ text: String) -> [String] {
        var sentences: [String] = []
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .bySentences) { substring, _, _, _ in
            if let trimmed = substring?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty {
                sentences.append(trimmed)
            }
        }
        return sentences
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