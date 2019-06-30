//
//  TableData.swift
//  TDDebug
//
//  Created by Stuart Rankin on 6/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

class TableData: TableWatcher
{
    init(_ Watcher: TableWatcher? = nil)
    {
        Delegate = Watcher
    }
    
    weak var Delegate: TableWatcher? = nil
    
    func TableChanged(TableID: UUID)
    {
    //Not used in this class.
    }
    
    func TableDeleted(TableID: UUID)
    {
        //Not used in this class
    }
    
    private var _Open: Bool = true
    public var Open: Bool
    {
        get
        {
            return _Open
        }
        set
        {
            _Open = newValue
        }
    }
    
    private var _YAxisLabel: String = ""
    public var YAxisLabel: String
    {
        get
        {
            return _YAxisLabel
        }
        set
        {
            _YAxisLabel = newValue
        }
    }
    
    private var _TableID: UUID = UUID.Empty
    public var TableID: UUID
    {
        get
        {
            return _TableID
        }
        set
        {
            _TableID = newValue
        }
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
    
    private var _Annotation: String = ""
    public var Annotation: String
    {
        get
        {
            return _Annotation
        }
        set
        {
            _Annotation = newValue
        }
    }
    
    private var _Rows: [TableDataRow] = [TableDataRow]()
    public var Rows: [TableDataRow]
    {
        get
        {
            return _Rows
        }
        set
        {
            _Rows = newValue
        }
    }
    
    public var RowCount: Int
    {
        get
        {
            return Rows.count
        }
    }
    
    public func AddRow(NewData: Any?, Label: String)
    {
        let NewRow = TableDataRow(DataType)
        NewRow.RowLabel = Label
        NewRow.RowData = NewData
        Rows.append(NewRow)
        Delegate?.TableChanged(TableID: TableID)
    }
    
    public func AddRow(NewRow: TableDataRow)
    {
        Rows.append(NewRow)
        Delegate?.TableChanged(TableID: TableID)
    }
    
    public func EditRow(NewData: Any?, RowIndex: Int)
    {
        if RowIndex < 0 || RowIndex >= RowCount
        {
            fatalError("RowIndex out of bounds in EditRow. RowIndex=\(RowIndex), RowCount=\(RowCount)")
        }
        Rows[RowIndex].RowData = NewData
                Delegate?.TableChanged(TableID: TableID)
    }
    
    public func DeleteRow(RowIndex: Int)
    {
        if RowIndex < 0 || RowIndex >= RowCount
        {
            fatalError("RowIndex out of bounds in DeleteRow. RowIndex=\(RowIndex), RowCount=\(RowCount)")
        }
        Rows.remove(at: RowIndex)
                Delegate?.TableChanged(TableID: TableID)
    }
}

public enum TableDataTypes: String, CaseIterable
{
    case Int = "Int"
    case String = "String"
    case Double = "Double"
}
