//
//  ListNode.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Represents a list block element (ordered or unordered)
public final class ListNode: BaseASTNode {
    
    /// Whether this is an ordered list
    public let isOrdered: Bool
    
    public init(isOrdered: Bool, range: NSRange = NSRange(location: 0, length: 0)) {
        self.isOrdered = isOrdered
        super.init(type: .list(ordered: isOrdered), range: range)
    }
    
    public override func accept<T>(_ visitor: any ASTVisitor<T>) -> T {
        return visitor.visitList(self)
    }
}
