//
//  FilterObject.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class FilterObject
{
    func Reset()
    {
        _EnableFiltering = true
        _TextRegularExpression = "*"
        _CombineLogicalOperator = .And
        _FilterByText = true
        _FilterBySource = true
        var NewList = [(String, Bool)]()
        for (Name, _) in SourceList
        {
            NewList.append((Name, true))
        }
        _SourceList = NewList
    }
    
    private var _EnableFiltering: Bool = true
    public var EnableFiltering: Bool
    {
        get
        {
            return _EnableFiltering
        }
        set
        {
            _EnableFiltering = newValue
        }
    }
    
    private var _FilterByText: Bool = true
    public var ByText: Bool
    {
        get
        {
            return _FilterByText
        }
        set
        {
            _FilterByText = newValue
        }
    }
    
    private var _TextRegularExpression: String = "*"
    public var TextRegularExpression: String
    {
        get
        {
            return _TextRegularExpression
        }
        set
        {
            _TextRegularExpression = newValue
        }
    }
    
    enum LogicalOperators
    {
        case And
        case Or
    }
    
    private var _CombineLogicalOperator: LogicalOperators = .And
    public var CombineLogicalOperator: LogicalOperators
    {
        get
        {
            return _CombineLogicalOperator
        }
        set
        {
            _CombineLogicalOperator = newValue
        }
    }
    
    private var _FilterBySource: Bool = true
    public var BySource: Bool
    {
        get
        {
            return _FilterBySource
        }
        set
        {
            _FilterBySource = newValue
        }
    }
    
    private var _SourceList: [(String, Bool)] = [(String, Bool)]()
    public var SourceList: [(String, Bool)]
    {
        get
        {
            return _SourceList
        }
        set
        {
            _SourceList = newValue
        }
    }
    
    public func IsInSourceList(_ Name: String) -> Bool
    {
        for (SName, IsActive) in _SourceList
        {
            if IsActive
            {
                let FSName = SName.replacingOccurrences(of: " ", with: "-")
                if FSName == Name
                {
                    return true
                }
            }
        }
        return false
    }
    
    private var _TextMustContain: Bool = false
    public var TextMustContain: Bool
    {
        get
        {
            return _TextMustContain
        }
        set
        {
            _TextMustContain = newValue
        }
    }
    
    public func TextMatchesMask(_ Text: String) -> Bool
    {
        #if true
        return Text.contains(TextRegularExpression)
        #else
        var MatchCount = 0
        do
        {
        let Regex = try NSRegularExpression(pattern: TextRegularExpression, options: [])
            MatchCount = Regex.numberOfMatches(in: Text,
                                  options: NSRegularExpression.MatchingOptions.anchored,
                                  range: NSMakeRange(0, Text.count))
        }
        catch
        {
            print("Regex threw exception: \(error.localizedDescription)")
            return false
        }
        return MatchCount > 0
        #endif
    }
    
    public func PredicatesMatchFilter(SourceOK: Bool, TextOK: Bool) -> Bool
    {
        print("FilterByText=\(ByText), TextOK=\(TextOK)")
        print("FilterBySource=\(BySource), SourceOK=\(SourceOK)")
        if !ByText && !BySource
        {
            return false
        }
        if !ByText
        {
            return SourceOK
        }
        if !BySource
        {
            return TextOK
        }
        switch CombineLogicalOperator
        {
        case .And:
            return SourceOK && TextOK
            
        case .Or:
            return SourceOK || TextOK
        }
    }
}
