//
//  ViewState.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/7/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ViewState
{
    init(ViewID: UUID, ClientID: UUID, ViewTitle: String)
    {
        _ID = ViewID
        _PgmID = ClientID
        _Title = ViewTitle
        _IsClosed = false
        _Start = Date()
    }
    
    private var _PgmID: UUID!
    public var ProgramID: UUID
    {
        get
        {
            return _PgmID
        }
    }
    
    private var _Start: Date = Date()
    public var Start: Date
    {
        get
        {
            return _Start
        }
    }
    
    private var _Stop: Date? = nil
    public var Stop: Date?
    {
        get
        {
            return _Stop
        }
    }
    
    public func Close()
    {
        _Stop = Date()
    }
    
    private var _IsClosed: Bool = false
    public var IsClosed: Bool
    {
        get
        {
            return _IsClosed
        }
    }
    
    private var _ID: UUID = UUID()
    public var ID: UUID
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
}

class IdiotLight
{
    init(LightAddress: String, LightContainer: NSView, LightText: NSTextField)
    {
        _Address = LightAddress
        _Container = LightContainer
        _Text = LightText
    }
    
    public func SetState(LightState: A1IdiotLightStates)
    {
        
    }
    
    private var _Address: String = ""
    public var Address: String
    {
        get
        {
            return _Address
        }
    }
    
    private var _Container: NSView!
    {
        didSet
        {
            
        }
    }
    public var Container: NSView
    {
        get
        {
            return _Container
        }
    }
    
    private var _Text: NSTextField!
    public var Text: NSTextField
    {
        get
        {
            return _Text
        }
    }
    
    public func SetText(_ NewText: String)
    {
        Text.stringValue = NewText
    }
    
    public func SetTextColor(_ NewColor: OSColor)
    {
        Text.textColor = NewColor
    }
    
    public func SetBackgroundColor(_ NewColor: OSColor)
    {
        Container.layer?.backgroundColor = NewColor.cgColor
    }
    
    public func SetBorderColor(_ NewColor: OSColor)
    {
        Container.layer?.borderColor = NewColor.cgColor
    }
    
    public func SetBorderWidth(_ NewWidth: CGFloat)
    {
        Container.layer?.borderWidth = NewWidth
    }
}

enum A1IdiotLightStates
{
    case NotConnected
    case PeersFound
    case NoPeers
    case Connected
}
