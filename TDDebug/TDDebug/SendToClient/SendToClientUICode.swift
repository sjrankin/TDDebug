//
//  SendToClientUICode.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/2/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import MultipeerConnectivity

class SendToClientUICode: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
    NSWindowDelegate, ConnectionNotificationProtocol
{
    let CommandTableTag = 100
    
    var HaveDelegate = false
    weak var Delegate: MainProtocol!
        {
        didSet
        {
            HaveDelegate = true
            UpdateClientCommandList()
            Delegate.SetProtocol(ForType: .SendTo, Delegate: self)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        CommandTable.delegate = self
        CommandTable.dataSource = self
        
        SendCommandTo.stringValue = "No connected peer - cannot send."
    }
    
    override func viewDidLayout()
    {
        super.viewDidLayout()
        OperandTable[0] = (Operand1Label, Operand1TextBox)
        OperandTable[1] = (Operand2Label, Operand2TextBox)
        OperandTable[2] = (Operand3Label, Operand3TextBox)
        OperandTable[3] = (Operand4Label, Operand4TextBox)
        OperandTable[4] = (Operand5Label, Operand5TextBox)
        OperandTable[5] = (Operand6Label, Operand6TextBox)
        
        for (_, (Label, Text)) in OperandTable
        {
            Label.drawsBackground = false
            Label.alphaValue = 0.0
            Text.alphaValue = 0.0
        }
    }
    
    override func viewWillDisappear()
    {
        if HaveDelegate
        {
            Delegate.CloseProtocol(ForType: .SendTo)
        }
        super.viewWillDisappear()
    }
    
    func LostConnectionTo(Peer: MCPeerID)
    {
        
    }
    
    func LostConnectionToClient()
    {
        SendCommandTo.stringValue = "Lost connection to client."
        ClientCommandList.removeAll()
        CommandTable.reloadData()
        CurrentCommandIndex = -1
        PopulateOperandTable()
    }
    
    func ConnectionChanged(ConnectionList: [MCPeerID])
    {
        
    }
    
    func ConnectedToClient(ClientID: MCPeerID)
    {
        
    }
    
    var OperandTable = [Int: (NSTextField, NSTextField)]()
    
    func UpdateClientCommandList()
    {
        if HaveDelegate
        {
            if Delegate.ConnectedClient == nil
            {
                SendCommandTo.stringValue = "No client found"
                return
            }
            SendCommandTo.stringValue = "Send command to " + Delegate.ConnectedClient!.displayName
            ClientCommandList = Delegate.ClientCommandList
            print("Found \(ClientCommandList.count) client commands.")
            CommandTable.reloadData()
        }
    }
    
    var ClientCommandList = [ClientCommand]()
    var CurrentOperandList = [String]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView.tag
        {
        case CommandTableTag:
            return ClientCommandList.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var Contents = ""
        var Identifier = ""
        var ContentColor = OSColor.black
        
        switch tableView.tag
        {
        case CommandTableTag:
            if tableColumn == tableView.tableColumns[0]
            {
                Identifier = "CommandColumn"
                Contents = ClientCommandList[row].Name
                ContentColor = OSColor.black
            }
            if tableColumn == tableView.tableColumns[1]
            {
                Identifier = "DescriptionColumn"
                Contents = ClientCommandList[row].Description
                ContentColor = OSColor.darkGray
            }
            let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: Identifier), owner: self) as? NSTableCellView
            Cell?.textField?.stringValue = Contents
            Cell?.textField?.textColor = ContentColor
            return Cell
            
        default:
            break
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        if notification.name.rawValue == "NSTableViewSelectionDidChangeNotification"
        {
            GatherText()
            CurrentCommandIndex = CommandTable.selectedRow
            PopulateOperandTable()
        }
    }
    
    var CurrentCommandIndex: Int = 0
    
    func PopulateOperandTable()
    {
        print("CurrentCommandIndex=\(CurrentCommandIndex)")
        if CurrentCommandIndex < 0
        {
            for (_, (Text, TextBox)) in OperandTable
            {
                Text.alphaValue = 0.0
                TextBox.alphaValue = 0.0
            }
            return
        }
        for Index in 0 ..< ClientCommandList[CurrentCommandIndex].ParameterCount
        {
            OperandTable[Index]?.0.alphaValue = 1.0
            OperandTable[Index]?.1.alphaValue = 1.0
            OperandTable[Index]?.0.stringValue = ClientCommandList[CurrentCommandIndex].Parameters[Index]
            OperandTable[Index]?.1.stringValue = ClientCommandList[CurrentCommandIndex].ParameterValues[Index]
        }
        for Index in ClientCommandList[CurrentCommandIndex].ParameterCount ..< 6
        {
            OperandTable[Index]?.0.alphaValue = 0.0
            OperandTable[Index]?.1.alphaValue = 0.0
        }
    }
    
    func windowDidResize(_ notification: Notification)
    {
        PopulateOperandTable()
    }
    
    @IBAction func SendButton(_ sender: Any)
    {
        if Delegate.ConnectedClient == nil
        {
            SendCommandTo.stringValue = "No connected client."
        }
        GatherText()
        var Parameters = [(String, String)]()
        //let v: String = OperandTable[0]!.1.stringValue
        for Index in 0 ..< ClientCommandList[CurrentCommandIndex].ParameterCount
        {
            let NewParam = (ClientCommandList[CurrentCommandIndex].Parameters[Index],
                            ClientCommandList[CurrentCommandIndex].ParameterValues[Index])
            Parameters.append(NewParam)
        }
        let Command = MessageHelper.MakeCommandForClient(CommandID: ClientCommandList[CurrentCommandIndex].ID, Parameters: Parameters)
        Delegate.MPManager.SendPreformatted(Message: Command, To: Delegate.ConnectedClient!)
    }
    
    @IBAction func CloseButton(_ sender: Any)
    {
        self.view.window!.performClose(sender)
    }
    
    func GatherText()
    {
        if CurrentCommandIndex < 0
        {
            return
        }
        for Index in 0 ..< ClientCommandList[CurrentCommandIndex].ParameterCount
        {
            let SomeOperand = OperandTable[Index]!.1.stringValue
            ClientCommandList[CurrentCommandIndex].ParameterValues[Index] = SomeOperand
        }
    }
    
    @IBAction func HandleTextEntry(_ sender: Any)
    {
        if let Entry = sender as? NSTextField
        {
            let Value = Entry.stringValue
            if Entry == Operand1TextBox
            {
                ClientCommandList[CurrentCommandIndex].ParameterValues[0] = Value
            }
            if Entry == Operand2TextBox
            {
                ClientCommandList[CurrentCommandIndex].ParameterValues[1] = Value
            }
            if Entry == Operand3TextBox
            {
                ClientCommandList[CurrentCommandIndex].ParameterValues[2] = Value
            }
            if Entry == Operand4TextBox
            {
                ClientCommandList[CurrentCommandIndex].ParameterValues[3] = Value
            }
            if Entry == Operand5TextBox
            {
                ClientCommandList[CurrentCommandIndex].ParameterValues[4] = Value
            }
            if Entry == Operand6TextBox
            {
                ClientCommandList[CurrentCommandIndex].ParameterValues[5] = Value
            }
        }
    }
    
    @IBOutlet weak var CommandTable: NSTableView!
    
    @IBOutlet weak var SendCommandTo: NSTextField!
    @IBOutlet weak var Operand1Label: NSTextField!
    @IBOutlet weak var Operand2Label: NSTextField!
    @IBOutlet weak var Operand3Label: NSTextField!
    @IBOutlet weak var Operand4Label: NSTextField!
    @IBOutlet weak var Operand5Label: NSTextField!
    @IBOutlet weak var Operand6Label: NSTextField!
    @IBOutlet weak var Operand1TextBox: NSTextField!
    @IBOutlet weak var Operand2TextBox: NSTextField!
    @IBOutlet weak var Operand3TextBox: NSTextField!
    @IBOutlet weak var Operand4TextBox: NSTextField!
    @IBOutlet weak var Operand5TextBox: NSTextField!
    @IBOutlet weak var Operand6TextBox: NSTextField!
}
