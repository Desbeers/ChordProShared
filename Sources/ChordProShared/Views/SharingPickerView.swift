//
//  SharingPickerView.swift
//
//
//  Created by Nick Berendsen on 01/07/2024.
//

import SwiftUI

public struct SharingPickerView: NSViewRepresentable {

    public init(isPresented: Binding<Bool>, url: URL) {
        self._isPresented = isPresented
        self.url = url
    }

    @Binding var isPresented: Bool
    let url: URL

    public func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        if isPresented {
            let picker = NSSharingServicePicker(items: [url])
            picker.delegate = context.coordinator
            Task {
                picker.show(relativeTo: .zero, of: nsView, preferredEdge: .minY)
                isPresented = false

            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, NSSharingServicePickerDelegate {

        let parent: SharingPickerView

        init(_ parent: SharingPickerView) {
            self.parent = parent
        }

        public func sharingServicePicker(
            _ sharingServicePicker: NSSharingServicePicker,
            sharingServicesForItems items: [Any],
            proposedSharingServices proposedServices: [NSSharingService]
        ) -> [NSSharingService] {
            /// Add a **print** service to the share-menu
            let image = NSImage(systemName: "printer")
            var share = proposedServices
            let printService = NSSharingService(title: "Print PDF", image: image, alternateImage: image) {
                Utils.printDialog(exportURL: self.parent.url)
            }
            share.insert(printService, at: 0)
            return share
        }

        public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
           sharingServicePicker.delegate = nil   // << cleanup
        }

        func setClipboard(text: String) {
                let clipboard = NSPasteboard.general
                clipboard.clearContents()
                clipboard.setString(text, forType: .string)
            }
    }
}
