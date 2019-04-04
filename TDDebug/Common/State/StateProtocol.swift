//
//  StateProtocol.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

protocol StateProtocol: class
{
    func StateChanged(NewState: States, HandShake: HandShakeCommands)
}
