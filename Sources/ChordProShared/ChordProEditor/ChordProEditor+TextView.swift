//
//  ChordProEditor+TextView.swift
//  ChordProShared
//
//  Created by Nick Berendsen on 27/06/2024.
//

import SwiftUI

extension ChordProEditor {

    // MARK: The text view for the editor

    /// The text view for the editor
    public class TextView: NSTextView {

        /// The delegate for the ChordProEditor
        var chordProEditorDelegate: ChordProEditorDelegate?

        /// The parent
        var parent: ChordProEditor?

        var directives: [ChordProDirective] = []

        var currentDirective: ChordProDirective?

        var currentDirectiveArgument: String = ""
        var currentDirectiveRange: NSRange?

        /// The current fragment of the cursor
        var currentFragment: NSTextLayoutFragment?

        var lastFragmentReduce: Double = 0

        /// The optional double-clicked directive in the editor
        var clickedDirective: Bool = false

        // MARK: Override functions

        /// Draw a background behind the current fragment
        /// - Parameter dirtyRect: The current rect of the editor
        override public func draw(_ dirtyRect: CGRect) {
            guard let context = NSGraphicsContext.current?.cgContext else { return }

            if let fragment = currentFragment {
                let lineRect = CGRect(
                    x: 0,
                    y: fragment.layoutFragmentFrame.origin.y,
                    width: bounds.width,
                    height: fragment.layoutFragmentFrame.height - lastFragmentReduce
                )
                context.setFillColor(ChordProEditor.highlightedForegroundColor.cgColor)
                context.fill(lineRect)
            }
            super.draw(dirtyRect)
        }

        /// Handle double-click on directives to edit them
        /// - Parameter event: The mouse click event
        public override func mouseDown(with event: NSEvent) {
            setFragmentInformation(selectedRange: selectedRange())
            if event.clickCount == 2, let currentDirective, currentDirective.editable == true {
                clickedDirective = true
                parent?.runIntrospect(self)
            } else {
                clickedDirective = false
                return super.mouseDown(with: event)
            }
        }

        // MARK: Custom functions

        public func replaceText(text: String) {
            let composeText = self.string as NSString
            self.insertText(text, replacementRange: NSRange(location: 0, length: composeText.length))
        }
        
        /// Set the fragment information
        /// - Parameter selectedRange: The current selected range of the text editor
        func setFragmentInformation(selectedRange: NSRange) {
            lastFragmentReduce = 0

            guard let textStorage = textStorage
            else { return }
            var selectedRange = selectedRange
            /// The last location of the document is ignored so reduce with 1 if we are at the last location
            selectedRange.location -= selectedRange.location == string.count ? 1 : 0
            guard
                let textLayoutManager = textLayoutManager,
                let textContentManager = textLayoutManager.textContentManager,
                let range = NSTextRange(range: selectedRange, in: textContentManager),
                let fragment = textLayoutManager.textLayoutFragment(for: range.location),
                let nsRange = NSRange(textRange: fragment.rangeInElement, in: textContentManager),
                let lastRange = NSTextRange(range: NSRange(location: string.count - 1, length: 0), in: textContentManager),
                let lastParagraph = textLayoutManager.textLayoutFragment(for: lastRange.location)
            else {
                currentFragment = nil
                currentDirective = nil
                currentDirectiveArgument = ""
                currentDirectiveRange = nil
                return
            }

            if
                fragment == lastParagraph,
                let swiftRange = Range(NSRange(location: string.count - 1, length: 1), in: string),
                string[swiftRange] == "\n"
            {
                lastFragmentReduce = ChordProEditor.totalLineHeight(fontSize: font?.pointSize)
            }
            /// Find the optional directive of the fragment
            var directive: ChordProDirective?
            textStorage.enumerateAttribute(.directive, in: nsRange) {values, _, _ in
                if let value = values as? String, directives.map(\.directive).contains(value) {
                    directive = directives.first(where: {$0.directive == value})
                }
            }
            /// Find the optional directive argument of the fragment
            var directiveArgument: String?
            textStorage.enumerateAttribute(.directiveArgument, in: nsRange) {values, _, _ in
                if let value = values as? String {
                    directiveArgument = value
                }
            }
            /// Get the range of the directive for optional editing
            var directiveRange: NSRange?

            if currentDirective != nil {
                textStorage.enumerateAttribute(.directiveRange, in: nsRange) {values, _, _ in
                    if let value = values as? NSRange {
                        directiveRange = value
                    }
                }
            }

            currentDirective = directive
            currentDirectiveArgument = directiveArgument?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            currentDirectiveRange = directiveRange

            currentFragment = fragment

            parent?.runIntrospect(self)

            setNeedsDisplay(bounds)
        }
    }
}
