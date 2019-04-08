//
//  SelectorWindow.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class SelectorWindow: NSWindowController
{
    weak var Delegate: SelectorDelegate? = nil
        {
        didSet
        {
            let VC = window!.contentViewController as? SelectorWindowUI 
            VC?.Delegate = Delegate
        }
    }
}
