//
//  MainCustomizeUICode.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MainCustomizeUICode: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeConnectionsUI()
    }
    
    // MARK: Connections-related code.
    
    func InitializeConnectionsUI()
    {
        AutoAcceptDelayPopup.removeAllItems()
        AutoAcceptDelayPopup.addItems(withTitles: ["1 second", "6 seconds", "10 seconds", "15 seconds", "30 seconds"])
        AutoAcceptDelayPopup.selectItem(at: 1)
        AutoAcceptInComingCheck.state = .on
        SetConnectionsUIState()
    }
    
    func SetConnectionsUIState()
    {
        AutoAcceptDelayLabel.isEnabled = AutoAcceptInComingCheck.state != .on
        AutoAcceptDelayPopup.isEnabled = AutoAcceptInComingCheck.state != .on
    }
    
    @IBAction func HandleAutoAcceptDelayPopupChanged(_ sender: Any)
    {
        let Index = AutoAcceptDelayPopup.indexOfSelectedItem
        let Delay = [1, 6, 10, 15, 30][Index]
        print("Auto accept delay set to \(Delay) seconds.")
    }
    
    @IBOutlet weak var AutoAcceptDelayPopup: NSPopUpButton!
    
    @IBAction func HandleAutoAcceptIncomingCheckChanged(_ sender: Any)
    {
        SetConnectionsUIState()
    }
    
    @IBOutlet weak var AutoAcceptInComingCheck: NSButton!
    @IBOutlet weak var AutoAcceptDelayLabel: NSTextField!
    
    // MARK: Visual-related code.
    
    // MARK: View Controller-related code.
    
    @IBAction func HandeDonePressed(_ sender: Any)
    {
        self.view.window!.performClose(sender)
    }
}
