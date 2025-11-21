// SwiftUI Popovers
// Copyright (c) 2025 Quirin Schweigert
// Licensed under the MIT License. See LICENSE file for details.

import SwiftUI

public struct PopoverMessageBubble<Content: View, F: ShapeStyle, S: ShapeStyle>: View {
    let cornerRadius: CGFloat = 22

    var showArrow: Bool = true
    var fill: F
    var secondaryFill: S?
    var enableGlassEffect: Bool
    var padding: EdgeInsets

    @ViewBuilder let content: () -> Content

    @Environment(\.effectiveAttachmentPoint) var effectiveAttachmentPoint
    
    var arrowEdge: MessageBubbleShape.ArrowEdge? {
        effectiveAttachmentPoint.map { $0.y > 0 ? .bottom : .top }
    }

    public var body: some View {
        content()
            .padding(padding)
            .background {
                ZStack {
                    if #available(iOS 26.0, macOS 26.0, watchOS 26.0, visionOS 26.0, tvOS 26.0, *),
                       enableGlassEffect {
                        backgroundShape
                            .fill(fill)
                            .glassEffect(in: backgroundShape)
                    } else {
                        backgroundShape
                            .fill(fill)
                    }
                    
                    if let secondaryFill {
                        backgroundShape
                            .fill(secondaryFill)
                    }
                }
            }
            .font(.system(size: 16, weight: .medium))
            .multilineTextAlignment(.center)
            .padding(arrowEdge == .bottom ? .bottom : .top, showArrow ? 12 : 4)
    }
    
    var backgroundShape: AnyShape {
        if showArrow {
            AnyShape(MessageBubbleShape(
                arrowEdge: arrowEdge ?? .bottom,
                cornerRadius: cornerRadius,
                arrowOffset: effectiveAttachmentPoint ?? .zero
            ))
        } else {
            AnyShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }

    public init(
        showArrow: Bool = true,
        fill: F,
        secondaryFill: S? = nil,
        enableGlassEffect: Bool = false,
        padding: EdgeInsets = PopoverConstants.defaultPadding,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.showArrow = showArrow
        self.fill = fill
        self.secondaryFill = secondaryFill
        self.enableGlassEffect = enableGlassEffect
        self.padding = padding
        self.content = content
    }
}

public struct PopoverConstants {
    #if os(watchOS)
    public static let defaultPadding: EdgeInsets = .init(
        top: 6,
        leading: 12,
        bottom: 6,
        trailing: 12
    )
    #else
    public static let defaultPadding: EdgeInsets = .init(
        top: 8,
        leading: 16,
        bottom: 8,
        trailing: 16
    )
    #endif
}

@available(iOS 17.0, *)
public extension PopoverMessageBubble where S == Never {
    init(
        fill: F,
        @ViewBuilder content: @escaping () -> Content,
        padding: EdgeInsets = PopoverConstants.defaultPadding
    ) {
        self.init(fill: fill, secondaryFill: nil, padding: padding, content: content)
    }
    
    init(fill: F, padding: EdgeInsets, @ViewBuilder content: @escaping () -> Content) {
        self.init(fill: fill, secondaryFill: nil, padding: padding, content: content)
    }
}

public struct MessageBubbleShape: Shape {
    public struct Constants {
        #if os(watchOS)
        static let arrowSize: CGFloat = 12
        #else
        static let arrowSize: CGFloat = 9
        #endif
        
        static let arrowPath: Path = MessageBubbleShape.arrowPath(size: arrowSize)
    }

    public enum ArrowEdge: Sendable {
        case top
        case right
        case bottom
        case left
    }

    public let arrowEdge: ArrowEdge
    public let cornerRadius: CGFloat
    public let arrowOffset: CGPoint

    public func path(in rect: CGRect) -> Path {
        .init { path in
            let cornerSize: CGSize = .init(width: cornerRadius, height: cornerRadius)
            path.addRoundedRect(in: rect, cornerSize: cornerSize, style: .circular)

            let maxOffset = max(0, rect.width / 2 - Constants.arrowSize * 1.5 - cornerRadius)
            
            let arrowOffsetX: CGFloat =
                (-maxOffset...maxOffset).clamp(arrowOffset.x - rect.width / 2)

            let transform: CGAffineTransform

            switch arrowEdge {
            case .bottom:
                transform = .identity
                    .translatedBy(x: rect.midX + arrowOffsetX, y: rect.maxY)

            case .top:
                transform = .identity
                    .scaledBy(x: 1, y: -1)
                    .translatedBy(x: rect.midX + arrowOffsetX, y: 0)
                
            case .left:
                transform =
                    .identity
                    .translatedBy(x: 0, y: rect.height / 2)
                    .rotated(by: .pi / 2)

            case .right:
                transform = .identity
                    .translatedBy(x: rect.width, y: rect.height / 2)
                    .rotated(by: -.pi / 2)

            }

            path.addPath(Constants.arrowPath, transform: transform)
        }
    }
    
    static func arrowPath(size: CGFloat) -> Path {
        Path { path in
            let arrowHeight = size
            let cornerRadius: CGFloat = arrowHeight * 0.5
            
            let arrowWidth = arrowHeight + cornerRadius * 4

            path.addArc(
                center: .init(x: -arrowWidth / 2, y: cornerRadius),
                radius: cornerRadius,
                startAngle: .radians(-.pi * 2 / 4),
                endAngle: .radians(-.pi * 1 / 4),
                clockwise: false
            )
            
            path.addArc(
                center: .init(x: 0, y: arrowHeight - cornerRadius),
                radius: cornerRadius,
                startAngle: .radians(.pi * 3 / 4),
                endAngle: .radians(.pi * 1 / 4),
                clockwise: true
            )
            
            path.addArc(
                center: .init(x: arrowWidth / 2, y: cornerRadius),
                radius: cornerRadius,
                startAngle: .radians(.pi * 5 / 4),
                endAngle: .radians(.pi * 6 / 4),
                clockwise: false
            )
        }
    }

    public init(
        arrowEdge: ArrowEdge = .bottom,
        cornerRadius: CGFloat = 20,
        arrowOffset: CGPoint = .zero
    ) {
        self.arrowEdge = arrowEdge
        self.cornerRadius = cornerRadius
        self.arrowOffset = arrowOffset
    }
}
