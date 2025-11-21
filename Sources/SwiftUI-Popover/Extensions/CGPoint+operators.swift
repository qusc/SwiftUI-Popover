// SwiftUI Popovers
// Copyright (c) 2025 Quirin Schweigert
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

extension CGPoint {
    static func + (left: CGPoint, right: CGSize) -> CGPoint {
        return CGPoint(x: left.x + right.width, y: left.y + right.height)
    }

    static func - (left: CGPoint, right: CGSize) -> CGPoint {
        return CGPoint(x: left.x - right.width, y: left.y - right.height)
    }

    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    func offset(by offset: CGPoint) -> Self {
        .init(x: x + offset.x, y: y + offset.y)
    }
}
