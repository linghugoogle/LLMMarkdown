//
//  ThemeTests.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import XCTest
@testable import LLMMarkdown

final class ThemeTests: XCTestCase {
    
    // MARK: - DefaultTheme Tests
    
    func testDefaultThemeCreation() {
        let theme = DefaultTheme()
        
        XCTAssertNotNil(theme.colorScheme)
        XCTAssertNotNil(theme.typography)
    }
    
    func testDefaultThemeColorScheme() {
        let theme = DefaultTheme()
        let colorScheme = theme.colorScheme
        
        XCTAssertNotNil(colorScheme.primary)
        XCTAssertNotNil(colorScheme.secondary)
        XCTAssertNotNil(colorScheme.background)
        XCTAssertNotNil(colorScheme.surface)
        XCTAssertNotNil(colorScheme.accent)
        XCTAssertNotNil(colorScheme.link)
        XCTAssertNotNil(colorScheme.code)
        XCTAssertNotNil(colorScheme.codeBackground)
    }
    
    func testDefaultThemeTypography() {
        let theme = DefaultTheme()
        let typography = theme.typography
        
        XCTAssertNotNil(typography.baseFont)
        XCTAssertGreaterThan(typography.baseFontSize, 0)
        XCTAssertGreaterThan(typography.lineHeight, 0)
        XCTAssertEqual(typography.headerSizeMultipliers.count, 6) // H1-H6
    }
    
    func testDefaultThemeTextStyles() {
        let theme = DefaultTheme()
        
        let textStyle = theme.textStyle(for: .text)
        let headerStyle = theme.textStyle(for: .header(level: 1))
        let strongStyle = theme.textStyle(for: .strong)
        let emphasisStyle = theme.textStyle(for: .emphasis)
        let codeStyle = theme.textStyle(for: .code)
        let linkStyle = theme.textStyle(for: .link(url: "https://example.com"))
        
        XCTAssertNotNil(textStyle.font)
        XCTAssertNotNil(headerStyle.font)
        XCTAssertNotNil(strongStyle.font)
        XCTAssertNotNil(emphasisStyle.font)
        XCTAssertNotNil(codeStyle.font)
        XCTAssertNotNil(linkStyle.font)
        
        XCTAssertNotNil(textStyle.color)
        XCTAssertNotNil(headerStyle.color)
        XCTAssertNotNil(strongStyle.color)
        XCTAssertNotNil(emphasisStyle.color)
        XCTAssertNotNil(codeStyle.color)
        XCTAssertNotNil(linkStyle.color)
    }
    
    func testDefaultThemeParagraphStyles() {
        let theme = DefaultTheme()
        
        let paragraphStyle = theme.paragraphStyle(for: .paragraph)
        let headerStyle = theme.paragraphStyle(for: .header(level: 1))
        let listStyle = theme.paragraphStyle(for: .list(ordered: true))
        
        XCTAssertNotNil(paragraphStyle)
        XCTAssertNotNil(headerStyle)
        XCTAssertNotNil(listStyle)
    }
    
    // MARK: - GitHubTheme Tests
    
    func testGitHubThemeCreation() {
        let theme = GitHubTheme()
        
        XCTAssertNotNil(theme.colorScheme)
        XCTAssertNotNil(theme.typography)
    }
    
    func testGitHubThemeColorScheme() {
        let theme = GitHubTheme()
        let colorScheme = theme.colorScheme
        
        XCTAssertNotNil(colorScheme.primary)
        XCTAssertNotNil(colorScheme.secondary)
        XCTAssertNotNil(colorScheme.background)
        XCTAssertNotNil(colorScheme.surface)
        XCTAssertNotNil(colorScheme.accent)
        XCTAssertNotNil(colorScheme.link)
        XCTAssertNotNil(colorScheme.code)
        XCTAssertNotNil(colorScheme.codeBackground)
    }
    
