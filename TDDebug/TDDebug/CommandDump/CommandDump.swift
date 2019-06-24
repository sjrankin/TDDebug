//
//  CommandDump.swift
//  TDDebug
//
//  Created by Stuart Rankin on 6/24/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CommandDump: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        RawDataTable.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return RawDataManager.RawNodeCount
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "SourceColumn"
            CellContents = RawDataManager.RawList[row].Source
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "ReceivedColumn"
            CellContents = "\(RawDataManager.RawList[row].TimeStamp)"
        }
        if tableColumn == tableView.tableColumns[2]
        {
            CellIdentifier = "CommandColumn"
            CellContents = "\(RawDataManager.RawList[row].MessageType)"
        }
        if tableColumn == tableView.tableColumns[3]
        {
            CellIdentifier = "RawColumn"
            CellContents = RawDataManager.RawList[row].Raw
        }
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBOutlet weak var RawDataTable: NSTableView!
    
    @IBAction func HandleRefreshButton(_ sender: Any)
    {
        RawDataTable.reloadData()
    }
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.view.window!.performClose(sender)
    }
}
