//
//  MacEditorView+Settings.swift
//  Chord Provider
//
//  © 2024 Nick Berendsen
//

import SwiftUI

extension ChordProEditor {

    // MARK: Settings for the editor

    /// Settings for the editor
    public struct Settings: Equatable, Codable, Sendable {

        public init() {}

        // MARK: Fonts

        /// The range of available font sizes
        public static let fontSizeRange: ClosedRange<Double> = 10...24

        /// The size of the font
        public var fontSize: Double = 14

        /// The font style of the editor
        public var fontStyle: FontStyle = .monospaced

        public var font: NSFont {
            return fontStyle.nsFont(size: fontSize)
        }

        // MARK: Colors (codable with an extension)

        /// The color for brackets
        public var bracketColor: Color = .gray
        /// The color for a chord
        public var chordColor: Color = .red
        /// The color for a directive
        public var directiveColor: Color = .indigo
        /// The color for a directive argument
        public var argumentColor: Color = .orange
        /// The color for pango stuff
        public var pangoColor: Color = .teal
        /// The color for comments
        public var commentColor: Color = .gray
    }
}

extension ChordProEditor.Settings {
    public enum FontStyle: String, CaseIterable, Codable {
        /// Use a monospaced font
        case monospaced = "Monospaced"
        /// Use a serif font
        case serif = "Serif"
        /// Use a sans-serif font
        case sansSerif = "Sans Serif"
        /// The calculated font for the `EditorView`
        public func nsFont(size: Double) -> NSFont {
            var descriptor = NSFontDescriptor()
            switch self {
            case .monospaced:
                descriptor = NSFont.systemFont(ofSize: size).fontDescriptor.addingAttributes().withDesign(.monospaced)!
            case .serif:
                descriptor = NSFont.systemFont(ofSize: size).fontDescriptor.addingAttributes().withDesign(.serif)!
            case .sansSerif:
                descriptor = NSFont.systemFont(ofSize: size).fontDescriptor.addingAttributes().withDesign(.default)!
            }
            return NSFont(descriptor: descriptor, size: size)!
        }
        /// The calculated font for the `SettingsView`
        public func font(size: Double) -> Font {
            switch self {
            case .monospaced:
                return .system(size: size, weight: .regular, design: .monospaced)
            case .serif:
                return .system(size: size, weight: .regular, design: .serif)
            case .sansSerif:
                return .system(size: size, weight: .regular, design: .default)
            }
        }
    }
}
