Pod::Spec.new do |spec|
  spec.name         = "LLMMarkdown"
  spec.version      = "1.0.0"
  spec.summary      = "A powerful, lightweight, and extensible Markdown parser for iOS and macOS applications."
  spec.description  = <<-DESC
    LLMMarkdown is a high-performance Markdown parser that converts Markdown text into beautifully styled NSAttributedString.
    Features include customizable themes, extensible rule system, cross-platform support, and SwiftUI integration.
  DESC

  spec.homepage     = "https://github.com/linghugoogle/LLMMarkdown"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Your Name" => "your.email@example.com" }

  spec.ios.deployment_target = "13.0"
  spec.osx.deployment_target = "10.15"
  spec.swift_version = "5.7"

  spec.source       = { :git => "https://github.com/linghugoogle/LLMMarkdown.git", :tag => "#{spec.version}" }
  spec.source_files = "Sources/**/*.swift"

  spec.framework    = "Foundation"
  spec.ios.framework = "UIKit"
  spec.osx.framework = "AppKit"

  spec.requires_arc = true
end