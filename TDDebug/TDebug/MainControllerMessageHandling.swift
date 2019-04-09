//
//  MainControllerMessageHandling.swift
//  TDebug
//
//  Created by Stuart Rankin on 4/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

extension MainController
{
    // MARK: MessageHandler delegate functions.
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, Command Broadcast: String)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, Message Broadcast: String)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, Log Message: String)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, VersionInformation: [(String, String)])
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, EchoReturned Message: String)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, EchoMessage: String, In Seconds: Double)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, SpecialCommand: SpecialCommands)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, KVPData: (UUID, String, String))
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, Execute: ClientCommand)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID,
                 IdiotLightCommand: IdiotLightCommands, Address: String,
                 Text: String?, FGColor: OSColor?, BGColor: OSColor?)
    {
    }
}
