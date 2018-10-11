//
//  WebShellPageActions.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2018 WebShell. All rights reserved.
//

import AppKit
import Foundation

extension WSViewController {
    /**
     Add Observers for menu items
     */
    func addObservers() {
        let observers = ["goHome", "reload", "copyUrl", "clearNotificationCount", "printThisPage"]
        
        for observer in observers {
            if responds(to: Selector(observer)) {
                NotificationCenter.default.addObserver(self, selector: Selector(observer), name: NSNotification.Name(rawValue: observer), object: nil)
            } else {
                let alert = NSAlert()
                alert.addButton(withTitle: "Ok")
                alert.alertStyle = .critical
                alert.messageText = "Critical error"
                alert.informativeText = "Selector \"\(observer)\" is not callable!\nPlease file a bug report!"
                alert.runModal()
                
                if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
                    if let appBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as? String {
                        let issue: String = String("[AUTOMATIC BUG REPORT] selector \"\(observer)\" unreachable").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!.replacingOccurrences(of: "&", with: "%26")
                        let body: String = (String("Product: Web-Shell/WebShell\r\n\r\nVersion: \(appVersion)\r\n\r\nBuild: \(appBuild) \r\n\r\n").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?.replacingOccurrences(of: "&", with: "%26"))!
                        let url: String = "https://github.com/Web-Shell/WebShell/issues/new?title=\(issue)&body=\(body)"
                        
                        NSWorkspace.shared.open(URL(string: (url as String))!)
                    }
                }
            }
        }
    }
    
    /**
     Go to the home url
     */
    @objc func goHome() {
        loadUrl(settings.url)
    }
    
    /**
     Reload the current webpage
     */
    @objc func reload() {
        mainWebview.mainFrame.reload()
    }
    
    /**
     Copy the URL
     */
    @objc func copyUrl() {
        let currentUrl: String = (mainWebview.mainFrame.dataSource?.request.url?.absoluteString)!
        let clipboard: NSPasteboard = NSPasteboard.general
        clipboard.clearContents()
        
        clipboard.setString(currentUrl, forType: .string)
    }
    
    /**
     Initialize settings
     */
    func initSettings() {
        if !settings.showLoadingBar {
            progressBar.isHidden = true
        }
        
        if settings.useragent.lowercased() == "default" {
            if let version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) {
                if var UA = Bundle.main.infoDictionary?["CFBundleName"] as? String {
                    UA = UA + "/"
                    UA = UA + version
                    UA = UA + " based on Safari/AppleWebKit (KHTML, like Gecko)"
                    
                    UserDefaults.standard.register(defaults: ["UserAgent": UA])
                    mainWebview.customUserAgent = UA
                }
            }
        } else {
            let UA = settings.useragent
            UserDefaults.standard.register(defaults: ["UserAgent": UA])
            mainWebview.customUserAgent = UA
        }
        
        launchingLabel.stringValue = settings.launchingText
    }
    
    /**
     Initialize window
     */
    func initWindow() {
        firstAppear = false
        
        if let title = settings.title {
            mainWindow.window?.title = title
        }
        
        mainWebview.preferences.isJavaScriptEnabled = true
        mainWebview.preferences.javaScriptCanOpenWindowsAutomatically = true
        mainWebview.preferences.arePlugInsEnabled = true
    }
    
    /**
     Load a specific URL
     
     - Parameter url: The url to load
     */
    
    func loadUrl(_ url: String) {
        if settings.showLoadingBar {
            progressBar.isHidden = false
            progressBar.startAnimation(self)
            progressBar.maxValue = 100
            progressBar.minValue = 1
            progressBar.increment(by: 24)
        }
        let URL = Foundation.URL(string: url)
        mainWebview.mainFrame.load(URLRequest(url: URL!))
    }
    
    /**
     Add Print Support (#39) [@wdg]
    */
    @objc func printThisPage() {
        let url = mainWebview.mainFrame.dataSource?.request?.url?.absoluteString
        
        let operation: NSPrintOperation = NSPrintOperation(view: mainWebview)
        operation.jobTitle = "Printing \(url!)"
        operation.printInfo.orientation = NSPrintInfo.PaperOrientation.landscape
        operation.printInfo.scalingFactor = 0.7
        
        if operation.run() {
            print("Printed?")
        }
    }
}
