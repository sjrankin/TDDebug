//
//  Grid.swift
//  TDDebug
//
//  Created by Stuart Rankin on 11/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Implements a regular grid control that the user can configure by pressing rectangles.
@IBDesignable class Grid: NSView, GridProtocol, IntraGridProtocol
{
    /// Delegate for owners of the instance to communicate to this class.
    weak var GridDelegate: GridProtocol? = nil
    
    // MARK: - Initialization.
    
    /// Initializer.
    /// - Parameter frame: Original frame for the grid.
    override init(frame: NSRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Used to initialize the class when running in the Interface Builder.
    override public func prepareForInterfaceBuilder()
    {
        Initialize()
    }
    
    /// Initialize the instance.
    private func Initialize()
    {
        self.wantsLayer = true
        self.alphaValue = 1.0
        self.layer?.borderColor = NSColor.black.cgColor
        self.layer?.borderWidth = 0.5
        self.layer?.cornerRadius = 5.0
        DrawGrid()
    }
    
    // MARK: - Drawing and related functions.
    
    /// Holds the bounds for the `Grid` instance. When the bounds changes, the instance will redraw the grid.
    override var bounds: NSRect
        {
        didSet
        {
            print("Redrawing grid due to bounds change.")
            DrawGrid()
        }
    }
    
    /// Draw the grid. Each time the grid is drawn, all existing grid cells are deleted then recreated.
    /// - Note: If the number of columns or the number of rows is 0, any previously existing grid cells are deleted then control
    ///         is returned.
    public func DrawGrid()
    {
        if _Columns == 0 || _Rows == 0
        {
            ClearAll()
            return
        }
        ClearAll()
        let CellWidth = self.bounds.size.width / CGFloat(_Columns)
        let CellHeight = self.bounds.size.height / CGFloat(_Rows)
        for Row in 0 ..< _Rows
        {
            for Column in 0 ..< _Columns
            {
                let TagValue = (Row * 10) + Column
                let Top = self.frame.height - (CGFloat(Row + 1) * CellHeight)
                let Cell = GridCell(frame: NSRect(x: CGFloat(Column) * CellWidth, y: Top,
                                                  width: CellWidth, height: CellHeight),
                                    TagValue: TagValue)
                Cell.Column = Column
                Cell.Row = Row
                Cell.CellParentDelegate = self
                Cell.Address = "\(RowPrefixes[Row])\(Column + 1)"
                Cell.BackgroundColor = NSColor.lightGray
                Cell.SetFont(NSFont.systemFont(ofSize: 14.0, weight: NSFont.Weight.bold))
                Cell.SetForegroundColor(NSColor.black)
                Cell.SetText(Cell.Address)
                Cell.Start()
                GridCellMap[Cell.Address.lowercased()] = Cell
                self.addSubview(Cell)
            }
        }
        display()
    }
    
    /// Cell row prefixes - supports 26 rows. More than that will generate a run-time exception.
    let RowPrefixes = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    /// Remove all grid cells from the grid.
    public func ClearAll()
    {
        self.subviews.forEach({$0.removeFromSuperview()})
        GridCellMap.removeAll()
    }
    
    /// Update the grid. All grid cells have their `Redraw` member called.
    private func UpdateGrid()
    {
        for (_, Cell) in GridCellMap
        {
            Cell.Redraw()
        }
    }

    /// Map of grid cells to their addresses.
    public var GridCellMap = [String: GridCell]()
    
    // MARK: Protocol functions not used in this class
    
    /// Not used in this class.
    func CellCountChanged(ColumnCount: Int, RowCount: Int)
    {
        //Not used in this class.
    }
    
    /// Not used in this class.
    func CellSelectionStateChanged(Column: Int, Row: Int, IsSelected: Bool)
    {
        //Not used in this class.
    }
    
    /// Not used in this class.
    func Redraw()
    {
        //Not used in this class.
    }
    
    /// Not used in this class.
    func Start()
    {
        //Not used in this class.
    }
    
    // MARK: Functions to control individual cells.
    
    /// Return the cell with the specified address.
    /// - Note:
    ///    - Addresses are in the form `{Column}{Row}` where `Column` is a letter with `A` being the left-most column and proceeding
    ///      alphabetically. (Valid columns are `A` through `Z`). `Row` is a number starting at `1` for the top-most row and
    ///      incrementing for each lower row.
    ///    - There is no space between the Column and Row.
    ///    - All address searches are case insensitive so `a` is just as valid as `A` and both refer to the same column.
    ///    - If an invalid address is passed, no action will be taken.
    ///    - Some valid addresses are:
    ///      - `A1`, `V28`, `X5`, `d97`, `q13`.
    ///    - Malformed (eg, invalid) addresses may be:
    ///      - `1a`: Order must be Column Row.
    ///      - `A 1`: No spaces allowed between column and row.
    ///      - `aAAa 95`: Columns are valid only for `A` through `Z`.
    /// - Parameter AtAddress: The address of the cell to return.
    /// - Returns: The cell with the specified address on success, nil if not found.
    func GetCell(AtAddress: String) -> GridCell?
    {
        if let Cell = GridCellMap[AtAddress.lowercased()]
        {
            return Cell
        }
        print("Error finding \(AtAddress)")
        return nil
    }
    
    /// Set a grid cell's text.
    /// - Note:
    ///    - Addresses are in the form `{Column}{Row}` where `Column` is a letter with `A` being the left-most column and proceeding
    ///      alphabetically. (Valid columns are `A` through `Z`). `Row` is a number starting at `1` for the top-most row and
    ///      incrementing for each lower row.
    ///    - There is no space between the Column and Row.
    ///    - All address searches are case insensitive so `a` is just as valid as `A` and both refer to the same column.
    ///    - If an invalid address is passed, no action will be taken.
    ///    - Some valid addresses are:
    ///      - `A1`, `V28`, `X5`, `d97`, `q13`.
    ///    - Malformed (eg, invalid) addresses may be:
    ///      - `1a`: Order must be Column Row.
    ///      - `A 1`: No spaces allowed between column and row.
    ///      - `aAAa 95`: Columns are valid only for `A` through `Z`.
    /// - Parameter Address: Address of the grid cell.
    /// - Parameter WithText: The text to set the grid cell to.
    public func SetCell(_ Address: String, WithText: String)
    {
        if let Cell = GetCell(AtAddress: Address)
        {
            Cell.SetText(WithText)
        }
    }
    
    /// Set the specified grid cell's text to empty.
    /// - Note:
    ///    - Addresses are in the form `{Column}{Row}` where `Column` is a letter with `A` being the left-most column and proceeding
    ///      alphabetically. (Valid columns are `A` through `Z`). `Row` is a number starting at `1` for the top-most row and
    ///      incrementing for each lower row.
    ///    - There is no space between the Column and Row.
    ///    - All address searches are case insensitive so `a` is just as valid as `A` and both refer to the same column.
    ///    - If an invalid address is passed, no action will be taken.
    ///    - Some valid addresses are:
    ///      - `A1`, `V28`, `X5`, `d97`, `q13`.
    ///    - Malformed (eg, invalid) addresses may be:
    ///      - `1a`: Order must be Column Row.
    ///      - `A 1`: No spaces allowed between column and row.
    ///      - `aAAa 95`: Columns are valid only for `A` through `Z`.
    /// - Parameter Address: Address of the grid cell.
    public func ClearCellText(_ Address: String)
    {
        SetCell(Address, WithText: "")
    }
    
    /// Set a grid cell's background color.
    /// - Note:
    ///    - Addresses are in the form `{Column}{Row}` where `Column` is a letter with `A` being the left-most column and proceeding
    ///      alphabetically. (Valid columns are `A` through `Z`). `Row` is a number starting at `1` for the top-most row and
    ///      incrementing for each lower row.
    ///    - There is no space between the Column and Row.
    ///    - All address searches are case insensitive so `a` is just as valid as `A` and both refer to the same column.
    ///    - If an invalid address is passed, no action will be taken.
    ///    - Some valid addresses are:
    ///      - `A1`, `V28`, `X5`, `d97`, `q13`.
    ///    - Malformed (eg, invalid) addresses may be:
    ///      - `1a`: Order must be Column Row.
    ///      - `A 1`: No spaces allowed between column and row.
    ///      - `aAAa 95`: Columns are valid only for `A` through `Z`.
    /// - Parameter Address: Address of the grid cell.
    /// - Parameter WithBackgroundColor: The new color for the background.
    public func SetCell(_ Address: String, WithBackgroundColor: NSColor)
    {
        if let Cell = GetCell(AtAddress: Address)
        {
            Cell.BackgroundColor = WithBackgroundColor
        }
    }
    /// Set a grid cell's text color.
    /// - Note:
    ///    - Addresses are in the form `{Column}{Row}` where `Column` is a letter with `A` being the left-most column and proceeding
    ///      alphabetically. (Valid columns are `A` through `Z`). `Row` is a number starting at `1` for the top-most row and
    ///      incrementing for each lower row.
    ///    - There is no space between the Column and Row.
    ///    - All address searches are case insensitive so `a` is just as valid as `A` and both refer to the same column.
    ///    - If an invalid address is passed, no action will be taken.
    ///    - Some valid addresses are:
    ///      - `A1`, `V28`, `X5`, `d97`, `q13`.
    ///    - Malformed (eg, invalid) addresses may be:
    ///      - `1a`: Order must be Column Row.
    ///      - `A 1`: No spaces allowed between column and row.
    ///      - `aAAa 95`: Columns are valid only for `A` through `Z`.
    /// - Parameter Address: Address of the grid cell.
    /// - Parameter WithForegroundColor: The new text foreground color.
    public func SetCell(_ Address: String, WithForegroundColor: NSColor)
    {
        if let Cell = GetCell(AtAddress: Address)
        {
            Cell.SetForegroundColor(WithForegroundColor)
        }
    }
    
    /// Set a grid cell's font.
    /// - Note:
    ///    - Addresses are in the form `{Column}{Row}` where `Column` is a letter with `A` being the left-most column and proceeding
    ///      alphabetically. (Valid columns are `A` through `Z`). `Row` is a number starting at `1` for the top-most row and
    ///      incrementing for each lower row.
    ///    - There is no space between the Column and Row.
    ///    - All address searches are case insensitive so `a` is just as valid as `A` and both refer to the same column.
    ///    - If an invalid address is passed, no action will be taken.
    ///    - Some valid addresses are:
    ///      - `A1`, `V28`, `X5`, `d97`, `q13`.
    ///    - Malformed (eg, invalid) addresses may be:
    ///      - `1a`: Order must be Column Row.
    ///      - `A 1`: No spaces allowed between column and row.
    ///      - `aAAa 95`: Columns are valid only for `A` through `Z`.
    /// - Parameter Address: Address of the grid cell.
    /// - Parameter WithFont: The new font for the grid cell's label.
    public func SetCell(_ Address: String, WithFont: NSFont)
    {
        if let Cell = GetCell(AtAddress: Address)
        {
            Cell.SetFont(WithFont)
        }
    }
    
    // MARK: Protocol implementations and supporting functions and properties.
    
    /// Called when a grid cell's selection state changed. Passed along to the `GridDelegate`.
    /// - Parameter Column: The column address of the grid cell that was tapped.
    /// - Parameter Row: The row address of the grid cell that was tapped.
    /// - Parameter IsInSelectedState: The grid cell's new selection state.
    public func GridCellSelected(Column: Int, Row: Int, IsInSelectedState: Bool)
    {
        GridDelegate?.CellSelectionStateChanged(Column: Column, Row: Row, IsSelected: IsInSelectedState)
    }
    
    // MARK: - IBInspectable properties.
    
    /// Holds the number of columns in the grid.
    private var _Columns: Int = 0
    {
        didSet
        {
            DrawGrid()
        }
    }
    /// Get or set the number of columns in the grid. Setting this value will immediately recreate the grid.
    @IBInspectable public var Columns: Int
        {
        get
        {
            return _Columns
        }
        set
        {
            _Columns = newValue
        }
    }
    
    /// Holds the number of rows in the grid.
    private var _Rows: Int = 0
    {
        didSet
        {
            DrawGrid()
        }
    }
    /// Get or set the number of rows in the grid. Setting this value will immediately recreate the grid.
    @IBInspectable public var Rows: Int
        {
        get
        {
            return _Rows
        }
        set
        {
            _Rows = newValue
        }
    }
    
    /// Holds the base, unselected background color for grid cells.
    private var _BaseBackground: NSColor = NSColor.white
    {
        didSet
        {
            UpdateGrid()
        }
    }
    /// Get or set the base, unselected background color for grid cells.
    @IBInspectable public var BaseBackground: NSColor
        {
        get
        {
            return _BaseBackground
        }
        set
        {
            _BaseBackground = newValue
        }
    }
    
    /// Returns the base, unselected background color for grid cells.
    /// - Returns: Color to use for base, unselected backgrounds.
    func GetBaseBackgroundColor() -> NSColor
    {
        return _BaseBackground
    }
    
    /// Holds the selected background color for grid cells.
    private var _SelectedBackground: NSColor = NSColor.red
    {
        didSet
        {
            UpdateGrid()
        }
    }
    /// Get or set the selected background color for grid cells.
    @IBInspectable public var SelectedBackground: NSColor
        {
        get
        {
            return _SelectedBackground
        }
        set
        {
            _SelectedBackground = newValue
        }
    }
    
    /// Returns the selected background color for grid cells.
    /// - Returns: Color to use for selected backgrounds.
    func GetSelectedBackgroundColor() -> NSColor
    {
        return _SelectedBackground
    }
    
    /// Holds the border color for grid cells.
    private var _BorderColor: NSColor = NSColor.black
    {
        didSet
        {
            UpdateGrid()
        }
    }
    /// Get or set the border color to use for grid cells.
    @IBInspectable public var BorderColor: NSColor
        {
        get
        {
            return _BorderColor
        }
        set
        {
            _BorderColor = newValue
        }
    }
    
    /// Returns the border color for grid cells.
    /// - Returns: Color to use for grid cell borders.
    public func GetBaseBorderColor() -> NSColor
    {
        return _BorderColor
    }
    
    /// Holds the width of grid cell borders.
    private var _BorderWidth: CGFloat = 0.5
    {
        didSet
        {
            UpdateGrid()
        }
    }
    /// Get or set the width of grid cell borders.
    @IBInspectable public var BorderWidth: CGFloat
        {
        get
        {
            return _BorderWidth
        }
        set
        {
            _BorderWidth = newValue
        }
    }
    
    /// Returns the width to use when drawing grid cell borders.
    /// - Returns: Value to use as the width for grid cell borders.
    func GetBorderWidth() -> CGFloat
    {
        return _BorderWidth
    }
}
