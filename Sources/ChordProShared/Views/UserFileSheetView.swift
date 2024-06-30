//
//  UserFileSheetView.swift
//  ChordProShared
//
//  Created by Nick Berendsen on 26/06/2024.
//

import SwiftUI
import OSLog

/// SwiftUI `Modifier` to add a `FileImporter` sheet
struct UserFileSheetView<T: UserFile>: ViewModifier {
    /// Bool to show the sheet
    @Binding var isPresented: Bool
    /// The ``CustomFile`` to select
    let bookmark: T
    /// The action when a file is selected
    let action: () -> Void
    /// The body of the `ViewModifier`
    func body(content: Content) -> some View {
        content
            .fileImporter(
                isPresented: $isPresented,
                allowedContentTypes: bookmark.utTypes
            ) { result in
                switch result {
                case .success(let url):
                    UserFileBookmark.setBookmarkURL(bookmark, url)
                    action()
                case .failure(let error):
                    Logger.fileAccess.error("\(error.localizedDescription, privacy: .public)")
                }
            }
    }
}
//}

extension View {

    /// SwiftUI `Modifier` to add a `FileImporter` sheet
    /// - Parameters:
    ///   - isPresented: Bool to show the sheet
    ///   - bookmark: The ``CustomFile`` to select
    ///   - action: The action when a file is selected
    /// - Returns: A modified `View`
    public func selectFileSheet<T: UserFile>(
        isPresented: Binding<Bool>,
        bookmark: T,
        action: @escaping () -> Void
    ) -> some View {
        modifier(
            UserFileSheetView(
                isPresented: isPresented,
                bookmark: bookmark,
                action: action
            )
        )
    }
}
