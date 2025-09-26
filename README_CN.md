# KXMarkdown

[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS-lightgrey.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

中文文档 | [English](README.md)

一个功能强大、轻量级且可扩展的 Markdown 解析器，专为 iOS 和 macOS 应用程序设计。KXMarkdown 将 Markdown 文本转换为美观的 `NSAttributedString`，并支持完全自定义。

## ✨ 特性

- 🚀 **高性能**: 基于 AST 架构的高效解析
- 🎨 **可自定义主题**: 内置主题（默认、GitHub）并支持完全自定义
- 📱 **跨平台**: 原生支持 iOS 和 macOS
- 🔧 **可扩展**: 基于插件的规则系统，支持自定义 Markdown 元素
- 💪 **类型安全**: 使用 Swift 编写，具有全面的类型安全性
- 🎯 **SwiftUI 就绪**: 轻松集成到 SwiftUI 应用程序

### 支持的 Markdown 元素

- **文本格式**: 粗体、斜体、嵌套强调
- **标题**: H1-H6 可自定义样式
- **列表**: 有序和无序列表，支持正确编号
- **链接**: 可点击链接，支持自定义样式
- **代码**: 内联代码，支持语法高亮
- **段落**: 正确的段落间距和格式
- **换行**: 保留空行和间距

## 📦 安装

### Swift Package Manager

使用 Xcode 将 KXMarkdown 添加到您的项目：

1. 文件 → 添加包依赖项
2. 输入仓库 URL：`https://github.com/yourusername/KXMarkdown.git`
3. 选择版本并添加到您的目标

或者添加到您的 `Package.swift`：

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/KXMarkdown.git", from: "1.0.0")
]
```

### 手动安装

1. 克隆仓库
2. 将 `Source` 文件夹拖入您的 Xcode 项目
3. 确保将其添加到您的目标

## 🚀 快速开始

### 基本用法

```swift
import KXMarkdown

let markdown = """
# 你好世界

这是 **粗体** 文本，这是 *斜体*。

这里有一些 `内联代码` 和一个 [链接](https://example.com)。

## 列表

1. 第一项
2. 第二项
3. 第三项

- 无序项目
- 另一个项目
"""

// 转换为 NSAttributedString
let attributedString = KXMarkdown.attributedString(from: markdown)

// 在 UILabel、UITextView 等中使用
textView.attributedText = attributedString
```

### SwiftUI 集成

```swift
import SwiftUI
import KXMarkdown

struct ContentView: View {
    let markdown = "# 你好 **SwiftUI**!"
    
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
        uiView.attributedText = KXMarkdown.attributedString(from: markdown)
    }
}
```

### 自定义主题

```swift
// 使用内置的 GitHub 主题
let parser = KXMarkdown(theme: GitHubTheme())
let styledText = parser.attributedString(from: markdown)

// 创建自定义主题
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

let customParser = KXMarkdown(theme: MyCustomTheme())
```

### 高级用法

```swift
// 解析为 AST 进行自定义处理
let parser = KXMarkdown()
let ast = parser.parseAST(from: markdown)

// 添加自定义规则
parser.addRule(MyCustomRule())

// 移除内置规则
parser.removeRule(BoldRule.self)
```

## 🏗 架构

KXMarkdown 遵循清晰的模块化架构：