//
//  File.swift
//  
//
//  Created by Nick Berendsen on 26/06/2024.
//

import Foundation

extension ChordProEditor {

    public struct Internals {

        public init(
            directive: ChordProDirective? = nil,
            directiveArgument: String? = nil,
            directiveRange: NSRange? = nil,
            clickedFragment: Bool = false,
            selectedRange: NSRange = NSRange(),
            textView: TextView? = nil
        ) {
            self.directive = directive
            self.directiveArgument = directiveArgument
            self.directiveRange = directiveRange
            self.clickedFragment = clickedFragment
            self.selectedRange = selectedRange
            self.textView = textView
        }

        public var directive: ChordProDirective?
        public var directiveArgument: String?
        public var directiveRange: NSRange?
        /// Click detection
        public var clickedFragment: Bool = false
        public var selectedRange = NSRange()
        public var textView: TextView?
    }
}
