//
//  +TextMessages.swift
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
    // MARK: Text message command encoding commands.
    
    /// Create a text message to send to a peer.
    /// - Note: This function is probably obsolete and shouldn't be used anymore.
    /// - Parameter WithType: The message type being sent.
    /// - Parameter WithText: The text to send.
    /// - Parameter HostName: The host name that sent the message.
    /// - Returns: Properly formatted string to send.
    public static func MakeMessage(WithType: MessageTypes, _ WithText: String, _ HostName: String) -> String
    {
        let P1 = "Message=\(WithText)"
        let P2 = "HostName=\(HostName)"
        let P3 = "TimeStamp=\(MakeTimeStamp(FromDate: Date()))"
        let P4 = "Command=\(WithType.rawValue)"
        let Final = GenerateCommand(Command: .TextMessage, Prefix: PrefixCode, Parts: [P1, P2, P3, P4])
        return Final
    }
    
    /// Create a text message to send to a peer.
    /// - Parameter WithText: The text to send.
    /// - Parameter HostName: The host name that sent the message.
    /// - Returns: Properly formatted string to send.
    public static func MakeMessage(_ WithText: String, _ HostName: String) -> String
    {
        let P1 = "Message=\(WithText)"
        let P2 = "HostName=\(HostName)"
        let P3 = "TimeStamp=\(MakeTimeStamp(FromDate: Date()))"
        let Final = GenerateCommand(Command: .TextMessage, Prefix: PrefixCode, Parts: [P1, P2, P3])
        return Final
    }
    
    /// Create a text message to send to a peer.
    /// - Parameter WithText: The text to send.
    /// - Parameter Marked: Context-dependent flag for the receipent to handle.
    /// - Parameter HostName: The host name that sent the message.
    /// - Returns: Properly formatted string to send.
    public static func MakeMessage(_ WithText: String, Marked: Bool, _ HostName: String) -> String
    {
        let P1 = "Message=\(WithText)"
        let P2 = "Marked=\(Marked)"
        let P3 = "HostName=\(HostName)"
        let P4 = "TimeStamp=\(MakeTimeStamp(FromDate: Date()))"
        let Final = GenerateCommand(Command: .TextMessage, Prefix: PrefixCode, Parts: [P1, P2, P3, P4])
        return Final
    }
    
    /// Make a command to send a block of text.
    /// - Note: The difference between a text block message and a normal message is that text block messages are displayed in a
    ///         special view for large amounts of text.
    /// - Parameter WithText: The block of text to send.
    /// - Parameter UseMonoSpaceFont: Determines whether a monospaced font should be used to display the text.
    /// - Parameter HostName: Name of the host that sent the message.
    /// - Returns: Command to send.
    public static func MakeTextBlock(_ WithText: String, _ UseMonoSpaceFont: Bool, _ HostName: String) -> String
    {
        let P1 = "Block=\(WithText)"
        let P2 = "Monofont=\(UseMonoSpaceFont)"
        let P3 = "HostName=\(HostName)"
        let P4 = "TimeStamp=\(MakeTimeStamp(FromDate: Date()))"
        let Final = GenerateCommand(Command: .TextBlock, Prefix: PrefixCode, Parts: [P1, P2, P3, P4])
        return Final
    }
    
    // MARK: Text message command decoding.
    
    /// Decodes a raw text command.
    /// - Parameter Raw: The raw text command to parse.
    /// - Returns: Tuple with parsed information. Contents of tuple are: The text message, the host name, the time stamp from
    ///            the host, and the marked flag. (If the sender didn't use the Marked flag, this value will be false.)
    public static func DecodeTextMessage(_ Raw: String) -> (String, String, String, Bool)
    {
        let Params = GetParameters(From: Raw, ["Message", "HostName", "TimeStamp", "Marked"])
        var Message = ""
        if let Msg = Params["Message"]
        {
            Message = Msg
        }
        var HostName = ""
        if let Host = Params["HostName"]
        {
            HostName = Host
        }
        var TimeStamp = ""
        if let TS = Params["TimeStamp"]
        {
            TimeStamp = TS
        }
        var Marked = false
        if let Mk = Params["Marked"]
        {
            Marked = Bool(Mk)!
        }
        return(Message, HostName, TimeStamp, Marked)
    }
    
    /// Decode a text block message.
    /// - Parameter Raw: Raw data to decode.
    /// - Returns: Tuple with: text block, monospace font flag, host name, and time stamp.
    public static func DecodeTextBlockMessage(_ Raw: String) -> (String, Bool, String, String)
    {
        let Params = GetParameters(From: Raw, ["Block", "Monofont", "HostName", "TimeStamp"])
        var Block = ""
        if let Msg = Params["Block"]
        {
            Block = Msg
        }
        var HostName = ""
        if let Host = Params["HostName"]
        {
            HostName = Host
        }
        var TimeStamp = ""
        if let TS = Params["TimeStamp"]
        {
            TimeStamp = TS
        }
        var UseMonospace = true
        if let Mono = Params["Monofont"]
        {
            if let MonoValue = Bool(Mono)
            {
                UseMonospace = MonoValue
            }
        }
        return(Block, UseMonospace, HostName, TimeStamp)
    }
}
