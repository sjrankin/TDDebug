//
//  KVPItems.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import MultipeerConnectivity

class KVPItems
{
    private var _Filter: FilterObject? = nil
    {
        didSet
        {
            if _Filter != nil
            {
                RefilterList()
            }
        }
    }
    public var Filter: FilterObject?
    {
        get
        {
            return _Filter
        }
        set
        {
            _Filter = newValue
        }
    }
    
    private var _List: [KVPItem] = [KVPItem]()
    {
        didSet
        {
            RefilterList()
        }
    }
    public var List: [KVPItem]
    {
        get
        {
            return _List
        }
        set
        {
            _List = newValue
        }
    }
    
    private func RefilterList()
    {
        if let Filter = Filter
        {
        _FilteredList.removeAll()
        for Item in _List
        {
            var SourceFilterSatisfied = false
            if Filter.BySource
            {
                SourceFilterSatisfied = Filter.IsInSourceList(Item.Value)
            }
        }
        }
        else
        {
            _FilteredList.removeAll()
            _FilteredList = _List
        }
    }
    
    private var _FilteredList: [KVPItem] = [KVPItem]()
    public var FilteredList: [KVPItem]
    {
        get
        {
            return _FilteredList
        }
    }
}
