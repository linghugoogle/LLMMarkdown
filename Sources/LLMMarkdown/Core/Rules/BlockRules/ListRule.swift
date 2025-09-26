//
//  ListRule.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Rule for parsing individual list items (used as fallback, main list parsing is in LLMMarkdown)
public final class ListRule: BaseMarkdownRule {
    
    private let unorderedPattern = #"^(\s*)[-*+]\s+(.+)$"#
    private let orderedPattern = #"^(\s*)\d+\.\s+(.+)$"#
    private let unorderedRegex: NSRegularExpression
    private let orderedRegex: NSRegularExpression

    public init() {
        self.unorderedRegex = try! NSRegularExpression(pattern: unorderedPattern, options: [.anchorsMatchLines])
        self.orderedRegex = try! NSRegularExpression(pattern: orderedPattern, options: [.anchorsMatchLines])
        super.init(priority: 80, isBlockRule: true)
    }
    
    public override func canHandle(_ text: String, at location: Int) -> Bool {
        let nsText = text as NSString
        let lineRange = nsText.lineRange(for: NSRange(location: location, length: 0))
        let line = nsText.substring(with: lineRange)
        
        return unorderedRegex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) != nil ||
               orderedRegex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) != nil
    }

    public override func parse(_ text: String, at location: Int) -> RuleMatch? {
        let nsText = text as NSString
        let lineRange = nsText.lineRange(for: NSRange(location: location, length: 0))
        let line = nsText.substring(with: lineRange)
        
        // Try unordered list first
        if let match = unorderedRegex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) {
            let contentRange = match.range(at: 2)
            let content = (line as NSString).substring(with: contentRange)
            
            let listItemNode = ListItemNode(range: lineRange)
            let textNode = TextNode(content: content, range: NSRange(location: lineRange.location + contentRange.location, length: contentRange.length))
            listItemNode.addChild(textNode)
            
            return RuleMatch(range: lineRange, node: listItemNode)
        }
        
        // Try ordered list
        if let match = orderedRegex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) {
            let contentRange = match.range(at: 2)
            let content = (line as NSString).substring(with: contentRange)
            
            let listItemNode = ListItemNode(range: lineRange)
            let textNode = TextNode(content: content, range: NSRange(location: lineRange.location + contentRange.location, length: contentRange.length))
            listItemNode.addChild(textNode)
            
            return RuleMatch(range: lineRange, node: listItemNode)
        }
        
        return nil
    }
}
