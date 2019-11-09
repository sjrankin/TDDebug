//
//  GridCell.swift
//  TDDebug
//
//  Created by Stuart Rankin on 11/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Contains a single cell for the `Grid` control.
class GridCell: NSView, IntraGridProtocol
{
    /// Used for communicating with the `Grid` parent control.
    weak var CellParentDelegate: IntraGridProtocol? = nil
    
    // MARK: - Initialization
    
    /// Initializer.
    /// - Parameter frame: Frame of the cell.
    override init(frame: NSRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    init(frame: NSRect, TagValue: Any)
    {
        super.init(frame: frame)
        Initialize(WithTag: TagValue)
    }
    
    init(frame: NSRect, State: CellState)
    {
        super.init(frame: frame)
        Initialize(WithState: State)
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Initialize the grid cell.
    /// - Parameter WithTag: The initial tag value.
    public func Initialize(WithTag: Any? = nil)
    {
        //Set up mouse tracking.
        let TrackingArea = NSTrackingArea(rect: self.bounds,
                                          options: [.mouseEnteredAndExited, .activeAlways],
                                          owner: self,
                                          userInfo: nil)
        self.addTrackingArea(TrackingArea)
        if let InitialTag = WithTag
        {
            Tag = InitialTag
        }
        else
        {
            Tag = nil
        }
        self.wantsLayer = true
        self.layer?.masksToBounds = true
        _Label = NSTextField(labelWithString: "")
        _Label?.alignment = .center
        _Label?.lineBreakMode = .byWordWrapping
        let ParentWidth = self.frame.width
        let ParentHeight = self.frame.height
        _Label?.frame = NSRect(x: 2, y: 2, width: ParentWidth - 4, height: ParentHeight - 4)
        _Label?.font = NSFont.systemFont(ofSize: 14.0)
        _Label?.alphaValue = 1.0
        _Label?.maximumNumberOfLines = 4
        if let SomeTag = Tag
        {
            _Label?.tag = (SomeTag as? Int)!
        }
        self.subviews.forEach({$0.removeFromSuperview()})
        self.addSubview(_Label!)
    }
    
    /// Initialize the grid cell.
    /// The state used to initialize the contents of the cell.
    public func Initialize(WithState: CellState)
    {
        //Set up mouse tracking.
        let TrackingArea = NSTrackingArea(rect: self.bounds,
                                          options: [.mouseEnteredAndExited, .activeAlways],
                                          owner: self,
                                          userInfo: nil)
        self.addTrackingArea(TrackingArea)
        Tag = WithState.CellTag
        self.wantsLayer = true
        self.layer?.masksToBounds = true
        _Label = NSTextField(labelWithString: WithState.CellContents)
        _Label?.alignment = .center
        _Label?.lineBreakMode = .byWordWrapping
        let ParentWidth = self.frame.width
        let ParentHeight = self.frame.height
        _Label?.frame = NSRect(x: 2, y: 2, width: ParentWidth - 4, height: ParentHeight - 4)
        _Label?.font = NSFont.systemFont(ofSize: 14.0)
        _Label?.alphaValue = 1.0
        _Label?.maximumNumberOfLines = 4
        if let SomeTag = Tag
        {
            _Label?.tag = (SomeTag as? Int)!
        }
        self.subviews.forEach({$0.removeFromSuperview()})
        self.addSubview(_Label!)
        SetForegroundColor(WithState.TextColor)
        BackgroundColor = WithState.BackgroundColor
        Address = WithState.CellAddress
    }
    
    /// Holds the label.
    private var _Label: NSTextField? = nil
    
    /// Start "execution" of the grid cell. Should be called after initialization.
    func Start()
    {
        DrawCell()
        display()
    }
    
    // MARK: - Label functions.
    
    /// Change the text of the cell.
    /// - Parameter NewText: New text to display.
    func SetText(_ NewText: String)
    {
        _Label?.stringValue = NewText
    }
    
    /// Change the font of the cell.
    /// - Parameter: New font for the label.
    func SetFont(_ NewFont: NSFont)
    {
        _Label?.font = NewFont
    }
    
    /// Change the text color.
    /// - Parameter NewColor: New text color.
    func SetForegroundColor(_ NewColor: NSColor)
    {
        _Label?.textColor = NewColor
    }
    
    // MARK: - Drawing functions.
    
    /// Redraw the grid cell. Can be called by the parent `Grid`.
    public func Redraw()
    {
        DrawCell()
    }
    
    /// Draw the grid cell.
    private func DrawCell()
    {
        self.layer?.backgroundColor = BackgroundColor.cgColor
        self.layer?.borderWidth = (CellParentDelegate?.GetBorderWidth())!
        self.layer?.borderColor = (CellParentDelegate?.GetBaseBorderColor())!.cgColor
    }
    
    // MARK: - Properities
    
    /// Holds the cell's background color.
    private var _BackgroundColor: NSColor = NSColor.systemIndigo
    /// Get or set the background color of the cell.
    public var BackgroundColor: NSColor
    {
        get
        {
            return _BackgroundColor
        }
        set
        {
            _BackgroundColor = newValue
            self.layer?.backgroundColor = newValue.cgColor
        }
    }
    
    /// Holds the address of the grid cell.
    private var _Address: String = ""
    /// Get or set the address of the grid cell.
    public var Address: String
    {
        get
        {
            return _Address
        }
        set
        {
            _Address = newValue
        }
    }
    
    /// Holds the tag value.
    private var _Tag: Any? = nil
    /// Get or set the tag value.
    /// - Note:
    ///   - This is a true tag in the sense that it can contain anything (and not just an integer).
    ///   - This value is not used in any way by the `GridCell` class.
    public var Tag: Any?
    {
        get
        {
            return _Tag
        }
        set
        {
            _Tag = newValue
        }
    }
    
    /// Holds the column value.
    private var _Column: Int = -1
    /// Get or set the column value. This is the column in the parent grid where the instance of the cell lives.
    /// - Note: While changeable, the design of the `Grid` uses cell coordinates to report events, so changing this value
    ///         is ill-advised.
    public var Column: Int
    {
        get
        {
            return _Column
        }
        set
        {
            _Column = newValue
        }
    }
    
    /// Holds the row value.
    private var _Row: Int = -1
    /// Get or set the row value. This is the row in the parent grid where the instance of the cell lives.
    /// - Note: While changeable, the design of the `Grid` uses cell coordinates to report events, so changing this value
    ///         is ill-advised.
    public var Row: Int
    {
        get
        {
            return _Row
        }
        set
        {
            _Row = newValue
        }
    }
    
    /// Not intended to be called. Returns `NSColor.clear`.
    func GetBaseBackgroundColor() -> NSColor
    {
        return NSColor.clear
    }
    
    /// Not intended to be called. Returns `NSColor.clear`.
    func GetSelectedBackgroundColor() -> NSColor
    {
        return NSColor.clear
    }
    
    /// Not intended to be called. Returns `NSColor.clear`.
    func GetBaseBorderColor() -> NSColor
    {
        return NSColor.clear
    }
    
    /// Not intended to be called. Returns `0.0`.
    func GetBorderWidth() -> CGFloat
    {
        return 0.0
    }
    
    var OldBG: NSColor = NSColor.systemBrown
    override func mouseEntered(with event: NSEvent)
    {
        OldBG = BackgroundColor
        BackgroundColor = NSColor.systemYellow
    }
    
    override func mouseExited(with event: NSEvent)
    {
        BackgroundColor = OldBG
    }
    
    // MARK: State functions.
    
    /// Returns the current state context of the cell. This data can be used to reconstruct a cell if necessary.
    /// - Returns: Object with the state of the cell.
    public func GetState() -> CellState
    {
        let CurrentState = CellState()
        CurrentState.BackgroundColor = BackgroundColor
        CurrentState.TextColor = _Label!.textColor!
        CurrentState.CellAddress = Address
        CurrentState.CellContents = _Label!.stringValue
        CurrentState.CellTag = Tag
        return CurrentState
    }
    
    /// Populate the cell with the passed state information.
    /// - Parameter ExistingState: The state to use to populate the cell.
    public func SetState(_ ExistingState: CellState)
    {
        Initialize(WithState: ExistingState)
    }
}
