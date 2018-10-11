//
//  Notifications.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2018 WebShell. All rights reserved.
//

import AppKit
import AudioToolbox
import Foundation

// @wdg Add Notification Support
// Issue: #2
// This extension will handle the HTML5 Notification API.
extension WSViewController {
    @objc func clearNotificationCount() {
        notificationCount = 0
    }
    
    // @wdg Add Notification Support
    // Issue: #2
    func makeNotification(_ title: NSString, message: NSString, icon: NSString) {
        let notification: NSUserNotification = NSUserNotification() // Set up Notification
        
        // If has no message (title = message)
        if message.isEqual(to: "undefined") {
            if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
                notification.title = appName // Use App name
            } else {
                notification.title = "WebShell"
            }
            notification.informativeText = title as String // Title   = string
        } else {
            notification.title = title as String // Title   = string
            notification.informativeText = message as String // Message = string
        }
        
        notification.soundName = NSUserNotificationDefaultSoundName // Default sound
        notification.deliveryDate = Date(timeIntervalSinceNow: 0) // Now
        notification.actionButtonTitle = "Close"
        
        // Notification has a icon, so add it
        if !icon.isEqual(to: "undefined") {
            if let imagePathUrl = URL(string: icon as String) {
                notification.contentImage = NSImage(contentsOf: imagePathUrl)
            }
        }
        
        let notificationcenter: NSUserNotificationCenter? = NSUserNotificationCenter.default // Notification centre
        notificationcenter?.scheduleNotification(notification) // Pushing to notification centre
        
        notificationCount += 1
        
        NSApplication.shared.dockTile.badgeLabel = String(notificationCount)
    }
    
    // @wdg Add Notification Support
    // Issue: #2
    func flashScreen(_ data: NSString) {
        if (Int(data as String)) != nil || data.isEqual(to: "undefined") {
            AudioServicesPlaySystemSound(kSystemSoundID_FlashScreen)
        } else {
            let time: [String] = (data as String).components(separatedBy: ",")
            for i in 0 ..< time.count {
                // @wdg Fix flashScreen(...)
                // Issue: #66
                if let timeAsNumber = NumberFormatter().number(from: time[i])?.intValue {
                    Timer.scheduledTimer(timeInterval: TimeInterval(timeAsNumber), target: self, selector: #selector(WSViewController.flashScreenNow), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    // @wdg Add Notification Support
    // Issue: #2
    @objc func flashScreenNow() {
        AudioServicesPlaySystemSound(kSystemSoundID_FlashScreen)
    }
}
