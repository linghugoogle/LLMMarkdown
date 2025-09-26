//
//  RuleEngine.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation

/// Engine for applying markdown rules to text
public final class RuleEngine {
    
    private var blockRules: [MarkdownRule] = []
    private var inlineRules: [MarkdownRule] = []
    
    public init() {
        setupDefaultRules()
    }
    
    /// Register a new rule
    public func addRule(_ rule: MarkdownRule) {
        if rule.isBlockRule {
            blockRules.append(rule)
            blockRules.sort { $0.priority > $1.priority }
        } else {
            inlineRules.append(rule)
            inlineRules.sort { $0.priority > $1.priority }
        }
    }
    
    /// Remove a rule
    public func removeRule(_ ruleType: MarkdownRule.Type) {
        blockRules.removeAll { type(of: $0) == ruleType }
        inlineRules.removeAll { type(of: $0) == ruleType }
    }
    
    /// Parse text using block rules
    public func parseBlocks(_ text: String) -> [ASTNode] {
        return parseWithRules(text, rules: blockRules)
    }
    
    /// Parse text using inline rules
    public func parseInlines(_ text: String) -> [ASTNode] {
        let nodes = parseWithRules(text, rules: inlineRules)
        return processNestedInlines(nodes)
    }
    
    /// Recursively process nested inline elements
    private func processNestedInlines(_ nodes: [ASTNode]) -> [ASTNode] {
        var processedNodes: [ASTNode] = []
        
        for node in nodes {
            if let textNode = node as? TextNode {
                // For text nodes, check if they contain nested inline elements
                let nestedNodes = parseWithRules(textNode.content, rules: inlineRules)
                if nestedNodes.count > 1 || (nestedNodes.count == 1 && !(nestedNodes[0] is TextNode)) {
                    // Found nested elements, use them instead
                    processedNodes.append(contentsOf: processNestedInlines(nestedNodes))
                } else {
                    // No nested elements, keep the original text node
                    processedNodes.append(textNode)
                }
            } else {
                // For non-text nodes, recursively process their children
                let processedChildren = processNestedInlines(node.children)
                node.children.removeAll()
                for child in processedChildren {
                    node.addChild(child)
                }
                processedNodes.append(node)
            }
        }
        
        return processedNodes
    }
    
    private func parseWithRules(_ text: String, rules: [MarkdownRule]) -> [ASTNode] {
        var nodes: [ASTNode] = []
        var currentLocation = 0
        
        while currentLocation < text.count {
            var matched = false
            
            // Try each rule in priority order
            for rule in rules {
                if rule.canHandle(text, at: currentLocation) {
                    if let match = rule.parse(text, at: currentLocation) {
                        nodes.append(match.node)
                        
                        if match.consumes {
                            currentLocation = match.range.location + match.range.length
                            matched = true
                            break
                        }
                    }
                }
            }
            
            // If no rule matched, create a text node for the current character and advance
            if !matched {
                // Use Swift String indexing to properly handle Unicode characters
                let startIndex = text.index(text.startIndex, offsetBy: currentLocation)
                let endIndex = text.index(after: startIndex)
                let char = String(text[startIndex..<endIndex])
                
                let textNode = TextNode(content: char, range: NSRange(location: currentLocation, length: char.utf16.count))
                nodes.append(textNode)
                currentLocation += char.utf16.count
            }
        }
        
        // Merge consecutive text nodes
        return mergeConsecutiveTextNodes(nodes)
    }
    
    private func mergeConsecutiveTextNodes(_ nodes: [ASTNode]) -> [ASTNode] {
        var mergedNodes: [ASTNode] = []
        var currentTextContent = ""
        var currentTextRange = NSRange(location: 0, length: 0)
        
        for node in nodes {
            if let textNode = node as? TextNode {
                if currentTextContent.isEmpty {
                    currentTextContent = textNode.content
                    currentTextRange = textNode.range
                } else {
                    currentTextContent += textNode.content
                    currentTextRange = NSRange(location: currentTextRange.location, 
                                             length: currentTextRange.length + textNode.range.length)
                }
            } else {
                // Add accumulated text node if any
                if !currentTextContent.isEmpty {
                    mergedNodes.append(TextNode(content: currentTextContent, range: currentTextRange))
                    currentTextContent = ""
                }
                mergedNodes.append(node)
            }
        }
        
        // Add final text node if any
        if !currentTextContent.isEmpty {
            mergedNodes.append(TextNode(content: currentTextContent, range: currentTextRange))
        }
        
        return mergedNodes
    }
    
    private func setupDefaultRules() {
        // Block rules
        addRule(HeaderRule())
        addRule(ListRule())  // Add list rule
        addRule(ParagraphRule())
        
        // Inline rules
        addRule(StrongRule())
        addRule(EmphasisRule())
        addRule(CodeRule())
        addRule(LinkRule())
    }
}
