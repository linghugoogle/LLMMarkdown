//
//  RendererTests.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import XCTest
@testable import LLMMarkdown

final class RendererTests: XCTestCase {
    
    var renderer: AttributedStringRenderer!
    var theme: MarkdownTheme!
    
    override func setUp() {
        super.setUp()
        theme = DefaultTheme()
        renderer = AttributedStringRenderer(theme: theme)
    }
    
    override func tearDown() {
        renderer = nil
        theme = nil
        super.tearDown()
    }
    
    // MARK: - Text Node Tests
    
    func testRenderTextNode() {
        let textNode = TextNode(content: "Hello World")
        let result = renderer.render(textNode)
        
        XCTAssertEqual(result.string, "Hello World")
        XCTAssertEqual(result.length, 11)
    }
    
    func testRenderEmptyTextNode() {
        let textNode = TextNode(content: "")
        let result = renderer.render(textNode)
        
        XCTAssertEqual(result.string, "")
        XCTAssertEqual(result.length, 0)
    }
    
    // MARK: - Header Node Tests
    
    func testRenderHeaderNode() {
        let headerNode = HeaderNode(level: 1)
        let textNode = TextNode(content: "Main Title")
        headerNode.addChild(textNode)
        
        let result = renderer.render(headerNode)
        
        XCTAssertEqual(result.string, "Main Title\n")
        
        // 检查字体大小是否正确
        let attributes = result.attributes(at: 0, effectiveRange: nil)
        let font = attributes[.font] as? PlatformFont
        XCTAssertNotNil(font)
        XCTAssertTrue(font!.pointSize > theme.typography.baseFontSize)
    }
    
    func testRenderMultipleLevelHeaders() {
        for level in 1...6 {
            let headerNode = HeaderNode(level: level)
            let textNode = TextNode(content: "Header \(level)")
            headerNode.addChild(textNode)
            
            let result = renderer.render(headerNode)
            
            XCTAssertEqual(result.string, "Header \(level)\n")
            
            let attributes = result.attributes(at: 0, effectiveRange: nil)
            let font = attributes[.font] as? PlatformFont
            XCTAssertNotNil(font)
        }
    }
    
    // MARK: - Strong Node Tests
    
    func testRenderStrongNode() {
        let strongNode = StrongNode()
        let textNode = TextNode(content: "Bold Text")
        strongNode.addChild(textNode)
        
        let result = renderer.render(strongNode)
        
        XCTAssertEqual(result.string, "Bold Text")
        
        // 检查是否应用了粗体样式
        let attributes = result.attributes(at: 0, effectiveRange: nil)
        let font = attributes[.font] as? PlatformFont
        XCTAssertNotNil(font)
        
        #if os(iOS)
        XCTAssertTrue(font!.fontDescriptor.symbolicTraits.contains(.traitBold))
        #elseif os(macOS)
        XCTAssertTrue(font!.fontDescriptor.symbolicTraits.contains(.bold))
        #endif
    }
    
    // MARK: - Emphasis Node Tests
    
    func testRenderEmphasisNode() {
        let emphasisNode = EmphasisNode()
        let textNode = TextNode(content: "Italic Text")
        emphasisNode.addChild(textNode)
        
        let result = renderer.render(emphasisNode)
        
        XCTAssertEqual(result.string, "Italic Text")
        
        // 检查是否应用了斜体样式
        let attributes = result.attributes(at: 0, effectiveRange: nil)
        let font = attributes[.font] as? PlatformFont
        XCTAssertNotNil(font)
        
        #if os(iOS)
        XCTAssertTrue(font!.fontDescriptor.symbolicTraits.contains(.traitItalic))
        #elseif os(macOS)
        XCTAssertTrue(font!.fontDescriptor.symbolicTraits.contains(.italic))
        #endif
    }
    
    // MARK: - Code Node Tests
    
