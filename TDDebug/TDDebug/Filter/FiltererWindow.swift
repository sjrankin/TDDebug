//
//  FiltererWindow.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class FiltererWindow: NSWindowController
{
    weak var MainDelegate: MainProtocol? = nil
        {
        didSet
        {
            let VC = window!.contentViewController as? FiltererUICode
            VC?.Delegate = MainDelegate
        }
    }
}
