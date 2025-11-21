// SwiftUI Popovers
// Copyright (c) 2025 Quirin Schweigert
// Licensed under the MIT License. See LICENSE file for details.

import SwiftUI

struct PopoverPresentationModifier: ViewModifier {
    struct EffectiveAttachmentPointKey: EnvironmentKey {
        static let defaultValue: CGPoint? = .none
    }

    @State var popoverContentSizes: [UUID: CGSize] = [:]

    var padding: EdgeInsets?

    func body(content: Content) -> some View {
        content
            .overlayPreferenceValue(PopoverModifier.PopoverPreferenceKey.self) { popovers in
                GeometryReader { presentationGeometry in
                    ForEach(popoversToPresent(of: popovers)) { popover in
                        overlay(for: popover, in: presentationGeometry)
                    }
                }
                .padding(padding ?? .init(top: 8, leading: 0, bottom: 0, trailing: 8))
                .background {
                    if let onDismiss = popovers.first(where: { $0.onDismiss != nil })?.onDismiss {
                        Color.black.opacity(0.1).edgesIgnoringSafeArea(.all)
                            .contentShape(Rectangle())
                            .simultaneousGesture(
                                DragGesture(minimumDistance: .zero)
                                    .onChanged({ _ in onDismiss() })
                            )
                    }
                }
                .edgesIgnoringSafeArea(.all)
                #if os(watchOS)
                .buttonStyle(.plain)
                #endif
            }
            .preference(key: PopoverModifier.PopoverPreferenceKey.self, value: [])
    }
    
    @ViewBuilder func overlay(
        for popover: PopoverModifier.Popover,
        in presentationGeometry: GeometryProxy
    ) -> some View {
        let anchorFrame = presentationGeometry[popover.anchor]

        let attachmentEdge: VerticalEdge = popover.preferredAttachmentEdge ??
            (anchorFrame.midY > presentationGeometry.size.height / 2 ? .top : .bottom)

        let attachmentPoint = attachmentPoint(
            of: anchorFrame,
            at: attachmentEdge == .top ? .top : .bottom
        )

        let contentSize = popoverContentSizes[popover.id]

        let idealFrame = idealFrame(
            forContentSize: contentSize ?? .zero,
            attachedTo: attachmentPoint,
            at: attachmentEdge == .top ? .bottom : .top
        )

        let constrainedFrame = constrainedFrame(
            idealFrame,
            in: presentationGeometry.frame(in: .local)
        )
        
        let effectiveAttachmentPoint = attachmentPoint - constrainedFrame.origin

        let verticalDelta = abs(constrainedFrame.midY - idealFrame.midY)
        let hidePopover = verticalDelta > 1

        if contentSize == nil {
            /// Show in a hidden state until we have the content size and can position the view correctly
            popover.content()
                .onGeometryChange(for: CGSize.self) { geometry in
                    geometry.size
                } action: { newSize in
                    popoverContentSizes[popover.id] = newSize
                }
                .hidden()
        } else {
            /// We could calcuate the effective attachment point here and pass it to popover container to dynamically adjust the
            /// arrow position
            popover.content()
                .environment(\.effectiveAttachmentPoint, effectiveAttachmentPoint)
                .onGeometryChange(for: CGSize.self) { geometry in
                    geometry.size
                } action: { newSize in
                    popoverContentSizes[popover.id] = newSize
                }
                .offset(x: constrainedFrame.minX, y: constrainedFrame.minY)
                .opacity(hidePopover ? 0 : 1)
                .animation(.default, value: hidePopover)
                .transition(.asymmetric(
                    insertion: .opacity
                        .animation(popover.disableDelay ? .default : .default.delay(0.5)),
                    removal: .offset(y: 10).combined(with: .opacity).animation(.default))
                )
        }
    }

    func popoversToPresent(of popovers: [PopoverModifier.Popover]) -> [PopoverModifier.Popover] {
        if let exclusivePopover = popovers.last(where: { $0.isExclusive }) {
            [exclusivePopover]
        } else {
            popovers
        }
    }

    /// For now: always attach at the top right corner of the popover content and bottom middle of the view it's attached to
    func attachmentPoint(of anchor: CGRect, at unitPoint: UnitPoint) -> CGPoint {
        .init(
            x: anchor.minX + unitPoint.x * anchor.width,
            y: anchor.minY + unitPoint.y * anchor.height
        )
    }

    func idealFrame(
        forContentSize size: CGSize,
        attachedTo attachmentPoint: CGPoint,
        at unitPoint: UnitPoint
    ) -> CGRect {
        .init(
            origin: .init(
                x: attachmentPoint.x - size.width * unitPoint.x,
                y: attachmentPoint.y - size.height * unitPoint.y
            ),
            size: size
        )
    }

    func constrainedFrame(_ frame: CGRect, in bounds: CGRect) -> CGRect {
        frame.offsetBy(
            dx: max(0, bounds.minX - frame.minX) + min(0, bounds.maxX - frame.maxX),
            dy: max(0, bounds.minY - frame.minY) + min(0, bounds.maxY - frame.maxY)
        )
    }
}
