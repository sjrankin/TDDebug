//
//  TableWatcher.swift
//  TDDebug
//
//  Created by Stuart Rankin on 6/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

protocol TableWatcher: class
{
    func TableChanged(TableID: UUID)
    func TableDeleted(TableID: UUID)
}
