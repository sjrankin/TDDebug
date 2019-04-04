//
//  ClientTestUICode.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class ClientTestUICode: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate,
    UIPickerViewDataSource
{
    let IdiotLightAddresses = 100
    let IdiotLightCommands = 200
    let ServerMessageTableTag = 200
    weak var Main: MainProtocol? = nil
    var MPMgr: MultiPeerManager? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        MPMgr = Main?.MPManager
        ServerList = (MPMgr?.GetPeerList())!
        if ServerList.count > 0
        {
            print("In ClientTestUICode.viewDidLoad:")
            for PeerID in ServerList
            {
                print(" Initial peer: \(PeerID.displayName)")
            }
        }
        else
        {
            print("No peers loaded at start up.")
        }
        
        KVPValue.text = KVPID.uuidString
        
        ServerMessageTable.layer.cornerRadius = 5.0
        ServerMessageTable.layer.borderColor = UIColor.black.cgColor
        ServerMessageTable.layer.borderWidth = 0.5
        IdiotLightPicker.layer.cornerRadius = 5.0
        IdiotLightPicker.layer.borderWidth = 0.5
        IdiotLightPicker.layer.borderColor = UIColor.black.cgColor
        IdiotLightCommandPicker.layer.cornerRadius = 5.0
        IdiotLightCommandPicker.layer.borderWidth = 0.5
        IdiotLightCommandPicker.layer.borderColor = UIColor.black.cgColor
        
        IdiotLightPicker.delegate = self
        IdiotLightPicker.dataSource = self
        IdiotLightPicker.reloadAllComponents()
        IdiotLightCommandPicker.delegate = self
        IdiotLightCommandPicker.dataSource = self
        IdiotLightCommandPicker.reloadAllComponents()
        
        ServerMessageTable.delegate = self
        ServerMessageTable.dataSource = self
        ServerMessageTable.reloadData()
    }
    
    override func viewDidLayoutSubviews()
    {
        BusyIndicator.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if CurrentHostIndex > -1
        {
            let Disconnect = MessageHelper.MakeHandShake(.ConnectionClose)
            MPMgr?.SendPreformatted(Message: Disconnect, To: ServerList[CurrentHostIndex])
        }
        super.viewWillDisappear(animated)
    }
    
    var ServerList = [MCPeerID]()
    var MessageList = [String]()
    var IdiotLightList = ["A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"]
    var IdiotCommands = ["Disable", "Enable", "Text", "FGColor", "BGColor"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag
        {
        case IdiotLightCommands:
            return IdiotCommands.count
            
        case IdiotLightAddresses:
            return IdiotLightList.count
            
        default:
            break
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag
        {
        case IdiotLightAddresses:
            return IdiotLightList[row]
            
        case IdiotLightCommands:
            return IdiotCommands[row]
            
        default:
            break
        }
        return "{unexpected \(row)}"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView.tag
        {
        case ServerMessageTableTag:
            return MessageList.count
            
        default:
            return 0
        }
    }
    
    func MakeServerTableCell(ServerName: String) -> UITableViewCell
    {
        let Cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "ServerCell")
        Cell.textLabel!.text = ServerName
        return Cell
    }
    
    func MakeServerMessageTableCell(Message: String) -> UITableViewCell
    {
        let Cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "ServerMessageCell")
        Cell.textLabel!.text = Message
        return Cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView.tag
        {
        case ServerMessageTableTag:
            return MakeServerMessageTableCell(Message: MessageList[indexPath.row])
            
        default:
            break
        }
        return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "NotUsed")
    }
    
    @IBAction func HandleStartStopButton(_ sender: Any)
    {
        if IsRunning
        {
            IsRunning = false
            StartStopButton.title = "Start"
        }
        else
        {
            IsRunning = true
            StartStopButton.title = "Stop"
        }
    }
    
    func SetRunning(To: Bool)
    {
        
    }
    
    var IsRunning = false
    {
        didSet
        {
            SetRunning(To: IsRunning)
        }
    }
    
    @IBOutlet weak var StartStopButton: UIBarButtonItem!
    
    
    @IBOutlet weak var ServerMessageTable: UITableView!
    
    @IBAction func HandleBackButtonPressed(_ sender: Any)
    {
        IsRunning = false
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleHeartbeatPayloadChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleSendTextButtonPressed(_ sender: Any)
    {
        if let Message = SendTextBox.text
        {
            MPMgr?.Send(Message: Message, To: ServerList[CurrentHostIndex])
            SendTextBox.text = ""
        }
        else
        {
            print("No text to send.")
        }
    }
    
    @IBAction func HandleEchoButtonPressed(_ sender: Any)
    {
        if let Message = EchoTextBox.text
        {
            if Message.isEmpty
            {
                print("No message to echo.")
                return
            }
            let Delay = [0, 1, 5, 10, 30, 60][EchoDelaySegment.selectedSegmentIndex]
            let Count = [1, 2, 5, 10, Int.max][EchoCountSegment.selectedSegmentIndex]
            let FinalMessage = MessageHelper.MakeEchoMessage(Message: Message,
                                                             Delay: Delay,
                                                             Count: Count,
                                                             Host: ConvertToNetworkName(GetDeviceName()))
            MPMgr?.SendPreformatted(Message: FinalMessage, To: ServerList[CurrentHostIndex])
            if EchoTimer != nil
            {
                EchoTimer.invalidate()
                EchoTimer = nil
            }
            EchoCount = Count
            EchoedCount = 1
            EchoRepeater(FinalMessage as Any?)
            EchoTimer = Timer.scheduledTimer(timeInterval: Double(Delay), target: self,
                                             selector: #selector(EchoRepeater(_:)),
                                             userInfo: FinalMessage as Any?, repeats: true)
        }
    }
    
    var EchoedCount = 0
    var EchoCount = 0
    var EchoTimer: Timer!
    
    @objc func EchoRepeater(_ EchoInfo: Any?)
    {
        if EchoedCount >= EchoCount
        {
            EchoTimer.invalidate()
            EchoTimer = nil
            return
        }
        if let Message = EchoInfo as? String
        {
            MPMgr?.SendPreformatted(Message: Message, To: ServerList[CurrentHostIndex])
        }
        EchoedCount = EchoedCount + 1
    }
    
    @IBAction func HandleIdiotLightButtonPressed(_ sender: Any)
    {
        let AddressRow = IdiotLightPicker.selectedRow(inComponent: 0)
        let CommandRow = IdiotLightCommandPicker.selectedRow(inComponent: 0)
        let Address = IdiotLightList[AddressRow]
        let Command = IdiotCommands[CommandRow]
        var Message = ""
        switch Command
        {
        case "Text":
            Message = MessageHelper.MakeIdiotLightMessage(Address: Address, Text: "Idiot Light \(IdiotLightTextIndex)")
            IdiotLightTextIndex = IdiotLightTextIndex + 1
            
        case "Enable":
            Message = MessageHelper.MakeIdiotLightMessage(Address: Address, State: UIFeatureStates.Enabled)
            
        case "Disable":
            Message = MessageHelper.MakeIdiotLightMessage(Address: Address, State: UIFeatureStates.Disabled)
            
        case "FGColor":
            Message = MessageHelper.MakeIdiotLightMessage(Address: Address, FGColor: OSColor.MakeRandomColor(.Dark))
            
        case "BGColor":
            Message = MessageHelper.MakeIdiotLightMessage(Address: Address, BGColor: OSColor.MakeRandomColor(.Light))
        default:
            print("Unknown idiot light command received: \(Command).")
            return
        }
        MPMgr?.SendPreformatted(Message: Message, To: ServerList[CurrentHostIndex])
    }
    
    var IdiotLightTextIndex = 1
    
    func ConvertToNetworkName(_ Raw: String) -> String
    {
        return Raw.replacingOccurrences(of: " ", with: "-")
    }
    
    @IBAction func HandleServerButtonPressed(_ sender: Any)
    {
        BusyIndicator.isHidden = false
        if ServerList.count < 1
        {
            //search for servers first
            ServerList = (MPMgr?.GetPeerList())!
        }
        if ServerList.count < 1
        {
            ServerButton.title = "Server: none found"
            BusyIndicator.isHidden = true
            return
        }
        
        let Button = sender as? UIBarButtonItem
        
        let ThisDevice = ConvertToNetworkName(GetDeviceName())
        let Alert = UIAlertController(title: "Server List",
                                      message: "Select server to test.",
                                      preferredStyle: UIAlertController.Style.actionSheet)
        for Index in 0 ..< ServerList.count
        {
            var IsSelf = false
            print("\(ThisDevice): \(ConvertToNetworkName(ServerList[Index].displayName))")
            if ConvertToNetworkName(ServerList[Index].displayName) == ThisDevice
            {
                IsSelf = true
            }
            let Title = "\(Index + 1). " + ServerList[Index].displayName
            let AAction = UIAlertAction(title: Title, style: UIAlertAction.Style.default, handler: HandleServerSelection)
            Alert.addAction(AAction)
            if IsSelf
            {
                Alert.actions[Index].isEnabled = false
                Alert.actions[Index].setValue(UIColor.darkGray, forKey: "titleTextColor")
            }
        }
        Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: HandleServerSelection))
        
        BusyIndicator.isHidden = true
        let Presenter = Alert.popoverPresentationController
        Presenter?.barButtonItem = Button
        present(Alert, animated: true, completion: nil)
    }
    
    @objc func HandleServerSelection(Alert: UIAlertAction)
    {
        if Alert.title == "Cancel"
        {
            return
        }
        if !Alert.isEnabled
        {
            return
        }
        let FirstIndex = CurrentHostIndex
        let Parts = Alert.title!.split(separator: ".")
        let Index = Int(String(Parts[0]))! - 1
        CurrentHostIndex = Index
        ServerButton.title = "Server: " + ServerList[Index].displayName
        if FirstIndex != -1
        {
            let Disconnect = MessageHelper.MakeHandShake(.ConnectionClose)
            MPMgr?.SendPreformatted(Message: Disconnect, To: ServerList[FirstIndex])
        }
        let ConnectRequest = MessageHelper.MakeHandShake(.RequestConnection)
        MPMgr?.SendPreformatted(Message: ConnectRequest, To: ServerList[Index])
    }
    
    var CurrentHostIndex: Int = -1
    {
        didSet
        {
            let HaveHost = CurrentHostIndex >= 0
            SendKVPButton.isEnabled = HaveHost
            SendTextButton.isEnabled = HaveHost
            EchoButton.isEnabled = HaveHost
            SetIdiotLightButton.isEnabled = HaveHost
            StartStopButton.isEnabled = HaveHost
            if HeartbeatTimer != nil
            {
                HeartbeatTimer?.invalidate()
                HeartbeatTimer = nil
            }
        }
    }
    
    func GetEchoDelay() -> Int
    {
        let Index = EchoDelaySegment.selectedSegmentIndex
        return [0, 1, 5, 10, 30, 60][Index]
    }
    
    func GetHeartbeatInterval() -> Int
    {
        let Index = HeartbeatIntervalSegment.selectedSegmentIndex
        return [1, 5, 10, 30, 60, 120, 300][Index]
    }
    
    @IBAction func HandleHeartbeatIntervalChanged(_ sender: Any)
    {
        HandleEnableHeartbeatChanged(EnableHeartbeatSwitch as Any)
    }
    
    @IBAction func HandleEnableHeartbeatChanged(_ sender: Any)
    {
        if EnableHeartbeatSwitch.isOn
        {
            if HeartbeatTimer != nil
            {
                HeartbeatTimer?.invalidate()
                HeartbeatTimer = nil
            }
            let Interval = Double(GetHeartbeatInterval())
            HeartbeatTimer = Timer.scheduledTimer(timeInterval: Interval, target: self,
                                                  selector: #selector(HandleHeartbeat),
                                                  userInfo: nil, repeats: true)
        }
        else
        {
            if HeartbeatTimer != nil
            {
                HeartbeatTimer?.invalidate()
                HeartbeatTimer = nil
            }
        }
    }
    
    @objc func HandleHeartbeat()
    {
        let NextExpected = GetHeartbeatInterval()
        var HeartbeatMessage: String = ""
        if HeartbeatPayloadSwitch.isOn
        {
            HeartbeatMessage = MessageHelper.MakeHeartbeatMessage(Payload: HeartbeatPayload,
                                                                  NextExpectedIn: NextExpected,
                                                                  GetDeviceName())
        }
        else
        {
            HeartbeatMessage = MessageHelper.MakeHeartbeatMessage(NextExpectedIn: NextExpected,
                                                                  GetDeviceName())
        }
        MPMgr?.SendPreformatted(Message: HeartbeatMessage, To: ServerList[CurrentHostIndex])
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
    
    @IBAction func HandleSendKVPButtonPressed(_ sender: Any)
    {
        if let KeyValue = KVPKeyText.text,
            let ValueValue = KVPValueText.text
        {
            let KVPMessage = MessageHelper.MakeKVPMessage(ID: KVPID, Key: KeyValue, Value: ValueValue)
            MPMgr?.SendPreformatted(Message: KVPMessage, To: ServerList[CurrentHostIndex])
        }
    }
    
    @IBAction func HandleGenerateNewKVPID(_ sender: Any)
    {
        KVPID = UUID()
        KVPValue.text = KVPID.uuidString
    }
    
    var KVPID: UUID = UUID()
    
    @IBAction func HandleSpecialCommandButton(_ sender: Any)
    {
        let Button = sender as? UIBarButtonItem
        let Alert = UIAlertController(title: "Special Command",
                                      message: "Execute a special command. Commands are executed immediately after you select it.",
                                      preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Reset Idiot Lights", style: UIAlertAction.Style.default, handler: HandleSpecialCommandAction))
        Alert.addAction(UIAlertAction(title: "Clear KVP List", style: UIAlertAction.Style.default, handler: HandleSpecialCommandAction))
        Alert.addAction(UIAlertAction(title: "Clear Log List", style: UIAlertAction.Style.default, handler: HandleSpecialCommandAction))
        Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        let Presenter = Alert.popoverPresentationController
        Presenter?.barButtonItem = Button
        present(Alert, animated: true, completion: nil)
    }
    
    @objc func HandleSpecialCommandAction(Action: UIAlertAction)
    {
        var Message = ""
        switch Action.title
        {
        case "Reset Idiot Lights":
            Message = MessageHelper.MakeSpcialCommand(.ClearIdiotLights)
            
        case "Clear KVP List":
            Message = MessageHelper.MakeSpcialCommand(.ClearKVPList)
            
        case "Clear Log List":
            Message = MessageHelper.MakeSpcialCommand(.ClearLogList)
            
        default:
            break
        }
        if !Message.isEmpty
        {
            MPMgr?.SendPreformatted(Message: Message, To: ServerList[CurrentHostIndex])
        }
    }
    
    var HeartbeatTimer: Timer? = nil
    
    @IBOutlet weak var KVPValueText: UITextField!
    @IBOutlet weak var KVPKeyText: UITextField!
    @IBOutlet weak var KVPValue: UILabel!
    @IBOutlet weak var EchoDelaySegment: UISegmentedControl!
    @IBOutlet weak var HeartbeatIntervalSegment: UISegmentedControl!
    @IBOutlet weak var ServerButton: UIBarButtonItem!
    @IBOutlet weak var EchoButton: UIButton!
    @IBOutlet weak var SendTextButton: UIButton!
    @IBOutlet weak var EchoTextBox: UITextField!
    @IBOutlet weak var SendTextBox: UITextField!
    @IBOutlet weak var HeartbeatPayloadSwitch: UISwitch!
    @IBOutlet weak var IdiotLightPicker: UIPickerView!
    @IBOutlet weak var EnableHeartbeatSwitch: UISwitch!
    @IBOutlet weak var SetIdiotLightButton: UIButton!
    @IBOutlet weak var BusyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var IdiotLightCommandPicker: UIPickerView!
    @IBOutlet weak var EchoCountSegment: UISegmentedControl!
    @IBOutlet weak var SendKVPButton: UIButton!
    
    let HeartbeatPayload = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed a leo blandit, commodo nunc sit amet, euismod eros. Pellentesque varius ornare est sit amet accumsan. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla lectus ante, lacinia eget odio ac, facilisis consectetur lacus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Praesent pulvinar fermentum ante in cursus. Ut ac ullamcorper enim.
"""
}
