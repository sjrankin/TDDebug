//
//  MainController.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class MainController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    MultiPeerDelegate, MainProtocol, StateProtocol
{
    var HostNames: [String]? = nil
    
    let KVPTableTag = 100
    let LogTableTag = 300
    var MPMgr: MultiPeerManager!
    var LocalCommands: ClientCommands!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        State.Initialize(WithDelegate: self)
        InitializeUI()
        
        MPMgr = MultiPeerManager()
        MPMgr.Delegate = self
        
        LocalCommands = ClientCommands()
        
        KVPTable.delegate = self
        KVPTable.dataSource = self
        KVPTable.reloadData()
        
        LogTable.delegate = self
        LogTable.dataSource = self
        LogTable.reloadData()
        
        IdiotLightContainer.layer.cornerRadius = 5.0
        IdiotLightContainer.layer.borderWidth = 0.5
        IdiotLightContainer.layer.borderColor = UIColor.darkGray.cgColor
        LoadIdiotLights()
        
        AddKVPData("Program", Versioning.ApplicationName)
        AddKVPData("Version", Versioning.MakeVersionString(IncludeVersionSuffix: true, IncludeVersionPrefix: false))
        AddKVPData("Build", "\(Versioning.Build)")
        AddKVPData("This Host", GetDeviceName())
        let SomeItem = LogItem(ItemID: UUID(),
                               TimeStamp: MessageHelper.MakeTimeStamp(FromDate: Date()),
                               Text: Versioning.MakeVersionBlock() + "\n" + "Running on \(GetDeviceName())")
        SomeItem.HostName = "TDebug"
        SomeItem.BGColor = UIColor(named: "Lavender")
        LogList.append(SomeItem)
        
        SetIdiotLight("A", 1, "Not Connected", UIColor.white, UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0))
        EnableIdiotLight("A", 2, false)
        EnableIdiotLight("A", 3, false)
        EnableIdiotLight("B", 1, false)
        EnableIdiotLight("B", 2, false)
        EnableIdiotLight("B", 3, false)
        EnableIdiotLight("C", 1, false)
        EnableIdiotLight("C", 2, false)
        EnableIdiotLight("C", 3, false)
    }
    
    func StateChanged(NewState: States, HandShake: HandShakeCommands)
    {
        OperationQueue.main.addOperation
            {
                switch HandShake
                {
                case .ConnectionGranted:
                    self.SetIdiotLight("A", 1, "Connected", UIColor.black, UIColor.green)
                    
                case .Disconnected:
                    self.SetIdiotLight("A", 1, "Not Connected", UIColor.white, UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0))
                    
                default:
                    break
                }
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        IdiotLights["A1"] = (A1, A1Label)
        IdiotLights["A2"] = (A2, A2Label)
        IdiotLights["A3"] = (A3, A3Label)
        IdiotLights["B1"] = (B1, B1Label)
        IdiotLights["B2"] = (B2, B2Label)
        IdiotLights["B3"] = (B3, B3Label)
        IdiotLights["C1"] = (C1, C1Label)
        IdiotLights["C2"] = (C2, C2Label)
        IdiotLights["C3"] = (C3, C3Label)
    }
    
    var MPManager: MultiPeerManager
    {
        get
        {
            return MPMgr
        }
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
    
    func AddLogMessage(Item: LogItem)
    {
        OperationQueue.main.addOperation
            {
                self.LogList.append(Item)
                self.LogTable.reloadData()
                self.LogTable.scrollToRow(at: IndexPath(row: self.LogList.count - 1, section: 0),
                                          at: UITableView.ScrollPosition.bottom, animated: true)
        }
    }
    
    func ConnectedDeviceChanged(Manager: MultiPeerManager, ConnectedDevices: [MCPeerID], Changed: MCPeerID, NewState: MCSessionState)
    {
        let ChangedPeerName = Changed.displayName
        var NewStateName = ""
        switch NewState
        {
        case MCSessionState.notConnected:
            NewStateName = "Not Connected"
            
        case MCSessionState.connecting:
            NewStateName = "Connecting"
            
        case MCSessionState.connected:
            NewStateName = "Connected"
            
        default:
            NewStateName = "undetermined"
        }
        let Item = LogItem(Text: "Device \(ChangedPeerName) is now \(NewStateName).")
        AddLogMessage(Item: Item)
        AddKVPData(ID: ConnectCountID, "Peers", "\(ConnectedDevices.count)")
    }
    
    let ConnectCountID = UUID()
    
    func DelaySomething(_ BySeconds: Double, Closure: @escaping() -> ())
    {
        let When = DispatchTime.now() + BySeconds
        OperationQueue.main.addOperation
            {
                DispatchQueue.main.asyncAfter(deadline: When, execute: Closure)
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
                    Item.BGColor = UIColor(named: "Tomato")
                    Item.BGAnimateTargetColor = UIColor.white
                    Item.BGAnimateColorDuration = 2.0
                    Item.DoAnimateBGColor = true
                    self.LogList.append(Item)
                    self.LogTable.reloadData()
                    self.LogTable.scrollToRow(at: IndexPath(row: self.LogList.count - 1, section: 0),
                                              at: UITableView.ScrollPosition.bottom, animated: true)
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
                    self.IdiotLights[FinalAddress]!.0.backgroundColor = BGColor!
                    let CS: String = BGColor!.AsHexString()
                    print("BGColor for \(FinalAddress) = \(CS)")
                    
                case .SetFGColor:
                    self.IdiotLights[FinalAddress]!.1.textColor = FGColor!
                    let CS: String = FGColor!.AsHexString()
                    print("BGColor for \(FinalAddress) = \(CS)")
                    
                case .SetText:
                    self.IdiotLights[FinalAddress]!.1.text = Text
                    
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
        MPMgr.SendPreformatted(Message: Message, To: EchoBackTo)
        let Item = LogItem(Text: "Echoing message to \(EchoBackTo.displayName)")
        Item.HostName = "TDebug"
        Item.BGColor = UIColor(named: "Tomato")
        Item.BGAnimateTargetColor = UIColor(named: "Lavender")!
        Item.BGAnimateColorDuration = 2.0
        Item.DoAnimateBGColor = true
        LogList.append(Item)
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
                    self.KVPList.removeAll()
                    self.KVPTable.reloadData()
                    
                case .ClearLogList:
                    self.LogList.removeAll()
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
        WaitingFor.append((EncapsulatedID, MessageTypes.GetAllClientCommands))
    }
    
    var WaitingFor = [(UUID, MessageTypes)]()
    
    private var _ClientCommandList: [ClientCommand] = [ClientCommand]()
    var ClientCommandList: [ClientCommand]
    {
        get
        {
            return _ClientCommandList
        }
    }
    
    var _ConnectedClient: MCPeerID? = nil
    {
        didSet
        {
            if _ConnectedClient == nil
            {
                _ClientCommandList.removeAll()
            }
            else
            {
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
    }
    
    func HandleHandShakeCommand(_ Raw: String, Peer: MCPeerID)
    {
        let Command = MessageHelper.DecodeHandShakeCommand(Raw)
        print("Handshake command: \(Command)")
        var PostConnect = ""
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
                    let Item = LogItem(Text: "\(Peer.displayName) is debugee.")
                    self.AddLogMessage(Item: Item)
                    ReturnState = MessageHelper.MakeHandShake(ReturnMe)
                    PostConnect = MessageHelper.MakeSendVersionInfo()
                    
                case .ConnectionRefused:
                    let Item = LogItem(Text: "Connection refused by \(Peer.displayName)")
                    self.AddLogMessage(Item: Item)
                    ReturnState = MessageHelper.MakeHandShake(ReturnMe)
                    
                case .Disconnected:
                    ReturnState = MessageHelper.MakeHandShake(ReturnMe)
                    
                case .RequestConnection:
                    break
                    
                case .DropAsClient:
                    State.TransitionTo(NewState: .Disconnected)
                    break
                    
                case .Unknown:
                    break
                }
                if !ReturnState.isEmpty
                {
                    self.MPMgr.SendPreformatted(Message: ReturnState, To: Peer)
                    if !PostConnect.isEmpty
                    {
                        self.MPMgr.SendPreformatted(Message: PostConnect, To: Peer)
                    }
                }
        }
    }
    
    func HandleEchoReturn(_ Raw: String)
    {
        let (_, HostName, TimeStamp, FinalMessage) = MessageHelper.DecodeMessage(Raw)
        OperationQueue.main.addOperation
            {
                let Item = LogItem(TimeStamp: TimeStamp, Host: HostName, Text: "Echo returned: " + FinalMessage,
                                   ShowInitialAnimation: true, FinalBG: UIColor(named: "GrannySmith")!)
                self.AddLogMessage(Item: Item)
        }
    }
    
    func HandleTextMessage(_ Raw: String)
    {
        let (_, HostName, TimeStamp, FinalMessage) = MessageHelper.DecodeMessage(Raw)
        OperationQueue.main.addOperation
            {
                let Item = LogItem(TimeStamp: TimeStamp, Host: HostName, Text: FinalMessage, ShowInitialAnimation: true,
                                   FinalBG: UIColor.white)
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
    
    func InitializeUI()
    {
        KVPTable.layer.cornerRadius = 5.0
        KVPTable.layer.borderColor = UIColor.black.cgColor
        KVPTable.layer.borderWidth = 0.5
        
        LogTable.layer.cornerRadius = 5.0
        LogTable.layer.borderColor = UIColor.black.cgColor
        LogTable.layer.borderWidth = 0.5
    }
    
    func GetKVPByID(_ ID: UUID) -> KVPItem?
    {
        for Item in KVPList
        {
            if Item.ID == ID
            {
                return Item
            }
        }
        return nil
    }
    
    func AddKVPData(_ Name: String, _ Value: String)
    {
        KVPList.append(KVPItem(WithKey: Name, AndValue: Value))
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
                if let ItemIndex = self.KVPList.firstIndex(where: {$0.ID == ID})
                {
                    self.KVPList[ItemIndex].Key = Name
                    self.KVPList[ItemIndex].Value = Value
                }
                else
                {
                    self.KVPList.append(KVPItem(ID, WithKey: Name, AndValue: Value))
                }
                self.KVPTable.reloadData()
        }
    }
    
    func RemoveKVP(ItemID: UUID)
    {
        KVPList.removeAll(where: {$0.ID == ItemID})
        KVPTable.reloadData()
    }
    
    func ClearKVPList()
    {
        KVPList.removeAll()
        KVPTable.reloadData()
    }
    
    func EnableIdiotLight(_ Address: String, _ DoEnable: Bool,
                          _ EnableFGColor: UIColor = UIColor.black,
                          _ EnableBGColor: UIColor = UIColor.white)
    {
        if DoEnable
        {
            UIView.animate(withDuration: 0.2, animations:
                {
                    self.IdiotLights[Address]!.0.backgroundColor = EnableBGColor
                    self.IdiotLights[Address]!.1.textColor = EnableFGColor
            })
        }
        else
        {
            UIView.animate(withDuration: 0.35, animations:
                {
                    self.IdiotLights[Address]!.0.backgroundColor = UIColor.white
                    self.IdiotLights[Address]!.1.textColor = UIColor.clear
            })
        }
    }
    
    func EnableIdiotLight(_ Row: String, _ Column: Int, _ DoEnable: Bool,
                          _ EnableFGColor: UIColor = UIColor.black,
                          _ EnableBGColor: UIColor = UIColor.white)
    {
        if DoEnable
        {
            UIView.animate(withDuration: 0.2, animations:
                {
                    self.IdiotLightAt(Row, Column)!.1.textColor = EnableFGColor
                    self.IdiotLightAt(Row, Column)!.0.backgroundColor = EnableBGColor
            })
        }
        else
        {
            UIView.animate(withDuration: 0.35, animations:
                {
                    self.IdiotLightAt(Row, Column)!.1.textColor = UIColor.clear
                    self.IdiotLightAt(Row, Column)!.0.backgroundColor = UIColor.white
            })
        }
    }
    
    func IdiotLightAt(_ Row: String, _ Column: Int) -> (UIView, UILabel)?
    {
        for (IRow, IColumn, IView, ILabel) in IdiotLightTable
        {
            if IRow == Row && IColumn == Column
            {
                return (IView, ILabel)
            }
        }
        return nil
    }
    
    func LoadIdiotLights()
    {
        InitializeIdiotLight("A", 1, View: A1, Label: A1Label)
        InitializeIdiotLight("A", 2, View: A2, Label: A2Label)
        InitializeIdiotLight("A", 3, View: A3, Label: A3Label)
        InitializeIdiotLight("B", 1, View: B1, Label: B1Label)
        InitializeIdiotLight("B", 2, View: B2, Label: B2Label)
        InitializeIdiotLight("B", 3, View: B3, Label: B3Label)
        InitializeIdiotLight("C", 1, View: C1, Label: C1Label)
        InitializeIdiotLight("C", 2, View: C2, Label: C2Label)
        InitializeIdiotLight("C", 3, View: C3, Label: C3Label)
    }
    
    func InitializeIdiotLight(_ Row: String, _ Column: Int, View: UIView, Label: UILabel)
    {
        View.layer.cornerRadius = 5.0
        View.layer.borderColor = UIColor.black.cgColor
        View.layer.borderWidth = 0.5
        View.backgroundColor = UIColor.white
        Label.textColor = UIColor.black
        IdiotLightTable.append((Row, Column, View, Label))
    }
    
    var IdiotLightTable = [(String, Int, UIView, UILabel)]()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch tableView.tag
        {
        case KVPTableTag:
            return IDTableCell.CellHeight
            
        case LogTableTag:
            return LogTableCell.CellHeight
            
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView.tag
        {
        case KVPTableTag:
            return KVPList.count
            
        case LogTableTag:
            return LogList.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView.tag
        {
        case KVPTableTag:
            return MakeIDCell(indexPath.row)
            
        case LogTableTag:
            return MakeLogCell(indexPath.row)
            
        default:
            return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "UnexpectedTableTag")
        }
    }
    
    var TappedLogItemID: UUID!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView.tag == LogTableTag
        {
            TappedLogItemID = LogList[indexPath.row].ID!
            performSegue(withIdentifier: "ToLogItemViewer", sender: self)
        }
    }
    
    func MakeIDCell(_ Row: Int) -> UITableViewCell
    {
        let IDCell = IDTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "IDTableCell")
        IDCell.SetData(Name: KVPList[Row].Key, Value: KVPList[Row].Value)
        return IDCell
    }
    
    func MakeLogCell(_ Row: Int) -> UITableViewCell
    {
        let LogCell = LogTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "LogTableCell")
        LogCell.SetData(Item: LogList[Row])
        return LogCell
    }
    
    func SetIdiotLight(_ Row: String, _ Column: Int, _ Text: String, _ TextColor: UIColor = UIColor.black,
                       _ BGColor: UIColor = UIColor.white)
    {
        EnableIdiotLight(Row, Column, true)
        IdiotLightAt(Row, Column)!.0.backgroundColor = BGColor
        IdiotLightAt(Row, Column)!.1.textColor = TextColor
        IdiotLightAt(Row, Column)!.1.text = Text
    }
    
    @IBAction func HandleClearLogButton(_ sender: Any)
    {
        let Alert = UIAlertController(title: "Clear Log Display?",
                                      message: "Do you really want to clear the contents of the log? You can save the log first if you want.",
                                      preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: HandleClearLogButtonAction))
        Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: HandleClearLogButtonAction))
        present(Alert, animated: true)
    }
    
    @objc func HandleClearLogButtonAction(Alert: UIAlertAction)
    {
        switch Alert.title
        {
        case "OK":
            LogList.removeAll()
            LogTable.reloadData()
            
        default:
            break
        }
    }
    
    @IBAction func HandleDisconnectButton(_ sender: Any)
    {
        let Alert = UIAlertController(title: "Really Disconnect?",
                                      message: "Do you really want to disconnect from the remote process?",
                                      preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: HandleDisconnectAction))
        Alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: HandleDisconnectAction))
    }
    
    @objc func HandleDisconnectAction(Alert: UIAlertAction)
    {
        switch Alert.title
        {
        case "Yes":
            //disconnect here
            break
            
        default:
            break
        }
    }
    
    @IBAction func HandlePauseButton(_ sender: Any)
    {
    }
    
    @IBAction func HandleActionButton(_ sender: Any)
    {
    }
    
    func GetLogItem(_ FromID: UUID) -> LogItem
    {
        for Item in LogList
        {
            if Item.ID! == FromID
            {
                return Item
            }
        }
        fatalError("Could not find log item even though it should be present.")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToLogItemViewer":
            if let Dest = segue.destination as? LogItemViewerCode
            {
                Dest.DisplayItem = GetLogItem(TappedLogItemID)
            }
            
        case "SendToRemote":
            if let Dest = segue.destination as? SendToRemoteCode
            {
                Dest.Main = self
            }
            
        case "ToClientTest":
            if let Dest = segue.destination as? ClientTestUICode
            {
                Dest.Main = self
            }
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: self)
    }
    
    @IBAction func HandleTestButton(_ sender: Any)
    {
        #if true
        MPMgr.Broadcast(Message: "Test \(TestCount)")
        TestCount = TestCount + 1
        #else
        if CurrentHost.isEmpty
        {
            MustSelectHostFirst()
            return
        }
        TComm.ConnectToRemote(CurrentServer!)
        TComm.Broadcast(Message: "Test \(TestCount)")
        TestCount = TestCount + 1
        #endif
    }
    
    var TestCount: Int = 1
    
    func MustSelectHostFirst()
    {
        let Alert = UIAlertController(title: "No Host", message: "You must select a host first.", preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(Alert, animated: true)
    }
    
    func ConvertToNetworkName(_ Raw: String) -> String
    {
        return Raw.replacingOccurrences(of: " ", with: "-")
    }
    
    @IBAction func HandleDumpPeers(_ sender: Any)
    {
        let ServerList = MPMgr.GetPeerList()
        let Button = sender as? UIBarButtonItem
        
        let ThisDevice = ConvertToNetworkName(GetDeviceName())
        let Alert = UIAlertController(title: "Server List",
                                      message: "Current list of peers that are advertising.",
                                      preferredStyle: UIAlertController.Style.actionSheet)
        for Index in 0 ..< ServerList.count
        {
            var IsSelf = false
            if ConvertToNetworkName(ServerList[Index].displayName) == ThisDevice
            {
                IsSelf = true
            }
            let Title = ServerList[Index].displayName
            let AAction = UIAlertAction(title: Title, style: UIAlertAction.Style.default, handler: nil)
            Alert.addAction(AAction)
            if IsSelf
            {
                Alert.actions[Index].isEnabled = false
                Alert.actions[Index].setValue(UIColor.darkGray, forKey: "titleTextColor")
            }
        }
        Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        let Presenter = Alert.popoverPresentationController
        Presenter?.barButtonItem = Button
        present(Alert, animated: true, completion: nil)
    }
    
    var KVPList = [KVPItem]()
    var LogList = [LogItem]()
    
    var IdiotLights = [String: (UIView, UILabel)]()
    
    @IBOutlet weak var A1Label: UILabel!
    @IBOutlet weak var A2Label: UILabel!
    @IBOutlet weak var A3Label: UILabel!
    @IBOutlet weak var B1Label: UILabel!
    @IBOutlet weak var B2Label: UILabel!
    @IBOutlet weak var B3Label: UILabel!
    @IBOutlet weak var C1Label: UILabel!
    @IBOutlet weak var C2Label: UILabel!
    @IBOutlet weak var C3Label: UILabel!
    @IBOutlet weak var A1: UIView!
    @IBOutlet weak var A2: UIView!
    @IBOutlet weak var A3: UIView!
    @IBOutlet weak var B1: UIView!
    @IBOutlet weak var B2: UIView!
    @IBOutlet weak var B3: UIView!
    @IBOutlet weak var C1: UIView!
    @IBOutlet weak var C2: UIView!
    @IBOutlet weak var C3: UIView!
    @IBOutlet weak var IdiotLightContainer: UIView!
    @IBOutlet weak var KVPTable: UITableView!
    @IBOutlet weak var LogTable: UITableView!
}
