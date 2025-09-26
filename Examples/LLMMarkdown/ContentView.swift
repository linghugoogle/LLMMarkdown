//
//  ContentView.swift
//  LLMMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var markdownText = """
    # LLMMarkdown Demo

    This is a **powerful** markdown parser with *italic* support.

    ## Features

    - **Bold text** support
    - *Italic text* support
    - `Inline code` support
    - [Links](https://example.com) support
    
    1. Test one
    2. Test two
    3. Test three

    ### Code Example

    Here's some `Swift` code: `let x = 42`

    **Nested _emphasis_ works** too!
    """

    var body: some View {
        VStack {
            Text("Markdown Input")
                .font(.headline)
                .padding(.top)

            TextEditor(text: $markdownText)
                .font(.system(.body, design: .monospaced))
                .cornerRadius(8)

            Divider()

            Text("Rendered Output")
                .font(.headline)

            // Remove ScrollView wrapper for macOS NSTextView
            #if os(iOS)
            MarkdownTextView(markdown: markdownText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            #elseif os(macOS)
            MarkdownTextView(markdown: markdownText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
            #endif

            Spacer()
        }
        .padding()
    }
}

#if os(iOS)
struct MarkdownTextView: UIViewRepresentable {
    let markdown: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        // Basic configuration
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = true
        
        // Configure text container for proper wrapping
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.heightTracksTextView = false
        
        // Set content compression resistance
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let attributedString = LLMMarkdown.attributedString(from: markdown)
        uiView.attributedText = attributedString
    }
}
#elseif os(macOS)
struct MarkdownTextView: NSViewRepresentable {
    let markdown: String
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        textView.isEditable = false
        textView.backgroundColor = .clear
        
        // Configure text container
        textView.textContainer?.containerSize = CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        
        // Configure layout
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        // Configure scroll view
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        let attributedString = LLMMarkdown.attributedString(from: markdown)
        print(attributedString.string)
        textView.textStorage?.setAttributedString(attributedString)
    }
}
#endif

#Preview {
    ContentView()
}
