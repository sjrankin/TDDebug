//
//  TableCommandData.swift
//  TDDebug
//
//  Created by Stuart Rankin on 6/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

class TableCommandData
{
    init(_ ID: UUID, _ SubCommand: TableCommands)
    {
        TableID = ID
        TableSubCommand = SubCommand
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
    
    private var _TableSubCommand: TableCommands = .Unknown
    public var TableSubCommand: TableCommands
    {
        get
        {
            return _TableSubCommand
        }
        set
        {
            _TableSubCommand = newValue
        }
    }
    
    private var _CommandParameters: [String: String] = [String: String]()
    public var CommandParameters: [String: String]
    {
        get
        {
            return _CommandParameters
        }
        set
        {
            _CommandParameters = newValue
        }
    }
}
