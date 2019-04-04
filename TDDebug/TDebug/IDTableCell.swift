//
//  IDTableCell.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class IDTableCell: UITableViewCell
{
    public static var CellHeight: CGFloat = 40.0
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    var TitleLabel: UILabel!
    var ValueLabel: UILabel!
    
    override init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        let TableWidth = self.contentView.bounds.width
        
        TitleLabel = UILabel(frame: CGRect(x: 15, y: 5, width: 85, height: 30))
        TitleLabel.font = UIFont(name: "Avenir", size: 18.0)
        TitleLabel.textColor = UIColor.blue
        self.contentView.addSubview(TitleLabel)
        
        ValueLabel = UILabel(frame: CGRect(x: 95, y: 5, width: TableWidth - 95, height: 30))
        ValueLabel.font = UIFont(name: "Avenir-Bold", size: 18.0)
        ValueLabel.textColor = UIColor.black
        self.contentView.addSubview(ValueLabel)
    }
    
    public func SetData(Name: String, Value: String)
    {
        TitleLabel.text = Name
        ValueLabel.text = Value
    }
}
