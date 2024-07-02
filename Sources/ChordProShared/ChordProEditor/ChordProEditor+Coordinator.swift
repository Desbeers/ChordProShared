//
//  ChordProEditor+Coordinator.swift
//  ChordProShared
//
//  Created by Nick Berendsen on 27/06/2024.
//

import SwiftUI

public extension ChordProEditor {

    // MARK: The coordinator for the editor

    /// The coordinator for the ``ChordProEditor``
    class Coordinator: NSObject, NSTextViewDelegate {
        /// The parent
        var parent: ChordProEditor
        /// The optional balance string, close  a`{` or `[`
        private var balance: String?
        /// Bool if the whole text must be (re)highlighted or just the current fragment
        private var fullHighlight: Bool = true
        /// Debounce task for the text update
        private var task: Task<Void, Never>?

        /// Init the **coordinator**
        /// - Parameter parent: The ``ChordProEditor``
        public init(_ parent: ChordProEditor) {
            self.parent = parent
        }

        // MARK: Protocol Functions

        public func textView(_ view: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
            /// Disable context-menu, it is full with useless rubbish...
            return nil

            /// Experimental code to add **ChordPro** directives to the context-menu

//            guard let textView = view as? TextView else {
//                return menu
//            }
//            let newMenu = NSMenu()
//            newMenu.allowsContextMenuPlugIns = false
//            newMenu.autoenablesItems = false
//            newMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "")
//            newMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "")
//            newMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "")
//            newMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "")
//            newMenu.addItem(.separator())
//            let menuItem = newMenu.addItem(withTitle: "Metadata", action: nil, keyEquivalent: "")
//            menuItem.isEnabled = textView.currentDirective == nil ? true : false
//            let subMenu = NSMenu()
//            menuItem.submenu = subMenu
//            for directive in parent.directives {
//                let item = subMenu.addItem(withTitle: directive.directive, action: #selector(self.didSelectClickMe(_:)), keyEquivalent: "")
//                item.representedObject = directive
//                item.target = self
//            }
//            return newMenu
        }

        @objc func didSelectClickMe(_ sender: NSMenuItem) {
            guard 
                let directive = sender.representedObject as? ChordProDirective,
                let textView = parent.textView
            else {
                return
            }
            print("Directive: \(directive.directive)")
            textView.insertText(directive.directive, replacementRange: textView.selectedRange())
        }

        /// Protocol function to check if a text should change
        /// - Parameters:
        ///   - textView: The `NSTextView`
        ///   - affectedCharRange: The character range that is affected
        ///   - replacementString: The optional replacement string
        /// - Returns: True or false
        public func textView(
            _ textView: NSTextView,
            shouldChangeTextIn affectedCharRange: NSRange,
            replacementString: String?
        ) -> Bool {
            balance = replacementString == "[" ? "]" : replacementString == "{" ? "}" : nil
            fullHighlight = replacementString?.count ?? 0 > 1
            return true
        }

        /// Protocol function with a notification that the text has changed
        /// - Parameter notification: The notification with the `NSTextView` as object
        public func textDidChange(_ notification: Notification) {
            guard
                let textView = notification.object as? TextView,
                let range = textView.selectedRanges.first?.rangeValue
            else {
                return
            }
            /// Check if a typed `[` or `{` should be closed
            if let balance {
                textView.insertText(balance, replacementRange: range)
                textView.selectedRanges = [NSValue(range: range)]
                self.balance = nil
            }
            let composeText = textView.string as NSString
            var highlightRange = NSRange()
            if fullHighlight {
                /// Full highlighting of the document
                highlightRange = NSRange(location: 0, length: composeText.length)
            } else {
                /// Highlight only the current paragraph
                highlightRange = composeText.paragraphRange(for: textView.selectedRange)
            }
            /// Do the highlighting
            parent.highlightText(textView: textView, range: highlightRange)
            /// Update the fragment information
            textView.setFragmentInformation(selectedRange: range)
            /// Debounce the text update
            self.task?.cancel()
            self.task = Task {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    parent.text = textView.string
                } catch { }
            }
        }

        /// Protocol function with a notification that the text selection has changed
        /// - Parameter notification: The notification with the `NSTextView` as object
        public func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? TextView, let range = textView.selectedRanges.first?.rangeValue
            else { return }
            /// Update the fragment information
            textView.setFragmentInformation(selectedRange: range)
            textView.chordProEditorDelegate?.selectionNeedsDisplay()
        }
    }
}
