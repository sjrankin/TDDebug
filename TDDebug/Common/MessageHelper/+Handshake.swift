//
//  +Handshake.swift
//  TDDebug
//
//  Created by Stuart Rankin on 6/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
#if FOR_MACOS
import AppKit
#else
import UIKit
#endif
import MultipeerConnectivity

extension MessageHelper
{
    // MARK: Handshake command encoding commands.
    
    /// Make a handshake command to negotiate host-client relationships.
    ///
    /// - Parameter Command: The command to send.
    /// - Returns: Command string with the passed handshake command.
    public static func MakeHandShake(_ Command: HandShakeCommands) -> String
    {
        let SCmd = "Command=" + HandShakeIndicators[Command]!
        let Final = GenerateCommand(Command: .HandShake, Prefix: PrefixCode, Parts: [SCmd])
        return Final
    }
    
    // MARK: Handshake command decoding.
    
    public static func DecodeHandShakeCommand(_ Raw: String) -> HandShakeCommands
    {
        let Results = GetParameters(From: Raw, ["Command"])
        if Results.count < 1
        {
            return HandShakeCommands.Unknown
        }
        let Command = Results["Command"]
        for (Cmd, Indicator) in HandShakeIndicators
        {
            if Indicator.lowercased() == Command?.lowercased()
            {
                return Cmd
            }
        }
        return HandShakeCommands.Unknown
    }
}