    func testRenderCodeNode() {
        let codeNode = CodeNode(content: "let x = 42")
        
        let result = renderer.render(codeNode)
        
        XCTAssertEqual(result.string, "let x = 42")
        
        // 检查是否应用了代码样式
        var range = NSRange()
        let attributes = result.attributes(at: 0, effectiveRange: &range)
        let font = attributes[NSAttributedString.Key.font] as? PlatformFont
        let backgroundColor = attributes[NSAttributedString.Key.backgroundColor] as? PlatformColor
        
        XCTAssertNotNil(font)
        XCTAssertNotNil(backgroundColor)
        
        // 验证是否使用了等宽字体
        #if os(iOS)
        XCTAssertTrue(font!.fontDescriptor.symbolicTraits.contains(.traitMonoSpace))
        #elseif os(macOS)
        XCTAssertTrue(font!.isFixedPitch)
        #endif
    }
    
    // MARK: - Link Node Tests
    
    func testRenderLinkNode() {
        let linkNode = LinkNode(url: "https://example.com")
        let textNode = TextNode(content: "Example Link")
        linkNode.addChild(textNode)
        
        let result = renderer.render(linkNode)
        
        XCTAssertEqual(result.string, "Example Link")
        
        // 检查链接属性
        let attributes = result.attributes(at: 0, effectiveRange: nil)
        let linkURL = attributes[.link] as? URL
        let color = attributes[.foregroundColor] as? PlatformColor
        
        XCTAssertNotNil(linkURL)
        XCTAssertEqual(linkURL?.absoluteString, "https://example.com")
        XCTAssertNotNil(color)
    }
    
    // MARK: - Paragraph Node Tests
    
    func testRenderParagraphNode() {
        let paragraphNode = ParagraphNode()
        let textNode = TextNode(content: "This is a paragraph.")
        paragraphNode.addChild(textNode)
        
        let result = renderer.render(paragraphNode)
        
        XCTAssertEqual(result.string, "This is a paragraph.")
    }
    
    func testRenderEmptyParagraphNode() {
        let paragraphNode = ParagraphNode()
        let emptyTextNode = TextNode(content: "")
        paragraphNode.addChild(emptyTextNode)
        
        let result = renderer.render(paragraphNode)
        
        XCTAssertEqual(result.string, "\n")
    }
    
    // MARK: - List Node Tests
    
    func testRenderUnorderedListNode() {
        let listNode = ListNode(isOrdered: false)
        
        let listItem1 = ListItemNode()
        let text1 = TextNode(content: "First item")
        listItem1.addChild(text1)
        
        let listItem2 = ListItemNode()
        let text2 = TextNode(content: "Second item")
        listItem2.addChild(text2)
        
        listNode.addChild(listItem1)
        listNode.addChild(listItem2)
        
        let result = renderer.render(listNode)
        
        XCTAssertTrue(result.string.contains("• First item"))
        XCTAssertTrue(result.string.contains("• Second item"))
    }
    
    func testRenderOrderedListNode() {
        let listNode = ListNode(isOrdered: true)
        
        let listItem1 = ListItemNode()
        let text1 = TextNode(content: "First item")
        listItem1.addChild(text1)
        
        let listItem2 = ListItemNode()
        let text2 = TextNode(content: "Second item")
        listItem2.addChild(text2)
        
        let listItem3 = ListItemNode()
        let text3 = TextNode(content: "Third item")
        listItem3.addChild(text3)
        
        listNode.addChild(listItem1)
        listNode.addChild(listItem2)
        listNode.addChild(listItem3)
        
        let result = renderer.render(listNode)
        
        XCTAssertTrue(result.string.contains("1. First item"))
        XCTAssertTrue(result.string.contains("2. Second item"))
        XCTAssertTrue(result.string.contains("3. Third item"))
    }
    
    // MARK: - Document Node Tests
    
    func testRenderDocumentNode() {
        let document = DocumentNode()
        
        let header = HeaderNode(level: 1)
        let headerText = TextNode(content: "Title")
        header.addChild(headerText)
        
        let paragraph = ParagraphNode()
        let paragraphText = TextNode(content: "Content")
        paragraph.addChild(paragraphText)
        
        document.addChild(header)
        document.addChild(paragraph)
        
        let result = renderer.render(document)
        
        XCTAssertTrue(result.string.contains("Title"))
        XCTAssertTrue(result.string.contains("Content"))
    }
    
