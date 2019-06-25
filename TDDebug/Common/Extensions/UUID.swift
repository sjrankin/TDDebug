//
//  UUID.swift
//  TDDebug
//
//  Created by Stuart Rankin on 6/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation


/// Convenience extensions for UUID.
extension UUID
{
    /// Returns an empty UUID (all zero values for all fields).
    static var Empty: UUID
    {
        get
        {
            return UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        }
    }
}
