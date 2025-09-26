//
//  RuleEngineTests.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import XCTest
@testable import LLMMarkdown

final class RuleEngineTests: XCTestCase {
    
    var ruleEngine: RuleEngine!
    
    override func setUp() {
        super.setUp()
        ruleEngine = RuleEngine()
    }
    
    override func tearDown() {
        ruleEngine = nil
        super.tearDown()
    }
    
    // MARK: - Basic Rule Engine Tests
    
    func testRuleEngineInitialization() {
        XCTAssertNotNil(ruleEngine)
    }
    
    func testParseEmptyString() {
        let blockNodes = ruleEngine.parseBlocks("")
        let inlineNodes = ruleEngine.parseInlines("")
        
        XCTAssertTrue(blockNodes.isEmpty)
        XCTAssertTrue(inlineNodes.isEmpty)
    }
    
    func testParseSimpleText() {
        let text = "Simple text"
        let blockNodes = ruleEngine.parseBlocks(text)
        
        XCTAssertGreaterThanOrEqual(blockNodes.count, 1)
        
        // Should create a paragraph with text
        if let paragraphNode = blockNodes.first as? ParagraphNode {
            XCTAssertGreaterThan(paragraphNode.children.count, 0)
        }
    }
    
    // MARK: - Block Rule Tests
    
    func testHeaderParsing() {
        let headerTexts = [
            "# Header 1",
            "## Header 2",
            "### Header 3",
            "#### Header 4",
            "##### Header 5",
            "###### Header 6"
        ]
        
        for (index, headerText) in headerTexts.enumerated() {
            let nodes = ruleEngine.parseBlocks(headerText)
            XCTAssertGreaterThan(nodes.count, 0, "Failed to parse: \(headerText)")
            
            if let headerNode = nodes.first as? HeaderNode {
                XCTAssertEqual(headerNode.level, index + 1)
            } else {
                XCTFail("Expected HeaderNode for: \(headerText)")
            }
        }
    }
    
    func testInvalidHeaders() {
        let invalidHeaders = [
            "####### Too many hashes",
            "#No space after hash",
            " # Space before hash"
        ]
        
        for invalidHeader in invalidHeaders {
            let nodes = ruleEngine.parseBlocks(invalidHeader)
            // Should not create HeaderNode, might create ParagraphNode instead
            let hasHeaderNode = nodes.contains { $0 is HeaderNode }
            XCTAssertFalse(hasHeaderNode, "Should not create HeaderNode for: \(invalidHeader)")
        }
    }
    
    func testParagraphParsing() {
        let paragraphText = "This is a regular paragraph without any special formatting."
        let nodes = ruleEngine.parseBlocks(paragraphText)
        
        XCTAssertGreaterThan(nodes.count, 0)
        
        if let paragraphNode = nodes.first as? ParagraphNode {
            XCTAssertGreaterThan(paragraphNode.children.count, 0)
        } else {
            XCTFail("Expected ParagraphNode")
        }
    }
    
    // MARK: - Inline Rule Tests
    
    func testBoldParsing() {
        let boldTexts = [
            "**bold text**",
            "__bold text__"
        ]
        
        for boldText in boldTexts {
            let nodes = ruleEngine.parseInlines(boldText)
            
            var foundStrong = false
            func findStrong(in nodes: [ASTNode]) {
                for node in nodes {
                    if node is StrongNode {
                        foundStrong = true
                        return
                    }
                    findStrong(in: node.children)
                }
            }
            findStrong(in: nodes)
            
            XCTAssertTrue(foundStrong, "Failed to find StrongNode in: \(boldText)")
        }
    }
    
    func testItalicParsing() {
        let italicTexts = [
            "*italic text*",
            "_italic text_"
        ]
        
        for italicText in italicTexts {
            let nodes = ruleEngine.parseInlines(italicText)
            
            var foundEmphasis = false
            func findEmphasis(in nodes: [ASTNode]) {
                for node in nodes {
                    if node is EmphasisNode {
                        foundEmphasis = true
                        return
                    }
                    findEmphasis(in: node.children)
                }
            }
            findEmphasis(in: nodes)
            
            XCTAssertTrue(foundEmphasis, "Failed to find EmphasisNode in: \(italicText)")
        }
    }
    
    func testCodeParsing() {
        let codeText = "`inline code`"
        let nodes = ruleEngine.parseInlines(codeText)
        
        var foundCode = false
        func findCode(in nodes: [ASTNode]) {
            for node in nodes {
                if let codeNode = node as? CodeNode {
                    foundCode = true
                    XCTAssertEqual(codeNode.content, "inline code")
                    return
                }
                findCode(in: node.children)
            }
        }
        findCode(in: nodes)
        
        XCTAssertTrue(foundCode)
    }
    
