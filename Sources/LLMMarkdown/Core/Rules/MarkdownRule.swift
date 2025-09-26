//
//  MarkdownRule.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Result of a rule match
public struct RuleMatch {
    /// The matched range in the original text
    public let range: NSRange
    
    /// The AST node created from this match
    public let node: ASTNode
    
    /// Whether this match should consume the matched text (prevent other rules from matching)
    public let consumes: Bool
    
    public init(range: NSRange, node: ASTNode, consumes: Bool = true) {
        self.range = range
        self.node = node
        self.consumes = consumes
    }
}

/// Protocol for markdown parsing rules
public protocol MarkdownRule {
    /// Priority of this rule (higher priority rules are applied first)
    var priority: Int { get }
    
    /// Whether this rule applies to block-level elements
    var isBlockRule: Bool { get }
    
    /// Check if this rule can handle the text at the given position
    func canHandle(_ text: String, at location: Int) -> Bool
    
    /// Parse the text at the given location and return a match if successful
    func parse(_ text: String, at location: Int) -> RuleMatch?
}

/// Base implementation for markdown rules
open class BaseMarkdownRule: MarkdownRule {
    public let priority: Int
    public let isBlockRule: Bool
    
    public init(priority: Int, isBlockRule: Bool = false) {
        self.priority = priority
        self.isBlockRule = isBlockRule
    }
    
    open func canHandle(_ text: String, at location: Int) -> Bool {
        fatalError("Subclasses must implement canHandle(_:at:)")
    }
    
    open func parse(_ text: String, at location: Int) -> RuleMatch? {
        fatalError("Subclasses must implement parse(_:at:)")
    }
}
