//
//  SearcherWindow.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class SearcherWindow: NSWindowController
{
    weak var MainDelegate: MainProtocol? = nil
        {
        didSet
        {
            let VC = window!.contentViewController as? SearcherUICode 
            VC?.Delegate = MainDelegate
        }
    }
    
    @IBAction func HandleRefreshPressed(_ sender: Any)
    {
        let VC = window!.contentViewController as? SearcherUICode
        VC?.LoadUI()
    }
}
