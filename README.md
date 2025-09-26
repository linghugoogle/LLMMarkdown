# LLMMarkdown

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2013.0%2B%20%7C%20macOS%2010.15%2B-lightgrey.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/v/LLMMarkdown.svg)](https://cocoapods.org/pods/LLMMarkdown)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

[中文文档](README_CN.md) | English

A powerful, lightweight, and extensible Markdown parser for iOS and macOS applications. LLMMarkdown converts Markdown text into beautifully styled `NSAttributedString` with full customization support.

## ✨ Features

- 🚀 **High Performance**: Efficient parsing with AST-based architecture
- 🎨 **Customizable Themes**: Built-in themes (Default, GitHub) with full customization support
- 📱 **Cross-Platform**: Native support for both iOS and macOS
- 🔧 **Extensible**: Plugin-based rule system for custom Markdown elements
- 💪 **Type-Safe**: Written in Swift with comprehensive type safety
- 🎯 **SwiftUI Ready**: Easy integration with SwiftUI applications

### Supported Markdown Elements

- **Text Formatting**: Bold, italic, nested emphasis
- **Headers**: H1-H6 with customizable styling
- **Lists**: Ordered and unordered lists with proper numbering
- **Links**: Clickable links with custom styling
- **Code**: Inline code with syntax highlighting support
- **Paragraphs**: Proper paragraph spacing and formatting
- **Line Breaks**: Preserved empty lines and spacing

## 📦 Installation

### Swift Package Manager

Add LLMMarkdown to your project using Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/linghugoogle/LLMMarkdown.git`
3. Select the version and add to your target

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/linghugoogle/LLMMarkdown.git", from: "1.0.0")
]
```

### CocoaPods

Add the following line to your `Podfile`:

```ruby
pod 'LLMMarkdown', '~> 1.0'
```

Then run:

```bash
pod install
```

### Manual Installation

1. Clone the repository
2. Drag the `Sources/LLMMarkdown` folder into your Xcode project
3. Make sure to add it to your target

## 🚀 Quick Start

### Basic Usage

```swift
import LLMMarkdown

let markdown = """
# Hello World

This is **bold** text and this is *italic*.

Here's some `inline code` and a [link](https://example.com).

## Lists

1. First item
2. Second item
3. Third item

- Unordered item
- Another item
"""

// Convert to NSAttributedString
let attributedString = LLMMarkdown.attributedString(from: markdown)

// Use in UILabel, UITextView, etc.
textView.attributedText = attributedString
```

### SwiftUI Integration

```swift
import SwiftUI
import LLMMarkdown

struct ContentView: View {
    let markdown = "# Hello **SwiftUI**!"

    var body: some View {
        MarkdownTextView(markdown: markdown)
            .padding()
    }
}

struct MarkdownTextView: UIViewRepresentable {
    let markdown: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = LLMMarkdown.attributedString(from: markdown)
    }
}
```

### Custom Themes

```swift
// Use built-in GitHub theme
let parser = LLMMarkdown(theme: GitHubTheme())
let styledText = parser.attributedString(from: markdown)

// Create custom theme
struct MyCustomTheme: MarkdownTheme {
    var colorScheme: ColorScheme {
        ColorScheme(
            primary: .label,
            secondary: .secondaryLabel,
            background: .systemBackground,
            surface: .secondarySystemBackground,
            accent: .systemBlue,
            link: .systemBlue,
            code: .systemRed,
            codeBackground: .systemGray6
        )
    }

    var typography: Typography {
        Typography(
            baseFont: .systemFont(ofSize: 16),
            baseFontSize: 16,
            lineHeight: 1.5
        )
    }
}

let customParser = LLMMarkdown(theme: MyCustomTheme())
```

## 📋 Requirements

- iOS 13.0+ / macOS 10.15+
- Xcode 14.0+
- Swift 5.7+

## 🏗 Architecture

LLMMarkdown follows a clean, modular architecture:

- **Parser**: Converts Markdown text to AST
- **Rules**: Extensible rule system for different Markdown elements
- **Renderer**: Converts AST to NSAttributedString
- **Themes**: Customizable styling system

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

LLMMarkdown is available under the MIT license. See the LICENSE file for more info.