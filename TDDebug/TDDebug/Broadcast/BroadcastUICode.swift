//
//  BroadcastUICode.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class BroadcastUICode: NSViewController, NSTabViewDelegate
{
    weak var Delegate: MainProtocol? = nil
    {
        didSet
        {
            LoadUI()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        TabControl.delegate = self
    }
    
    func LoadUI()
    {
        
    }
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?)
    {
        if tabViewItem == TabControl.tabViewItem(at: 1)
        {
            CurrentTab = 1
            BroadcastButton.isEnabled = false
        }
        else
        {
            CurrentTab = 0
            BroadcastButton.isEnabled = true
        }
    }
    
    var CurrentTab: Int = 0
    
    @IBOutlet weak var TabControl: NSTabView!
    
    @IBOutlet weak var BroadcastButton: NSButton!
    
    @IBAction func HandleBroadcastButtonPressed(_ sender: Any)
    {
        switch CurrentTab
        {
        case 0:
            let MessageToBroadcast = BroadcastMessageBox.stringValue
            let BroadcastMessage = MessageHelper.MakeBroadcastMessage(From: "(Delegate?.MPManager.SelfPeer)!", Message: MessageToBroadcast)
            Delegate?.MPManager.BroadcastPreformatted(Message: BroadcastMessage)
            
        case 1:
            break
            
        default:
            break
        }
    }
    
    @IBOutlet weak var BroadcastMessageBox: NSTextField!
    
    @IBAction func HandleCloseButtonPressed(_ sender: Any)
    {
        self.view.window!.performClose(sender)
    }
}
