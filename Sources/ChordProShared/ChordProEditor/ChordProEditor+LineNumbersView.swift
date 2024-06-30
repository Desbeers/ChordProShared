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

        /// Draw marks and labels in the current `NSRulerView`
        /// - Parameter rect: The rect of the current `NSRulerView`
        override public func drawHashMarksAndLabels(in rect: NSRect) {
            guard
                let textView: TextView = self.clientView as? TextView,
                let textLayoutManager = textView.textLayoutManager,
                let textContentManager = textLayoutManager.textContentManager,
                let context: CGContext = NSGraphicsContext.current?.cgContext
            else {
                return
            }

            let font = NSFont.monospacedSystemFont(ofSize: textView.font?.pointSize ?? NSFont.systemFontSize, weight: .ultraLight)

            let lineHeight = ChordProEditor.totalLineHeight(fontSize: font.pointSize)

            ruleThickness = font.pointSize * 3
            let relativePoint = self.convert(NSPoint.zero, from: textView)

            let selectedTextLayoutFragment = textView.currentFragment

            var paragraphs: [NSTextLayoutFragment] = []
            textLayoutManager.enumerateTextLayoutFragments(
                from: textContentManager.documentRange.location,
                options: [.ensuresLayout, .ensuresExtraLineFragment]
            ) { paragraph in
                paragraphs.append(paragraph)
                return true
            }

            var attributes = ChordProEditor.rulerNumberStyle
            attributes[NSAttributedString.Key.font] = font
            attributes[NSAttributedString.Key.baselineOffset] = ChordProEditor.baselineOffset(fontSize: font.pointSize)
            var number = 1
            var lineRect = CGRect()
            for paragraph in paragraphs {
                lineRect = paragraph.layoutFragmentFrame
                lineRect.size.width = rect.width
                lineRect.origin.x = 0
                lineRect.origin.y += relativePoint.y

                if paragraph == paragraphs.last {
                    lineRect.size.height -= textView.lastFragmentReduce
                }

                guard
                    let content = textView.textLayoutManager?.textContentManager,
                    let nsRange = NSRange(textRange: paragraph.rangeInElement, in: content)
                else {
                    print("error")
                    return
                }
                var directive: ChordProDirective?

                textView.textStorage?.enumerateAttribute(.directive, in: nsRange) {value, _, _ in
                    if let value = value as? String, let match = textView.directives.first(where: { $0.directive == value }) {
                        directive = match
                    }
                }

                if paragraph.layoutFragmentFrame == selectedTextLayoutFragment?.layoutFragmentFrame {
                    context.setFillColor(ChordProEditor.highlightedForegroundColor.cgColor)
                    context.fill(lineRect)
                    attributes[NSAttributedString.Key.foregroundColor] = NSColor.textColor
                } else {
                    attributes[NSAttributedString.Key.foregroundColor] = NSColor.secondaryLabelColor
                }
                /// Draw a symbol if we have a known directive
                if let directive {
//                    let color = NSColor(textView.parent?.settings.directiveColor ?? .secondary)
                    //let color = NSColor(.accentColor)
                    var iconRect = lineRect
                    let imageAttachment = NSTextAttachment()
                    let imageConfiguration = NSImage.SymbolConfiguration(pointSize: font.pointSize * 0.7, weight: .medium)
                    imageAttachment.image = NSImage(systemName: directive.icon).withSymbolConfiguration(imageConfiguration)
                    let imageString = NSMutableAttributedString(attachment: imageAttachment)
                    imageString.addAttributes([.foregroundColor: NSColor.secondaryLabelColor], range: NSRange(location: 0, length: imageString.length))
                    let imageSize = imageString.size()
                    let offset = lineHeight - (imageSize.height * 0.9)
                    iconRect.origin.x += iconRect.width - (imageSize.width * 1.2)
                    iconRect.origin.y += offset / 2
                    imageString.draw(in: iconRect)
                }
                /// Draw the line number
                var numberRect = lineRect
                numberRect.size.width -= lineHeight
                NSString(string: "\(number)").draw(in: numberRect, withAttributes: attributes)
                /// Add one more line number for the next paragraph
                number += 1
            }
        }
    }
}
