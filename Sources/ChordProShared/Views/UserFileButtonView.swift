//
//  UserFileButtonView.swift
//  ChordProShared
//
//  Created by Nick Berendsen on 26/06/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import OSLog

/// SwiftUI `View`to select a file
/// - Note: A file can be a *normal* file but also a folder
public struct UserFileButtonView<T: UserFile>: View {

    public init(bookmark: T, action: @escaping () -> Void) {
        self.bookmark = bookmark
        self.action = action
    }
    /// The file to bookmark
    let bookmark: T
    /// The action when a file is selected
    let action: () -> Void
    /// Bool to show the file importer sheet
    @State private var isPresented: Bool = false
    /// The body of the `View`
    public var body: some View {
        Button(
            action: {
                isPresented.toggle()
            },
            label: {
                Label(bookmark.label ?? "Select", systemImage: bookmark.icon)
            }
        )
        .selectFileSheet(
            isPresented: $isPresented,
            bookmark: bookmark,
            action: action
        )
    }
}
