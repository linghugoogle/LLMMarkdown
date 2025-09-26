//
//  EmphasisNode.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Represents italic/emphasis text
public final class EmphasisNode: BaseASTNode {
    
    public init(range: NSRange = NSRange(location: 0, length: 0)) {
        super.init(type: .emphasis, range: range)
    }
    
    public override func accept<T>(_ visitor: any ASTVisitor<T>) -> T {
        return visitor.visitEmphasis(self)
    }
}
