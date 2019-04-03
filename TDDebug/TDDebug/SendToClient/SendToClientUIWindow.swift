//
//  SendToClientUIWindow.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/2/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class SendToClientUIWindow: NSWindowController
{
    weak var MainDelegate: MainProtocol? = nil
        {
        didSet
        {
            let VC = window!.contentViewController as? SendToClientUICode
            VC?.Delegate = MainDelegate
        }
    }
}
