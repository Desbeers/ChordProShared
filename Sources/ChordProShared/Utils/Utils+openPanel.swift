//
//  File.swift
//  
//
//  Created by Nick Berendsen on 28/06/2024.
//

import AppKit
import UniformTypeIdentifiers
import OSLog

extension Utils {

    @MainActor public static func openPanel<T: UserFile>(userFile: T, action: @escaping () -> Void) throws {
        /// Make sure we have a window to attach the sheet
        guard let window = NSApp.keyWindow else {
            throw AppError.noKeyWindow
        }
        let selection = try UserFileBookmark.getBookmarkURL(userFile)
        let panel = NSOpenPanel()
        panel.showsResizeIndicator = true
        panel.showsHiddenFiles = false
        panel.canChooseDirectories = userFile.utTypes.contains(UTType.folder) ? true : false
        panel.allowedContentTypes = userFile.utTypes
        panel.directoryURL = selection
        panel.message = userFile.message
        panel.prompt = "Select"
        panel.canCreateDirectories = false
        /// Open the panel in a sheet
        panel.beginSheetModal(for: window) { result in
            guard  result == .OK, let url = panel.url else {
                return
            }
            UserFileBookmark.setBookmarkURL(userFile, url)
            Logger.application.info("Bookmark set for '\(url.lastPathComponent, privacy: .public)'")
            action()
        }
    }
}
