//
//  ConfirmConnectionUICode.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import MultipeerConnectivity

class ConfirmConnectionUICode: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @objc func HandleUpdateAutoAcceptIndicator()
    {
        CurrentCount = CurrentCount + 1
        if CurrentCount >= ExpectedCount
        {
            print("Automatically auto accepting.")
            AutoAccept()
        }
        AutoAcceptIndicator.doubleValue = CurrentCount
    }
    
    var Peer: MCPeerID? = nil
    {
        didSet
        {
            let Duration = AutoAcceptInSec
            AutoAcceptIndicator.maxValue = Duration
            ExpectedCount = Duration
            AutoAcceptTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                                   selector: #selector(HandleUpdateAutoAcceptIndicator),
                                                   userInfo: nil, repeats: true)
            Message.stringValue = "The peer \((Peer?.displayName)!) wants to connect to this instance so it can send debug information. Accept this connection?"
        }
    }
    
    var CurrentCount: Double = 0
    var ExpectedCount: Double = 0
    var AutoAcceptInSec: Double = 6.0
    var AutoAcceptTimer: Timer? = nil
    
    func AutoAccept()
    {
        AutoAcceptTimer?.invalidate()
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: NSApplication.ModalResponse(1000))
    }
    
    @IBAction func HandleDenyButtonPress(_ sender: Any)
    {
        AutoAcceptTimer?.invalidate()
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: NSApplication.ModalResponse(0))
    }
    
    @IBAction func HandleAcceptButtonPress(_ sender: Any)
    {
        AutoAccept()
    }
    
    @IBOutlet weak var Message: NSTextField!
    @IBOutlet weak var AutoAcceptIndicator: NSProgressIndicator!
}
