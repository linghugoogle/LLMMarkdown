//
//  ASTVisitor.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Visitor protocol for traversing AST nodes
public protocol ASTVisitor<T> {
    associatedtype T
    
    func visit(_ node: ASTNode) -> T
    func visitDocument(_ node: DocumentNode) -> T
    func visitParagraph(_ node: ParagraphNode) -> T
    func visitHeader(_ node: HeaderNode) -> T
    func visitText(_ node: TextNode) -> T
    func visitStrong(_ node: StrongNode) -> T
    func visitEmphasis(_ node: EmphasisNode) -> T
    func visitCode(_ node: CodeNode) -> T
    func visitLink(_ node: LinkNode) -> T
    func visitList(_ node: ListNode) -> T
    func visitListItem(_ node: ListItemNode) -> T
}

/// Default implementation for ASTVisitor
public extension ASTVisitor {
    func visit(_ node: ASTNode) -> T {
        switch node.type {
        case .document:
            return visitDocument(node as! DocumentNode)
        case .paragraph:
            return visitParagraph(node as! ParagraphNode)
        case .header:
            return visitHeader(node as! HeaderNode)
        case .text:
            return visitText(node as! TextNode)
        case .strong:
            return visitStrong(node as! StrongNode)
        case .emphasis:
            return visitEmphasis(node as! EmphasisNode)
        case .code:
            return visitCode(node as! CodeNode)
        case .link:
            return visitLink(node as! LinkNode)
        case .list:
            return visitList(node as! ListNode)
        case .listItem:
            return visitListItem(node as! ListItemNode)
        default:
            fatalError("Unhandled node type: \(node.type)")
        }
    }
}
