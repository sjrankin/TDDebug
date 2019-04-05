//
//  MainWindow.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MainWindow: NSWindowController
{
    @IBOutlet weak var DisconnectButton: NSToolbarItem!
    @IBAction func HandleDisconnectButton(_ sender: Any)
    {
        let VC = window!.contentViewController as? ViewController
        VC?.DoDisconnectFromClient()
    }
    
    @IBOutlet weak var HelpButton: NSToolbarItem!
    @IBAction func HandleHelpButtonPressed(_ sender: Any)
    {
        let VC = window!.contentViewController as? ViewController
        VC?.DoShowHelp()
    }
    
    @IBOutlet weak var SendButton: NSToolbarItem!
    @IBAction func HandleSendToPeerButtonPressed(_ sender: Any)
    {
        let VC = window!.contentViewController as? ViewController
        VC?.DoSendToClient()
    }
    
    @IBOutlet weak var PeersButton: NSToolbarItem!
    @IBAction func HandlePeersButtonPressed(_ sender: Any)
    {
        let VC = window!.contentViewController as? ViewController
        VC?.DoShowPeers()
    }
    
    @IBOutlet weak var FontButton: NSToolbarItem!
    @IBAction func HandleFontButtonPress(_ sender: Any)
    {
    }
    
    @IBOutlet weak var CustomizeButton: NSToolbarItem!
    @IBAction func HandleCustomizeButtonPress(_ sender: Any)
    {
    }
    
    @IBOutlet weak var FilterButton: NSToolbarItem!
    @IBAction func HandleFilterButtonPress(_ sender: Any)
    {
        let VC = window!.contentViewController as? ViewController
        VC?.DoRunLogFilter()
    }
}
