//
//  MacEditorView.swift
//  Chord Provider
//
//  © 2024 Nick Berendsen
//

import SwiftUI

/// SwiftUI `NSViewRepresentable` for the ChordPro editor
public struct ChordProEditor: NSViewRepresentable {

    @Binding var text: String

    let settings: Settings

    let directives: [ChordProDirective]

    private(set) var introspect: IntrospectCallback?

    public init(text: Binding<String>, settings: Settings, directives: [ChordProDirective]) {
        self._text = text
        self.settings = settings
        self.directives = directives
    }

    /// Make a `coordinator` for the ``SWIFTViewRepresentable``
    /// - Returns: A `coordinator`
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeNSView(context: Context) -> Wrapper {
        let wrapper = Wrapper()
        wrapper.delegate = context.coordinator
        wrapper.textView.directives = directives
        wrapper.textView.parent = self
        wrapper.textView.string = text
        /// Wait for next cycle and set the textview as first responder
        Task { @MainActor in
            highlightText(textView: wrapper.textView)
            wrapper.textView.selectedRanges = [NSValue(range: NSRange())]
            wrapper.textView.window?.makeFirstResponder(wrapper.textView)
        }
        return wrapper
    }

    public func updateNSView(_ view: Wrapper, context: Context) {
        if context.coordinator.parent.settings != settings {
            context.coordinator.parent = self
            highlightText(textView: view.textView)
            view.textView.chordProEditorDelegate?.selectionNeedsDisplay()
        }
    }

    @MainActor func highlightText(textView: NSTextView, range: NSRange? = nil) {
        ChordProEditor.highlight(
            view: textView,
            settings: settings,
            font: settings.font,
            range: range ?? NSRange(location: 0, length: text.utf16.count),
            directives: directives
        )
    }
}

extension ChordProEditor {

    @MainActor func runIntrospect(_ view: TextView) {
        guard let introspect = introspect else { return }
        let internals = Internals(
            directive: view.currentDirective,
            directiveArgument: view.currentDirectiveArgument,
            directiveRange: view.currentDirectiveRange,
            clickedFragment: view.clickedFragment,
            selectedRange: view.selectedRange(),
            textView: view
        )
        introspect(internals)
    }


    public func introspect(callback: @escaping IntrospectCallback) -> Self {
        var editor = self
        editor.introspect = callback
        return editor
    }
}

public typealias IntrospectCallback = (_ editor: ChordProEditor.Internals) -> Void
