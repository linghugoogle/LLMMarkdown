//
//  IntegrationTests.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import XCTest
@testable import LLMMarkdown

final class IntegrationTests: XCTestCase {
    
    var parser: LLMMarkdown!
    
    override func setUp() {
        super.setUp()
        parser = LLMMarkdown()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    // MARK: - Real-world Document Tests
    
    func testCompleteMarkdownDocument() {
        let markdown = """
        # LLMMarkdown Documentation
        
        This is a comprehensive test of the LLMMarkdown parser.
        
        ## Features
        
        LLMMarkdown supports the following features:
        
        ### Text Formatting
        
        - **Bold text** for emphasis
        - *Italic text* for subtle emphasis
        - `Inline code` for technical terms
        - **_Nested emphasis_** for complex formatting
        
        ### Lists
        
        Ordered lists:
        1. First item
        2. Second item
        3. Third item
        
        Unordered lists:
        - First bullet
        - Second bullet
        - Third bullet
        
        ### Links
        
        Check out [Apple's documentation](https://developer.apple.com) for more information.
        
        ## Code Examples
        
        Here's some Swift code: `let message = "Hello, World!"`
        
        ## Conclusion
        
        LLMMarkdown provides a **powerful** and *flexible* way to parse Markdown.
        """
        
        let result = parser.attributedString(from: markdown)
        
        // 验证基本结构
        XCTAssertTrue(result.string.contains("LLMMarkdown Documentation"))
        XCTAssertTrue(result.string.contains("Features"))
        XCTAssertTrue(result.string.contains("Text Formatting"))
        XCTAssertTrue(result.string.contains("1. First item"))
        XCTAssertTrue(result.string.contains("• First bullet"))
        XCTAssertTrue(result.string.contains("Apple's documentation"))
        
        // 验证长度合理
        XCTAssertGreaterThan(result.length, 0)
    }
    
    func testREADMEStyleDocument() {
        let markdown = """
        # Project Name
        
        [![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://example.com)
        
        A brief description of the project.
        
        ## Installation
        
        Install using Swift Package Manager:
        
        1. Open Xcode
        2. Go to File → Add Package Dependencies
        3. Enter the repository URL
        
        ## Usage
        
        Basic usage example:
        
        ```swift
        let parser = LLMMarkdown()
        let result = parser.attributedString(from: markdown)
        ```
        
        ## Features
        
        - ✅ **Fast parsing**
        - ✅ *Flexible theming*
        - ✅ `Cross-platform support`
        
        ## Contributing
        
        Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.
        
        ## License
        
        This project is licensed under the MIT License.
        """
        
        let result = parser.attributedString(from: markdown)
        
        XCTAssertTrue(result.string.contains("Project Name"))
        XCTAssertTrue(result.string.contains("Installation"))
        XCTAssertTrue(result.string.contains("1. Open Xcode"))
        XCTAssertTrue(result.string.contains("✅"))
        XCTAssertGreaterThan(result.length, 0)
    }
    
    // MARK: - Edge Case Integration Tests
    
    func testEmptyDocument() {
        let markdown = ""
        let result = parser.attributedString(from: markdown)
        
        XCTAssertEqual(result.string, "")
        XCTAssertEqual(result.length, 0)
    }
    
    func testWhitespaceOnlyDocument() {
        let markdown = "   \n\n   \n   "
        let result = parser.attributedString(from: markdown)
        
        // 应该保留空行
        XCTAssertTrue(result.string.contains("\n"))
    }
    
    func testDocumentWithOnlyHeaders() {
        let markdown = """
        # Header 1
        ## Header 2
        ### Header 3
        #### Header 4
        ##### Header 5
        ###### Header 6
        """
        
        let result = parser.attributedString(from: markdown)
        
        XCTAssertTrue(result.string.contains("Header 1"))
        XCTAssertTrue(result.string.contains("Header 6"))
        XCTAssertGreaterThan(result.length, 0)
    }
    
    func testDocumentWithOnlyLists() {
        let markdown = """
        1. First ordered item
        2. Second ordered item
        3. Third ordered item
        
        - First unordered item
        - Second unordered item
        - Third unordered item
        """
        
        let result = parser.attributedString(from: markdown)
        
        XCTAssertTrue(result.string.contains("1. First ordered item"))
        XCTAssertTrue(result.string.contains("• First unordered item"))
        XCTAssertGreaterThan(result.length, 0)
    }
    
    // MARK: - Theme Integration Tests
    
    func testDefaultThemeIntegration() {
        let markdown = """
        # Title
        
        This is **bold** and *italic* text with `code`.
        
        [Link](https://example.com)
        """
        
        let defaultParser = LLMMarkdown(theme: DefaultTheme())
        let result = defaultParser.attributedString(from: markdown)
        
        XCTAssertGreaterThan(result.length, 0)
        
        // 检查是否应用了样式
        let attributes = result.attributes(at: 0, effectiveRange: nil)
        XCTAssertNotNil(attributes[.font])
        XCTAssertNotNil(attributes[.foregroundColor])
    }
    
    func testGitHubThemeIntegration() {
        let markdown = """
        # GitHub Style
        
        This uses **GitHub styling** with *italic* and `code`.
        """
        
        let githubParser = LLMMarkdown(theme: GitHubTheme())
        let result = githubParser.attributedString(from: markdown)
        
        XCTAssertGreaterThan(result.length, 0)
        XCTAssertTrue(result.string.contains("GitHub Style"))
    }
    
    // MARK: - Custom Rule Integration Tests
    
    func testCustomRuleIntegration() {
        // Create a simple custom rule for testing
        struct TestCustomRule: MarkdownRule {
            let priority: Int = 100
            let isBlockRule: Bool = false
            
            func canHandle(_ text: String, at location: Int) -> Bool {
                // Check if we have the strikethrough pattern at this location
                let substring = String(text.dropFirst(location))
                return substring.hasPrefix("~~")
            }
            
            func parse(_ text: String, at location: Int) -> RuleMatch? {
                let substring = String(text.dropFirst(location))
                let pattern = #"^~~(.+?)~~"#
                
                guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
                
                let range = NSRange(location: 0, length: substring.count)
                guard let match = regex.firstMatch(in: substring, range: range) else { return nil }
                
                let contentRange = match.range(at: 1)
                let content = (substring as NSString).substring(with: contentRange)
                
                // Create a text node with the strikethrough content
                let textNode = TextNode(content: content, range: contentRange)
                
                // Return the match with the full range including the ~~ markers
                let fullRange = NSRange(location: location, length: match.range.length)
                return RuleMatch(range: fullRange, node: textNode, consumes: true)
            }
        }
        
        parser.addRule(TestCustomRule())
        
        let markdown = "This has ~~strikethrough~~ text."
        let result = parser.attributedString(from: markdown)
        
        XCTAssertGreaterThan(result.length, 0)
    }
    
    // MARK: - Error Handling Integration Tests
    
    func testMalformedMarkdown() {
        let markdown = """
        # Unclosed **bold text
        
        *Unclosed italic
        
        [Incomplete link](
        
        `Unclosed code
        """
        
        // 解析器应该能够处理格式错误的 Markdown 而不崩溃
        let result = parser.attributedString(from: markdown)
        
        XCTAssertGreaterThan(result.length, 0)
        XCTAssertTrue(result.string.contains("Unclosed"))
    }
    
    func testSpecialCharacters() {
        let markdown = """
        # Special Characters Test
        
        Unicode: 中文 🚀 ñáéíóú
        
        HTML entities: &amp; &lt; &gt; &quot;
        
        Symbols: © ® ™ § ¶
        """
        
        let result = parser.attributedString(from: markdown)
        
        XCTAssertTrue(result.string.contains("中文"))
        XCTAssertTrue(result.string.contains("🚀"))
        XCTAssertTrue(result.string.contains("ñáéíóú"))
        XCTAssertGreaterThan(result.length, 0)
    }
    
    // MARK: - Platform Integration Tests
    
    #if os(iOS)
    func testiOSSpecificIntegration() {
        let markdown = "# iOS Test\n\nThis is **bold** text."
        let result = parser.attributedString(from: markdown)
        
        // 验证使用了 iOS 特定的字体和颜色
        let attributes = result.attributes(at: 0, effectiveRange: nil)
        let font = attributes[.font] as? UIFont
        let color = attributes[.foregroundColor] as? UIColor
        
        XCTAssertNotNil(font)
        XCTAssertNotNil(color)
    }
    #endif
    
    #if os(macOS)
    func testmacOSSpecificIntegration() {
        let markdown = "# macOS Test\n\nThis is **bold** text."
        let result = parser.attributedString(from: markdown)
        
        // 验证使用了 macOS 特定的字体和颜色
        let attributes = result.attributes(at: 0, effectiveRange: nil)
        let font = attributes[.font] as? NSFont
        let color = attributes[.foregroundColor] as? NSColor
        
        XCTAssertNotNil(font)
        XCTAssertNotNil(color)
    }
    #endif
    
    // MARK: - Memory and Performance Integration
    
    func testLargeDocumentIntegration() {
        var markdown = "# Large Document Test\n\n"
        
        // 创建一个大文档
        for i in 1...100 {
            markdown += """
            ## Section \(i)
            
            This is section \(i) with **bold**, *italic*, and `code` text.
            
            1. Item 1
            2. Item 2
            3. Item 3
            
            """
        }
        
        let result = parser.attributedString(from: markdown)
        
        XCTAssertGreaterThan(result.length, 1000)
        XCTAssertTrue(result.string.contains("Section 1"))
        XCTAssertTrue(result.string.contains("Section 100"))
    }
}
