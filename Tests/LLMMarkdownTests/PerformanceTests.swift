//
//  PerformanceTests.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import XCTest
@testable import LLMMarkdown

final class PerformanceTests: XCTestCase {
    
    var parser: LLMMarkdown!
    
    override func setUp() {
        super.setUp()
        parser = LLMMarkdown()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    // MARK: - Parsing Performance Tests
    
    func testParsingPerformanceSmallDocument() {
        let markdown = """
        # Title
        
        This is a **bold** text with *italic* and `code`.
        
        ## Subtitle
        
        Here's a [link](https://example.com).
        """
        
        measure {
            _ = parser.attributedString(from: markdown)
        }
    }
    
    func testParsingPerformanceMediumDocument() {
        var markdown = "# Large Document\n\n"
        
        for i in 1...50 {
            markdown += """
            ## Section \(i)
            
            This is paragraph \(i) with **bold text**, *italic text*, and `inline code`.
            
            Here's a list:
            1. Item one
            2. Item two
            3. Item three
            
            And an unordered list:
            - First item
            - Second item
            - Third item
            
            """
        }
        
        measure {
            _ = parser.attributedString(from: markdown)
        }
    }
    
    func testParsingPerformanceLargeDocument() {
        var markdown = "# Very Large Document\n\n"
        
        for i in 1...200 {
            markdown += """
            ## Section \(i)
            
            This is a longer paragraph \(i) with **bold text**, *italic text*, `inline code`, and a [link](https://example\(i).com).
            
            ### Subsection \(i).1
            
            More content with nested **_emphasis_** and complex structures.
            
            1. Ordered item \(i).1
            2. Ordered item \(i).2
            3. Ordered item \(i).3
            
            - Unordered item \(i).1
            - Unordered item \(i).2
            - Unordered item \(i).3
            
            """
        }
        
        measure {
            _ = parser.attributedString(from: markdown)
        }
    }
    
    func testParsingPerformanceComplexNesting() {
        let markdown = """
        # Complex Nesting Test
        
        This paragraph contains **bold text with *nested italic* inside** and more content.
        
        Here's a complex list:
        1. First item with **bold**
        2. Second item with *italic*
        3. Third item with `code` and [link](https://example.com)
        
        ## Another section
        
        More **_nested emphasis_** with `inline code` and [multiple](https://one.com) [links](https://two.com).
        """
        
        measure {
            for _ in 1...100 {
                _ = parser.attributedString(from: markdown)
            }
        }
    }
    
    // MARK: - Memory Performance Tests
    
    func testMemoryUsageWithLargeDocument() {
        var markdown = ""
        
        for i in 1...1000 {
            markdown += "This is line \(i) with some **bold** and *italic* text.\n"
        }
        
        measure {
            let result = parser.attributedString(from: markdown)
            // 强制使用结果以防止编译器优化
            _ = result.length
        }
    }
    
    func testMemoryUsageWithManySmallDocuments() {
        let markdown = "# Title\n\nThis is **bold** and *italic*."
        
        measure {
            for _ in 1...1000 {
                let result = parser.attributedString(from: markdown)
                _ = result.length
            }
        }
    }
    
    // MARK: - AST Performance Tests
    
    func testASTParsingPerformance() {
        let markdown = """
        # Performance Test
        
        This document tests AST parsing performance with various elements:
        
        ## Lists
        1. First item
        2. Second item
        3. Third item
        
        - Unordered item
        - Another item
        
        ## Text Formatting
        
        **Bold text**, *italic text*, `inline code`, and [links](https://example.com).
        
        ### Nested formatting
        
        **Bold with *nested italic* inside** and more complex structures.
        """
        
        measure {
            for _ in 1...100 {
                _ = parser.parseAST(from: markdown)
            }
        }
    }
    
    // MARK: - Rendering Performance Tests
    
    func testRenderingPerformance() {
        let markdown = """
        # Rendering Performance Test
        
        This tests the rendering performance of the AttributedStringRenderer.
        
        ## Multiple Paragraphs
        
        Paragraph 1 with **bold** text.
        
        Paragraph 2 with *italic* text.
        
        Paragraph 3 with `code` text.
        
        ## Lists
        
        1. Ordered item 1
        2. Ordered item 2
        3. Ordered item 3
        
        - Unordered item 1
        - Unordered item 2
        - Unordered item 3
        """
        
        let ast = parser.parseAST(from: markdown)
        let renderer = AttributedStringRenderer(theme: DefaultTheme())
        
        measure {
            for _ in 1...100 {
                _ = renderer.render(ast)
            }
        }
    }
    
    // MARK: - Rule Engine Performance Tests
    
    func testRuleEnginePerformance() {
        let ruleEngine = RuleEngine()
        let text = "This is **bold** text with *italic* and `code` elements."
        
        measure {
            for _ in 1...1000 {
                _ = ruleEngine.parseInlines(text)
            }
        }
    }
    
    // MARK: - Theme Performance Tests
    
    func testThemePerformance() {
        let markdown = "# Title\n\nThis is **bold** and *italic* text."
        
        let defaultParser = LLMMarkdown(theme: DefaultTheme())
        let githubParser = LLMMarkdown(theme: GitHubTheme())
        
        measure {
            for _ in 1...100 {
                _ = defaultParser.attributedString(from: markdown)
                _ = githubParser.attributedString(from: markdown)
            }
        }
    }
    
    // MARK: - Stress Tests
    
    func testStressTestWithVeryLongText() {
        let longText = String(repeating: "This is a very long line of text that should test the parser's ability to handle large amounts of content efficiently. ", count: 1000)
        let markdown = "# Stress Test\n\n\(longText)"
        
        measure {
            _ = parser.attributedString(from: markdown)
        }
    }
    
    func testStressTestWithManyHeaders() {
        var markdown = ""
        
        for i in 1...500 {
            let level = (i % 6) + 1
            let prefix = String(repeating: "#", count: level)
            markdown += "\(prefix) Header \(i)\n\n"
        }
        
        measure {
            _ = parser.attributedString(from: markdown)
        }
    }
    
    func testStressTestWithManyLists() {
        var markdown = "# Many Lists Test\n\n"
        
        for i in 1...100 {
            markdown += """
            ## List \(i)
            
            1. Item 1
            2. Item 2
            3. Item 3
            
            - Bullet 1
            - Bullet 2
            - Bullet 3
            
            """
        }
        
        measure {
            _ = parser.attributedString(from: markdown)
        }
    }
}
