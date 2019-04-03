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
            PeerList = Delegate.MPManager.GetPeerList()
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
        var IsDebugClient = false
        if tableColumn == tableView.tableColumns[1]
        {
            if PeerList[row] == Delegate.ConnectedClient
            {
                Contents = "debug client"
                IsDebugClient = true
            }
            else
            {
                Contents = "connected"
                IsDebugClient = false
            }
            Identifier = "StateColumn"
        }
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: Identifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = Contents
        if IsDebugClient
        {
            Cell?.textField?.textColor = OSColor.blue
        }
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
}
