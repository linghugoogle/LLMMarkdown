//
//  AttributedStringRenderer.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Renders AST nodes to NSAttributedString
public final class AttributedStringRenderer: ASTVisitor {
    
    private let theme: MarkdownTheme
    private var result: NSMutableAttributedString
    
    public init(theme: MarkdownTheme = DefaultTheme()) {
        self.theme = theme
        self.result = NSMutableAttributedString()
    }
    
    /// Render an AST node to NSAttributedString
    public func render(_ node: ASTNode) -> NSAttributedString {
        result = NSMutableAttributedString()
        _ = node.accept(self)
        return result.copy() as! NSAttributedString
    }
    
    // MARK: - ASTVisitor Implementation
    
    public func visit(_ node: ASTNode) -> NSAttributedString {
        // This method is called by the default visitor implementation
        // The actual rendering is done in the specific visit methods
        return NSAttributedString()
    }
    
    public func visitDocument(_ node: DocumentNode) -> NSAttributedString {
        for child in node.children {
            _ = child.accept(self)
        }
        return result
    }
    
    public func visitParagraph(_ node: ParagraphNode) -> NSAttributedString {
        let startLength = result.length
        
        // Render all children
        for child in node.children {
            _ = child.accept(self)
        }
        
        // Check if this paragraph has any content
        let hasContent = result.length > startLength
        
        // If this is an empty paragraph, add a line break to preserve spacing
        if !hasContent {
            result.append(NSAttributedString(string: "\n"))
        } else {
            // Add paragraph break if not the last paragraph and has content
            if let parent = node.parent,
               node !== parent.children.last {
                result.append(NSAttributedString(string: "\n"))
            }
        }
        
        // Apply paragraph style to the entire paragraph
        let paragraphRange = NSRange(location: startLength, length: result.length - startLength)
        let style = theme.textStyle(for: node.type)
        if let paragraphStyle = style.paragraphStyle {
            result.addAttribute(.paragraphStyle, value: paragraphStyle, range: paragraphRange)
        }
        
        return result
    }
    
    public func visitHeader(_ node: HeaderNode) -> NSAttributedString {
        let startLength = result.length
        
        // Render all children
        for child in node.children {
            _ = child.accept(self)
        }
        
        // Add line break after header
        result.append(NSAttributedString(string: "\n"))
        
        // Apply header style
        let headerRange = NSRange(location: startLength, length: result.length - startLength - 1) // Exclude the newline
        let style = theme.textStyle(for: node.type)
        result.addAttributes(style.attributes(), range: headerRange)
        
        return result
    }
    
    public func visitText(_ node: TextNode) -> NSAttributedString {
        let style = theme.textStyle(for: node.type)
        let attributedText = NSAttributedString(string: node.content, attributes: style.attributes())
        result.append(attributedText)
        return result
    }
    
    public func visitStrong(_ node: StrongNode) -> NSAttributedString {
        let startLength = result.length
        
        // Render all children
        for child in node.children {
            _ = child.accept(self)
        }
        
        // Apply strong style by combining with existing font traits
        let strongRange = NSRange(location: startLength, length: result.length - startLength)
        
        // Get existing attributes at the start of the range
        var existingAttributes: [NSAttributedString.Key: Any] = [:]
        if strongRange.length > 0 && startLength < result.length {
            existingAttributes = result.attributes(at: startLength, effectiveRange: nil)
        }
        
        // Get the base style from theme
        let style = theme.textStyle(for: node.type)
        var newAttributes = style.attributes()
        
        // If there's an existing font, combine traits instead of replacing
        if let existingFont = existingAttributes[.font] as? PlatformFont {
            #if os(iOS)
            let existingTraits = existingFont.fontDescriptor.symbolicTraits
            let newTraits = existingTraits.union(.traitBold)
            if let newDescriptor = existingFont.fontDescriptor.withSymbolicTraits(newTraits) {
                let combinedFont = UIFont(descriptor: newDescriptor, size: existingFont.pointSize)
                newAttributes[.font] = combinedFont
            }
            #elseif os(macOS)
            let existingTraits = existingFont.fontDescriptor.symbolicTraits
            let newTraits = existingTraits.union(.bold)
            let newDescriptor = existingFont.fontDescriptor.withSymbolicTraits(newTraits)
            let combinedFont = NSFont(descriptor: newDescriptor, size: existingFont.pointSize) ?? existingFont
            newAttributes[.font] = combinedFont
            #endif
        }
        
        result.addAttributes(newAttributes, range: strongRange)
        
        return result
    }
    