    // MARK: - Complex Structure Tests
    
    func testRenderNestedEmphasis() {
        let strongNode = StrongNode()
        let emphasisNode = EmphasisNode()
        let textNode = TextNode(content: "Bold and Italic")
        
        emphasisNode.addChild(textNode)
        strongNode.addChild(emphasisNode)
        
        let result = renderer.render(strongNode)
        
        XCTAssertEqual(result.string, "Bold and Italic")
        
        // 检查是否同时应用了粗体和斜体
        let attributes = result.attributes(at: 0, effectiveRange: nil)
        let font = attributes[.font] as? PlatformFont
        XCTAssertNotNil(font)
        
        #if os(iOS)
        let traits = font!.fontDescriptor.symbolicTraits
        XCTAssertTrue(traits.contains(.traitBold))
        XCTAssertTrue(traits.contains(.traitItalic))
        #elseif os(macOS)
        let traits = font!.fontDescriptor.symbolicTraits
        XCTAssertTrue(traits.contains(.bold))
        XCTAssertTrue(traits.contains(.italic))
        #endif
    }
    
    func testRenderMixedContent() {
        let paragraph = ParagraphNode()
        
        let text1 = TextNode(content: "This is ")
        let strong = StrongNode()
        let strongText = TextNode(content: "bold")
        strong.addChild(strongText)
        
        let text2 = TextNode(content: " and this is ")
        let emphasis = EmphasisNode()
        let emphasisText = TextNode(content: "italic")
        emphasis.addChild(emphasisText)
        
        let text3 = TextNode(content: " text.")
        
        paragraph.addChild(text1)
        paragraph.addChild(strong)
        paragraph.addChild(text2)
        paragraph.addChild(emphasis)
        paragraph.addChild(text3)
        
        let result = renderer.render(paragraph)
        
        XCTAssertEqual(result.string, "This is bold and this is italic text.")
    }
    
    // MARK: - Theme Tests
    
    func testRenderWithGitHubTheme() {
        let githubTheme = GitHubTheme()
        let githubRenderer = AttributedStringRenderer(theme: githubTheme)
        
        let textNode = TextNode(content: "GitHub styled text")
        let result = githubRenderer.render(textNode)
        
        XCTAssertEqual(result.string, "GitHub styled text")
        
        // 验证使用了GitHub主题的样式
        let attributes = result.attributes(at: 0, effectiveRange: nil)
        let color = attributes[.foregroundColor] as? PlatformColor
        XCTAssertNotNil(color)
    }
    
    // MARK: - Performance Tests
    
    func testRenderPerformance() {
        let document = DocumentNode()
        
        // 创建大量内容
        for i in 1...100 {
            let paragraph = ParagraphNode()
            let text = TextNode(content: "This is paragraph number \(i) with some content.")
            paragraph.addChild(text)
            document.addChild(paragraph)
        }
        
        measure {
            _ = renderer.render(document)
        }
    }
    
    // MARK: - Edge Cases
    
    func testRenderNodeWithoutChildren() {
        let paragraph = ParagraphNode()
        let result = renderer.render(paragraph)
        
        XCTAssertEqual(result.string, "\n")
    }
    
    func testRenderWithSpecialCharacters() {
        let textNode = TextNode(content: "Special chars: 中文 🚀 \"quotes\" & <tags>")
        let result = renderer.render(textNode)
        
        XCTAssertEqual(result.string, "Special chars: 中文 🚀 \"quotes\" & <tags>")
    }
    
    func testRenderWithNewlines() {
        let textNode = TextNode(content: "Line 1\nLine 2\nLine 3")
        let result = renderer.render(textNode)
        
        XCTAssertEqual(result.string, "Line 1\nLine 2\nLine 3")
    }
}
