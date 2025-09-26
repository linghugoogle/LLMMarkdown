//
//  StrongNode.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Represents bold/strong text
public final class StrongNode: BaseASTNode {
    
    public init(range: NSRange = NSRange(location: 0, length: 0)) {
        super.init(type: .strong, range: range)
    }
    
    public override func accept<T>(_ visitor: any ASTVisitor<T>) -> T {
        return visitor.visitStrong(self)
    }
}
