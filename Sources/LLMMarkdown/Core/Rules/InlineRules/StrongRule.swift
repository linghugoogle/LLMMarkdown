//
//  StrongRule.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Rule for parsing strong/bold text (**text** or __text__)
public final class StrongRule: BaseMarkdownRule {
    
    private let strongPattern = #"(\*\*|__)(.+?)\1"#
    private let regex: NSRegularExpression
    
    public init() {
        self.regex = try! NSRegularExpression(pattern: strongPattern, options: [])
        super.init(priority: 80, isBlockRule: false)
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
        
        let strongNode = StrongNode(range: match.range)
        let textNode = TextNode(content: content, range: contentRange)
        strongNode.addChild(textNode)
        
        return RuleMatch(range: match.range, node: strongNode)
    }
}
