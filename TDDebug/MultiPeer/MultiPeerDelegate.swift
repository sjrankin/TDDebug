//
//  MultiPeerDelegate.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity

/// Delegate for communication between the MultiPeerManager class and whatever classes that us it.
protocol MultiPeerDelegate
{
    /// Notifies the receiver when a peer changes status (eg, connected or disconnected).
    ///
    /// - Parameters:
    ///   - Manager: The instance of the multipeer manager.
    ///   - ConnectedDevices: List of connected devices. Connected in this case means the device is
    ///                       advertising but not necessarily talking to us.
    ///   - Changed: The specific peer that changed.
    ///   - NewState: The new state of the peer that changed.
    func ConnectedDeviceChanged(Manager: MultiPeerManager, ConnectedDevices: [MCPeerID], Changed: MCPeerID, NewState: MCSessionState)
    
    /// Notifies the receiver that data has been received by a peer.
    ///
    /// - Parameters:
    ///   - Manager: The instance of the multipeer manager.
    ///   - Peer: The peer that sent the data. The data sent is not from a stream or a resource.
    ///   - RawData: The raw data in string format.
    func ReceivedData(Manager: MultiPeerManager, Peer: MCPeerID, RawData: String)
}
