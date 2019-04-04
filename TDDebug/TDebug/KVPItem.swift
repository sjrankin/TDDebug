//
//  KVPItem.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/31/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class KVPItem
{
    init(_ InitialID: UUID, WithKey: String, AndValue: String)
    {
        _ID = InitialID
        _Key = WithKey
        _Value = AndValue
    }
    
    init(WithKey: String, AndValue: String)
    {
        _Key = WithKey
        _Value = AndValue
    }
    
    private var _Key: String = ""
    public var Key: String
    {
        get
        {
            return _Key
        }
        set
        {
            _Key = newValue
        }
    }
    
    private var _Value: String = ""
    public var Value: String
    {
        get
        {
            return _Value
        }
        set
        {
            _Value = newValue
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
}
