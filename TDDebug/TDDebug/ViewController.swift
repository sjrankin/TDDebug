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

/// Code to run the main view controller for TDDebug.
class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, MultiPeerDelegate, MainProtocol, StateProtocol
{
    let KVPTableTag = 100
    let LogTableTag = 200
    var MPMgr: MultiPeerManager!
    var LocalCommands: ClientCommands!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        State.Initialize(WithDelegate: self)
        
        InitializeIdiotLights()
        InitializeTables()
        
        MPMgr = MultiPeerManager()
        MPMgr.Delegate = self
        
        LocalCommands = ClientCommands()
        
        AddKVPData("Program", Versioning.ApplicationName)
        AddKVPData("Version", Versioning.MakeVersionString())
        AddKVPData("Build", "\(Versioning.Build)")
    }
    
    override func viewDidLayout()
    {
        super.viewDidLayout()
        IdiotLights["A1"] = (A1View, A1Text)
        IdiotLights["A2"] = (A2View, A2Text)
        IdiotLights["A3"] = (A3View, A3Text)
        IdiotLights["B1"] = (B1View, B1Text)
        IdiotLights["B2"] = (B2View, B2Text)
        IdiotLights["B3"] = (B3View, B3Text)
        IdiotLights["C1"] = (C1View, C1Text)
        IdiotLights["C2"] = (C2View, C2Text)
        IdiotLights["C3"] = (C3View, C3Text)
        
        SetIdiotLightA1(ToState: .NotConnected)
        EnableIdiotLight("A2", false)
        EnableIdiotLight("A3", false)
        EnableIdiotLight("B1", false)
        EnableIdiotLight("B2", false)
        EnableIdiotLight("B3", false)
        EnableIdiotLight("C1", false)
        EnableIdiotLight("C2", false)
        EnableIdiotLight("C3", false)
    }
    
    var IdiotLights = [String: (NSView, NSTextField)]()
    
    var MPManager: MultiPeerManager
    {
        get
        {
            return MPMgr!
        }
    }
    
    private var _ClientCommandList: [ClientCommand] = [ClientCommand]()
    var ClientCommandList: [ClientCommand]
    {
        get
        {
            return _ClientCommandList
        }
    }
    
    override var representedObject: Any?
        {
        didSet
        {
            // Update the view, if already loaded.
        }
    }
    
    func StateChanged(NewState: States, HandShake: HandShakeCommands)
    {
        OperationQueue.main.addOperation
            {
                switch HandShake
                {
                case .ConnectionGranted:
                    self.SetIdiotLightA1(ToState: .Connected)
                    //                    self.SetIdiotLight("A1", "Connected", NSColor.black, NSColor.green)
                    
                case .Disconnected:
                    self.SetIdiotLightA1(ToState: .PeersFound)
                    //                    self.SetIdiotLight("A1", "Not Connected", NSColor.white, NSColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0))
                    
                default:
                    break
                }
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
        if Changed == _ConnectedClient && NewState == .notConnected
        {
            _ConnectedClient = nil
            State.TransitionTo(NewState: .Disconnected)
            SetIdiotLightA1(ToState: .PeersFound)
        }
        if ConnectedDevices.count < 1
        {
            SetIdiotLightA1(ToState: .NoPeers)
        }
        else
        {
            SetIdiotLightA1(ToState: .PeersFound)
        }
    }
    
    func DisplayHeartbeatData(_ Raw: String, TimeStamp: String, Host: String, Peer: MCPeerID)
    {
        if let (NextExpected, Payload) = MessageHelper.DecodeHeartbeat(Raw)
        {
            OperationQueue.main.addOperation
                {
                    var HBMessage = "Received heartbeat. Next expected in \(NextExpected) seconds."
                    if let FinalPayload = Payload
                    {
                        HBMessage = HBMessage + "\n" + FinalPayload
                    }
                    let Item = LogItem(TimeStamp: TimeStamp, Host: Host, Text: HBMessage)
                    self.AddLogMessage(Item: Item)
            }
        }
    }
    
    func ControlIdiotLight(_ Raw: String)
    {
        OperationQueue.main.addOperation
            {
                let (Command, Address, Text, FGColor, BGColor) = MessageHelper.DecodeIdiotLightMessage(Raw)
                let FinalAddress = Address.uppercased()
                print("Controlling idiot light at \(Address)")
                switch Command
                {
                case .Disable:
                    self.EnableIdiotLight(FinalAddress, false)
                    
                case .Enable:
                    self.EnableIdiotLight(FinalAddress, true)
                    
                case .SetBGColor:
                    self.IdiotLights[FinalAddress]!.0.layer?.backgroundColor = BGColor?.cgColor
                    let CS: String = BGColor!.AsHexString()
                    print("BGColor for \(FinalAddress) = \(CS)")
                    
                case .SetFGColor:
                    self.IdiotLights[FinalAddress]!.1.textColor = FGColor!
                    let CS: String = FGColor!.AsHexString()
                    print("BGColor for \(FinalAddress) = \(CS)")
                    
                case .SetText:
                    self.IdiotLights[FinalAddress]!.1.stringValue = Text!
                    
                default:
                    return
                }
        }
    }
    
    func DoEcho(Delay: Int, Message: String)
    {
        if EchoTimer != nil
        {
            EchoTimer.invalidate()
            EchoTimer = nil
        }
        MessageToEcho = Message
        EchoTimer = Timer.scheduledTimer(timeInterval: Double(Delay), target: self,
                                         selector: #selector(EchoSomething(_:)),
                                         userInfo: Message as Any?, repeats: false)
    }
    
    @objc func EchoSomething(_ Info: Any?)
    {
        let ReturnToSender = MessageToEcho//Info as? String
        let Message = MessageHelper.MakeMessage(WithType: .EchoReturn, ReturnToSender!, GetDeviceName())
        MPMgr!.SendPreformatted(Message: Message, To: EchoBackTo)
        let Item = LogItem(Text: "Echoing message to \(EchoBackTo.displayName)")
        Item.HostName = "TDebug"
        AddLogMessage(Item: Item)
    }
    
    var EchoTimer: Timer!
    var EchoBackTo: MCPeerID!
    var MessageToEcho: String!
    
    func HandleEchoMessage(_ Raw: String, Peer: MCPeerID)
    {
        let (EchoMessage, _, Delay, _) = MessageHelper.DecodeEchoMessage(Raw)
        print("HandleEchoMessage: Delay=\(Delay)")
        let REchoMessage = String(EchoMessage.reversed())
        EchoBackTo = Peer
        OperationQueue.main.addOperation
            {
                print("Echoing \(REchoMessage) to \(self.EchoBackTo.displayName) in \(Delay) seconds")
                self.DoEcho(Delay: Delay, Message: REchoMessage)
        }
    }
    
    func ManageKVPData(_ Raw: String, Peer: MCPeerID)
    {
        OperationQueue.main.addOperation
            {
                let (ID, Key, Value) = MessageHelper.DecodeKVPMessage(Raw)
                print("Received KVP \(Key):\(Value)")
                if ID == nil
                {
                    let TimeStamp = MessageHelper.MakeTimeStamp(FromDate: Date())
                    let Message = "Received KVP with Key of \"\(Key)\" and value of \"\(Value)\" but no valid ID."
                    let Item = LogItem(TimeStamp: TimeStamp, Host: Peer.displayName, Text: Message, ShowInitialAnimation: true)
                    self.AddLogMessage(Item: Item)
                    return
                }
                self.AddKVPData(ID: ID!, Key, Value)
        }
    }
    
    func HandleSpecialCommand(_ Raw: String, Peer: MCPeerID)
    {
        OperationQueue.main.addOperation
            {
                let Operation = MessageHelper.DecodeSpecialCommand(Raw)
                switch Operation
                {
                case .ClearIdiotLights:
                    self.EnableIdiotLight("A2", false)
                    self.EnableIdiotLight("A3", false)
                    self.EnableIdiotLight("B1", false)
                    self.EnableIdiotLight("B2", false)
                    self.EnableIdiotLight("B3", false)
                    self.EnableIdiotLight("C1", false)
                    self.EnableIdiotLight("C2", false)
                    self.EnableIdiotLight("C3", false)
                    
                case .ClearKVPList:
                    self.KVPItems.removeAll()
                    self.KVPTable.reloadData()
                    
                case .ClearLogList:
                    self.LogItems.removeAll()
                    self.LogTable.reloadData()
                    
                default:
                    break
                }
        }
    }
    
    func GetCommandsFromClient(_ Peer: MCPeerID)
    {
        let GetClientCmds = MessageHelper.MakeGetAllClientCommands()
        let EncapsulatedID = MPMgr.SendWithAsyncResponse(Message: GetClientCmds, To: Peer)
        print("GetCommands(EncapsulatedID)=\(EncapsulatedID.uuidString)")
        WaitingFor.append((EncapsulatedID, MessageTypes.GetAllClientCommands))
    }
    
    var WaitingFor = [(UUID, MessageTypes)]()
    
    var _ConnectedClient: MCPeerID? = nil
    {
        didSet
        {
            if _ConnectedClient == nil
            {
                print("Connected client reset - command list cleared.")
                _ClientCommandList.removeAll()
            }
            else
            {
                print("Set connected client - getting command list.")
                GetCommandsFromClient(_ConnectedClient!)
            }
        }
    }
    var ConnectedClient: MCPeerID?
    {
        get
        {
            return _ConnectedClient
        }
        set
        {
            _ConnectedClient = newValue
        }
    }
    
    func HandleHandShakeCommand(_ Raw: String, Peer: MCPeerID)
    {
        let Command = MessageHelper.DecodeHandShakeCommand(Raw)
        print("Handshake command: \(Command)")
        OperationQueue.main.addOperation
            {
                let ReturnMe = State.TransitionTo(NewState: Command)
                print("State result=\(ReturnMe), State.CurrentState=\(State.CurrentState)")
                var ReturnState = ""
                switch ReturnMe
                {
                case .ConnectionClose:
                    break
                    
                case .ConnectionGranted:
                    self._ConnectedClient = Peer
                    let Item = LogItem(Text: "\(Peer.displayName) is debug client.")
                    Item.HostName = "TDDebug"
                    self.AddLogMessage(Item: Item)
                    ReturnState = MessageHelper.MakeHandShake(ReturnMe)
                    
                case .ConnectionRefused:
                    let Item = LogItem(Text: "Connection refused by \(Peer.displayName)")
                    self.AddLogMessage(Item: Item)
                    ReturnState = MessageHelper.MakeHandShake(ReturnMe)
                    
                case .Disconnected:
                    self._ConnectedClient = nil
                    ReturnState = MessageHelper.MakeHandShake(ReturnMe)
                    
                case .RequestConnection:
                    break
                    
                case .DropAsClient:
                    let Item = LogItem(Text: "Dropped as client by \(Peer.displayName)")
                    self.AddLogMessage(Item: Item)
                    State.TransitionTo(NewState: .Disconnected)
                    
                case .Unknown:
                    break
                }
                if !ReturnState.isEmpty
                {
                    self.MPMgr!.SendPreformatted(Message: ReturnState, To: Peer)
                }
        }
    }
    
    func HandleEchoReturn(_ Raw: String)
    {
        let (_, HostName, TimeStamp, FinalMessage) = MessageHelper.DecodeMessage(Raw)
        OperationQueue.main.addOperation
            {
                let Item = LogItem(TimeStamp: TimeStamp, Host: HostName, Text: "Echo returned: " + FinalMessage,
                                   ShowInitialAnimation: true, FinalBG: NSColor.green)
                self.AddLogMessage(Item: Item)
        }
    }
    
    func HandleTextMessage(_ Raw: String)
    {
        let (_, HostName, TimeStamp, FinalMessage) = MessageHelper.DecodeMessage(Raw)
        OperationQueue.main.addOperation
            {
                let Item = LogItem(TimeStamp: TimeStamp, Host: HostName, Text: FinalMessage, ShowInitialAnimation: true,
                                   FinalBG: NSColor.white)
                self.AddLogMessage(Item: Item)
        }
    }
    
    func SendClientCommandList(Peer: MCPeerID, CommandID: UUID)
    {
        let AllCommands = MessageHelper.MakeAllClientCommands(Commands: LocalCommands)
        let EncapsulatedReturn = MessageHelper.MakeEncapsulatedCommand(WithID: CommandID, Payload: AllCommands)
        MPMgr.SendPreformatted(Message: EncapsulatedReturn, To: Peer)
    }
    
    func ReceivedData(Manager: MultiPeerManager, Peer: MCPeerID, RawData: String,
                      OverrideMessageType: MessageTypes? = nil, EncapsulatedID: UUID? = nil)
    {
        var MessageType: MessageTypes = .Unknown
        if let OverrideMe = OverrideMessageType
        {
            MessageType = OverrideMe
        }
        else
        {
            MessageType = MessageHelper.GetMessageType(RawData)
        }
        print("MessageType=\(MessageType)")
        switch MessageType
        {
        case .HandShake:
            HandleHandShakeCommand(RawData, Peer: Peer)
            
        case .SpecialCommand:
            HandleSpecialCommand(RawData, Peer: Peer)
            
        case .EchoMessage:
            //Should be handled by the instance that received the echo.
            HandleEchoMessage(RawData, Peer: Peer)
            
        case .Heartbeat:
            let (_, HostName, TimeStamp, FinalMessage) = MessageHelper.DecodeMessage(RawData)
            DisplayHeartbeatData(FinalMessage, TimeStamp: TimeStamp, Host: HostName, Peer: Peer)
            
        case .ControlIdiotLight:
            ControlIdiotLight(RawData)
            
        case .KVPData:
            ManageKVPData(RawData, Peer: Peer)
            
        case .EchoReturn:
            //Should be handled by the instance that sent the echo in the first place.
            HandleEchoReturn(RawData)
            
        case .TextMessage:
            HandleTextMessage(RawData)
            
        case .GetAllClientCommands:
            SendClientCommandList(Peer: Peer, CommandID: EncapsulatedID!)
            
        default:
            print("Unhandled message type: \(MessageType)")
            break
        }
    }
    
    func ProcessAsyncResult(CommandID: UUID, Peer: MCPeerID, MessageType: MessageTypes, RawData: String)
    {
        WaitingFor.removeAll(where: {$0.0 == CommandID})
        print("RawData=\(RawData)")
    }
    
    func ReceivedAsyncData(Manager: MultiPeerManager, Peer: MCPeerID, CommandID: UUID, RawData: String)
    {
        print("Received async response from ID: \(CommandID).")
        for (ID, MessageType) in WaitingFor
        {
            if ID == CommandID
            {
                //Handle the asynchronous response here - be sure to return after handling it and to not
                //drop through the bottom of the loop.
                print("Found matching response for \(MessageType) command.")
                ProcessAsyncResult(CommandID: CommandID, Peer: Peer, MessageType: MessageType, RawData: RawData)
                return
            }
        }
        
        //If we're here, we most likely received an encapsulated command.
        if let MessageType = MessageHelper.MessageTypeFromString(RawData)
        {
            print("Bottom of ReceivedAsyncData: MessageType=\(MessageType), RawData=\(RawData)")
            ReceivedData(Manager: Manager, Peer: Peer, RawData: RawData,
                         OverrideMessageType: MessageType, EncapsulatedID: CommandID)
        }
        else
        {
            print("Unknown message type found: \(RawData)")
        }
    }
    
    func EnableIdiotLight(_ Address: String, _ DoEnable: Bool,
                          _ EnableFGColor: NSColor = NSColor.black,
                          _ EnableBGColor: NSColor = NSColor.white)
    {
        OperationQueue.main.addOperation
            {
                self.IdiotLights[Address]!.0.layer?.backgroundColor = DoEnable ? EnableBGColor.cgColor : NSColor.white.cgColor
                self.IdiotLights[Address]!.1.textColor = DoEnable ? EnableFGColor : NSColor.clear
        }
    }
    
    func SetIdiotLight(_ Address: String, _ Text: String, _ TextColor: NSColor = NSColor.black,
                       _ BGColor: NSColor = NSColor.white)
    {
        OperationQueue.main.addOperation
            {
                self.IdiotLights[Address]!.0.layer?.backgroundColor = BGColor.cgColor
                self.IdiotLights[Address]!.1.textColor = TextColor
                self.IdiotLights[Address]!.1.stringValue = Text
        }
    }
    
    func SetIdiotLightA1(ToState: A1States)
    {
        OperationQueue.main.addOperation {
            switch ToState
            {
            case .NotConnected:
                self.SetIdiotLight("A1", "Not Connected", OSColor.black, OSColor.white)
                
            case .Connected:
                self.SetIdiotLight("A1", "Connected to Client", OSColor.black, OSColor.green)
                
            case .NoPeers:
                self.SetIdiotLight("A1", "No Peers", OSColor.black, OSColor.lightGray)
                
            case .PeersFound:
                self.SetIdiotLight("A1", "Peers Available", OSColor.white, OSColor.purple)
            }
        }
    }
    
    enum A1States
    {
        case NotConnected
        case PeersFound
        case NoPeers
        case Connected
    }
    
    func InitializeTables()
    {
        InitializeKVPTable()
        InitializeLogTable()
    }
    
    var LogItems = [LogItem]()
    var KVPItems = [KVPItem]()
    
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
        KVPTable.delegate = self
        KVPTable.dataSource = self
        KVPTable.reloadData()
    }
    
    func InitializeLogTable()
    {
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
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int)
    {
        switch tableView.tag
        {
        case LogTableTag:
            rowView.backgroundColor = OSColor.MakeRandomColor(.Light)
            
        default:
            return
        }
    }
    
    func InitializeIdiotLights()
    {
        IdiotLightContainer.fillColor = NSColor.clear
        
        InitializeIdiotLight(A1View, A1Text, IsA1: true)
        InitializeIdiotLight(A2View, A2Text)
        InitializeIdiotLight(A3View, A3Text)
        InitializeIdiotLight(B1View, B1Text)
        InitializeIdiotLight(B2View, B2Text)
        InitializeIdiotLight(B3View, B3Text)
        InitializeIdiotLight(C1View, C1Text)
        InitializeIdiotLight(C2View, C2Text)
        InitializeIdiotLight(C3View, C3Text)
    }
    
    func InitializeIdiotLight(_ Light: NSView, _ Text: NSTextField, IsA1: Bool = false)
    {
        Light.wantsLayer = true
        Light.layer?.borderColor = NSColor.black.cgColor
        Light.layer?.borderWidth = IsA1 ? 2.0 : 0.5
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
    
    var PeerViewerController: NSWindowController? = nil
    
    func DoShowPeers()
    {
        if PeerViewerController == nil
        {
            let Storyboard = NSStoryboard(name: "Main", bundle: nil)
            PeerViewerController = Storyboard.instantiateController(withIdentifier: "PeerViewerUI") as? PeerViewerUIWindow
        }
        if let PVC = PeerViewerController as? PeerViewerUIWindow
        {
            PVC.MainDelegate = self
            PVC.showWindow(nil)
        }
    }
    
    //https://stackoverflow.com/questions/24694587/osx-storyboards-open-non-modal-window-with-standard-segue
    @IBAction func HandleShowCurrentPeers(_ sender: Any)
    {
        DoShowPeers()
    }
    
    var SendToController: NSWindowController? = nil
    
    func DoSendToClient()
    {
        if SendToController == nil
        {
            let Storyboard = NSStoryboard(name: "Main", bundle: nil)
            SendToController = Storyboard.instantiateController(withIdentifier: "SendToClientWindow") as? SendToClientUIWindow
        }
        if let SVC = SendToController as? SendToClientUIWindow
        {
            SVC.MainDelegate = self
            SVC.showWindow(nil)
        }
    }
    
    @IBAction func HandleSendToClient(_ sender: Any)
    {
        DoSendToClient()
    }
    
    func DoDisconnectFromClient()
    {
        if ConnectedClient == nil
        {
            print("No one to drop.")
            return
        }
        let DroppedClientName: String = (ConnectedClient?.displayName)!
        print("Dropping \(DroppedClientName) as client.")
        let Disconnect = MessageHelper.MakeHandShake(.DropAsClient)
        MPMgr.SendPreformatted(Message: Disconnect, To: ConnectedClient!)
        _ConnectedClient = nil
        State.TransitionTo(NewState: .Disconnected)
        SetIdiotLightA1(ToState: .PeersFound)
        let Item = LogItem(Text: "Dropped \(DroppedClientName) as debug client.")
        Item.HostName = "TDDump"
        AddLogMessage(Item: Item)
    }
    
    @IBAction func DisconnectFromDebuggee(_ sender: Any)
    {
        DoDisconnectFromClient()
    }
    
    func DoShowHelp()
    {
        
    }
    
    @IBAction func ShowHelp(_ sender: Any)
    {
        DoShowHelp()
    }
    
    func DoCustomize()
    {
        
    }
    
    @IBAction func RunCustomization(_ sender: Any)
    {
        
    }
    
    func DoShowAbout()
    {
        let Storyboard = NSStoryboard(name: "AboutTDDebug", bundle: nil)
        let AboutController = Storyboard.instantiateController(withIdentifier: "AboutTDDebugWindow") as? NSWindowController
        AboutController?.showWindow(nil)
    }
    
    @IBAction func AboutTDDebug(_ sender: Any)
    {
        DoShowAbout()
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

