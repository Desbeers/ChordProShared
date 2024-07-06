//
//  ChordProEditor+Wrapper.swift
//  ChordProShared
//
//  Created by Nick Berendsen on 27/06/2024.
//

import AppKit

extension ChordProEditor {

    // MARK: The wrapper for the editor

    /// A wrapper for
    /// - `NSScrollView`
    /// - `NSTextView`
    /// - `NSRulerView`
    public class Wrapper: NSView, ChordProEditorDelegate {

        /// Init the `NSView`
        /// - Parameter frameRect: The rect of the `NSView`
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            self.wantsLayer = true;
            self.layer?.masksToBounds = true
        }

        /// Init the `NSView`
        /// - Parameter coder: The `NSCoder`
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        weak var delegate: NSTextViewDelegate?

        private lazy var scrollView: NSScrollView = {
            let scrollView = NSScrollView()
            scrollView.drawsBackground = true
            scrollView.borderType = .noBorder
            scrollView.hasVerticalScroller = true
            scrollView.hasHorizontalScroller = false
            scrollView.hasHorizontalRuler = false
            scrollView.hasVerticalRuler = true
            scrollView.rulersVisible = true
            scrollView.autoresizingMask = [.width, .height]
            scrollView.translatesAutoresizingMaskIntoConstraints = false

            return scrollView
        }()

        lazy var textView: TextView = {
            let contentSize = scrollView.contentSize
            let textStorage = NSTextStorage()
            let layoutManager = LayoutManager()

            //layoutManager.allowsNonContiguousLayout = true

            textStorage.addLayoutManager(layoutManager)

            let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
            textContainer.widthTracksTextView = true
            textContainer.containerSize = NSSize(
                width: contentSize.width,
                height: CGFloat.greatestFiniteMagnitude
            )

            layoutManager.addTextContainer(textContainer)

            let textView = TextView(frame: .zero, textContainer: textContainer)
            textView.autoresizingMask = .width
            textView.backgroundColor = NSColor.textBackgroundColor
            textView.delegate = self.delegate
            textView.font = .systemFont(ofSize: 8)
            textView.isEditable = true
            textView.isHorizontallyResizable = false
            textView.isVerticallyResizable = true
            textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            textView.minSize = NSSize(width: 0, height: contentSize.height)
            textView.textColor = NSColor.labelColor
            textView.allowsUndo = true
            textView.isAutomaticQuoteSubstitutionEnabled = false
            textView.layoutManager?.delegate = layoutManager
            textView.chordProEditorDelegate = self
            textView.textContainerInset = .init(width: 2, height: 0)
            textView.drawsBackground = false

            return textView
        }()

        /// The `NSRulerView`
        //lazy private var lineNumbers = NSRulerView()
        lazy var lineNumbers: LineNumbersView = {
            let lineNumbersView = LineNumbersView()
            return lineNumbersView
        }()

        public override func viewWillDraw() {
            super.viewWillDraw()

            setupScrollViewConstraints()
            setupTextView()
        }

        func setupScrollViewConstraints() {
            lineNumbers.scrollView = scrollView
            lineNumbers.orientation = .verticalRuler
            lineNumbers.clientView = textView
            lineNumbers.ruleThickness = 40
//
//            scrollView.hasVerticalRuler = true
//            scrollView.rulersVisible = true

            scrollView.translatesAutoresizingMaskIntoConstraints = false

            scrollView.verticalRulerView = lineNumbers

            addSubview(scrollView)

            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: topAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
            ])
        }

        func setupTextView() {
            scrollView.documentView = textView
        }

//        // MARK: Layout Manager Delegate
//
//        // swiftlint:disable:next function_parameter_count
//        public func layoutManager(
//            _ layoutManager: NSLayoutManager,
//            shouldSetLineFragmentRect lineFragmentRect: UnsafeMutablePointer<NSRect>,
//            lineFragmentUsedRect: UnsafeMutablePointer<NSRect>,
//            baselineOffset: UnsafeMutablePointer<CGFloat>,
//            in textContainer: NSTextContainer,
//            forGlyphRange glyphRange: NSRange
//        ) -> Bool {
//            print("Layout Manager Delegate")
//            let font: NSFont = textView.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
//
//            let fontLineHeight = layoutManager.defaultLineHeight(for: font)
//            let lineHeight = fontLineHeight * ChordProEditor.lineHeightMultiple
//            let baselineNudge = (lineHeight - fontLineHeight) * 0.5
//
//            var rect = lineFragmentRect.pointee
//            rect.size.height = lineHeight
//
//            var usedRect = lineFragmentUsedRect.pointee
//            usedRect.size.height = max(lineHeight, usedRect.size.height) // keep emoji sizes
//
//            lineFragmentRect.pointee = rect
//            lineFragmentUsedRect.pointee = usedRect
//            baselineOffset.pointee += baselineNudge
//
//            return true
//        }

        // MARK: MacEditorDelegate

        /// A delegate function to update a view
        func selectionNeedsDisplay() {
            lineNumbers.needsDisplay = true
        }
    }
}
