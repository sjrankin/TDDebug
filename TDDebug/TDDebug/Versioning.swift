//
//  Versioning.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Contains versioning and copyright information. The contents of this file are automatically updated with each
/// build by the VersionUpdater utility.
public class Versioning
{
    /// Major version number.
    public static let MajorVersion: String = "1"
    
    /// Minor version number.
    public static let MinorVersion: String = "1"
    
    /// Potential version suffix.
    public static let VersionSuffix: String = ""
    
    /// Name of the application.
    public static let ApplicationName = "TDDebug"
    
    /// ID of the application.
    public static let ProgramID = "cc321f92-0c86-4588-a1a1-235cd0177bd9"
    
    /// The intended OS for the program.
    public static let IntendedOS = "macOS"
    
    /// Returns a standard-formatted version string in the form of "Major.Minor" with optional
    /// version suffix.
    ///
    /// - Parameter IncludeVersionSuffix: If true and the VersionSuffix value is non-empty, the contents
    ///                                   of VersionSuffix will be appended (with a leading space) to the
    ///                                   returned string.
    /// - Parameter IncludeVersionPrefix: If true, the word "Version" is prepended to the returned string.
    /// - Returns: Standard version string.
    public static func MakeVersionString(IncludeVersionSuffix: Bool = false,
                                         IncludeVersionPrefix: Bool = true) -> String
    {
        let VersionLabel = IncludeVersionPrefix ? "Version " : ""
        var Final = "\(VersionLabel)\(MajorVersion).\(MinorVersion)"
        if IncludeVersionSuffix
        {
            if !VersionSuffix.isEmpty
            {
                Final = Final + " " + VersionSuffix
            }
        }
        return Final
    }
    
    /// Build number.
    public static let Build: Int = 650
    
    /// Build increment.
    private static let BuildIncrement = 1
    
    /// Build ID.
    public static let BuildID: String = "077F751A-5D9F-4E77-8BC6-09E047294953"
    
    /// Build date.
    public static let BuildDate: String = "25 June 2019"
    
    /// Build Time.
    public static let BuildTime: String = "21:56"
    
    /// Return a standard build string.
    ///
    /// - Parameter IncludeBuildPrefix: If true, the word "Build" is prepended to the returned string.
    /// - Returns: Standard build string
    public static func MakeBuildString(IncludeBuildPrefix: Bool = true) -> String
    {
        let BuildLabel = IncludeBuildPrefix ? "Build " : ""
        let Final = "\(BuildLabel)\(Build), \(BuildDate) \(BuildTime)"
        return Final
    }
    
    /// Copyright years.
    public static let CopyrightYears = [2019]
    
    /// Legal holder of the copyright.
    public static let CopyrightHolder = "Stuart Rankin"
    
    /// Returns copyright text.
    ///
    /// - Returns: Program copyright text.
    public static func CopyrightText() -> String
    {
        var Years = Versioning.CopyrightYears
        var CopyrightYears = ""
        if Years.count > 1
        {
            Years = Years.sorted()
            let FirstYear = Years.first
            let LastYear = Years.last
            CopyrightYears = "\(FirstYear!) - \(LastYear!)"
        }
        else
        {
            CopyrightYears = String(describing: Years[0])
        }
        let CopyrightTextString = "Copyright © \(CopyrightYears) \(CopyrightHolder)"
        return CopyrightTextString
    }
    
    /// Return the program ID as a UUID.
    public static func ProgramIDAsUUID() -> UUID
    {
        return UUID(uuidString: ProgramID)!
    }
    
    /// Returns a block of text with most of the versioning information.
    ///
    /// - Returns: Most versioning information, on different lines.
    public static func MakeVersionBlock() -> String
    {
        var Block = ApplicationName + "\n"
        Block = Block + MakeVersionString(IncludeVersionSuffix: true, IncludeVersionPrefix: true) + "\n"
        Block = Block + MakeBuildString() + "\n"
        Block = Block + "Build ID " + BuildID + "\n"
        Block = Block + CopyrightText() + "\n"
        Block = Block + "Program ID " + ProgramID
        return Block
    }
    
    /// Return an XML-formatted key-value pair string.
    ///
    /// - Parameters:
    ///   - Key: The key part of the key-value pair.
    ///   - Value: The value part of the key-value pair.
    /// - Returns: XML-formatted key-value pair string.
    private static func MakeKVP(_ Key: String, _ Value: String) -> String
    {
        let KVP = "\(Key)=\"\(Value)\""
        return KVP
    }
    
    /// Emit version information as an XML string.
    ///
    /// - Parameter LeadingSpaceCount: The number of leading spaces to insert before
    ///                                each line of the returned result. If not specified,
    ///                                no extra leading spaces are used.
    /// - Returns: XML string with version information.
    public static func EmitXML(_ LeadingSpaceCount: Int = 0) -> String
    {
        let Spaces = String(repeating: " ", count: LeadingSpaceCount)
        var Emit = Spaces + "<Version "
        Emit = Emit + MakeKVP("Application", ApplicationName) + " "
        Emit = Emit + MakeKVP("Version", MajorVersion + "." + MinorVersion) + " "
        Emit = Emit + MakeKVP("Build", String(describing: Build)) + " "
        Emit = Emit + MakeKVP("BuildDate", BuildDate + ", " + BuildTime) + " "
        Emit = Emit + MakeKVP("BuildID", BuildID)
        Emit = Emit + ">\n"
        Emit = Emit + Spaces + "  " + CopyrightText() + "\n"
        Emit = Emit + Spaces + "</Version>"
        return Emit
    }
}
