//
//  IntraGridProtocol.swift
//  TDDebug
//
//  Created by Stuart Rankin on 11/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Protocol for communications between instances of grid cells and their `Grid` instance parent.
protocol IntraGridProtocol: class
{
    // MARK: - Cell customization.
    
    /// Request by a grid cell to get the base grid cell background color from the `Grid` instance.
    /// - Returns: Color to be used as the unselected, base background color.
    func GetBaseBackgroundColor() -> NSColor
    
    /// Request by a grid cell to get the border color from the `Grid` instance.
    /// - Returns: Color to be used as the border color.
    func GetBaseBorderColor() -> NSColor
    
    /// Request by a grid cell to get the border width from the `Grid` instance.
    /// - Returns: Value to be used as the border width.
    func GetBorderWidth() -> CGFloat
    
    //MARK: - Messages from the parent.
    
    /// Request by the `Grid` instance to redraw the grid cell.
    func Redraw()
    
    /// Request by the `Grid` instance to start execution of a grid cell.
    func Start()
}
