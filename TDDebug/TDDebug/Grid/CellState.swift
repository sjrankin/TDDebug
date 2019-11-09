//
//  CellState.swift
//  TDDebug
//
//  Created by Stuart Rankin on 11/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Holds the state contents of one cell.
class CellState
{
    /// The address of the cell.
    var CellAddress: String = ""
    
    /// The text color of the cell.
    var TextColor: NSColor = NSColor.black
    
    /// The background color of the cell.
    var BackgroundColor: NSColor = NSColor.white
    
    /// The text of the cell.
    var CellContents: String = ""
    
    /// The cell's tag.
    var CellTag: Any? = nil
}
