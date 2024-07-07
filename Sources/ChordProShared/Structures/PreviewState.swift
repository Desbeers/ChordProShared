//
//  PreviewState.swift
//
//
//  Created by Nick Berendsen on 02/07/2024.
//

import Foundation

public struct PreviewState: Equatable {
    public init(id: String = UUID().uuidString, url: URL? = nil, data: Data? = nil, outdated: Bool = false) {
        self.id = id
        self.url = url
        self.data = data
        self.outdated = outdated
    }
    public var id: String
    /// The optional URL for a PDF preview
    public var url: URL?
    /// The optional data for a PDF preview
    public var data: Data?
    /// Bool if the PDF preview is outdated
    public var outdated: Bool = false
    /// Bool if the preview is active
    public var active: Bool {
        return (url != nil || data != nil)
    }
}
