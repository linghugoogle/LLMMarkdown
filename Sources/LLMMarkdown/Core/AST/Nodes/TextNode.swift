//
//  TextNode.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Represents plain text content
public final class TextNode: BaseASTNode {
    
    /// The text content
    public let content: String
    
    public init(content: String, range: NSRange = NSRange(location: 0, length: 0)) {
        self.content = content
        super.init(type: .text, range: range)
    }
    
    public override func accept<T>(_ visitor: any ASTVisitor<T>) -> T {
        return visitor.visitText(self)
    }
}
