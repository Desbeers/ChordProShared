//
//  PreviewView.swift
//  ChordProShared
//
//  Created by Nick Berendsen on 01/07/2024.
//

import SwiftUI
import Quartz

/// Show a PDF preview of the current document
/// - Note: I don't use the SwiftUI ` .quickLookPreview($url)` here because that seems to conflict with a `NSTextView` in a `NSViewRepresentableContext.
///         Unsaved documents cannot be previewed on macOS 14 for some unknown reason...
public struct PreviewView: NSViewRepresentable {

    public init(url: URL) {
        self.url = url
    }

    var url: URL
    public func makeNSView(context: NSViewRepresentableContext<PreviewView>) -> QLPreviewView {
        let preview = QLPreviewView(frame: .zero, style: .normal)
        preview?.autostarts = true
        preview?.previewItem = url as QLPreviewItem

        return preview ?? QLPreviewView()
    }

    public func updateNSView(_ nsView: QLPreviewView, context: NSViewRepresentableContext<PreviewView>) {
        nsView.previewItem = url as QLPreviewItem
    }
}
