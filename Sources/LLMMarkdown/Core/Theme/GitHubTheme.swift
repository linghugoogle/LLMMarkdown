//
//  GitHubTheme.swift
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

/// GitHub-style theme
public struct GitHubTheme: MarkdownTheme {
    
    public let colorScheme: ColorScheme
    public let typography: Typography
    
    public init() {
        // GitHub-inspired colors
        #if os(iOS)
        self.colorScheme = ColorScheme(
            primary: UIColor(red: 0.13, green: 0.17, blue: 0.21, alpha: 1.0), // #24292e
            secondary: UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0), // #737373
            background: UIColor.white,
            surface: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.0), // #f6f8fa
            accent: UIColor(red: 0.20, green: 0.45, blue: 0.93, alpha: 1.0), // #0366d6
            link: UIColor(red: 0.20, green: 0.45, blue: 0.93, alpha: 1.0), // #0366d6
            code: UIColor(red: 0.85, green: 0.19, blue: 0.47, alpha: 1.0), // #d73a49
            codeBackground: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.0) // #f6f8fa
        )
        
        self.typography = Typography(
            baseFont: UIFont.systemFont(ofSize: 16.0),
            headerSizeMultipliers: [2.0, 1.5, 1.25, 1.0, 0.875, 0.85]
        )
        #elseif os(macOS)
        self.colorScheme = ColorScheme(
            primary: NSColor(red: 0.13, green: 0.17, blue: 0.21, alpha: 1.0),
            secondary: NSColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0),
            background: NSColor.white,
            surface: NSColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.0),
            accent: NSColor(red: 0.20, green: 0.45, blue: 0.93, alpha: 1.0),
            link: NSColor(red: 0.20, green: 0.45, blue: 0.93, alpha: 1.0),
            code: NSColor(red: 0.85, green: 0.19, blue: 0.47, alpha: 1.0),
            codeBackground: NSColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.0)
        )
        
        self.typography = Typography(
            baseFont: NSFont.systemFont(ofSize: 16.0),
            headerSizeMultipliers: [2.0, 1.5, 1.25, 1.0, 0.875, 0.85]
        )
        #endif
    }
}
