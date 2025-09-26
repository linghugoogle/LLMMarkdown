//
//  CodeNode.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Represents inline code
public final class CodeNode: BaseASTNode {
    
    /// The code content
    public let content: String
    
    public init(content: String, range: NSRange = NSRange(location: 0, length: 0)) {
        self.content = content
        super.init(type: .code, range: range)
    }
    
    public override func accept<T>(_ visitor: any ASTVisitor<T>) -> T {
        return visitor.visitCode(self)
    }
}
