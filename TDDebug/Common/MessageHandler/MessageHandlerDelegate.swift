//
//  MessageHandlerDelegate.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

protocol MessageHandlerDelegate: class
{
    func Message(_ Handler: MessageHandler, KVPData: (UUID, String, String))
    func Message(_ Handler: MessageHandler, Execute: ClientCommand)
    func Message(_ Handler: MessageHandler, IdiotLightCommand: IdiotLightCommands, Address: String, Text: String?, FGColor: OSColor?, BGColor: OSColor?)
}
