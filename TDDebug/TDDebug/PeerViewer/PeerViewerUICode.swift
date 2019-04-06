//
//  PeerViewerUICode.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import MultipeerConnectivity

class PeerViewerUICode: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    var HaveDelegate = false
    weak var Delegate: MainProtocol!
        {
        didSet
        {
            HaveDelegate = true
            RefreshPeerList()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        PeerTable.delegate = self
        PeerTable.dataSource = self
        PeerTable.reloadData()
        #if false
        RefreshTimer = Timer.scheduledTimer(timeInterval: 3, target: self,
                                            selector: #selector(RefreshPeerList),
                                            userInfo: nil,
                                            repeats: true)
        #endif
    }
    
    @objc func RefreshPeerList()
    {
        if HaveDelegate
        {
            PeerList = Delegate.MPManager.GetPeerList(IncludingSelf: ShowSelf)
            PeerTable.reloadData()
        }
    }
    
    var RefreshTimer: Timer!
    
    override func viewDidDisappear()
    {
        if RefreshTimer != nil
        {
            RefreshTimer.invalidate()
            RefreshTimer = nil
        }
        super.viewWillDisappear()
    }
    
    var PeerList: [MCPeerID] = [MCPeerID]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return PeerList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var Contents = ""
        var Identifier = ""
        if tableColumn == tableView.tableColumns[0]
        {
            Contents = PeerList[row].displayName
            Identifier = "PeerColumn"
        }
        var TextColor = OSColor.black
        if tableColumn == tableView.tableColumns[1]
        {
            Contents = "connected"
            if PeerList[row] == Delegate.ConnectedClient
            {
                Contents = "debug client"
                TextColor = OSColor.blue
            }
            if PeerList[row] == Delegate.MPManager.SelfPeer
            {
                Contents = "this instance"
                TextColor = OSColor.purple
            }
            Identifier = "StateColumn"
        }
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: Identifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = Contents
        Cell?.textField?.textColor = TextColor
        return Cell
    }
    
    @IBOutlet weak var PeerTable: NSTableView!
    
    func HandleConnectButtonPressed()
    {
        let SelectedRow = PeerTable.selectedRow
        if SelectedRow == -1
        {
            print("No row selected.")
            return
        }
        if PeerList[SelectedRow] == Delegate.ConnectedClient
        {
            print("\((Delegate.ConnectedClient?.displayName)!) already connected as client")
            return
        }
        Delegate.ConnectedClient = PeerList[SelectedRow]
        RefreshPeerList()
    }
    
    func HandleDisconnectButtonPressed()
    {
        let SelectedRow = PeerTable.selectedRow
        if SelectedRow == -1
        {
            print("No row selected.")
            return
        }
        if PeerList[SelectedRow] != Delegate.ConnectedClient
        {
            print("\((Delegate.ConnectedClient?.displayName)!) is not connected as client")
            return
        }
        Delegate.ConnectedClient = nil
        RefreshPeerList()
    }
    
    func HandleRefreshButtonPressed()
    {
        RefreshPeerList()
    }
    
    func ToggleAllPeers(_ sender: Any)
    {
        let Button = sender as? NSToolbarItem
        ShowSelf = !ShowSelf
        if ShowSelf
        {
            ShowAllStatus.stringValue = "Showing all speers (including self)."
            PeerList = Delegate.MPManager.GetPeerList(IncludingSelf: true)
            Button?.image = NSImage(named: "AllOfSomething")
        }
        else
        {
            ShowAllStatus.stringValue = "Not showing self."
            PeerList = Delegate.MPManager.GetPeerList(IncludingSelf: false)
            Button?.image = NSImage(named: "NotAllOfSomething")
        }
        PeerTable.reloadData()
    }
    
    var ShowSelf: Bool = false
    
    @IBOutlet weak var ShowAllStatus: NSTextField!
}