    func testLinkParsing() {
        let linkText = "[Google](https://google.com)"
        let nodes = ruleEngine.parseInlines(linkText)
        
        var foundLink = false
        var linkURL: String?
        
        func findLink(in nodes: [ASTNode]) {
            for node in nodes {
                if let linkNode = node as? LinkNode {
                    foundLink = true
                    linkURL = linkNode.url
                    return
                }
                findLink(in: node.children)
            }
        }
        findLink(in: nodes)
        
        XCTAssertTrue(foundLink)
        XCTAssertEqual(linkURL, "https://google.com")
    }
    
    // MARK: - Custom Rule Tests
    
    func testAddCustomRule() {
        let customRule = MockRule()
        ruleEngine.addRule(customRule)
        
        let text = "test"
        let nodes = ruleEngine.parseBlocks(text)
        
        // The mock rule should have been applied
        XCTAssertTrue(customRule.wasApplied)
    }
    
    func testRemoveRule() {
        let customRule = MockRule()
        ruleEngine.addRule(customRule)
        
        // Verify rule was added
        let text = "test"
        _ = ruleEngine.parseBlocks(text)
        XCTAssertTrue(customRule.wasApplied)
        
        // Reset and remove rule
        customRule.wasApplied = false
        ruleEngine.removeRule(MockRule.self)
        
        // Verify rule was removed
        _ = ruleEngine.parseBlocks(text)
        XCTAssertFalse(customRule.wasApplied)
    }
    
    // MARK: - Complex Parsing Tests
    
    func testNestedInlineElements() {
        let text = "**Bold with _nested italic_ text**"
        let nodes = ruleEngine.parseInlines(text)
        
        var foundStrong = false
        var foundEmphasis = false
        
        func findNodes(in nodes: [ASTNode]) {
            for node in nodes {
                if node is StrongNode {
                    foundStrong = true
                }
                if node is EmphasisNode {
                    foundEmphasis = true
                }
                findNodes(in: node.children)
            }
        }
        findNodes(in: nodes)
        
        XCTAssertTrue(foundStrong)
        XCTAssertTrue(foundEmphasis)
    }
    
    func testMixedInlineElements() {
        let text = "Text with **bold**, *italic*, `code`, and [link](https://example.com)"
        let nodes = ruleEngine.parseInlines(text)
        
        var foundStrong = false
        var foundEmphasis = false
        var foundCode = false
        var foundLink = false
        
        func findNodes(in nodes: [ASTNode]) {
            for node in nodes {
                if node is StrongNode { foundStrong = true }
                if node is EmphasisNode { foundEmphasis = true }
                if node is CodeNode { foundCode = true }
                if node is LinkNode { foundLink = true }
                findNodes(in: node.children)
            }
        }
        findNodes(in: nodes)
        
        XCTAssertTrue(foundStrong)
        XCTAssertTrue(foundEmphasis)
        XCTAssertTrue(foundCode)
        XCTAssertTrue(foundLink)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyMarkdownElements() {
        let emptyElements = [
            "****",      // Empty bold
            "**",        // Incomplete bold
            "``",        // Empty code
            "`",         // Incomplete code
            "[]()",      // Empty link
            "[]",        // Incomplete link
        ]
        
        for element in emptyElements {
            let nodes = ruleEngine.parseInlines(element)
            // Should not crash and should handle gracefully
            XCTAssertNotNil(nodes)
        }
    }
    
    func testSpecialCharacters() {
        let specialText = "Text with émojis 🚀 and spëcial çharacters"
        let blockNodes = ruleEngine.parseBlocks(specialText)
        let inlineNodes = ruleEngine.parseInlines(specialText)
        
        XCTAssertGreaterThan(blockNodes.count, 0)
        XCTAssertGreaterThan(inlineNodes.count, 0)
    }
}

// MARK: - Mock Rule for Testing

class MockRule: MarkdownRule {
    var wasApplied = false
    
    var priority: Int { return 100 }
    var isBlockRule: Bool { return true }
    
    func canHandle(_ text: String, at location: Int) -> Bool {
        // Simple mock: can handle any text
        return location < text.count
    }
    
    func parse(_ text: String, at location: Int) -> RuleMatch? {
        wasApplied = true
        
        // Create a simple paragraph node for testing
        let paragraphNode = ParagraphNode()
        let textNode = TextNode(content: "Mock parsed content")
        paragraphNode.addChild(textNode)
        
        // Return a match that consumes one character
        let range = NSRange(location: location, length: min(1, text.count - location))
        return RuleMatch(range: range, node: paragraphNode, consumes: true)
    }
}
