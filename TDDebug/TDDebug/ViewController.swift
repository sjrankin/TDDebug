//
//  ViewController.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import Cocoa
import AppKit
import MultipeerConnectivity

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, MultiPeerDelegate
{    
    let KVPTableTag = 100
    let LogTableTag = 200
    var MPMgr: MultiPeerManager? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        InitializeIdiotLights()
        InitializeTables()
        
        MPMgr = MultiPeerManager()
        MPMgr?.Delegate = self
        
        AddKVPData("Program", Versioning.ApplicationName)
        AddKVPData("Version", Versioning.MakeVersionString())
        AddKVPData("Build", "\(Versioning.Build)")
    }
    
    var MPManager: MultiPeerManager
    {
        get
        {
            return MPMgr!
        }
    }
    
    override var representedObject: Any?
        {
        didSet
        {
            // Update the view, if already loaded.
        }
    }
    
    func AddLogMessage(Item: LogItem)
    {
        OperationQueue.main.addOperation
            {
            self.LogItems.append(Item)
                self.LogTable.reloadData()
                self.LogTable.scrollToEndOfDocument(self)
        }
    }
    
    func AddKVPData(_ Name: String, _ Value: String)
    {
        KVPItems.append(KVPItem(WithKey: Name, AndValue: Value))
        KVPTable.reloadData()
    }
    
    /// Add data to the KVP table. If the data is already present (determined by the ID),
    /// it is edited in place.
    ///
    /// - Parameters:
    ///   - ID: ID of the data to add.
    ///   - Name: Key name.
    ///   - Value: Value associated with the key.
    func AddKVPData(ID: UUID, _ Name: String, _ Value: String)
    {
        OperationQueue.main.addOperation
            {
                if let ItemIndex = self.KVPItems.firstIndex(where: {$0.ID == ID})
                {
                    self.KVPItems[ItemIndex].Key = Name
                    self.KVPItems[ItemIndex].Value = Value
                }
                else
                {
                    self.KVPItems.append(KVPItem(ID, WithKey: Name, AndValue: Value))
                }
                self.KVPTable.reloadData()
        }
    }
    
    func RemoveKVP(ItemID: UUID)
    {
        KVPItems.removeAll(where: {$0.ID == ItemID})
        KVPTable.reloadData()
    }
    
    func ClearKVPList()
    {
        KVPItems.removeAll()
        KVPTable.reloadData()
    }
    
    func ConnectedDeviceChanged(Manager: MultiPeerManager, ConnectedDevices: [MCPeerID], Changed: MCPeerID, NewState: MCSessionState)
    {
        let StateDescription = ["Not Connected", "Connecting", "Connected"][NewState.rawValue]
        let Item = LogItem(Text: "Device \(Changed.displayName) is \(StateDescription)")
        Item.HostName = "TDDump"
        AddLogMessage(Item: Item)
    }
    
    func ReceivedData(Manager: MultiPeerManager, Peer: MCPeerID, RawData: String)
    {
    }
    
    func InitializeTables()
    {
        InitializeKVPTable()
        InitializeLogTable()
    }
    
    var LogItems = [LogItem]()
    var KVPItems = [KVPItem]()
