//
//  HeaderRule.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Rule for parsing markdown headers (# ## ### etc.)
public final class HeaderRule: BaseMarkdownRule {
    
    private let headerPattern = #"^(#{1,6})\s+(.+)$"#
    private let regex: NSRegularExpression
    
    public init() {
        self.regex = try! NSRegularExpression(pattern: headerPattern, options: [.anchorsMatchLines])
        super.init(priority: 100, isBlockRule: true)
    }
    
    public override func canHandle(_ text: String, at location: Int) -> Bool {
        // Check if we're at the start of a line and the line starts with #
        let nsText = text as NSString
        
        // Find the start of the current line
        let lineRange = nsText.lineRange(for: NSRange(location: location, length: 0))
        let lineStart = lineRange.location
        
        // Only match if we're at the start of the line
        guard location == lineStart else { return false }
        
        let line = nsText.substring(with: lineRange)
        return regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) != nil
    }
    
    public override func parse(_ text: String, at location: Int) -> RuleMatch? {
        let nsText = text as NSString
        let lineRange = nsText.lineRange(for: NSRange(location: location, length: 0))
        let line = nsText.substring(with: lineRange)
        
        guard let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) else {
            return nil
        }
        
        let hashesRange = match.range(at: 1)
        let contentRange = match.range(at: 2)
        
        let level = hashesRange.length
        let content = (line as NSString).substring(with: contentRange)
        
        let headerNode = HeaderNode(level: level, range: lineRange)
        let textNode = TextNode(content: content, range: NSRange(location: lineRange.location + contentRange.location, length: contentRange.length))
        headerNode.addChild(textNode)
        
        return RuleMatch(range: lineRange, node: headerNode)
    }
}
