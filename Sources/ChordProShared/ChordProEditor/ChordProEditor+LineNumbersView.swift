//
//  ChordProEditor+LineNumbersView.swift
//  ChordProShared
//
//  Created by Nick Berendsen on 27/06/2024.
//

import AppKit

extension ChordProEditor {

    // MARK: The line numbers view for the editor

    /// The line numbers view for the editor
    public class LineNumbersView: NSRulerView {

        // MARK: Init

        /// Init the `NSRulerView`
        /// - Parameters:
        ///   - scrollView: The current `NSScrollView`
        ///   - orientation: The orientation of the `NSRulerView`
        required override public init(scrollView: NSScrollView?, orientation: NSRulerView.Orientation) {
            super.init(scrollView: scrollView, orientation: orientation)
        }

        /// Init the `NSRulerView`
        /// - Parameter coder: The `NSCoder`
        required public init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: Override functions

        /// Draw a background a a stroke on the right of the `NSRulerView`
        /// - Parameter dirtyRect: The current rect of the editor
        override public func draw(_ dirtyRect: NSRect) {
            guard
                let context: CGContext = NSGraphicsContext.current?.cgContext
            else {
                return
            }
            /// Fill the background
            context.setFillColor(ChordProEditor.highlightedBackgroundColor.cgColor)
            context.fill(bounds)
            /// Draw a border on the right
            context.setStrokeColor(NSColor.secondaryLabelColor.cgColor)
            context.setLineWidth(0.5)
            context.move(to: CGPoint(x: bounds.width - 1, y: 0))
            context.addLine(to: CGPoint(x: bounds.width - 1, y: bounds.height))
            context.strokePath()
            /// - Note: Below usually gets called on super.draw(dirtyRect), but we're not calling it because that will override the background color
            drawHashMarksAndLabels(in: bounds)
        }

        override public func drawHashMarksAndLabels(in rect: NSRect) {
            guard
                let textView: TextView = self.clientView as? TextView,
                let textContainer: NSTextContainer = textView.textContainer,
                let textStorage: NSTextStorage = textView.textStorage,
                let layoutManager: LayoutManager = textView.layoutManager as? LayoutManager,
                let context: CGContext = NSGraphicsContext.current?.cgContext
            else {
                return
            }

            /// Get the range of glyphs in the visible area of the text view
            let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textContainer)

            /// Get the current font
            let font: NSFont = layoutManager.font

            ruleThickness = font.pointSize * 4

            /// Set the initial positions
            var positions = Positions()
            /// Get the scalar values of the text view content
            let scalars = textStorage.string.unicodeScalars

            // MARK: NEW


            let fontLineHeight = layoutManager.defaultLineHeight(for: font)
            let lineHeight = fontLineHeight * ChordProEditor.lineHeightMultiple
            let baselineNudge = (lineHeight - fontLineHeight) * 0.5

            //let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textView.textContainer!)
            let firstVisibleGlyphCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)
            let newLineRegex = try! NSRegularExpression(pattern: "\n", options: [])
            /// The line number for the first visible line
//            positions.lineNumber = newLineRegex.numberOfMatches(in: textView.string, options: [], range: NSMakeRange(0, firstVisibleGlyphCharacterIndex)) + 1
            positions.lineNumber += newLineRegex.numberOfMatches(in: textView.string, options: [], range: NSRange(location: 0, length: firstVisibleGlyphCharacterIndex))

            //dump(lineNumber)

            // MARK: END NEW




            let selectedLinePosition: CGFloat = textView.currentRect?.origin.y ?? -1

