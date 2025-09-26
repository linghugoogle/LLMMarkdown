//
//  HeaderNode.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Represents a header block element (H1-H6)
public final class HeaderNode: BaseASTNode {
    
    /// Header level (1-6)
    public let level: Int
    
    public init(level: Int, range: NSRange = NSRange(location: 0, length: 0)) {
        self.level = max(1, min(6, level)) // Clamp between 1-6
        super.init(type: .header(level: self.level), range: range)
    }
    
    public override func accept<T>(_ visitor: any ASTVisitor<T>) -> T {
        return visitor.visitHeader(self)
    }
}
