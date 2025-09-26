//
//  ListItemNode.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Represents a list item
public final class ListItemNode: BaseASTNode {
    
    public init(range: NSRange = NSRange(location: 0, length: 0)) {
        super.init(type: .listItem, range: range)
    }
    
    public override func accept<T>(_ visitor: any ASTVisitor<T>) -> T {
        return visitor.visitListItem(self)
    }
}
