//
//  CodeRule.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Rule for parsing inline code (`code`)
public final class CodeRule: BaseMarkdownRule {
    
    private let codePattern = #"`([^`]+)`"#
    private let regex: NSRegularExpression
    
    public init() {
        self.regex = try! NSRegularExpression(pattern: codePattern, options: [])
        super.init(priority: 90, isBlockRule: false)
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
        
        let contentRange = match.range(at: 1)
        let content = nsText.substring(with: contentRange)
        
        let codeNode = CodeNode(content: content, range: match.range)
        
        return RuleMatch(range: match.range, node: codeNode)
    }
}
