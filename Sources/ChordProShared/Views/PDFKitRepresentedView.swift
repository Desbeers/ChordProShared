//
//  PDFKitRepresentedView.swift
//  ChordProShared
//
//  Created by Nick Berendsen on 26/07/2023.
//

import SwiftUI
import PDFKit
import Quartz

/// SwiftUI `NSViewRepresentable` for a PDF View
public struct PDFKitRepresentedView: NSViewRepresentable {
    /// The data of the PDF
    let data: Data
    /// Init the `View`
    /// - Parameter data: The data of the PDF
    public init(data: Data) {
        print("INIT PDF")
        self.data = data
    }
    /// Make the `View`
    /// - Parameter context: The context
    /// - Returns: The PDFView
    public func makeNSView(context: NSViewRepresentableContext<PDFKitRepresentedView>) -> PDFView {
        /// Create a `PDFView` and set its `PDFDocument`.
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        return pdfView
    }
    /// Update the `View`
    /// - Parameters:
    ///   - pdfView: The PDFView
    ///   - context: The context
    public func updateNSView(_ pdfView: PDFView, context: NSViewRepresentableContext<PDFKitRepresentedView>) {
        print("updateNSView PDF")
        
        let newData = PDFDocument(data: data)

        if newData?.string != pdfView.document?.string {
            print("TEXT CHANGED")
        }
        
        /// Animate the transition
        pdfView.animator().isHidden = true
        /// Make sure we have a document with a page
        guard
            let currentDestination = pdfView.currentDestination,
            let page = currentDestination.page,
            let document = pdfView.document
        else {
            return
        }
        /// Save the view parameters
        let position = PDFParameters(
            pageIndex: document.index(for: page),
            zoom: currentDestination.zoom,
            location: currentDestination.point
        )
        /// Update the document
        pdfView.document = PDFDocument(data: data)
        /// Restore the view parameters
        if let restoredPage = document.page(at: position.pageIndex) {
            let restoredDestination = PDFDestination(page: restoredPage, at: position.location)
            restoredDestination.zoom = position.zoom
            pdfView.go(to: restoredDestination)
        }
        pdfView.animator().isHidden = false
    }
}

extension PDFKitRepresentedView {
    /// The view parameters of a PDF
    struct PDFParameters {
        /// The page index
        let pageIndex: Int
        /// The zoom factor
        let zoom: CGFloat
        /// The location on the page
        let location: NSPoint
    }
}

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
        
        print("update QLPreviewView")
        
        nsView.previewItem = url as QLPreviewItem
    }
}