//    var KVPItems = [(String, String)]()
//    var LogItems = [(String, String, String)]()
    
    func PopulateTuple(ItemCount: Int) -> (String?, String?, String?, String?)
    {
        let Count = ItemCount > 4 ? 4 : ItemCount
        var RS = [String]()
        
        for _ in 0 ..< Count
        {
            let CharCount: Int = [5, 15, 20, 25, 40, 50].randomElement()!
            var Working = ""
            for _ in 0 ..< CharCount
            {
                let RC = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"].randomElement()!
                Working = Working + RC
            }
            RS.append(Working)
        }
        
        switch Count
        {
        case 1:
            return (RS[0], nil, nil, nil)
            
        case 2:
            return (RS[0], RS[1], nil, nil)
            
        case 3:
            return (RS[0], RS[1], RS[2], nil)
            
        default:
            break
        }
        return (RS[0], RS[1], RS[2], RS[3])
    }
    
    func InitializeKVPTable()
    {
        #if false
        let RndCnt = [3, 5, 9, 15].randomElement()!
        for _ in 0 ..< RndCnt
        {
            let (E1, E2, _, _) = PopulateTuple(ItemCount: 2)
            KVPItems.append((E1!, E2!))
        }
        #endif
        KVPTable.delegate = self
        KVPTable.dataSource = self
        KVPTable.reloadData()
    }
    
    func InitializeLogTable()
    {
        #if false
        let RndCnt = [3, 5, 9, 15, 30, 50, 100].randomElement()!
        for _ in 0 ..< RndCnt
        {
            let (E1, E2, E3, _) = PopulateTuple(ItemCount: 3)
            LogItems.append((E1!, E2!, E3!))
        }
        #endif
        LogTable.delegate = self
        LogTable.dataSource = self
        LogTable.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView.tag
        {
        case KVPTableTag:
            return KVPItems.count
            
        case LogTableTag:
            return LogItems.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        switch tableView.tag
        {
        case KVPTableTag:
            var CellContents = ""
            var CellIdentifier = ""
            if tableColumn == tableView.tableColumns[0]
            {
                CellIdentifier = "KeyColumn"
                CellContents = KVPItems[row].Key
            }
            if tableColumn == tableView.tableColumns[1]
            {
                CellIdentifier = "ValueColumn"
                CellContents = KVPItems[row].Value
            }
            let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
            Cell?.textField?.stringValue = CellContents
            return Cell
            
        case LogTableTag:
            var CellContents = ""
            var CellIdentifier = ""
            if tableColumn == tableView.tableColumns[0]
            {
                CellIdentifier = "TimeColumn"
                CellContents = LogItems[row].Title
            }
            if tableColumn == tableView.tableColumns[1]
            {
                CellIdentifier = "SourceColumn"
                CellContents = LogItems[row].HostName ?? "{unknown}"
            }
            if tableColumn == tableView.tableColumns[2]
            {
                CellIdentifier = "MessageColumn"
                CellContents = LogItems[row].Message
            }
            let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
            Cell?.textField?.stringValue = CellContents
            return Cell
            
        default:
            return nil
        }
    }
    
    func InitializeIdiotLights()
    {
        IdiotLightContainer.fillColor = NSColor.clear
        
        InitializeIdiotLight(A1View, A1Text)
        InitializeIdiotLight(A2View, A2Text)
        InitializeIdiotLight(A3View, A3Text)
        InitializeIdiotLight(B1View, B1Text)
        InitializeIdiotLight(B2View, B2Text)
        InitializeIdiotLight(B3View, B3Text)
        InitializeIdiotLight(C1View, C1Text)
        InitializeIdiotLight(C2View, C2Text)
        InitializeIdiotLight(C3View, C3Text)
    }
    
    func InitializeIdiotLight(_ Light: NSView, _ Text: NSTextField)
    {
        Light.wantsLayer = true
        Light.layer?.borderColor = NSColor.black.cgColor
        Light.layer?.borderWidth = 0.5
        Light.layer?.cornerRadius = 5.0
        Light.layer?.backgroundColor = NSColor.white.cgColor
        Text.font = NSFont(name: "Avenir-Heavy", size: 15.0)
        Text.alignment = .center
    }
    
    /// Returns the name of the device. In this case, "name" means the name the user gave the device.
    ///
    /// - Returns: Name of the device.
    func GetDeviceName() -> String
    {
        var SysInfo = utsname()
        uname(&SysInfo)
        let Name = withUnsafePointer(to: &SysInfo.nodename.0)
        {
            ptr in
            return String(cString: ptr)
        }
        let Parts = Name.split(separator: ".")
        return String(Parts[0])
    }
    
    @IBOutlet weak var A1View: NSView!
    @IBOutlet weak var A2View: NSView!
    @IBOutlet weak var A3View: NSView!
    @IBOutlet weak var B1View: NSView!
    @IBOutlet weak var B2View: NSView!
    @IBOutlet weak var B3View: NSView!
    @IBOutlet weak var C1View: NSView!
    @IBOutlet weak var C2View: NSView!
    @IBOutlet weak var C3View: NSView!
    @IBOutlet weak var A1Text: NSTextField!
    @IBOutlet weak var A2Text: NSTextField!
    @IBOutlet weak var A3Text: NSTextField!
    @IBOutlet weak var B1Text: NSTextField!
    @IBOutlet weak var B2Text: NSTextField!
    @IBOutlet weak var B3Text: NSTextField!
    @IBOutlet weak var C1Text: NSTextField!
    @IBOutlet weak var C2Text: NSTextField!
    @IBOutlet weak var C3Text: NSTextField!
    
    @IBOutlet weak var LogTable: NSTableView!
    @IBOutlet weak var LogTableHeader: NSTableHeaderView!
    @IBOutlet weak var KVPTable: NSTableView!
    @IBOutlet weak var KVPTableHeader: NSTableHeaderView!
    
    @IBOutlet weak var IdiotLightContainer: NSBox!
}

