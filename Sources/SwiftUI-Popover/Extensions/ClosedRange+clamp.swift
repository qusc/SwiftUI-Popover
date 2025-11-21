// SwiftUI Popovers
// Copyright (c) 2025 Quirin Schweigert
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

extension ClosedRange {
    func clamp(_ value: Bound) -> Bound {
        value < lowerBound ? lowerBound : value > upperBound ? upperBound : value
    }
}
