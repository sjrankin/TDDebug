//
//  BroadcastWindow.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class BroadcastWindow: NSWindowController
{
    weak var MainDelegate: MainProtocol? = nil
        {
        didSet
        {
            let VC = window!.contentViewController as? BroadcastUICode
            VC?.Delegate = MainDelegate
        }
    }
}
