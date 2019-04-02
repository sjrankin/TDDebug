//
//  OSColor.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/2/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
#if FOR_MACOS
import AppKit
#else
import UIKit
#endif

#if FOR_MACOS
/// Ultra-thin wrapper around NSColor.
class OSColor: NSColor
{

}
#else
/// Ultra-thin wrapper around UIColor.
class OSColor: UIColor
{
    
}
#endif
