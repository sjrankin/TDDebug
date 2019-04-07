//
//  ConnectionNotificationProtocol.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/7/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ConnectionNotificationProtocol: class
{
    func LostConnectionTo(Peer: MCPeerID)
    func LostConnectionToClient()
    func ConnectionChanged(ConnectionList: [MCPeerID])
    func ConnectedToClient(ClientID: MCPeerID)
}
