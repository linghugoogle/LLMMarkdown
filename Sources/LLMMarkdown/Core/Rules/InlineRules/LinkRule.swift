//
//  LinkRule.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Rule for parsing links [text](url) or [text](url "title")
public final class LinkRule: BaseMarkdownRule {
    
    private let linkPattern = #"\[([^\]]+)\]\(([^)]+?)(?:\s+"([^"]+)")?\)"#
    private let regex: NSRegularExpression
    
    public init() {
        self.regex = try! NSRegularExpression(pattern: linkPattern, options: [])
        super.init(priority: 85, isBlockRule: false)
    }
    
    public override func canHandle(_ text: String, at location: Int) -> Bool {
        let nsText = text as NSString
        let searchRange = NSRange(location: location, length: nsText.length - location)
        
        if let match = regex.firstMatch(in: text, options: [], range: searchRange) {
            return match.range.location == location
        }
        
        return false
    }
    
    public override func parse(_ text: String, at location: Int) -> RuleMatch? {
        let nsText = text as NSString
        let searchRange = NSRange(location: location, length: nsText.length - location)
        
        guard let match = regex.firstMatch(in: text, options: [], range: searchRange),
              match.range.location == location else {
            return nil
        }
        
        let textRange = match.range(at: 1)
        let urlRange = match.range(at: 2)
        let titleRange = match.numberOfRanges > 3 ? match.range(at: 3) : NSRange(location: NSNotFound, length: 0)
        
        let linkText = nsText.substring(with: textRange)
        let url = nsText.substring(with: urlRange)
        let title = titleRange.location != NSNotFound ? nsText.substring(with: titleRange) : nil
        
        let linkNode = LinkNode(url: url, title: title, range: match.range)
        let textNode = TextNode(content: linkText, range: textRange)
        linkNode.addChild(textNode)
        
        return RuleMatch(range: match.range, node: linkNode)
    }
}
