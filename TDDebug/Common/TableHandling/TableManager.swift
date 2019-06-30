//
//  TableManager.swift
//  TDDebug
//
//  Created by Stuart Rankin on 6/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

class TableManager
{
    public static func Initialize(Watcher: TableWatcher? = nil)
    {
        Observer = Watcher
    }
    
    private static var Observer: TableWatcher? = nil
    
    private static var _Tables: [UUID: TableData] = [UUID: TableData]()
    public static var Tables: [UUID: TableData]
    {
        get
        {
            return _Tables
        }
        set
        {
            _Tables = newValue
        }
    }
    
    public static func GetTable(WithID: UUID) -> TableData?
    {
        if let Table = Tables[WithID]
        {
            return Table
        }
        return nil
    }
    
    public static func HandleCommand(Command: TableCommandData)
    {
        let TableID = Command.TableID
        switch Command.TableSubCommand
        {
        case .AddRow:
            //Expected parameters: Data, Label
            if let Table = GetTable(WithID: TableID)
            {
                var FinalData = ""
                if let RawData = Command.CommandParameters["Data"]
                {
                    FinalData = RawData
                }
                else
                {
                    print("Parameter \"Data\" not found in .AddRow command.")
                    return
                }
                var FinalLabel = ""
                if let RowLabel = Command.CommandParameters["Label"]
                {
                    FinalLabel = RowLabel
                }
                else
                {
                    print("Parameter \"Label\" not found in .AddRow command.")
                    return
                }
                let NewRow = TableDataRow(Table.DataType)
                NewRow.RowLabel = FinalLabel
                switch Table.DataType
                {
                case .Double:
                    NewRow.RowData = Double(FinalData)! as Any?
                    
                case .Int:
                    NewRow.RowData = Int(FinalData)! as Any?
                    
                case .String:
                    NewRow.RowData = FinalData
                }
                Table.AddRow(NewRow: NewRow)
            }
            else
            {
                print("Could not find table with ID \(TableID.uuidString)")
            }
            
        case .DeleteRow:
            //Expected parameters: Index
            if let Table = GetTable(WithID: TableID)
            {
                var DeleteIndex = 0
                if let Index: String = Command.CommandParameters["Index"]
                {
                    if let RawIndex = Int(Index)
                    {
                        DeleteIndex = RawIndex
                    }
                    else
                    {
                        print("Invalid index: \(Index) in .DeleteRow.")
                        return
                    }
                }
                else
                {
                    print("Malformed .DeleteRow command - no index found.")
                    return
                }
                Table.DeleteRow(RowIndex: DeleteIndex)
            }
            
        case .EditRow:
            //Expected parameters: Index, Data
            if let Table = GetTable(WithID: TableID)
            {
                var EditIndex = 0
                if let Index: String = Command.CommandParameters["Index"]
                {
                    if let RawIndex = Int(Index)
                    {
                        EditIndex = RawIndex
                    }
                    else
                    {
                        print("Invalid index: \(Index) in .EditRow.")
                        return
                    }
                }
                else
                {
                    print("Malformed .EditRow command - no index found.")
                    return
                }
                var FinalData = ""
                if let RawData = Command.CommandParameters["Data"]
                {
                    FinalData = RawData
                }
                else
                {
                    print("Parameter \"Data\" not found in .EditRow command.")
                    return
                }
                var Edited: Any? = nil
                switch Table.DataType
                {
                case .Double:
                    Edited = Double(FinalData)! as Any?
                    
                case .Int:
                    Edited = Int(FinalData)! as Any?
                    
                case .String:
                    Edited = FinalData
                }
                Table.EditRow(NewData: Edited, RowIndex: EditIndex)
            }
            
        case .CloseTable:
            if let Table = GetTable(WithID: TableID)
            {
                Table.Open = false
            }
            
        case .CreateTable:
            //Expected parameters: DataType, YAxisLabel, Annotation (optional)
            let NewTable = TableData(Observer)
            Tables[TableID] = NewTable
            var FinalLabel = ""
            if let AxisLabel = Command.CommandParameters["YAxisLabel"]
            {
                FinalLabel = AxisLabel
            }
            else
            {
                print("Parameter \"YAxisLabel\" not found in .CreateTable command.")
                return
            }
            NewTable.YAxisLabel = FinalLabel
            var Annotation = ""
            if let SomeAnnotation = Command.CommandParameters["Annotation"]
            {
                Annotation = SomeAnnotation
            }
            NewTable.Annotation = Annotation
            
        case .DeleteTable:
            Tables.removeValue(forKey: TableID)
            Observer?.TableDeleted(TableID: TableID)
            
        case .SaveTable:
            break
            
        case .Unknown:
            break
        }
    }
}
