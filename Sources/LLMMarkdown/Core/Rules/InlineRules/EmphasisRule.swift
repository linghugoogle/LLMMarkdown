//
//  EmphasisRule.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Rule for parsing emphasis/italic text (*text* or _text_)
public final class EmphasisRule: BaseMarkdownRule {
    
    private let emphasisPattern = #"(?<!\*|\w)(\*|_)(.+?)\1(?!\*|\w)"#
    private let regex: NSRegularExpression
    
    public init() {
        self.regex = try! NSRegularExpression(pattern: emphasisPattern, options: [])
        super.init(priority: 70, isBlockRule: false)
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
        
        let contentRange = match.range(at: 2)
        let content = nsText.substring(with: contentRange)
        
        let emphasisNode = EmphasisNode(range: match.range)
        let textNode = TextNode(content: content, range: contentRange)
        emphasisNode.addChild(textNode)
        
        return RuleMatch(range: match.range, node: emphasisNode)
    }
}
