// SwiftUI Popovers
// Copyright (c) 2025 Quirin Schweigert
// Licensed under the MIT License. See LICENSE file for details.

import SwiftUI

struct PopoverModifier: ViewModifier {
    struct Popover: Identifiable {
        let id: UUID
        let anchor: Anchor<CGRect>
        let content: () -> AnyView
        let disableDelay: Bool
        let isExclusive: Bool
        let preferredAttachmentEdge: VerticalEdge?
        let onDismiss: (() -> Void)?
    }

    @MainActor
    struct PopoverPreferenceKey: @MainActor PreferenceKey {
        @MainActor
        static let defaultValue: [PopoverModifier.Popover] = []

        static func reduce(value: inout [Popover], nextValue: () -> [Popover]) {
            value += nextValue()
        }
    }

    let isPresented: Binding<Bool>
    let popoverView: AnyView
    var disableDelay: Bool = false
    var isExclusive: Bool = false
    var isDismissible: Bool = false
    var preferredAttachmentEdge: VerticalEdge?

    @State var id: UUID = .init()

    func body(content: Content) -> some View {
        content
            .transformAnchorPreference(
                key: PopoverPreferenceKey.self,
                value: .bounds
            ) { value, anchor in
                guard isPresented.wrappedValue else { return }

                value.append(
                    Popover(
                        id: id,
                        anchor: anchor,
                        content: { popoverView },
                        disableDelay: disableDelay,
                        isExclusive: isExclusive,
                        preferredAttachmentEdge: preferredAttachmentEdge,
                        onDismiss: isDismissible ?
                            { withAnimation { isPresented.wrappedValue = false } } : nil
                    )
                )
            }
    }
}

extension EnvironmentValues {
    var effectiveAttachmentPoint: CGPoint? {
        get { self[PopoverPresentationModifier.EffectiveAttachmentPointKey.self] }
        set { self[PopoverPresentationModifier.EffectiveAttachmentPointKey.self] = newValue }
    }
}

public extension View {
    @MainActor
    func swiftUIPopover<P: View>(
        isPresented: Binding<Bool>,
        disableDelay: Bool = false,
        isExclusive: Bool = false,
        isDismissible: Bool = false,
        preferredAttachmentEdge: VerticalEdge? = nil,
        @ViewBuilder content: @escaping () -> P
    ) -> some View {
        modifier(PopoverModifier(
            isPresented: isPresented,
            popoverView: AnyView(content()),
            disableDelay: disableDelay,
            isExclusive: isExclusive,
            isDismissible: isDismissible,
            preferredAttachmentEdge: preferredAttachmentEdge
        ))
    }

    @MainActor
    public func presentPopovers(
        padding: EdgeInsets? = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    ) -> some View {
        modifier(PopoverPresentationModifier(padding: padding))
    }
}
