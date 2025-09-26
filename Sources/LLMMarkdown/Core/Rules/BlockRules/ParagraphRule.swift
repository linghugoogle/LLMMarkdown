//
//  ParagraphRule.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Rule for parsing regular paragraphs (fallback rule)
public final class ParagraphRule: BaseMarkdownRule {
    
    public init() {
        super.init(priority: 1, isBlockRule: true) // Lowest priority - fallback
    }
    
    public override func canHandle(_ text: String, at location: Int) -> Bool {
        // Paragraph rule can handle any non-empty line
        let nsText = text as NSString
        let lineRange = nsText.lineRange(for: NSRange(location: location, length: 0))
        let line = nsText.substring(with: lineRange).trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !line.isEmpty
    }
    
    public override func parse(_ text: String, at location: Int) -> RuleMatch? {
        let nsText = text as NSString
        let lineRange = nsText.lineRange(for: NSRange(location: location, length: 0))
        let line = nsText.substring(with: lineRange).trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !line.isEmpty else { return nil }
        
        let paragraphNode = ParagraphNode(range: lineRange)
        let textNode = TextNode(content: line, range: lineRange)
        paragraphNode.addChild(textNode)
        
        return RuleMatch(range: lineRange, node: paragraphNode)
    }
}
