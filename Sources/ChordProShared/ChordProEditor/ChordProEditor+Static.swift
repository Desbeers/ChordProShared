//
//  ChordProEditor+Static.swift
//  ChordProShared
//
//  Created by Nick Berendsen on 27/06/2024.
//

import SwiftUI

extension ChordProEditor {

    // MARK: Static settings for the editor

    /// The line height multiplier for the editor text
    static let lineHeightMultiple: Double = 1.2

    /// The style of a paragraph in the editor
    static let paragraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = ChordProEditor.lineHeightMultiple
        //style.lineSpacing = 10
        //style.maximumLineHeight = 12
        return style
    }()

    /// The style of a number in the ruler
    static var rulerNumberStyle: SWIFTStringAttribute {
        let lineNumberStyle = NSMutableParagraphStyle()
        lineNumberStyle.alignment = .right
        lineNumberStyle.lineHeightMultiple = lineHeightMultiple
        var fontAttributes: SWIFTStringAttribute = [:]
        fontAttributes[NSAttributedString.Key.paragraphStyle] = lineNumberStyle
        fontAttributes[NSAttributedString.Key.backgroundColor] = NSColor.clear
        fontAttributes[NSAttributedString.Key.foregroundColor] = highlightedForegroundColor

        return fontAttributes
    }

    /// The style of a symbol in the ruler
    static var rulerSymbolStyle: SWIFTStringAttribute {
        let lineNumberStyle = NSMutableParagraphStyle()
        lineNumberStyle.alignment = .right
        lineNumberStyle.lineHeightMultiple = lineHeightMultiple
        var fontAttributes: SWIFTStringAttribute = [:]
        fontAttributes[NSAttributedString.Key.paragraphStyle] = lineNumberStyle
        fontAttributes[NSAttributedString.Key.backgroundColor] = NSColor.clear
        fontAttributes[NSAttributedString.Key.foregroundColor] = highlightedForegroundColor

        return fontAttributes
    }

    /// The foreground of the highlighted line in the editor
    static let highlightedForegroundColor: NSColor = .gray.withAlphaComponent(0.9)

    /// The background of the highlighted line in the editor
    static let highlightedBackgroundColor: NSColor = .gray.withAlphaComponent(0.1)
}
