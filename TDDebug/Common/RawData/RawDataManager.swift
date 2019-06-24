//
//  RawDataManager.swift
//  TDDebug
//
//  Created by Stuart Rankin on 6/24/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
#if FOR_MACOS
import AppKit
#else
import UIKit
#endif

/// Manages raw data from remote peers.
class RawDataManager
{
    /// Initializer (needed because Swift doesn't support static initializers).
    public static func Initialize()
    {
        _RawList = [RawDataNode]()
    }
    
    /// Returns the number of nodes in the list of raw data.
    public static var RawNodeCount: Int
    {
        get
        {
            if _RawList == nil
            {
                return 0
            }
            return _RawList.count
        }
    }
    
    /// Holds the list of raw data.
    private static var _RawList: [RawDataNode]!
    /// Get the list of raw data.
    public static var RawList: [RawDataNode]
    {
        get
        {
            return _RawList
        }
    }
    
    /// Add a raw data node to the list of raw data.
    /// - Parameter Node: The node to add.
    public static func AddNode(_ Node: RawDataNode)
    {
        _RawList.append(Node)
    }
    
    /// Add raw data to the list of raw data.
    /// - Parameter RawValue: The raw data from the remote peer.
    /// - Parameter FromSource: The source of the raw data.
    /// - Parameter MsgType: The message/command type.
    /// - Parameter Received: Time stamp the data was received.
    public static func Add(_ RawValue: String, FromSource: String, MsgType: MessageTypes, Received: Date)
    {
        let NewNode = RawDataNode(RawValue, FromSource: FromSource, MsgType: MsgType, Received: Received)
        AddNode(NewNode)
    }
}
