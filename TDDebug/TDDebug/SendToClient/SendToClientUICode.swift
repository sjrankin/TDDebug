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

class SendToClientUICode: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    var HaveDelegate = false
    weak var Delegate: MainProtocol!
        {
        didSet
        {
            HaveDelegate = true
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func UpdateClienCommandList()
    {
        if HaveDelegate
        {
            ClientCommandList = Delegate.ClientCommandList
        }
    }
    
    var ClientCommandList = [ClientCommand]()
    
    @IBAction func SendButton(_ sender: Any)
    {
    }
    
    @IBAction func CloseButton(_ sender: Any)
    {
        self.view.window!.performClose(sender)
    }
    
    @IBOutlet weak var CommandTable: NSTableView!
    @IBOutlet weak var OperandTable: NSTableView!
}
