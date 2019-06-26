//
//  +DebuggeeExecution.swift
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

/// Extensions for idiot light message encoding and decoding.
extension MessageHelper
{
    // MARK: Debuggee execution encoding commands.
    
    public static func MakeExecutionStartedCommand(Prefix: UUID, Exclusive: Bool) -> String
    {
        let P1 = "Prefix=\(Prefix.uuidString)"
        let P2 = "RequestExclusive=\(Exclusive)"
        let Final = GenerateCommand(Command: .ExecutionStarted, Prefix: Prefix, Parts: [P1, P2])
        return Final
    }
    
    public static func MakeExecutionTerminatedCommand(Prefix: UUID, WasFatalError: Bool, LastMessage: String) -> String
    {
        let P1 = "Prefix=\(Prefix.uuidString)"
        let P2 = "FatalError=\(WasFatalError)"
        let P3 = "LastMessage=\(LastMessage)"
        let Final = GenerateCommand(Command: .ExecutionTerminated, Prefix: Prefix, Parts: [P1, P2, P3])
        return Final
    }
    
    // MARK: Debuggee execution command decoding.
    
    public static func DecodeExecutionStartedCommand(_ Raw: String) -> (UUID, Bool)?
    {
        let Results = GetParameters(From: Raw, ["Prefix", "RequestExclusive"])
        var PrefixCd = UUID.Empty
        if let PC = Results["Prefix"]
        {
            PrefixCd = UUID(uuidString: PC)!
        }
        else
        {
            print("Malformed execution started message encountered: missing prefix.")
            return nil
        }
        var Exclusive = false
        if let Ex = Results["Exclusive"]
        {
            Exclusive = Bool(Ex)!
        }
        return (PrefixCd, Exclusive)
    }
    
    public static func DecodeExecutionTerminatedCommand(_ Raw: String) -> (UUID, Bool, String)?
    {
        let Results = GetParameters(From: Raw, ["Prefix", "FatalError", "LastMessage"])
        var PrefixCd = UUID.Empty
        if let PC = Results["Prefix"]
        {
            PrefixCd = UUID(uuidString: PC)!
        }
        else
        {
            print("Malformed execution terminated message encountered: missing prefix.")
            return nil
        }
        var WasFatal = false
        if let Fatal = Results["FatalError"]
        {
            WasFatal = Bool(Fatal)!
        }
        var LastMessage = ""
        if let Last = Results["LastMessage"]
        {
            LastMessage = Last
        }
        return (PrefixCd, WasFatal, LastMessage)
    }
}
