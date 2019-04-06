//
//  FiltererUICode.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class FiltererUICode: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    var HaveDelegate = false
    weak var Delegate: MainProtocol!
        {
        didSet
        {
            HaveDelegate = true
            RefreshSourceList()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        FilterBy = FilterObject()
        SetUI()
        UpdateUI()
    }
    
    func SetUI()
    {
        switch (FilterBy?.FilterTextAs)!
        {
        case .Word:
            TextFilterSegment.selectedSegment = 0
            
        case .List:
            TextFilterSegment.selectedSegment = 1
            
        case .Regex:
            TextFilterSegment.selectedSegment = 2
        }
        ShowTextFilterLabelFor(TextFilterSegment.selectedSegment)
        ContainingSegment.selectedSegment = (FilterBy?.TextMustContain)! ? 0 : 1
        EnableFilteringCheck.state = (FilterBy?.EnableFiltering)! ? .on : .off
        SourceColumnContainsCheck.state = (FilterBy?.BySource)! ? .on : .off
        TextContainsCheck.state = (FilterBy?.ByText)! ? .on : .off
        TextMask.stringValue = (FilterBy?.TextToFind)!
        AndOrSegment.selectedSegment = (FilterBy?.CombineLogicalOperator)! == .And ? 0 : 1
        FilterBy?.SourceList.sort{$0.0 < $1.0}
        SourceTable.deselectAll(self)
        SourceTable.reloadData()
        var Indices = IndexSet()
        for Index in 0 ..< (FilterBy?.SourceList.count)!
        {
            if (FilterBy?.SourceList[Index].1)!
            {
                let Element = IndexSet.Element(Index)
                Indices.update(with: Element)
            }
        }
        SourceTable.selectColumnIndexes(Indices, byExtendingSelection: true)
    }
    
    func RefreshSourceList()
    {
        FilterBy = Delegate.GetFilterObject()
        SetUI()
        UpdateUI()
        SourceTable.reloadData()
    }
    
    var FilterBy: FilterObject? = nil
    
    var SourceList = [String]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        if FilterBy == nil
        {
            return 0
        }
        return (FilterBy?.SourceList.count)!
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let Content = (FilterBy?.SourceList[row].0)!
        //print("row(\(row))=\(Content)")
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SourceColumn"), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = Content
        return Cell
    }
    
    func UpdateUI()
    {
        if EnableFilteringCheck.state == .off
        {
            SourceColumnContainsCheck.isEnabled = false
            SourceTable.isEnabled = false
            AndOrSegment.isEnabled = false
            TextContainsCheck.isEnabled = false
            TextMask.isEnabled = false
            ResetButton.isEnabled = false
            TestFilterButton.isEnabled = false
            ReloadSourceButton.isEnabled = false
            ContainingSegment.isEnabled = false
        }
        else
        {
            SourceColumnContainsCheck.isEnabled = true
            if SourceColumnContainsCheck.state == .on && TextContainsCheck.state == .on
            {
                AndOrSegment.isEnabled = true
            }
            else
            {
                AndOrSegment.isEnabled = false
            }
            TextContainsCheck.isEnabled = true
            ResetButton.isEnabled = true
            SourceTable.isEnabled = SourceColumnContainsCheck.state == .on
            ReloadSourceButton.isEnabled = SourceColumnContainsCheck.state == .on
            TextMask.isEnabled = TextContainsCheck.state == .on
            ContainingSegment.isEnabled = TextContainsCheck.state == .on
            TextFilterSegment.isEnabled = TextContainsCheck.state == .on
            TextFilterLabel.isEnabled = TextContainsCheck.state == .on
            TestFilterButton.isEnabled = true
        }
    }
    
    @IBAction func HandleEnableFilteringChanged(_ sender: Any)
    {
        FilterBy?.EnableFiltering = EnableFilteringCheck.state == .on
        UpdateUI()
    }
    
    @IBAction func HandleSourceContainsCheckChanged(_ sender: Any)
    {
        FilterBy?.BySource = SourceColumnContainsCheck.state == .on
        UpdateUI()
    }
    
    func GatherFilterData()
    {
        FilterBy?.TextToFind = TextMask.stringValue
        FilterBy?.FilterTextAs = [.Word, .List, .Regex][TextFilterSegment.selectedSegment]
        FilterBy?.EnableFiltering = EnableFilteringCheck.state == .on
        let BySource = SourceColumnContainsCheck.state == .on
        let ByText = TextContainsCheck.state == .on
        FilterBy?.BySource = BySource
        FilterBy?.ByText = ByText
        FilterBy?.TextMustContain = ContainingSegment.selectedSegment == 0
        FilterBy?.CombineLogicalOperator = AndOrSegment.selectedSegment == 0 ? .And : .Or
        for Index in 0 ..< (FilterBy?.SourceList.count)!
        {
            FilterBy?.SourceList[Index] = ((FilterBy?.SourceList[Index].0)!, false)
        }
        let SelectedRows = SourceTable.selectedRowIndexes
        for Row in SelectedRows
        {
            FilterBy?.SourceList[Row] = ((FilterBy?.SourceList[Row].0)!, true)
            //print("Selected[\(Row)]: \((FilterBy?.SourceList[Row].0)!)")
        }
    }
    
    @IBAction func HandleTestFilter(_ sender: Any)
    {
        GatherFilterData()
        Delegate?.SetFilterTest(FilterBy)
    }
    
    @IBAction func HandleTextContainsCheckChanged(_ sender: Any)
    {
        UpdateUI()
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        GatherFilterData()
        Delegate?.SetFilterObject(Canceled: false, FilterBy)
        self.view.window!.performClose(sender)
    }
    
    @IBAction func HandleResetPressed(_ sender: Any)
    {
        SourceColumnContainsCheck.state = .on
        TextContainsCheck.state = .on
        TextMask.stringValue = ""
        AndOrSegment.selectedSegment = 0
        SourceTable.selectAll(self)
        ContainingSegment.selectedSegment = 0
        TextFilterSegment.selectedSegment = 0
    }
    
    @IBAction func HandleReloadSourceButtonPressed(_ sender: Any)
    {
        let NewSourceList = Delegate?.GetFilterSourceList()
        FilterBy?.SourceList.removeAll()
        for Source in NewSourceList!
        {
            FilterBy?.SourceList.append((Source, true))
        }
        SourceTable.reloadData()
        SourceTable.selectAll(self)
    }
    
    @IBAction func HandleUndoTestButtonPressed(_ sender: Any)
    {
        Delegate?.UndoFilterTest()
    }
    
    func ShowTextFilterLabelFor(_ Index: Int)
    {
        switch Index
        {
        case 0:
            TextFilterLabel.stringValue = ""
            
        case 1:
            TextFilterLabel.stringValue = "Comma-separated list of words/phrases. Any word match is a success."
            
        case 2:
            TextFilterLabel.stringValue = "Enter regex to filter text."
            
        default:
            TextFilterLabel.stringValue = ""
        }
    }
    
    @IBAction func HandleTextFilterChanged(_ sender: Any)
    {
        ShowTextFilterLabelFor(TextFilterSegment.selectedSegment)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        Delegate?.SetFilterObject(Canceled: true, nil)
        self.view.window!.performClose(sender)
    }
    
    @IBOutlet weak var TextFilterLabel: NSTextField!
    @IBOutlet weak var TextFilterSegment: NSSegmentedControl!
    @IBOutlet weak var UndoTestButton: NSButton!
    @IBOutlet weak var ContainingSegment: NSSegmentedControl!
    @IBOutlet weak var ReloadSourceButton: NSButton!
    @IBOutlet weak var TestFilterButton: NSButton!
    @IBOutlet weak var CancelButton: NSButton!
    @IBOutlet weak var OKButton: NSButton!
    @IBOutlet weak var ResetButton: NSButton!
    @IBOutlet weak var SourceTable: NSTableView!
    @IBOutlet weak var TextMask: NSTextField!
    @IBOutlet weak var TextContainsCheck: NSButton!
    @IBOutlet weak var SourceColumnContainsCheck: NSButton!
    @IBOutlet weak var EnableFilteringCheck: NSButton!
    @IBOutlet weak var AndOrSegment: NSSegmentedControl!
}
