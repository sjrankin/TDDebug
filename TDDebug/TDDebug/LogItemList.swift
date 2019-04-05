//
//  LogItemList.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit


class LogItemList
{
    private var _Filter: FilterObject? = nil
    {
        didSet
        {
            FilterLogList()
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
    
    private var _List: [LogItem] = [LogItem]()
    {
        didSet
        {
            FilterLogList()
        }
    }
    public var List: [LogItem]
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
    
    func Clear()
    {
        _List.removeAll()
        _FilteredList.removeAll()
    }
    
    func Add(_ NewItem: LogItem)
    {
        _List.append(NewItem)
        if FilterLogItem(Item: NewItem)
        {
            _FilteredList.append(NewItem)
        }
    }
    
    private var _FilteredList: [LogItem] = [LogItem]()
    public var FilteredList: [LogItem]
    {
        get
        {
            return _FilteredList
        }
    }
    
    public var FilteredCount: Int
    {
        get
        {
            return _FilteredList.count
        }
    }
    
    subscript(Index: Int) -> LogItem
    {
        get
        {
            if Index < 0
            {
                fatalError("Invalid index \(Index) in LogItemList[]")
            }
            if FilterActive
            {
                if Index > _FilteredList.count - 1
                {
                    fatalError("Invalid index \(Index) in LogItemList[]")
                }
                return _FilteredList[Index]
            }
            else
            {
                if Index > _List.count - 1
                {
                    fatalError("Invalid index \(Index) in LogItemList[]")
                }
                return _List[Index]
            }
        }
        set
        {
            if Index < 0
            {
                fatalError("Invalid index \(Index) in LogItemList[]")
            }
            if FilterActive
            {
                if Index > _FilteredList.count - 1
                {
                    fatalError("Invalid index \(Index) in LogItemList[]")
                }
                _FilteredList[Index] = newValue
            }
            else
            {
                if Index > _List.count - 1
                {
                    fatalError("Invalid index \(Index) in LogItemList[]")
                }
                _List[Index] = newValue
            }
        }
    }
    
    public var FilterActive: Bool
    {
        get
        {
            if _Filter == nil
            {
                return false
            }
            return (_Filter?.EnableFiltering)!
        }
    }
    
    private func FilterLogList()
    {
        _FilteredList.removeAll()
        if !FilterActive
        {
            _FilteredList = _List
            return
        }
        for Item in _List
        {
            if FilterLogItem(Item: Item)
            {
                _FilteredList.append(Item)
            }
        }
    }
    
    private func FilterLogItem(Item: LogItem) -> Bool
    {
        if _Filter == nil
        {
            return true
        }
        var SatisfiesText = false
        var SatisfiesSource = false
        if (_Filter?.ByText)!
        {
            SatisfiesText = (_Filter?.TextMatchesMask(Item.Message))!
        }
        if (_Filter?.BySource)!
        {
            SatisfiesSource = (_Filter?.IsInSourceList(Item.HostName ?? "{blank}"))!
        }
        let Result = _Filter?.PredicatesMatchFilter(SourceOK: SatisfiesSource, TextOK: SatisfiesText)
        return Result!
    }
}
