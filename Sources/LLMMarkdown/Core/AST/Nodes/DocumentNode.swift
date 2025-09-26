//
//  DocumentNode.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Root node of the AST representing the entire document
public final class DocumentNode: BaseASTNode {
    
    public init() {
        super.init(type: .document)
    }
    
    public override func accept<T>(_ visitor: any ASTVisitor<T>) -> T {
        return visitor.visitDocument(self)
    }
}
