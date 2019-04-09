//
//  SearcherUICode.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import MultipeerConnectivity

class SearcherUICode: NSViewController, NSTableViewDelegate, NSTableViewDataSource, LogItemProtocol
{
    let ResultsTableTag = 100
    let SourceTableTag = 200
    
    weak var Delegate: MainProtocol? = nil
        {
        didSet
        {
            LoadUI()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func LoadUI()
    {
        SearchBox.stringValue = ""
        IgnoreCaseCheck.state = .on
        let Sources = (Delegate?.MPManager.GetPeerList(IncludingSelf: true))!
        SourceList.removeAll()
        for Peer in Sources
        {
            if Peer == Delegate?.MPManager.SelfPeer
            {
                SourceList.append("TDDebug")
            }
            else
            {
                SourceList.append(Peer.displayName)
            }
        }
        SourceTable.reloadData()
        DoSelectAllPeers()
        ItemList.removeAll()
        AllItems = Delegate?.GetItemManager()
        ResultsTable.reloadData()
        ResultsTable.doubleAction = #selector(HandleLogDoubleClick(_:))
    }
    
    @objc func HandleLogDoubleClick(_ sender: Any)
    {
        let Row = ResultsTable.selectedRow
        guard Row >= 0 else
        {
            return
        }
        LastLogItemSelected = ItemList[Row]
        if LastLogItemSelected == nil
        {
            return
        }
        if ItemViewerController == nil
        {
            let Storyboard = NSStoryboard(name: "ItemViewer", bundle: nil)
            ItemViewerController = Storyboard.instantiateController(withIdentifier: "ItemViewerWindow") as? ItemViewerWindow
        }
        if let IVC = ItemViewerController as? ItemViewerWindow
        {
            IVC.MainDelegate = self
            IVC.showWindow(nil)
        }
    }
    
    var ItemViewerController: NSWindowController? = nil
    
    var LastLogItemSelected: LogItem? = nil
    func LastSelectedLogItem() -> LogItem?
    {
        return LastLogItemSelected
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView.tag
        {
        case ResultsTableTag:
            return ItemList.count
            
        case SourceTableTag:
            return SourceList.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        switch tableView.tag
        {
        case ResultsTableTag:
            var CellContents = ""
            var CellIdentifier = ""
            if tableColumn == tableView.tableColumns[0]
            {
                CellIdentifier = "TimeColumn"
                CellContents = ItemList[row].Title
            }
            if tableColumn == tableView.tableColumns[1]
            {
                CellIdentifier = "SourceColumn"
                CellContents = ItemList[row].HostName ?? "{unknown}"
            }
            if tableColumn == tableView.tableColumns[2]
            {
                CellIdentifier = "MessageColumn"
                CellContents = ItemList[row].Message
            }
            let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
            Cell?.textField?.stringValue = CellContents
            return Cell
            
        case SourceTableTag:
            var Content = ""
            var CellIdentifier = ""
            if tableColumn == tableView.tableColumns[0]
            {
                Content = SourceList[row]
                CellIdentifier = "OnlyColumn"
            }
            let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
            Cell?.textField?.stringValue = Content
            return Cell
            
        default:
            break
        }
        
        return nil
    }
    
    var AllItems: LogItemList? = nil
    var SourceList = [String]()
    var ItemList = [LogItem]()
    
    @IBAction func HandleSearchButton(_ sender: Any)
    {
        var SearchHosts = [String]()
        let SelectedRows = SourceTable.selectedRowIndexes
        for Row in SelectedRows
        {
            SearchHosts.append(SourceList[Row])
        }
        if SearchHosts.count < 1
        {
            ItemList.removeAll()
            ResultsTable.reloadData()
            return
        }
        ItemList = AllItems!.SearchFor(Text: SearchBox.stringValue,
                                       IgnoreCase: IgnoreCaseCheck.state == .on,
                                       SourceIn: SearchHosts)
        var ResultCount = ""
        if ItemList.count == 1
        {
            ResultCount = "1 found"
        }
        else
        {
            ResultCount = "\(ItemList.count) found"
        }
        SearchResultLabel.stringValue = "Search results: \(ResultCount)"
        ResultsTable.reloadData()
    }
    
    func DoSelectAllPeers()
    {
            SourceTable.selectAll(nil)
    }
    
    func DoDeselectAllPeers()
    {
        for Index in 0 ..< SourceList.count
        {
            SourceTable.deselectRow(Index)
        }
    }
    
    @IBAction func HandleSelectAllPeers(_ sender: Any)
    {
        let Button = sender as? NSButton
        if SelectButtonIsSelect
        {
        DoSelectAllPeers()
            SelectButtonIsSelect = false
        }
        else
        {
            DoDeselectAllPeers()
            SelectButtonIsSelect = true
        }
        Button?.title = SelectButtonIsSelect ? "Select All" : "Deselect All"
    }
    
    var SelectButtonIsSelect = false
    
    @IBOutlet weak var SearchResultLabel: NSTextField!
    @IBOutlet weak var ResultsTable: NSTableView!
    @IBOutlet weak var SourceTable: NSTableView!
    @IBOutlet weak var IgnoreCaseCheck: NSButton!
    @IBOutlet weak var SearchBox: NSTextField!
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.view.window!.performClose(sender)
    }
}
