//
//  MainProtocol.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MainProtocol: class
{
    var MPManager: MultiPeerManager {get}
    var ConnectedClient: MCPeerID? {get set}
    var ClientCommandList: [ClientCommand] {get}
    func GetFilterObject() -> FilterObject?
    func SetFilterObject(Canceled: Bool, _ NewObject: FilterObject?)
    func SetFilterTest(_ TestObject: FilterObject?)
    func UndoFilterTest()
    func GetFilterSourceList() -> [String]
    func CloseProtocol(ForType: ConnectionProtocolTypes)
    func SetProtocol(ForType: ConnectionProtocolTypes, Delegate: ConnectionNotificationProtocol)
    func LastSelectedLogItem() -> LogItem?
}

/// Types of windows that implement connection protocols.
///
/// - SendTo: The sent do client window.
/// - PeerViewer: The peer viewer window.
enum ConnectionProtocolTypes
{
    case SendTo
    case PeerViewer
}
