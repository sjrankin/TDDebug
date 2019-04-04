//
//  SendToRemoteCode.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class SendToRemoteCode: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    weak var Main: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        TextBox.text = ""
        HostList.layer.cornerRadius = 5.0
        HostList.layer.borderColor = UIColor.black.cgColor
        HostList.layer.borderWidth = 0.5
        SendButton.isEnabled = false
        PeerList = (Main?.MPManager.GetPeerList())!
        HostList.delegate = self
        HostList.dataSource = self
        HostList.reloadData()
    }
    
    var PeerList = [MCPeerID]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return PeerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "PeerIDCell")
        Cell.textLabel!.text = PeerList[indexPath.row].displayName
        if indexPath.row == SelectedIndex
        {
            Cell.accessoryType = .checkmark
        }
        else
        {
            Cell.accessoryType = .none
        }
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        SelectedIndex = indexPath.row
        HostList.reloadData()
        SendButton.isEnabled = true
    }
    
    var SelectedIndex = -1
    
    @IBAction func HandleSendPressed(_ sender: Any)
    {
        if let Message = TextBox.text
        {
            if Message.isEmpty
            {
                print("No message to send.")
                return
            }
            let PeerID = PeerList[SelectedIndex]
            Main?.MPManager.Send(Message: Message, To: PeerID)
        }
        TextBox.text = ""
    }
    
    @IBOutlet weak var SendButton: UIButton!
    
    @IBOutlet weak var HostList: UITableView!
    
    @IBOutlet weak var TextBox: UITextField!
    
    @IBAction func HandleBackButton(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleRefreshButton(_ sender: Any)
    {
        PeerList = (Main?.MPManager.GetPeerList())!
        SelectedIndex = -1
        HostList.reloadData()
    }
}
