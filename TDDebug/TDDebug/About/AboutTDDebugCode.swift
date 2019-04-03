//
//  AboutTDDebugCode.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class AboutTDDebugCode: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        VersionLabel.stringValue = Versioning.MakeVersionString()
        BuildLabel.stringValue = "Build \(Versioning.Build)"
        BuildDateLabel.stringValue = "Build date " + Versioning.BuildDate + " " + Versioning.BuildTime
        CopyrightLabel.stringValue = Versioning.CopyrightText()
    }
    
    @IBAction func HandleCloseButtonPressed(_ sender: Any)
    {
        self.view.window!.performClose(sender)
    }
    
    @IBOutlet weak var VersionLabel: NSTextField!
    @IBOutlet weak var BuildLabel: NSTextField!
    @IBOutlet weak var BuildDateLabel: NSTextField!
    @IBOutlet weak var CopyrightLabel: NSTextField!
}
