//
//  GridProtocol.swift
//  TDDebug
//
//  Created by Stuart Rankin on 11/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Protocol for communicating between the `Grid` class instantiation and its parent class.
protocol GridProtocol: class
{
    /// Notification that a selection state of one of the grid cells changed.
    /// - Parameter Column: The column address of the changed cell.
    /// - Parameter Row: The row address of the changed cell.
    /// - Parameter IsSelected: The new selection state for the cell.
    func CellSelectionStateChanged(Column: Int, Row: Int, IsSelected: Bool)
    
    /// Notification that the number of cells in the grid changed.
    /// - Parameter ColumnCount: The new number of columns in the grid.
    /// - Parameter RowCount: The new number of rows in the grid.
    func CellCountChanged(ColumnCount: Int, RowCount: Int)
}
