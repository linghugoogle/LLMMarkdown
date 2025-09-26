//
//  ASTNode.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Represents the type of an AST node
public enum NodeType {
    // Block elements
    case document
    case paragraph
    case header(level: Int)
    case codeBlock(language: String?)
    case list(ordered: Bool)
    case listItem
    
    // Inline elements
    case text
    case strong
    case emphasis
    case code
    case link(url: String)
    case lineBreak
}

/// Protocol for all AST nodes in the markdown parse tree
public protocol ASTNode: AnyObject {
    /// The type of this node
    var type: NodeType { get }
    
    /// The range of this node in the original text
    var range: NSRange { get set }
    
    /// Child nodes
    var children: [ASTNode] { get set }
    
    /// Additional attributes for this node
    var attributes: [String: Any] { get set }
    
    /// Parent node (weak reference to avoid retain cycles)
    var parent: ASTNode? { get set }
    
    /// Accept a visitor for traversal
    func accept<T>(_ visitor: any ASTVisitor<T>) -> T
    
    /// Add a child node
    func addChild(_ child: ASTNode)
    
    /// Remove a child node
    func removeChild(_ child: ASTNode)
}

/// Base implementation of ASTNode
open class BaseASTNode: ASTNode {
    public let type: NodeType
    public var range: NSRange
    public var children: [ASTNode] = []
    public var attributes: [String: Any] = [:]
    public weak var parent: ASTNode?
    
    public init(type: NodeType, range: NSRange = NSRange(location: 0, length: 0)) {
        self.type = type
        self.range = range
    }
    
    public func accept<T>(_ visitor: any ASTVisitor<T>) -> T {
        return visitor.visit(self)
    }
    
    public func addChild(_ child: ASTNode) {
        children.append(child)
        child.parent = self
    }
    
    public func removeChild(_ child: ASTNode) {
        if let index = children.firstIndex(where: { $0 === child }) {
            children.remove(at: index)
            child.parent = nil
        }
    }
}
