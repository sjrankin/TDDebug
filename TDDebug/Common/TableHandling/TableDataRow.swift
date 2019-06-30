//
//  TableDataRow.swift
//  TDDebug
//
//  Created by Stuart Rankin on 6/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Encapsulates a row's data.
public class TableDataRow
{
    init(_ RowType: TableDataTypes)
    {
        DataType = RowType
    }
    
    private var _DataType: TableDataTypes = .Double
    public var DataType: TableDataTypes
    {
        get
        {
            return _DataType
        }
        set
        {
            _DataType = newValue
        }
    }
    
    private var _RowData: Any? = nil
    public var RowData: Any?
    {
        get
        {
            return _RowData
        }
        set
        {
            _RowData = newValue
        }
    }
    
    private var _RowLabel: String = ""
    public var RowLabel: String
    {
        get
        {
            return _RowLabel
        }
        set
        {
            _RowLabel = newValue
        }
    }
}
