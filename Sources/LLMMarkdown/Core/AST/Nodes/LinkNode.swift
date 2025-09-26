//
//  LinkNode.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Represents a link element
public final class LinkNode: BaseASTNode {
    
    /// The URL of the link
    public let url: String
    
    /// Optional title attribute
    public let title: String?
    
    public init(url: String, title: String? = nil, range: NSRange = NSRange(location: 0, length: 0)) {
        self.url = url
        self.title = title
        super.init(type: .link(url: url), range: range)
    }
    
    public override func accept<T>(_ visitor: any ASTVisitor<T>) -> T {
        return visitor.visitLink(self)
    }
}
