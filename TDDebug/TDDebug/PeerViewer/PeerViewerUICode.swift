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
    #if true
    var HaveDelegate = false
    weak var Delegate: MainProtocol!
        {
        didSet
        {
            HaveDelegate = true
            //print("PeerViewUICode: \(Delegate!)")
            RefreshPeerList()
        }
    }
    #else
    weak var Delegate: MainProtocol? = nil
        {
        didSet
        {
            print("PeerViewUICode: \(Delegate!)")
            let D: MainProtocol = Delegate as! MainProtocol
            let x = D.MPManager.GetPeerList()
            if Delegate != nil
            {
                print("PeerViewUICode2: \(Delegate!)")
                PeerList = (Delegate?.MPManager.GetPeerList())!
            }
        }
    }
    #endif
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //PeerList = (Delegate?.MPManager.GetPeerList())!
        PeerTable.delegate = self
        PeerTable.dataSource = self
        PeerTable.reloadData()
        RefreshTimer = Timer.scheduledTimer(timeInterval: 5, target: self,
                                            selector: #selector(RefreshPeerList),
                                            userInfo: nil,
                                            repeats: true)
    }
    
    @objc func RefreshPeerList()
    {
        #if true
        if HaveDelegate
        {
            PeerList = Delegate.MPManager.GetPeerList()
            //print("RefreshPeerList: count=\(PeerList.count)")
        }
        #else
        PeerList = (Delegate?.MPManager.GetPeerList())!
        #endif
        PeerTable.reloadData()
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
        //print("PeerList.count=\(PeerList.count)")
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
        if tableColumn == tableView.tableColumns[1]
        {
            Contents = ""
            Identifier = "StateColumn"
        }
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: Identifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = Contents
        return Cell
    }
    
    @IBOutlet weak var PeerTable: NSTableView!
}
