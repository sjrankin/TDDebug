//
//  LogItem.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Contains one log item.
class LogItem
{
    /// Initializer. The ID and timestamp are generated automatically.
    ///
    /// - Parameter Text: The text of the item.
    init(Text: String, ShowInitialAnimation: Bool = true, FinalBG: NSColor = NSColor.white)
    {
        _ID = UUID()
        Title = MessageHelper.MakeTimeStamp(FromDate: Date())
        Message = Text
        DoAnimateBGColor = ShowInitialAnimation
        if ShowInitialAnimation
        {
            SetForAutoAnimation(FinalBG)
        }
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - TimeStamp: Timestamp value.
    ///   - Text: Message value.
    init(TimeStamp: String, Text: String, ShowInitialAnimation: Bool = true, FinalBG: NSColor = NSColor.white)
    {
        _ID = UUID()
        Title = TimeStamp
        Message = Text
        DoAnimateBGColor = ShowInitialAnimation
        if ShowInitialAnimation
        {
            SetForAutoAnimation(FinalBG)
        }
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - TimeStamp: Timestamp value.
    ///   - Host: Name of the host where the message originated.
    ///   - Text: Message value.
    init(TimeStamp: String, Host: String, Text: String, ShowInitialAnimation: Bool = true, FinalBG: NSColor = NSColor.white)
    {
        _ID = UUID()
        Title = TimeStamp
        Message = Text
        HostName = Host
        DoAnimateBGColor = ShowInitialAnimation
        if ShowInitialAnimation
        {
            SetForAutoAnimation(FinalBG)
        }
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - ItemID: ID of the log item.
    ///   - TimeStamp: Timestamp value.
    ///   - Text: Message value.
    init(ItemID: UUID, TimeStamp: String, Text: String, ShowInitialAnimation: Bool = true, FinalBG: NSColor = NSColor.white)
    {
        _ID = ItemID
        Title = TimeStamp
        Message = Text
        if ShowInitialAnimation
        {
            SetForAutoAnimation(FinalBG)
        }
    }
    
    func SetForAutoAnimation(_ FinalColor: NSColor)
    {
        BGColor = NSColor.red
        BGAnimateTargetColor = FinalColor
        DoAnimateBGColor = true
        BGAnimateColorDuration = 2.0
    }
    
    /// ID of the item instance.
    public let ItemID: UUID = UUID()
    
    private var _ID: UUID? = nil
    /// Get or set the ID of the log item.
    public var ID: UUID?
    {
        get
        {
            return _ID
        }
        set
        {
            _ID = newValue
        }
    }
    
    private var _Title: String = ""
    /// Get or set the title/time-stamp of the log item.
    public var Title: String
    {
        get
        {
            return _Title
        }
        set
        {
            _Title = newValue
        }
    }
    
    private var _Message: String = ""
    /// Get or set the contents/message of the log item.
    public var Message: String
    {
        get
        {
            return _Message
        }
        set
        {
            _Message = newValue
        }
    }
    
    private var _HostName: String? = nil
    /// Get or set the host name to display.
    public var HostName: String?
    {
        get
        {
            return _HostName
        }
        set
        {
            _HostName = newValue
        }
    }
    
    private var _FGColor: NSColor? = nil
    /// Get or set the foreground (eg, text) color. If nil, the default color is used.
    public var FGColor: NSColor?
    {
        get
        {
            return _FGColor
        }
        set
        {
            _FGColor = newValue
        }
    }
    
    private var _BGColor: NSColor? = nil
    /// Get or set the background color. If nil, the default color is used.
    public var BGColor: NSColor?
    {
        get
        {
            return _BGColor
        }
        set
        {
            _BGColor = newValue
        }
    }
    
    private var _DoAnimateBGColor: Bool = false
    /// Determines if the background color animates when initially displaying the item. Set to true to have the background color
    /// animate, and false to not perform animation.
    public var DoAnimateBGColor: Bool
    {
        get
        {
            return _DoAnimateBGColor
        }
        set
        {
            _DoAnimateBGColor = newValue
        }
    }
    
    private var _BGAnimateColorDuration: Double = 2.0
    /// Duration of the background animation in seconds. Performed only when the log item is first displayed. Ignored if `DoAnimatedBGColor`
    /// is false.
    public var BGAnimateColorDuration: Double
    {
        get
        {
            return _BGAnimateColorDuration
        }
        set
        {
            _BGAnimateColorDuration = newValue
        }
    }
    
    private var _BGAnimateTargetColor: NSColor = NSColor.white
    /// The final background color for the log item when animating the background color.
    public var BGAnimateTargetColor: NSColor
    {
        get
        {
            return _BGAnimateTargetColor
        }
        set
        {
            _BGAnimateTargetColor = newValue
        }
    }
    
    private var _HasAnimated: Bool = false
    /// Used by the log table view cell to determine whether the item has animated or not. **Do not set.**
    public var HasAnimated: Bool
    {
        get
        {
            return _HasAnimated
        }
        set
        {
            _HasAnimated = newValue
        }
    }
}
