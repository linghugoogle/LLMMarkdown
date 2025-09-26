//
//  MarkdownTheme.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import Foundation
#if os(iOS)
import UIKit
public typealias PlatformColor = UIColor
public typealias PlatformFont = UIFont
#elseif os(macOS)
import AppKit
public typealias PlatformColor = NSColor
public typealias PlatformFont = NSFont
#endif

/// Represents text styling attributes
public struct TextStyle {
    public let font: PlatformFont
    public let color: PlatformColor
    public let backgroundColor: PlatformColor?
    public let underlineStyle: NSUnderlineStyle?
    public let strikethroughStyle: NSUnderlineStyle?
    public let paragraphStyle: NSParagraphStyle?
    
    public init(
        font: PlatformFont,
        color: PlatformColor,
        backgroundColor: PlatformColor? = nil,
        underlineStyle: NSUnderlineStyle? = nil,
        strikethroughStyle: NSUnderlineStyle? = nil,
        paragraphStyle: NSParagraphStyle? = nil
    ) {
        self.font = font
        self.color = color
        self.backgroundColor = backgroundColor
        self.underlineStyle = underlineStyle
        self.strikethroughStyle = strikethroughStyle
        self.paragraphStyle = paragraphStyle
    }
    
    /// Convert to NSAttributedString attributes dictionary
    public func attributes() -> [NSAttributedString.Key: Any] {
        var attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        
        if let backgroundColor = backgroundColor {
            attrs[.backgroundColor] = backgroundColor
        }
        
        if let underlineStyle = underlineStyle {
            attrs[.underlineStyle] = underlineStyle.rawValue
        }
        
        if let strikethroughStyle = strikethroughStyle {
            attrs[.strikethroughStyle] = strikethroughStyle.rawValue
        }
        
        if let paragraphStyle = paragraphStyle {
            attrs[.paragraphStyle] = paragraphStyle
        }
        
        return attrs
    }
}

/// Color scheme for light/dark mode support
public struct ColorScheme {
    public let primary: PlatformColor
    public let secondary: PlatformColor
    public let background: PlatformColor
    public let surface: PlatformColor
    public let accent: PlatformColor
    public let link: PlatformColor
    public let code: PlatformColor
    public let codeBackground: PlatformColor
    
    public init(
        primary: PlatformColor,
        secondary: PlatformColor,
        background: PlatformColor,
        surface: PlatformColor,
        accent: PlatformColor,
        link: PlatformColor,
        code: PlatformColor,
        codeBackground: PlatformColor
    ) {
        self.primary = primary
        self.secondary = secondary
        self.background = background
        self.surface = surface
        self.accent = accent
        self.link = link
        self.code = code
        self.codeBackground = codeBackground
    }
}

/// Typography system for consistent font sizing
public struct Typography {
    public let baseFont: PlatformFont
    public let baseFontSize: CGFloat
    public let lineHeight: CGFloat
    public let headerSizeMultipliers: [CGFloat] // H1-H6 multipliers
    
    public init(
        baseFont: PlatformFont,
        baseFontSize: CGFloat = 16.0,
        lineHeight: CGFloat = 1.4,
        headerSizeMultipliers: [CGFloat] = [2.0, 1.5, 1.25, 1.1, 1.0, 0.9]
    ) {
        self.baseFont = baseFont
        self.baseFontSize = baseFontSize
        self.lineHeight = lineHeight
        self.headerSizeMultipliers = headerSizeMultipliers
    }
    
    /// Get font for header level (1-6)
    public func headerFont(level: Int) -> PlatformFont {
        let clampedLevel = max(1, min(6, level))
        let multiplier = headerSizeMultipliers[clampedLevel - 1]
        let fontSize = baseFontSize * multiplier
        
        #if os(iOS)
        return UIFont.boldSystemFont(ofSize: fontSize)
        #elseif os(macOS)
        return NSFont.boldSystemFont(ofSize: fontSize)
        #endif
    }
    
    /// Get monospace font for code
    public func codeFont() -> PlatformFont {
        #if os(iOS)
        return UIFont.monospacedSystemFont(ofSize: baseFontSize * 0.9, weight: .regular)
        #elseif os(macOS)
        return NSFont.monospacedSystemFont(ofSize: baseFontSize * 0.9, weight: .regular)
        #endif
    }
}

/// Protocol for markdown themes
public protocol MarkdownTheme {
    /// Color scheme for this theme
    var colorScheme: ColorScheme { get }
    
    /// Typography settings
    var typography: Typography { get }
    
    /// Get text style for a specific node type
    func textStyle(for nodeType: NodeType) -> TextStyle
    
    /// Get paragraph style for block elements
    func paragraphStyle(for nodeType: NodeType) -> NSParagraphStyle
}

/// Default implementation of MarkdownTheme
public extension MarkdownTheme {
    func textStyle(for nodeType: NodeType) -> TextStyle {
        let colors = colorScheme
        let typo = typography
        
        switch nodeType {
        case .document, .paragraph, .text:
            return TextStyle(
                font: typo.baseFont,
                color: colors.primary,
                paragraphStyle: paragraphStyle(for: nodeType)
            )
            
        case .header(let level):
            return TextStyle(
                font: typo.headerFont(level: level),
                color: colors.primary,
                paragraphStyle: paragraphStyle(for: nodeType)
            )
            
        case .strong:
            let boldFont: PlatformFont
            #if os(iOS)
            boldFont = UIFont.boldSystemFont(ofSize: typo.baseFontSize)
            #elseif os(macOS)
            boldFont = NSFont.boldSystemFont(ofSize: typo.baseFontSize)
            #endif
            
            return TextStyle(
                font: boldFont,
                color: colors.primary
            )
            
        case .emphasis:
            let italicFont: PlatformFont
            #if os(iOS)
            italicFont = UIFont.italicSystemFont(ofSize: typo.baseFontSize)
            #elseif os(macOS)
            let fontDescriptor = NSFont.systemFont(ofSize: typo.baseFontSize).fontDescriptor
            let italicDescriptor = fontDescriptor.withSymbolicTraits(.italic)
            italicFont = NSFont(descriptor: italicDescriptor, size: typo.baseFontSize) ?? NSFont.systemFont(ofSize: typo.baseFontSize)
            #endif
            
            return TextStyle(
                font: italicFont,
                color: colors.primary
            )
            
        case .code:
            return TextStyle(
                font: typo.codeFont(),
                color: colors.code,
                backgroundColor: colors.codeBackground
            )
            
        case .link:
            return TextStyle(
                font: typo.baseFont,
                color: colors.link,
                underlineStyle: .single
            )
            
        default:
            return TextStyle(
                font: typo.baseFont,
                color: colors.primary
            )
        }
    }
    
    func paragraphStyle(for nodeType: NodeType) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        let typo = typography
        
        style.lineHeightMultiple = typo.lineHeight
        
        switch nodeType {
        case .header:
            style.paragraphSpacingBefore = typo.baseFontSize * 0.5
            style.paragraphSpacing = typo.baseFontSize * 0.25
            
        case .paragraph:
            style.paragraphSpacing = typo.baseFontSize * 0.5
            
        case .codeBlock:
            style.paragraphSpacingBefore = typo.baseFontSize * 0.25
            style.paragraphSpacing = typo.baseFontSize * 0.25
            
        default:
            break
        }
        
        return style.copy() as! NSParagraphStyle
    }
}
