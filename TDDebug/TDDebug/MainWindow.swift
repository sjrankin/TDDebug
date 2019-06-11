//
//  MainWindow.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MainWindow: NSWindowController, NSToolbarItemValidation
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
    
    /// Flag that determines whether the Send to button should be validated (eg, enabled) or not.
    var EnableSend: Bool = false
    
    /// Validate toolbar items. We only care about the Send to button.
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool
    {
        if item.itemIdentifier.rawValue == "SendButton"
        {
            return EnableSend
        }
        return true
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
    
    @IBOutlet weak var ColorsButton: NSToolbarItem!
    @IBAction func HandleColorsButtonPress(_ sender: Any)
    {
    }
    
    
    @IBOutlet weak var CustomizeButton: NSToolbarItem!
    @IBAction func HandleCustomizeButtonPress(_ sender: Any)
    {
        let VC = window!.contentViewController as? ViewController
        VC?.DoCustomize()
    }
    
    @IBOutlet weak var FilterButton: NSToolbarItem!
    @IBAction func HandleFilterButtonPress(_ sender: Any)
    {
        let VC = window!.contentViewController as? ViewController
        VC?.DoRunLogFilter()
    }
    
    @IBOutlet weak var ResetConnectionButton: NSToolbarItem!
    @IBAction func HandleResetConnectionButtonPressed(_ sender: Any)
    {
        let VC = window!.contentViewController as? ViewController
        VC?.DoResetConnection()
    }
    
    @IBOutlet weak var PrinterButton: NSToolbarItem!
    @IBAction func HandlePrinterButtonPressed(_ sender: Any)
    {
        let VC = window!.contentViewController as? ViewController
        VC?.HandleFilePrint(sender)
    }
    
    @IBOutlet weak var SearchButton: NSToolbarItem!
    @IBAction func HandleSearchButtonPressed(_ sender: Any)
    {
        let VC = window!.contentViewController as? ViewController
        VC?.HandleSearch(sender) 
    }
    
    @IBOutlet weak var BroadcastButton: NSToolbarItem!
    @IBAction func HandleBroadcastButtonPressed(_ sender: Any)
    {
        let VC = window!.contentViewController as? ViewController
        VC?.HandleBroadcast(sender)
    }
    
    @IBOutlet weak var DebuggerButton: NSToolbarItem!
    @IBAction func HandleDebuggerButtonPressed(_ sender: Any)
    {
        let VC = window!.contentViewController as? ViewController
        VC?.HandleDebugButtonPressed(sender)
    }
}
