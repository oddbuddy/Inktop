//
//  InkTopApp.swift
//  InkTop
//
//  Created by Sumit Kumar on 15/11/25.
//

import SwiftUI

@main
struct InkTopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
        
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
