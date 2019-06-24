//
//  RawDataNode.swift
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

/// Contains one data node for raw data sent by a remote peer.
class RawDataNode
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer.
    /// - Parameter RawValue: The raw data received by TDDebug.
    /// - Parameter FromSource: The source of the raw data.
    /// - Parameter MsgType: The message type/command.
    /// - Parameter Received: The time stamp the data was received.
    init(_ RawValue: String, FromSource: String, MsgType: MessageTypes, Received: Date)
    {
        Raw = RawValue
        Source = FromSource
        MessageType = MsgType
        TimeStamp = Received
    }
    
    /// Holds the message type.
    private var _MessageType: MessageTypes = .Unknown
    /// Get or set the message type.
    public var MessageType: MessageTypes
    {
        get
        {
            return _MessageType
        }
        set
        {
            _MessageType = newValue
        }
    }
    
    /// Holds the source of the message.
    private var _Source: String = ""
    /// Get or set the source of the message.
    public var Source: String
    {
        get
        {
            return _Source
        }
        set
        {
            _Source = newValue
        }
    }
    
    /// Holds the data's time stamp.
    private var _TimeStamp = Date()
    /// Get or set the time stamp the data was received.
    public var TimeStamp: Date
    {
        get
        {
            return _TimeStamp
        }
        set
        {
            _TimeStamp = newValue
        }
    }
    
    /// Holds the raw data.
    private var _Raw: String = ""
    /// Get or set the raw data.
    public var Raw: String
    {
        get
        {
            return _Raw
        }
        set
        {
            _Raw = newValue
        }
    }
}
