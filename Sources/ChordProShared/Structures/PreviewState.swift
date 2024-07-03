//
//  PreviewState.swift
//
//
//  Created by Nick Berendsen on 02/07/2024.
//

import Foundation

public struct PreviewState: Equatable {
    public init(data: Data? = nil, outdated: Bool = false) {
        self.data = data
        self.outdated = outdated
    }
    /// The optional data for a PDF preview
    public var data: Data?
    /// Bool if the PDF preview is outdated
    public var outdated: Bool = false
}
