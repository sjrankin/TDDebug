//
//  +IdiotLights.swift
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
    // MARK: Idiot light encoding commands.
    
    /// Make an idiot light message.
    /// - Parameter Address: The address of the idiot light.
    /// - Parameter Message: The text of the idiot light (which shouldn't be very long).
    /// - Parameter FGColor: Color of the text.
    /// - Parameter BGColor: Color of the background.
    /// - Returns: Formatted string to send to the remote peer to set an idiot light.
    public static func MakeIdiotLightMessage(Address: String, Message: String, FGColor: OSColor, BGColor: OSColor) -> String
    {
        let P1 = "Address=\(Address)"
        let P2 = "Message=\(Message)"
        let P3 = "FGColor=\(FGColor.AsHexString())"
        let P4 = "BGColor=\(BGColor.AsHexString())"
        let Final = GenerateCommand(Command: .IdiotLightMessage, Prefix: PrefixCode, Parts: [P1, P2, P3, P4])
        return Final
    }
    
    /// Make an idiot light message.
    /// - Parameter Address: The address of the idiot light.
    /// - Parameter State: UIFeature state enabling flag.
    /// - Returns: Formatted string to send to the remote peer to set an idiot light.
    public static func MakeIdiotLightMessage(Address: String, State: UIFeatureStates) -> String
    {
        let Addr = "Address=\(Address)"
        let Action = "Enable=" + [UIFeatureStates.Disabled: "No", UIFeatureStates.Enabled: "Yes"][State]!
        let Final = GenerateCommand(Command: .ControlIdiotLight, Prefix: PrefixCode, Parts: [Addr, Action])
        return Final
    }
    
    /// Make an idiot light message.
    /// - Parameter Address: The address of the idiot light.
    /// - Parameter Text: The text of the idiot light (which shouldn't be very long).
    /// - Returns: Formatted string to send to the remote peer to set an idiot light.
    public static func MakeIdiotLightMessage(Address: String, Text: String) -> String
    {
        let Addr = "Address=\(Address)"
        let Action = "Text=" + Text
        let Final = GenerateCommand(Command: .ControlIdiotLight, Prefix: PrefixCode, Parts: [Addr, Action])
        return Final
    }
    
    /// Change the text color of an idiot light.
    /// - Parameter Address: The address of the idiot light.
    /// - Parameter FGColor: Color of the text.
    /// - Returns: Formatted string to send to the remote peer to set an idiot light.
    public static func MakeIdiotLightMessage(Address: String, FGColor: OSColor) -> String
    {
        let Addr = "Address=\(Address)"
        let Action1 = "FGColor=" + FGColor.AsHexString()
        let Final = GenerateCommand(Command: .ControlIdiotLight, Prefix: PrefixCode, Parts: [Addr, Action1])
        return Final
    }
    
    /// Change the background color of an idiot light.
    /// - Parameter Address: The address of the idiot light.
    /// - Parameter FGColor: Color of the text.
    /// - Returns: Formatted string to send to the remote peer to set an idiot light.
    public static func MakeIdiotLightMessage(Address: String, BGColor: OSColor) -> String
    {
        let Addr = "Address=\(Address)"
        let Action1 = "BGColor=" + BGColor.AsHexString()
        let Final = GenerateCommand(Command: .ControlIdiotLight, Prefix: PrefixCode, Parts: [Addr, Action1])
        return Final
    }
    
    // MARK: Idiot light command decoding.
    
    #if false
    /// Decode an idiot light command.
    /// - Note: Not currently used.
    /// - Parameter Raw: The raw string to decode.
    /// - Returns: Tuple.
    public static func DecodeIdiotLightCommand(_ Raw: String) -> (MessageTypes, String, String, String)
    {
        if Raw.isEmpty
        {
            return (MessageTypes.Unknown, "", "", "")
        }
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter), maxSplits: 4, omittingEmptySubsequences: false)
        if Parts.count != 4
        {
            //Assume the last item in the parts list is the message and return it as an unknown type.
            return (MessageTypes.Unknown, "", "", String(Parts[Parts.count - 1]))
        }
        return (MessageTypeFromID(String(Parts[0])), String(Parts[1]), String(Parts[2]), String(Parts[3]))
    }
    #endif
    
    //Format of command: command,address{,data}
    //returns command, address, text, fg color, bg color
    /// Decode an idiot light message from a remote peer.
    /// - Parameter Raw: The raw string to decode.
    /// - Returns: Tuple in the form: Idiot light command (enable or disable), idiot light address, idiot light text if available
    ///            (nil if not available), foreground color (nil if not available), and background color (nil if not available).
    public static func DecodeIdiotLightMessage(_ Raw: String) ->(IdiotLightCommands, String, String?, OSColor?, OSColor?)
    {
        let Params = GetParameters(From: Raw, ["Address", "Enable", "Text", "BGColor", "FGColor"])
        var Address = ""
        var Text: String? = nil
        var Command: IdiotLightCommands = .Unknown
        var BGColor: OSColor? = nil
        var FGColor: OSColor? = nil
        for (Key, Value) in Params
        {
            switch Key
            {
            case "Address":
                Address = Value
                
            case "Enable":
                if Value.lowercased() == "yes"
                {
                    Command = .Enable
                }
                else
                {
                    Command = .Disable
                }
                break
                
            case "Text":
                Command = .SetText
                Text = Value
                
            case "BGColor":
                Command = .SetBGColor
                BGColor = OSColor(HexString: Value)!
                
            case "FGColor":
                Command = .SetFGColor
                FGColor = OSColor(HexString: Value)!
                
            default:
                continue
            }
        }
        return (Command, Address, Text, FGColor, BGColor)
    }
    
    /// Decode an idiot light message.
    /// - Parameter Raw: The raw string to decode.
    /// - Returns: An IdiotLightMessage class instance with parsed data.
    public static func DecodeIdiotLightMessage2(_ Raw: String) -> IdiotLightMessage?
    {
        let Params = GetParameters(From: Raw, ["Address", "Message", "BGColor", "FGColor"])
                let Result = IdiotLightMessage()
        for (Key, Value) in Params
        {
            switch Key
            {
            case "Address":
                Result.Address = Value
                
            case "Message":
                Result.Message = Value
                
            case "FGColor":
                Result.FGColor = Value
                
            case "BGColor":
                Result.BGColor = Value
                
            default:
                continue
            }
        }
        return Result
    }
}
