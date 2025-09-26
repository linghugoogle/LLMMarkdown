//
//  ASTNodeTests.swift
//  KXMarkdown
//
//  Created by linghugoogle on 2025/9/26.
//

import XCTest
@testable import LLMMarkdown

final class ASTNodeTests: XCTestCase {
    
    // MARK: - TextNode Tests
    
    func testTextNodeCreation() {
        let content = "Hello World"
        let range = NSRange(location: 0, length: content.count)
        let textNode = TextNode(content: content, range: range)
        
        XCTAssertEqual(textNode.content, content)
        XCTAssertEqual(textNode.range, range)
        XCTAssertEqual(textNode.children.count, 0)
        
        if case .text = textNode.type {
            // Success
        } else {
            XCTFail("TextNode should have .text type")
        }
    }
    
    func testTextNodeWithEmptyContent() {
        let textNode = TextNode(content: "")
        XCTAssertEqual(textNode.content, "")
        XCTAssertEqual(textNode.children.count, 0)
    }
    
    // MARK: - HeaderNode Tests
    
    func testHeaderNodeCreation() {
        let headerNode = HeaderNode(level: 1)
        XCTAssertEqual(headerNode.level, 1)
        
        if case .header(let level) = headerNode.type {
            XCTAssertEqual(level, 1)
        } else {
            XCTFail("HeaderNode should have .header type")
        }
    }
    
    func testHeaderNodeLevelClamping() {
        // Test level clamping to 1-6 range
        let h0 = HeaderNode(level: 0)
        XCTAssertEqual(h0.level, 1) // Should clamp to 1
        
        let h7 = HeaderNode(level: 7)
        XCTAssertEqual(h7.level, 6) // Should clamp to 6
        
        let h3 = HeaderNode(level: 3)
        XCTAssertEqual(h3.level, 3) // Should remain 3
    }
    
    func testHeaderNodeWithChildren() {
        let headerNode = HeaderNode(level: 2)
        let textNode = TextNode(content: "Header Text")
        
        headerNode.addChild(textNode)
        
        XCTAssertEqual(headerNode.children.count, 1)
        XCTAssertTrue(textNode.parent === headerNode)
    }
    
    // MARK: - ListNode Tests
    
    func testOrderedListNode() {
        let listNode = ListNode(isOrdered: true)
        XCTAssertTrue(listNode.isOrdered)
        
        if case .list(let ordered) = listNode.type {
            XCTAssertTrue(ordered)
        } else {
            XCTFail("ListNode should have .list type")
        }
    }
    
    func testUnorderedListNode() {
        let listNode = ListNode(isOrdered: false)
        XCTAssertFalse(listNode.isOrdered)
        
        if case .list(let ordered) = listNode.type {
            XCTAssertFalse(ordered)
        } else {
            XCTFail("ListNode should have .list type")
        }
    }
    
    func testListNodeWithItems() {
        let listNode = ListNode(isOrdered: true)
        let item1 = ListItemNode()
        let item2 = ListItemNode()
        
        listNode.addChild(item1)
        listNode.addChild(item2)
        
        XCTAssertEqual(listNode.children.count, 2)
        XCTAssertTrue(item1.parent === listNode)
        XCTAssertTrue(item2.parent === listNode)
    }
    
    // MARK: - ListItemNode Tests
    
    func testListItemNode() {
        let listItemNode = ListItemNode()
        
        if case .listItem = listItemNode.type {
            // Success
        } else {
            XCTFail("ListItemNode should have .listItem type")
        }
    }
    
    func testListItemWithContent() {
        let listItemNode = ListItemNode()
        let textNode = TextNode(content: "List item content")
        
        listItemNode.addChild(textNode)
        
        XCTAssertEqual(listItemNode.children.count, 1)
        XCTAssertTrue(textNode.parent === listItemNode)
    }
    
    // MARK: - ParagraphNode Tests
    
    func testParagraphNode() {
        let paragraphNode = ParagraphNode()
        
        if case .paragraph = paragraphNode.type {
            // Success
        } else {
            XCTFail("ParagraphNode should have .paragraph type")
        }
    }
    
    func testParagraphWithContent() {
        let paragraphNode = ParagraphNode()
        let textNode = TextNode(content: "Paragraph content")
        
        paragraphNode.addChild(textNode)
        
        XCTAssertEqual(paragraphNode.children.count, 1)
        XCTAssertTrue(textNode.parent === paragraphNode)
    }
    
    // MARK: - StrongNode Tests
    
    func testStrongNode() {
        let strongNode = StrongNode()
        
        if case .strong = strongNode.type {
            // Success
        } else {
            XCTFail("StrongNode should have .strong type")
        }
    }
    