    func testGitHubThemeTypography() {
        let theme = GitHubTheme()
        let typography = theme.typography
        
        XCTAssertNotNil(typography.baseFont)
        XCTAssertGreaterThan(typography.baseFontSize, 0)
        XCTAssertGreaterThan(typography.lineHeight, 0)
        XCTAssertEqual(typography.headerSizeMultipliers.count, 6) // H1-H6
    }
    
    func testGitHubThemeTextStyles() {
        let theme = GitHubTheme()
        
        let textStyle = theme.textStyle(for: .text)
        let headerStyle = theme.textStyle(for: .header(level: 1))
        let strongStyle = theme.textStyle(for: .strong)
        let emphasisStyle = theme.textStyle(for: .emphasis)
        let codeStyle = theme.textStyle(for: .code)
        let linkStyle = theme.textStyle(for: .link(url: "https://example.com"))
        
        XCTAssertNotNil(textStyle.font)
        XCTAssertNotNil(headerStyle.font)
        XCTAssertNotNil(strongStyle.font)
        XCTAssertNotNil(emphasisStyle.font)
        XCTAssertNotNil(codeStyle.font)
        XCTAssertNotNil(linkStyle.font)
    }
    
    // MARK: - TextStyle Tests
    
    func testTextStyleCreation() {
        let font = PlatformFont.systemFont(ofSize: 16)
        let color = PlatformColor.black
        let backgroundColor = PlatformColor.white
        
        let textStyle = TextStyle(
            font: font,
            color: color,
            backgroundColor: backgroundColor,
            underlineStyle: .single,
            strikethroughStyle: .single
        )
        
        XCTAssertEqual(textStyle.font, font)
        XCTAssertEqual(textStyle.color, color)
        XCTAssertEqual(textStyle.backgroundColor, backgroundColor)
        XCTAssertEqual(textStyle.underlineStyle, .single)
        XCTAssertEqual(textStyle.strikethroughStyle, .single)
    }
    
    func testTextStyleAttributes() {
        let font = PlatformFont.systemFont(ofSize: 16)
        let color = PlatformColor.black
        
        let textStyle = TextStyle(font: font, color: color)
        let attributes = textStyle.attributes()
        
        XCTAssertEqual(attributes[.font] as? PlatformFont, font)
        XCTAssertEqual(attributes[.foregroundColor] as? PlatformColor, color)
    }
    
    func testTextStyleWithAllAttributes() {
        let font = PlatformFont.systemFont(ofSize: 16)
        let color = PlatformColor.black
        let backgroundColor = PlatformColor.white
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let textStyle = TextStyle(
            font: font,
            color: color,
            backgroundColor: backgroundColor,
            underlineStyle: .single,
            strikethroughStyle: .single,
            paragraphStyle: paragraphStyle
        )
        
        let attributes = textStyle.attributes()
        
        XCTAssertEqual(attributes[.font] as? PlatformFont, font)
        XCTAssertEqual(attributes[.foregroundColor] as? PlatformColor, color)
        XCTAssertEqual(attributes[.backgroundColor] as? PlatformColor, backgroundColor)
        XCTAssertEqual(attributes[.underlineStyle] as? Int, NSUnderlineStyle.single.rawValue)
        XCTAssertEqual(attributes[.strikethroughStyle] as? Int, NSUnderlineStyle.single.rawValue)
        XCTAssertEqual(attributes[.paragraphStyle] as? NSParagraphStyle, paragraphStyle)
    }
    
    // MARK: - ColorScheme Tests
    
    func testColorSchemeCreation() {
        let colorScheme = ColorScheme(
            primary: .black,
            secondary: .gray,
            background: .white,
            surface: .lightGray,
            accent: .blue,
            link: .blue,
            code: .red,
            codeBackground: .lightGray
        )
        
        XCTAssertEqual(colorScheme.primary, .black)
        XCTAssertEqual(colorScheme.secondary, .gray)
        XCTAssertEqual(colorScheme.background, .white)
        XCTAssertEqual(colorScheme.surface, .lightGray)
        XCTAssertEqual(colorScheme.accent, .blue)
        XCTAssertEqual(colorScheme.link, .blue)
        XCTAssertEqual(colorScheme.code, .red)
        XCTAssertEqual(colorScheme.codeBackground, .lightGray)
    }
    
