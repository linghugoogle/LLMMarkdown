//
//  ParagraphNode.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Represents a paragraph block element
public final class ParagraphNode: BaseASTNode {
    
    public init(range: NSRange = NSRange(location: 0, length: 0)) {
        super.init(type: .paragraph, range: range)
    }
    
    public override func accept<T>(_ visitor: any ASTVisitor<T>) -> T {
        return visitor.visitParagraph(self)
    }
}
