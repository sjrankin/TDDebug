//
//  LogTableCell.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Displays a log item in a UITableView.
class LogTableCell: UITableViewCell
{
    /// Height of the cell.
    public static var CellHeight: CGFloat = 80.0
    
    /// Required. See Apple documentation.
    ///
    /// - Parameter aDecoder: See Apple documentation.
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    /// Host name label.
    var HostLabel: UILabel!
    
    /// Time stamp label.
    var TimeStampLabel: UILabel!
    
    /// Value, eg, text message, label.
    var ValueLabel: UILabel!
    
    /// Set up the visual aspect of the cell.
    ///
    /// - Parameters:
    ///   - Style: Style of the cell. Implicitly ignored for our own style.
    ///   - ReuseIdentifier: Reuse identifier - passed to super.init.
    override init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        let TableWidth = self.frame.width * 2
        
        HostLabel = UILabel(frame: CGRect(x: 15, y: 10, width: 100, height: 20))
        HostLabel.font = UIFont(name: "Avenir", size: 16.0)
        HostLabel.textColor = UIColor.black
        self.contentView.addSubview(HostLabel)
        
        TimeStampLabel = UILabel(frame: CGRect(x: 125, y: 10, width: TableWidth - 125, height: 20))
        TimeStampLabel.font = UIFont(name: "Avenir", size: 16.0)
        TimeStampLabel.textColor = UIColor.darkGray
        self.contentView.addSubview(TimeStampLabel)
        
        ValueLabel = UILabel(frame: CGRect(x: 15, y: 30, width: TableWidth - 15, height: 45))
        ValueLabel.font = UIFont(name: "Avenir-Bold", size: 18.0)
        ValueLabel.textColor = UIColor.black
        ValueLabel.numberOfLines = 2
        self.contentView.addSubview(ValueLabel)
        
        self.accessoryType = .disclosureIndicator
    }
    
    /// Holds the log item.
    var TheItem: LogItem!
    
    /// Sets the log item to display.
    ///
    /// - Parameter Item: The log item to display.
    public func SetData(Item: LogItem)
    {
        TheItem = Item
        TimeStampLabel.text = TheItem.Title
        ValueLabel.text = TheItem.Message
        if let HostName = TheItem.HostName
        {
            HostLabel.text = HostName
        }
        else
        {
            HostLabel.text = "TDebug"
        }
        if let BGColor = TheItem.BGColor
        {
            self.backgroundColor = BGColor
        }
        if let FGColor = TheItem.FGColor
        {
            ValueLabel.textColor = FGColor
        }
        //If needed, animated the insertion.
        if TheItem.DoAnimateBGColor
        {
            if TheItem.HasAnimated
            {
                self.backgroundColor = TheItem.BGAnimateTargetColor
            }
            else
            {
                UIView.animate(withDuration: TheItem.BGAnimateColorDuration, animations:
                    {
                        self.backgroundColor = self.TheItem.BGAnimateTargetColor
                }, completion:
                    {
                        _ in
                        self.TheItem.HasAnimated = true
                })
            }
        }
    }
    
    /// Get the ID of the log item being displayed. This is from the data passed in `SetData`.
    ///
    /// - Returns: ID of the displayed log item.
    public func GetID() -> UUID
    {
        return TheItem.ID!
    }
}