    public func visitEmphasis(_ node: EmphasisNode) -> NSAttributedString {
        let startLength = result.length
        
        // Render all children
        for child in node.children {
            _ = child.accept(self)
        }
        
        // Apply emphasis style by combining with existing font traits
        let emphasisRange = NSRange(location: startLength, length: result.length - startLength)
        
        // Get existing attributes at the start of the range
        var existingAttributes: [NSAttributedString.Key: Any] = [:]
        if emphasisRange.length > 0 && startLength < result.length {
            existingAttributes = result.attributes(at: startLength, effectiveRange: nil)
        }
        
        // Get the base style from theme
        let style = theme.textStyle(for: node.type)
        var newAttributes = style.attributes()
        
        // If there's an existing font, combine traits instead of replacing
        if let existingFont = existingAttributes[.font] as? PlatformFont {
            #if os(iOS)
            let existingTraits = existingFont.fontDescriptor.symbolicTraits
            let newTraits = existingTraits.union(.traitItalic)
            if let newDescriptor = existingFont.fontDescriptor.withSymbolicTraits(newTraits) {
                let combinedFont = UIFont(descriptor: newDescriptor, size: existingFont.pointSize)
                newAttributes[.font] = combinedFont
            }
            #elseif os(macOS)
            let existingTraits = existingFont.fontDescriptor.symbolicTraits
            let newTraits = existingTraits.union(.italic)
            let newDescriptor = existingFont.fontDescriptor.withSymbolicTraits(newTraits)
            let combinedFont = NSFont(descriptor: newDescriptor, size: existingFont.pointSize) ?? existingFont
            newAttributes[.font] = combinedFont
            #endif
        }
        
        result.addAttributes(newAttributes, range: emphasisRange)
        
        return result
    }
    
    public func visitCode(_ node: CodeNode) -> NSAttributedString {
        let style = theme.textStyle(for: node.type)
        let attributedText = NSAttributedString(string: node.content, attributes: style.attributes())
        result.append(attributedText)
        return result
    }
    
    public func visitList(_ node: ListNode) -> NSAttributedString {
        for child in node.children {
            _ = child.accept(self)
        }
        return result
    }
    
    public func visitListItem(_ node: ListItemNode) -> NSAttributedString {
        let startLength = result.length
        
        // Determine bullet based on parent list type
        var bullet = "• "
        if let parent = node.parent as? ListNode, parent.isOrdered {
            // For ordered lists, we need to track the item number
            // Find the index of this item in the parent's children
            if let siblings = parent.children as? [ListItemNode],
               let index = siblings.firstIndex(where: { $0 === node }) {
                bullet = "\(index + 1). "
            } else {
                bullet = "1. " // Fallback
            }
        }
        
        let bulletStyle = theme.textStyle(for: .text)
        let bulletString = NSAttributedString(string: bullet, attributes: bulletStyle.attributes())
        result.append(bulletString)
        
        // Render all children
        for child in node.children {
            _ = child.accept(self)
        }
        
        // Add line break after list item
        result.append(NSAttributedString(string: "\n"))
        
        // Apply list item style
        let itemRange = NSRange(location: startLength, length: result.length - startLength - 1)
        let style = theme.textStyle(for: node.type)
        if let paragraphStyle = style.paragraphStyle {
            result.addAttribute(.paragraphStyle, value: paragraphStyle, range: itemRange)
        }
        
        return result
    }
    
    public func visitLink(_ node: LinkNode) -> NSAttributedString {
        let startLength = result.length
        
        // Render all children (link text)
        for child in node.children {
            _ = child.accept(self)
        }
        
        // Apply link style and URL attribute
        let linkRange = NSRange(location: startLength, length: result.length - startLength)
        let style = theme.textStyle(for: node.type)
        var attributes = style.attributes()
        
        // Add URL attribute for clickable links
        if let url = URL(string: node.url) {
            attributes[.link] = url
        }
        
        result.addAttributes(attributes, range: linkRange)
        
        return result
    }
}