    // MARK: - Typography Tests
    
    func testTypographyCreation() {
        let baseFont = PlatformFont.systemFont(ofSize: 16)
        let typography = Typography(
            baseFont: baseFont,
            baseFontSize: 16,
            lineHeight: 1.4,
            headerSizeMultipliers: [2.0, 1.5, 1.25, 1.1, 1.0, 0.9]
        )
        
        XCTAssertEqual(typography.baseFont, baseFont)
        XCTAssertEqual(typography.baseFontSize, 16)
        XCTAssertEqual(typography.lineHeight, 1.4)
        XCTAssertEqual(typography.headerSizeMultipliers.count, 6)
    }
    
    func testTypographyHeaderFonts() {
        let baseFont = PlatformFont.systemFont(ofSize: 16)
        let typography = Typography(baseFont: baseFont, baseFontSize: 16)
        
        let h1Font = typography.headerFont(level: 1)
        let h2Font = typography.headerFont(level: 2)
        let h6Font = typography.headerFont(level: 6)
        
        XCTAssertNotNil(h1Font)
        XCTAssertNotNil(h2Font)
        XCTAssertNotNil(h6Font)
        
        // H1 should be larger than H2
        XCTAssertGreaterThan(h1Font.pointSize, h2Font.pointSize)
        // H2 should be larger than H6
        XCTAssertGreaterThan(h2Font.pointSize, h6Font.pointSize)
    }
    
    func testTypographyCodeFont() {
        let baseFont = PlatformFont.systemFont(ofSize: 16)
        let typography = Typography(baseFont: baseFont, baseFontSize: 16)
        
        let codeFont = typography.codeFont()
        XCTAssertNotNil(codeFont)
        
        // Code font should be monospaced
        #if os(iOS)
        XCTAssertTrue(codeFont.fontDescriptor.symbolicTraits.contains(.traitMonoSpace))
        #elseif os(macOS)
        XCTAssertTrue(codeFont.fontDescriptor.symbolicTraits.contains(.monoSpace))
        #endif
    }
    
    // MARK: - Custom Theme Tests
    
    func testCustomTheme() {
        let customTheme = CustomTestTheme()
        
        let textStyle = customTheme.textStyle(for: .text)
        let headerStyle = customTheme.textStyle(for: .header(level: 1))
        
        XCTAssertNotNil(textStyle)
        XCTAssertNotNil(headerStyle)
        
        let paragraphStyle = customTheme.paragraphStyle(for: .paragraph)
        XCTAssertNotNil(paragraphStyle)
    }
    
    // MARK: - Theme Integration Tests
    
    func testThemeWithParser() {
        let defaultParser = LLMMarkdown(theme: DefaultTheme())
        let githubParser = LLMMarkdown(theme: GitHubTheme())
        
        let markdown = "# Header\n\nSome **bold** text with `code`."
        
        let defaultResult = defaultParser.attributedString(from: markdown)
        let githubResult = githubParser.attributedString(from: markdown)
        
        XCTAssertGreaterThan(defaultResult.length, 0)
        XCTAssertGreaterThan(githubResult.length, 0)
        
        // Results should have the same text content but potentially different styling
        XCTAssertEqual(defaultResult.string, githubResult.string)
    }
}

// MARK: - Custom Test Theme

struct CustomTestTheme: MarkdownTheme {
    var colorScheme: ColorScheme {
        ColorScheme(
            primary: .black,
            secondary: .gray,
            background: .white,
            surface: .lightGray,
            accent: .blue,
            link: .blue,
            code: .red,
            codeBackground: .lightGray
        )
    }
    
    var typography: Typography {
        Typography(
            baseFont: .systemFont(ofSize: 14),
            baseFontSize: 14,
            lineHeight: 1.2
        )
    }
}
