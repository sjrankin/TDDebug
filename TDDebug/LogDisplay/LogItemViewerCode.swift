//
//  LogItemViewerCode.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class LogItemViewerCode: UIViewController, LogItemProtocol
{
    var DisplayItem: LogItem!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        TextBox.text = DisplayItem.Message
        TimeStampLabel.text = DisplayItem.Title
        ItemIDLabel.text = DisplayItem.ID?.uuidString
    }
    
    func SetLogItem(_ Item: LogItem)
    {
        DisplayItem = Item
    }
    
    @IBAction func HandleFontStepperChanged(_ sender: Any)
    {
        if let Stepper = sender as? UIStepper
        {
            let FontSize = CGFloat(Stepper.value)
            TextBox.font = UIFont(name: "Courier", size: FontSize)
            FontSizeDisplay.title = "\(Int(FontSize))"
        }
    }
    
    @IBAction func HandleBackButton(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var FontSizeDisplay: UIBarButtonItem!
    @IBOutlet weak var ItemIDLabel: UILabel!
    @IBOutlet weak var TimeStampLabel: UILabel!
    @IBOutlet weak var TextBox: UITextView!
    @IBOutlet weak var FontSizeStepper: UIStepper!
}
