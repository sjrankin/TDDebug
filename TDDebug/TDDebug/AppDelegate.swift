//
//  AppDelegate.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Cocoa

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        // Insert code here to initialize your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }
    
    /// Reference to the debugger menu item.
    @IBOutlet weak var DebuggerMenuItem: NSMenuItem!
}

