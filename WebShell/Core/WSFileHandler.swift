//
//  WebShellFileHandler.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2018 WebShell. All rights reserved.
//

import Foundation
import WebKit

// @wdg: Enable file uploads.
// Issue: #29
// This extension will handle up & downloads
extension WSViewController {
    @objc(webView:runOpenPanelForFileButtonWithResultListener:allowMultipleFiles:) func webView(_ sender: WebView!, runOpenPanelForFileButtonWith resultListener: WebOpenPanelResultListener!, allowMultipleFiles: Bool) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = allowMultipleFiles
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.begin { (result) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                let uploadQeue: NSMutableArray = NSMutableArray()
                for i in 0 ..< panel.urls.count {
                    uploadQeue.add(panel.urls[i].relativePath)
                }
                
                if panel.urls.count == 1 {
                    resultListener.chooseFilename(String(describing: uploadQeue[0]))
                } else {
                    resultListener.chooseFilenames(uploadQeue as [AnyObject])
                }
            }
        }
    }
    
    /**
     Download window.
     
     - Parameter download: WebDownload!
     */
    func downloadWindow(forAuthenticationSheet download: WebDownload!) -> NSWindow! {
        print("I'd like to download something")
        print(download)
        
        return NSWindow()
    }
    
    // Usefull for debugging..
    @nonobjc func webView(_ sender: WebView!, mouseDidMoveOverElement elementInformation: [NSObject: Any]!, modifierFlags: Int) {
        // print("Sender=\(sender)\nEleInfo=\(elementInformation)\nModifier=\(modifierFlags)")
    }
}