    func testStrongNodeWithText() {
        let strongNode = StrongNode()
        let textNode = TextNode(content: "Bold text")
        
        strongNode.addChild(textNode)
        
        XCTAssertEqual(strongNode.children.count, 1)
        XCTAssertTrue(textNode.parent === strongNode)
    }
    
    // MARK: - EmphasisNode Tests
    
    func testEmphasisNode() {
        let emphasisNode = EmphasisNode()
        
        if case .emphasis = emphasisNode.type {
            // Success
        } else {
            XCTFail("EmphasisNode should have .emphasis type")
        }
    }
    
    func testEmphasisNodeWithText() {
        let emphasisNode = EmphasisNode()
        let textNode = TextNode(content: "Italic text")
        
        emphasisNode.addChild(textNode)
        
        XCTAssertEqual(emphasisNode.children.count, 1)
        XCTAssertTrue(textNode.parent === emphasisNode)
    }
    
    // MARK: - CodeNode Tests
    
    func testCodeNode() {
        let content = "console.log('hello')"
        let codeNode = CodeNode(content: content)
        
        XCTAssertEqual(codeNode.content, content)
        
        if case .code = codeNode.type {
            // Success
        } else {
            XCTFail("CodeNode should have .code type")
        }
    }
    
    func testCodeNodeWithEmptyContent() {
        let codeNode = CodeNode(content: "")
        XCTAssertEqual(codeNode.content, "")
    }
    
    // MARK: - LinkNode Tests
    
    func testLinkNode() {
        let url = "https://example.com"
        let linkNode = LinkNode(url: url)
        
        XCTAssertEqual(linkNode.url, url)
        
        if case .link(let nodeUrl) = linkNode.type {
            XCTAssertEqual(nodeUrl, url)
        } else {
            XCTFail("LinkNode should have .link type")
        }
    }
    
    func testLinkNodeWithText() {
        let url = "https://example.com"
        let linkNode = LinkNode(url: url)
        let textNode = TextNode(content: "Example Link")
        
        linkNode.addChild(textNode)
        
        XCTAssertEqual(linkNode.children.count, 1)
        XCTAssertTrue(textNode.parent === linkNode)
    }
    
    // MARK: - DocumentNode Tests
    
    func testDocumentNode() {
        let documentNode = DocumentNode()
        
        if case .document = documentNode.type {
            // Success
        } else {
            XCTFail("DocumentNode should have .document type")
        }
    }
    
    func testDocumentWithChildren() {
        let documentNode = DocumentNode()
        let headerNode = HeaderNode(level: 1)
        let paragraphNode = ParagraphNode()
        
        documentNode.addChild(headerNode)
        documentNode.addChild(paragraphNode)
        
        XCTAssertEqual(documentNode.children.count, 2)
        XCTAssertTrue(headerNode.parent === documentNode)
        XCTAssertTrue(paragraphNode.parent === documentNode)
    }
    
    // MARK: - Node Hierarchy Tests
    
    func testNodeParentChildRelationship() {
        let parent = ParagraphNode()
        let child = TextNode(content: "Child text")
        
        parent.addChild(child)
        
        XCTAssertEqual(parent.children.count, 1)
        XCTAssertTrue(parent.children.first === child)
        XCTAssertTrue(child.parent === parent)
    }
    
    func testRemoveChild() {
        let parent = ParagraphNode()
        let child1 = TextNode(content: "Child 1")
        let child2 = TextNode(content: "Child 2")
        
        parent.addChild(child1)
        parent.addChild(child2)
        
        XCTAssertEqual(parent.children.count, 2)
        
        parent.removeChild(child1)
        
        XCTAssertEqual(parent.children.count, 1)
        XCTAssertTrue(parent.children.first === child2)
        XCTAssertNil(child1.parent)
    }
    
    func testNodeAttributes() {
        let node = TextNode(content: "Test")
        
        XCTAssertTrue(node.attributes.isEmpty)
        
        node.attributes["custom"] = "value"
        node.attributes["number"] = 42
        
        XCTAssertEqual(node.attributes["custom"] as? String, "value")
        XCTAssertEqual(node.attributes["number"] as? Int, 42)
    }
    
    func testNodeRange() {
        let range = NSRange(location: 10, length: 20)
        let node = TextNode(content: "Test", range: range)
        
        XCTAssertEqual(node.range, range)
        
        let newRange = NSRange(location: 5, length: 15)
        node.range = newRange
        
        XCTAssertEqual(node.range, newRange)
    }
}