            /// Set the context based on the Y-offset of the text view
            context.translateBy(x: 0, y: convert(NSPoint.zero, from: textView).y)
            /// Get the range of each line as we step through the visible Range, starting at the start of the visible range
            positions.lineStart = visibleGlyphRange.location
            /// Start drawing the line numbers
            for index in visibleGlyphRange.location..<NSMaxRange(visibleGlyphRange) {
                positions.lineLength += 1
                if scalars[index].isNewline || index == (textView.string.count - 1) {
                    /// Get the range of the current paragraph
                    let nsRange = NSRange(location: positions.lineStart, length: positions.lineLength - 1)
                    /// Get the rect of the current paragraph
                    let lineRect = layoutManager.boundingRect(
                        forGlyphRange: nsRange,
                        in: textContainer
                    )

                    var directive: ChordProDirective?
                    textStorage.enumerateAttribute(.directive, in: nsRange) {values, _, _ in
                        if let value = values as? String, textView.directives.map(\.directive).contains(value) {
                            directive = textView.directives.first(where: {$0.directive == value})
                        }
                    }

                    let markerRect = NSRect(
                        x: 0,
                        y: lineRect.origin.y,
                        width: rect.width,
                        height: lineRect.height
                    )
                    /// Draw the line number
                    drawLineNumber(
                        positions.lineNumber,
                        inRect: markerRect,
                        highlight: markerRect.origin.y == selectedLinePosition
                    )
                    /// Draw a symbol if we have a known directive
                    if let directive {
                        var iconRect = markerRect
                        let imageAttachment = NSTextAttachment()
                        let imageConfiguration = NSImage.SymbolConfiguration(pointSize: font.pointSize * 0.7, weight: .medium)
                        imageAttachment.image = NSImage(systemName: directive.icon).withSymbolConfiguration(imageConfiguration)
                        let imageString = NSMutableAttributedString(attachment: imageAttachment)
                        imageString.addAttributes([.foregroundColor: NSColor.secondaryLabelColor], range: NSRange(location: 0, length: imageString.length))
                        let imageSize = imageString.size()
                        let offset = (markerRect.height - imageSize.height) * 0.5
                        iconRect.origin.x += iconRect.width - (imageSize.width * 1.4)
                        iconRect.origin.y += (offset)
                        imageString.draw(in: iconRect)
                    }

                    /// Update the positions
                    positions.lineStart += positions.lineLength
                    positions.lineLength = 0
                    positions.lineNumber += 1
                    positions.lastLinePosition = markerRect.origin.y + lineRect.height
                }
            }
            /// Draw the last line number
            if layoutManager.extraLineFragmentTextContainer != nil {
                drawLineNumber(
                    positions.lineNumber,
                    inRect: NSRect(
                        x: 0,
                        y: positions.lastLinePosition,
                        width: rect.width,
                        height: lineHeight
                    ),
                    highlight: positions.lastLinePosition == selectedLinePosition
                )
            }
            func drawLineNumber(_ number: Int, inRect rect: NSRect, highlight: Bool = false) {
                var attributes = ChordProEditor.rulerNumberStyle
                attributes[NSAttributedString.Key.font] = font
                switch highlight {
                case true:
                    context.setFillColor(ChordProEditor.highlightedBackgroundColor.cgColor)
                    context.fill(rect)

                    attributes[NSAttributedString.Key.foregroundColor] = NSColor.textColor
                    //attributes[NSAttributedString.Key.font] = NSFont.systemFont(ofSize: font.pointSize * 0.8, weight: .regular)
                case false:
                    attributes[NSAttributedString.Key.foregroundColor] = NSColor.systemGray
                    //attributes[NSAttributedString.Key.font] = NSFont.systemFont(ofSize: font.pointSize * 0.8, weight: .light)
                }
                var stringRect = rect
                /// Move the string a bit up
                stringRect.origin.y -= baselineNudge
                /// And a bit to the left
                stringRect.size.width -= font.pointSize * 1.75
                NSString(string: "\(number)").draw(in: stringRect, withAttributes: attributes)

            }
        }
    }
}

extension ChordProEditor.LineNumbersView {

    struct Positions {

        var lineNumber: Int = 1

        var lineStart: Int = 0

        var lineLength: Int = 0
        /// Y position of the last line
        var lastLinePosition: CGFloat = 0
    }
}
