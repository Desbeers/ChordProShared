//
//  ChordProDirective.swift
//  ChordProShared
//
//  Created by Nick Berendsen on 26/06/2024.
//

import Foundation

public protocol ChordProDirective {
    var directive: String { get }
    var label: String { get }
    var icon: String { get }
    var editable: Bool { get }
    var help: String { get }
}
