//
//  QLPreviewRepresentedView.swift
//  ChordProShared
//
//  Created by Nick Berendsen on 04/07/2024.
//

import SwiftUI
import Quartz

extension AppKitUtils {
    
    /// Show a QL preview of the current document
    /// - Note: I don't use the SwiftUI ` .quickLookPreview($url)` here because that seems to conflict with a `NSTextView` in a `NSViewRepresentable.
    ///         Unsaved documents cannot be previewed on macOS 14 for some unknown reason...
    public struct QLPreviewRepresentedView: NSViewRepresentable {
        
        public init(url: URL) {
            self.url = url
        }
        
        var url: URL
        
        public func makeNSView(context: NSViewRepresentableContext<QLPreviewRepresentedView>) -> QLPreviewView {
            print("MAKE QL")
            let preview = QLPreviewView(frame: .zero, style: .normal)
            preview?.autostarts = true
            preview?.previewItem = url as QLPreviewItem
            
            return preview ?? QLPreviewView()
        }
        
        public func updateNSView(_ nsView: QLPreviewView, context: NSViewRepresentableContext<QLPreviewRepresentedView>) {
            nsView.previewItem = url as QLPreviewItem
        }
    }
}
