//
//  Settings.swift
//  WebShell
//
//  Created by Wesley de Groot on 23-04-16.
//  Copyright © 2018 WebShell. All rights reserved.
//

import Foundation

class Settings: WSBaseSettings {
    static let shared = Settings()

    private override init() {
        super.init()
        // Override default settings for this particular target
        self.url = "http://udemy.com"

        // Save last URL
        self.openLastUrl = true
    }
}
