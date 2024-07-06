//
//  ChordProEditor+LayoutManager.swift
//  Chord Provider
//
//  © 2023 Nick Berendsen
//

import AppKit

extension ChordProEditor {

    /// The layout manager for the editor
    class LayoutManager: NSLayoutManager, NSLayoutManagerDelegate {

        var font: NSFont {
            return self.firstTextView?.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
        }

        var lineHeight: CGFloat {
            let fontLineHeight = self.defaultLineHeight(for: font)
            let lineHeight = fontLineHeight * ChordProEditor.lineHeightMultiple
            return lineHeight
        }

//        override func setLineFragmentRect(_ fragmentRect: NSRect, forGlyphRange glyphRange: NSRange, usedRect: NSRect) {
//            print("setLineFragmentRect")
//            /// This is only called when editing, and re-computing the
//            /// `lineHeight` isn't that expensive, so no caching.
//            let lineHeight = self.lineHeight
//            var fragmentRect = fragmentRect
//            fragmentRect.size.height = lineHeight
//            var usedRect = usedRect
//            usedRect.size.height = lineHeight
//            /// Call the super function
//            super.setLineFragmentRect(fragmentRect, forGlyphRange: glyphRange, usedRect: usedRect)
//        }

        /// Takes care only of the last empty newline in the text backing store, or totally empty text views.
        override func setExtraLineFragmentRect(
            _ fragmentRect: NSRect,
            usedRect: NSRect,
            textContainer container: NSTextContainer
        ) {
            //print("setExtraLineFragmentRect")
            /// This is only called when editing, and re-computing the
            /// `lineHeight` isn't that expensive, so no caching.
            let lineHeight = self.lineHeight
            var fragmentRect = fragmentRect
            fragmentRect.size.height = lineHeight
            var usedRect = usedRect
            usedRect.size.height = lineHeight
            /// Call the super function
            super.setExtraLineFragmentRect(
                fragmentRect,
                usedRect: usedRect,
                textContainer: container
            )
        }

        // swiftlint:disable:next function_parameter_count
        public func layoutManager(
            _ layoutManager: NSLayoutManager,
            shouldSetLineFragmentRect lineFragmentRect: UnsafeMutablePointer<NSRect>,
            lineFragmentUsedRect: UnsafeMutablePointer<NSRect>,
            baselineOffset: UnsafeMutablePointer<CGFloat>,
            in textContainer: NSTextContainer,
            forGlyphRange glyphRange: NSRange
        ) -> Bool {
            //print("Layout Manager Delegate")
            //let font: NSFont = textView.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)

            let fontLineHeight = layoutManager.defaultLineHeight(for: font)
            let lineHeight = fontLineHeight * ChordProEditor.lineHeightMultiple
            let baselineNudge = (lineHeight - fontLineHeight) * 0.5

            var rect = lineFragmentRect.pointee
            rect.size.height = lineHeight

            var usedRect = lineFragmentUsedRect.pointee
            usedRect.size.height = max(lineHeight, usedRect.size.height) // keep emoji sizes

            lineFragmentRect.pointee = rect
            lineFragmentUsedRect.pointee = usedRect
            baselineOffset.pointee += baselineNudge

            return true
        }
    }
}
