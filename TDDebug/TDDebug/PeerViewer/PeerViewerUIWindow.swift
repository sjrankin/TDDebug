//
//  PeerViewerUIWindow.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class PeerViewerUIWindow: NSWindowController
{
    weak var MainDelegate: MainProtocol? = nil
    {
        didSet
        {
            let VC = window!.contentViewController as? PeerViewerUICode
            VC?.Delegate = MainDelegate
            print("PeerViewerUIwindow: \(MainDelegate!)")
        }
    }
}
