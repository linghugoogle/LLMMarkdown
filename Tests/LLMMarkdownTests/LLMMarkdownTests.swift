//
//  LLMMarkdownTests.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import XCTest
@testable import LLMMarkdown

final class LLMMarkdownTests: XCTestCase {
    
    var parser: LLMMarkdown!
    
    override func setUp() {
        super.setUp()
        parser = LLMMarkdown()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    // MARK: - Basic Parsing Tests
    
    func testEmptyString() {
        let result = parser.attributedString(from: "")
        XCTAssertEqual(result.length, 0)
    }
    
    func testPlainText() {
        let markdown = "Hello World"
        let result = parser.attributedString(from: markdown)
        XCTAssertEqual(result.string, "Hello World")
    }
    
    func testMultipleLines() {
        let markdown = "Line 1\nLine 2\nLine 3"
        let result = parser.attributedString(from: markdown)
        XCTAssertTrue(result.string.contains("Line 1"))
        XCTAssertTrue(result.string.contains("Line 2"))
        XCTAssertTrue(result.string.contains("Line 3"))
    }
    
    // MARK: - Header Tests
    
    func testH1Header() {
        let markdown = "# Header 1"
        let result = parser.attributedString(from: markdown)
        XCTAssertTrue(result.string.contains("Header 1"))
        
        // Test AST
        let ast = parser.parseAST(from: markdown)
        XCTAssertTrue(ast.children.first is HeaderNode)
        let header = ast.children.first as! HeaderNode
        XCTAssertEqual(header.level, 1)
    }
    
    func testH2Header() {
        let markdown = "## Header 2"
        let result = parser.attributedString(from: markdown)
        XCTAssertTrue(result.string.contains("Header 2"))
        
        let ast = parser.parseAST(from: markdown)
        let header = ast.children.first as! HeaderNode
        XCTAssertEqual(header.level, 2)
    }
    
    func testH6Header() {
        let markdown = "###### Header 6"
        let result = parser.attributedString(from: markdown)
        XCTAssertTrue(result.string.contains("Header 6"))
        
        let ast = parser.parseAST(from: markdown)
        let header = ast.children.first as! HeaderNode
        XCTAssertEqual(header.level, 6)
    }
    
    func testMultipleHeaders() {
        let markdown = """
        # Header 1
        ## Header 2
        ### Header 3
        """
        let ast = parser.parseAST(from: markdown)
        XCTAssertEqual(ast.children.count, 3)
        
        let h1 = ast.children[0] as! HeaderNode
        let h2 = ast.children[1] as! HeaderNode
        let h3 = ast.children[2] as! HeaderNode
        
        XCTAssertEqual(h1.level, 1)
        XCTAssertEqual(h2.level, 2)
        XCTAssertEqual(h3.level, 3)
    }
    
    // MARK: - Text Formatting Tests
    
    func testBoldText() {
        let markdown = "This is **bold** text"
        let result = parser.attributedString(from: markdown)
        XCTAssertTrue(result.string.contains("bold"))
        
        let ast = parser.parseAST(from: markdown)
        // Should find a StrongNode in the AST
        var foundStrong = false
        func findStrong(in node: ASTNode) {
            if node is StrongNode {
                foundStrong = true
                return
            }
            for child in node.children {
                findStrong(in: child)
            }
        }
        findStrong(in: ast)
        XCTAssertTrue(foundStrong)
    }
    
    func testItalicText() {
        let markdown = "This is *italic* text"
        let result = parser.attributedString(from: markdown)
        XCTAssertTrue(result.string.contains("italic"))
        
        let ast = parser.parseAST(from: markdown)
        var foundEmphasis = false
        func findEmphasis(in node: ASTNode) {
            if node is EmphasisNode {
                foundEmphasis = true
                return
            }
            for child in node.children {
                findEmphasis(in: child)
            }
        }
        findEmphasis(in: ast)
        XCTAssertTrue(foundEmphasis)
    }
    
    func testNestedEmphasis() {
        let markdown = "**Bold with _nested italic_ text**"
        let result = parser.attributedString(from: markdown)
        XCTAssertTrue(result.string.contains("Bold with"))
        XCTAssertTrue(result.string.contains("nested italic"))
        
        let ast = parser.parseAST(from: markdown)
        var foundStrong = false
        var foundEmphasis = false
        
        func findNodes(in node: ASTNode) {
            if node is StrongNode {
                foundStrong = true
            }
            if node is EmphasisNode {
                foundEmphasis = true
            }
            for child in node.children {
                findNodes(in: child)
            }
        }
        findNodes(in: ast)
        
        XCTAssertTrue(foundStrong)
        XCTAssertTrue(foundEmphasis)
    }
    
    func testInlineCode() {
        let markdown = "This is `inline code` example"
        let result = parser.attributedString(from: markdown)
        XCTAssertTrue(result.string.contains("inline code"))
        
        let ast = parser.parseAST(from: markdown)
        var foundCode = false
        func findCode(in node: ASTNode) {
            if node is CodeNode {
                foundCode = true
                return
            }
            for child in node.children {
                findCode(in: child)
            }
        }
        findCode(in: ast)
        XCTAssertTrue(foundCode)
    }
    
    // MARK: - Link Tests
    
    func testSimpleLink() {
        let markdown = "Visit [Google](https://google.com) for search"
        let result = parser.attributedString(from: markdown)
        XCTAssertTrue(result.string.contains("Google"))
        
        let ast = parser.parseAST(from: markdown)
        var foundLink = false
        var linkURL: String?
        
        func findLink(in node: ASTNode) {
            if let linkNode = node as? LinkNode {
                foundLink = true
                linkURL = linkNode.url
                return
            }
            for child in node.children {
                findLink(in: child)
            }
        }
        findLink(in: ast)
        
        XCTAssertTrue(foundLink)
        XCTAssertEqual(linkURL, "https://google.com")
    }
    
    func testMultipleLinks() {
        let markdown = "Visit [Google](https://google.com) and [GitHub](https://github.com)"
        let ast = parser.parseAST(from: markdown)
        
        var linkCount = 0
        func countLinks(in node: ASTNode) {
            if node is LinkNode {
                linkCount += 1
            }
            for child in node.children {
                countLinks(in: child)
            }
        }
        countLinks(in: ast)
        
        XCTAssertEqual(linkCount, 2)
    }
    
    // MARK: - List Tests
    
    func testUnorderedList() {
        let markdown = """
        - Item 1
        - Item 2
        - Item 3
        """
        let result = parser.attributedString(from: markdown)
        XCTAssertTrue(result.string.contains("Item 1"))
        XCTAssertTrue(result.string.contains("Item 2"))
        XCTAssertTrue(result.string.contains("Item 3"))
        
        let ast = parser.parseAST(from: markdown)
        let listNode = ast.children.first as? ListNode
        XCTAssertNotNil(listNode)
        XCTAssertFalse(listNode!.isOrdered)
        XCTAssertEqual(listNode!.children.count, 3)
    }
    
    func testOrderedList() {
        let markdown = """
        1. First item
        2. Second item
        3. Third item
        """
        let result = parser.attributedString(from: markdown)
        XCTAssertTrue(result.string.contains("First item"))
        XCTAssertTrue(result.string.contains("Second item"))
        XCTAssertTrue(result.string.contains("Third item"))
        
        let ast = parser.parseAST(from: markdown)
        let listNode = ast.children.first as? ListNode
        XCTAssertNotNil(listNode)
        XCTAssertTrue(listNode!.isOrdered)
        XCTAssertEqual(listNode!.children.count, 3)
    }
    
    func testMixedLists() {
        let markdown = """
        - Unordered item
        - Another unordered
        
        1. Ordered item
        2. Another ordered
        """
        let ast = parser.parseAST(from: markdown)
        
        var unorderedList: ListNode?
        var orderedList: ListNode?
        
        for child in ast.children {
            if let listNode = child as? ListNode {
                if listNode.isOrdered {
                    orderedList = listNode
                } else {
                    unorderedList = listNode
                }
            }
        }
        
        XCTAssertNotNil(unorderedList)
        XCTAssertNotNil(orderedList)
        XCTAssertFalse(unorderedList!.isOrdered)
        XCTAssertTrue(orderedList!.isOrdered)
    }
    
    // MARK: - Paragraph Tests
    
    func testSingleParagraph() {
        let markdown = "This is a single paragraph with some text."
        let ast = parser.parseAST(from: markdown)
        
        XCTAssertEqual(ast.children.count, 1)
        XCTAssertTrue(ast.children.first is ParagraphNode)
    }
    
    func testMultipleParagraphs() {
        let markdown = """
        First paragraph.
        
        Second paragraph.
        
        Third paragraph.
        """
        let ast = parser.parseAST(from: markdown)
        
        // Should have 3 paragraphs and 2 empty paragraphs (for empty lines)
        XCTAssertGreaterThanOrEqual(ast.children.count, 3)
        
        var paragraphCount = 0
        for child in ast.children {
            if child is ParagraphNode {
                paragraphCount += 1
            }
        }
        XCTAssertGreaterThanOrEqual(paragraphCount, 3)
    }
    
    func testEmptyLines() {
        let markdown = """
        Paragraph 1
        
        
        Paragraph 2
        """
        let result = parser.attributedString(from: markdown)
        XCTAssertTrue(result.string.contains("Paragraph 1"))
        XCTAssertTrue(result.string.contains("Paragraph 2"))
        
        let ast = parser.parseAST(from: markdown)
        XCTAssertGreaterThan(ast.children.count, 2) // Should include empty paragraphs
    }
    
    // MARK: - Complex Document Tests
    
    func testComplexDocument() {
        let markdown = """
        # Main Title
        
        This is a paragraph with **bold** and *italic* text.
        
        ## Subsection
        
        Here's a list:
        
        1. First item with `code`
        2. Second item with [link](https://example.com)
        3. Third item
        
        And an unordered list:
        
        - Item A
        - Item B with **bold**
        - Item C
        
        ### Code Example
        
        Some `inline code` here.
        """
        
        let result = parser.attributedString(from: markdown)
        XCTAssertGreaterThan(result.length, 0)
        
        let ast = parser.parseAST(from: markdown)
        XCTAssertGreaterThan(ast.children.count, 5)
        
        // Verify we have headers
        var headerCount = 0
        var listCount = 0
        var paragraphCount = 0
        
        for child in ast.children {
            if child is HeaderNode {
                headerCount += 1
            } else if child is ListNode {
                listCount += 1
            } else if child is ParagraphNode {
                paragraphCount += 1
            }
        }
        
        XCTAssertGreaterThanOrEqual(headerCount, 3) // H1, H2, H3
        XCTAssertGreaterThanOrEqual(listCount, 2)   // Ordered and unordered
        XCTAssertGreaterThan(paragraphCount, 0)
    }
    
    // MARK: - Edge Cases
    
    func testInvalidMarkdown() {
        let markdown = "# \n## \n**\n*\n`\n[]("
        let result = parser.attributedString(from: markdown)
        XCTAssertGreaterThanOrEqual(result.length, 0) // Should not crash
    }
    
    func testSpecialCharacters() {
        let markdown = "Text with émojis 🚀 and spëcial çharacters"
        let result = parser.attributedString(from: markdown)
        XCTAssertTrue(result.string.contains("émojis"))
        XCTAssertTrue(result.string.contains("🚀"))
        XCTAssertTrue(result.string.contains("spëcial"))
    }
    
    func testVeryLongText() {
        let longText = String(repeating: "This is a very long text. ", count: 1000)
        let markdown = "# Header\n\n\(longText)"
        let result = parser.attributedString(from: markdown)
        XCTAssertGreaterThan(result.length, longText.count)
    }
    
    // MARK: - Theme Tests
    
    func testDefaultTheme() {
        let parser = LLMMarkdown(theme: DefaultTheme())
        let markdown = "# Header\n\nSome **bold** text."
        let result = parser.attributedString(from: markdown)
        XCTAssertGreaterThan(result.length, 0)
    }
    
    func testGitHubTheme() {
        let parser = LLMMarkdown(theme: GitHubTheme())
        let markdown = "# Header\n\nSome **bold** text."
        let result = parser.attributedString(from: markdown)
        XCTAssertGreaterThan(result.length, 0)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceSimpleText() {
        let markdown = "Simple text without any formatting."
        
        measure {
            for _ in 0..<1000 {
                _ = parser.attributedString(from: markdown)
            }
        }
    }
    
    func testPerformanceComplexDocument() {
        let markdown = """
        # Performance Test
        
        This is a **complex** document with *various* formatting.
        
        ## Lists
        
        1. Item with `code`
        2. Item with [link](https://example.com)
        3. **Bold item**
        
        - Unordered item
        - Another item
        
        ### More text
        
        Some more text with **_nested emphasis_**.
        """
        
        measure {
            for _ in 0..<100 {
                _ = parser.attributedString(from: markdown)
            }
        }
    }
}
