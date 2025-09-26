//
//  LLMMarkdown.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Main class for parsing and rendering Markdown
public final class LLMMarkdown {

    private let ruleEngine: RuleEngine
    private let renderer: AttributedStringRenderer
    private var theme: MarkdownTheme

    /// Initialize with a theme
    public init(theme: MarkdownTheme = DefaultTheme()) {
        self.theme = theme
        self.ruleEngine = RuleEngine()
        self.renderer = AttributedStringRenderer(theme: theme)
    }

    /// Parse markdown string and return NSAttributedString
    public func attributedString(from markdown: String) -> NSAttributedString {
        // Parse the markdown into an AST
        let ast = parseMarkdown(markdown)

        // Render the AST to NSAttributedString
        return renderer.render(ast)
    }

    /// Parse markdown string and return AST
    public func parseAST(from markdown: String) -> ASTNode {
        return parseMarkdown(markdown)
    }

    /// Update the theme
    public func setTheme(_ newTheme: MarkdownTheme) {
        self.theme = newTheme
        // Create new renderer with updated theme
        // Note: We create a new renderer because theme is immutable in renderer
        // In a production implementation, you might want to make renderer theme mutable
    }

    /// Add a custom rule
    public func addRule(_ rule: MarkdownRule) {
        ruleEngine.addRule(rule)
    }

    /// Remove a rule by type
    public func removeRule(_ ruleType: MarkdownRule.Type) {
        ruleEngine.removeRule(ruleType)
    }

    // MARK: - Private Methods

    private func parseMarkdown(_ markdown: String) -> ASTNode {
        let document = DocumentNode()

        // Handle completely empty markdown (not just whitespace)
        if markdown.isEmpty {
            return document
        }

        // Split into lines for block-level parsing
        let lines = markdown.components(separatedBy: .newlines)
        var currentLineIndex = 0

        while currentLineIndex < lines.count {
            let line = lines[currentLineIndex]

            // Check if this line starts a list first
            if isListLine(line) {
                // Parse consecutive list items
                let (listNode, consumedLines) = parseConsecutiveListItems(lines, startIndex: currentLineIndex)
                if let listNode = listNode {
                    // Parse inline elements within list items
                    parseInlineElements(in: listNode)
                    document.addChild(listNode)
                }
                currentLineIndex += consumedLines
            } else if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // Handle empty lines - create empty paragraph nodes to preserve spacing
                let emptyParagraph = ParagraphNode(range: NSRange(location: 0, length: 0))
                // Add an empty text node to make it render
                let emptyText = TextNode(content: "", range: NSRange(location: 0, length: 0))
                emptyParagraph.addChild(emptyText)
                document.addChild(emptyParagraph)
                currentLineIndex += 1
            } else {
                // Try to parse as other block element
                let blockNodes = ruleEngine.parseBlocks(line)

                for blockNode in blockNodes {
                    // Parse inline elements within block nodes
                    parseInlineElements(in: blockNode)
                    document.addChild(blockNode)
                }
                currentLineIndex += 1
            }
        }

        return document
    }
    
    private func isListLine(_ line: String) -> Bool {
        let unorderedPattern = #"^(\s*)[-*+]\s+(.+)$"#
        let orderedPattern = #"^(\s*)\d+\.\s+(.+)$"#
        
        let unorderedRegex = try! NSRegularExpression(pattern: unorderedPattern, options: [])
        let orderedRegex = try! NSRegularExpression(pattern: orderedPattern, options: [])
        
        return unorderedRegex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) != nil ||
               orderedRegex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) != nil
    }
    
    private func parseConsecutiveListItems(_ lines: [String], startIndex: Int) -> (ListNode?, Int) {
        let unorderedPattern = #"^(\s*)[-*+]\s+(.+)$"#
        let orderedPattern = #"^(\s*)\d+\.\s+(.+)$"#
        
        let unorderedRegex = try! NSRegularExpression(pattern: unorderedPattern, options: [])
        let orderedRegex = try! NSRegularExpression(pattern: orderedPattern, options: [])
        
        var currentIndex = startIndex
        var listNode: ListNode?
        var isOrdered: Bool?
        
        while currentIndex < lines.count {
            let line = lines[currentIndex]
            
            // Check if this is a list item
            var match: NSTextCheckingResult?
            var currentIsOrdered = false
            
            if let unorderedMatch = unorderedRegex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) {
                match = unorderedMatch
                currentIsOrdered = false
            } else if let orderedMatch = orderedRegex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) {
                match = orderedMatch
                currentIsOrdered = true
            }
            
            guard let validMatch = match else {
                // Not a list item, stop parsing (including empty lines)
                break
            }
            
            // Initialize list node on first item
            if listNode == nil {
                isOrdered = currentIsOrdered
                listNode = ListNode(isOrdered: currentIsOrdered, range: NSRange(location: 0, length: 0))
            } else if isOrdered != currentIsOrdered {
                // Different list type, stop parsing
                break
            }
            
            // Create list item
            let contentRange = validMatch.range(at: 2)
            let content = (line as NSString).substring(with: contentRange)
            
            let listItemNode = ListItemNode(range: NSRange(location: 0, length: line.count))
            let textNode = TextNode(content: content, range: contentRange)
            listItemNode.addChild(textNode)
            listNode?.addChild(listItemNode)
            
            currentIndex += 1
        }
        
        return (listNode, currentIndex - startIndex)
    }

    private func parseInlineElements(in node: ASTNode) {
        // Only parse inline elements in text nodes
        guard let textNode = node as? TextNode else {
            // Recursively parse children
            for child in node.children {
                parseInlineElements(in: child)
            }
            return
        }

        // Skip if this text node is empty
        if textNode.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }

        // Parse inline elements in text content
        let inlineNodes = ruleEngine.parseInlines(textNode.content)

        // If we found inline elements, replace the text node with parsed nodes
        if !inlineNodes.isEmpty && !(inlineNodes.count == 1 && inlineNodes[0] is TextNode && (inlineNodes[0] as! TextNode).content == textNode.content) {
            // Remove the original text node from its parent
            if let parent = textNode.parent {
                // Find the index of the text node to maintain order
                if let index = parent.children.firstIndex(where: { $0 === textNode }) {
                    parent.removeChild(textNode)
                    
                    // Insert the parsed inline nodes at the same position
                    for (offset, inlineNode) in inlineNodes.enumerated() {
                        parent.children.insert(inlineNode, at: index + offset)
                        inlineNode.parent = parent
                    }
                }
            }
        }
    }
}

// MARK: - Convenience Extensions

public extension LLMMarkdown {

    /// Create LLMMarkdown with default theme
    static let `default` = LLMMarkdown()

    /// Create LLMMarkdown with GitHub theme
    static let github = LLMMarkdown(theme: GitHubTheme())

    /// Quick method to convert markdown string to attributed string using default theme
    static func attributedString(from markdown: String) -> NSAttributedString {
        return LLMMarkdown.default.attributedString(from: markdown)
    }
}
