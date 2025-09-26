//
//  DefaultTheme.swift
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

/// Default theme with system colors
public struct DefaultTheme: MarkdownTheme {
    
    public let colorScheme: ColorScheme
    public let typography: Typography
    
    public init() {
        // Create color scheme based on system colors
        #if os(iOS)
        self.colorScheme = ColorScheme(
            primary: UIColor.label,
            secondary: UIColor.secondaryLabel,
            background: UIColor.systemBackground,
            surface: UIColor.secondarySystemBackground,
            accent: UIColor.systemBlue,
            link: UIColor.systemBlue,
            code: UIColor.systemRed,
            codeBackground: UIColor.systemGray6
        )
        
        self.typography = Typography(
            baseFont: UIFont.systemFont(ofSize: 16.0)
        )
        #elseif os(macOS)
        self.colorScheme = ColorScheme(
            primary: NSColor.labelColor,
            secondary: NSColor.secondaryLabelColor,
            background: NSColor.textBackgroundColor,
            surface: NSColor.controlBackgroundColor,
            accent: NSColor.systemBlue,
            link: NSColor.systemBlue,
            code: NSColor.systemRed,
            codeBackground: NSColor.controlBackgroundColor
        )
        
        self.typography = Typography(
            baseFont: NSFont.systemFont(ofSize: 16.0)
        )
        #endif
    }
}
