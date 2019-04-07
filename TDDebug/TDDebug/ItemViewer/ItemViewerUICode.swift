//
//  ItemViewerUICode.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/7/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ItemViewerUICode: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    var HaveDelegate = false
    weak var Delegate: MainProtocol!
        {
        didSet
        {
            HaveDelegate = true
            LoadContents()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MessageContents.stringValue = ""
        ItemHeader.removeAll()
    }
    
    func LoadContents()
    {
        if HaveDelegate
        {
            let Item = Delegate.LastSelectedLogItem()
            ItemHeader.append(("Sender", (Item?.HostName)!))
            ItemHeader.append(("Time-Stamp", (Item?.Title)!))
            ItemHeader.append(("Item ID", (Item?.ID!.uuidString)!))
            MessageContents.stringValue = (Item?.Message)!
            ItemHeaderTable.reloadData()
        }
    }
    
    var ItemHeader = [(String, String)]()
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.view.window!.performClose(sender)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        if HaveDelegate
        {
            return 3
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "NameColumn"
            CellContents = ItemHeader[row].0
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "ValueColumn"
            CellContents = ItemHeader[row].1
        }
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    
    @IBOutlet weak var ItemHeaderTable: NSTableView!
    @IBOutlet weak var MessageContents: NSTextField!
}
