//
//  SelectorWindowUI.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class SelectorWindowUI: NSViewController
{
    weak var Delegate: SelectorDelegate? = nil
        {
        didSet
        {
            LoadUI()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear()
    {
        super.viewWillAppear()
        MessageHeader.stringValue = MainMessage
    }
    
    func LoadUI()
    {
        MessageHeader.stringValue = (Delegate?.SelectorTitle())!
    }
    
    var MainMessage: String = ""
    
    @IBAction func RadioButtonAction(_ sender: Any)
    {
    }
    
    @IBOutlet weak var MessageHeader: NSTextField!
    @IBOutlet weak var HeaderRadioButton: NSButton!
    @IBOutlet weak var MessageRadioButton: NSButton!
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .cancel)
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        let Result = HeaderRadioButton.state == .on ? 1000 : 2000
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: NSApplication.ModalResponse(Result))
    }
}
