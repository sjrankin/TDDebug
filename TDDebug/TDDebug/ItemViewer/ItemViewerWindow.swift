//
//  ItemViewerWindow.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/7/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ItemViewerWindow: NSWindowController
{
    weak var MainDelegate: MainProtocol? = nil
        {
        didSet
        {
            let VC = window!.contentViewController as? ItemViewerUICode
            VC?.Delegate = MainDelegate
        }
    }
    
    @IBAction func HandlePrintButtonPress(_ sender: Any)
    {
        let VC = window!.contentViewController as? ItemViewerUICode
        VC?.HandlePrintButton(sender)
    }
    
    @IBAction func HandleColorButtonPress(_ sender: Any)
    {
        let VC = window!.contentViewController as? ItemViewerUICode
        VC?.HandleColorButton(sender) 
    }
    
    @IBAction func HandleFontButtonPress(_ sender: Any)
    {
        let VC = window!.contentViewController as? ItemViewerUICode
        VC?.HandleFontButton(sender)
    }
}
