//
//  ContentView.swift
//  PopoverExample
//
//  Created by Quirin Schweigert on 21.11.25.
//

import SwiftUI

/// Import SwiftUI Popover
import SwiftUI_Popover

struct ContentView: View {
    @State var showPopover: Bool = true
    @GestureState private var dragOffset: CGSize = .zero
    
    @State var showToolbarMenu: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                    // - MARK: Attaching the popover
                    .swiftUIPopover(isPresented: $showPopover, preferredAttachmentEdge: .top) {
                        PopoverMessageBubble(fill: Color.blue) {
                            Text("`Image(systemName: \"globe\")` ! 🙂")
                                .foregroundStyle(Color.white)
                                #if os(watchOS)
                                .font(.system(size: 14))
                                #endif
                        }
                    }
                
                Text("Hello, world!")
            }
            .toolbar {
                #if os(watchOS)
                let placement: ToolbarItemPlacement = .topBarTrailing
                #else
                let placement: ToolbarItemPlacement = .automatic
                #endif
                
                ToolbarItem(placement: placement) { toolbarButton }
            }
            .offset(x: dragOffset.width, y: dragOffset.height)
            .animation(
                .spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0),
                value: dragOffset
            )
            #if !os(tvOS)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
            )
            #endif
            /// Make sure we actually fill the screen with our view...
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            /// ...to present the popovers of the contained view hierarchy
        }
        
        // - MARK: Presenting Popovers
        /// Call `.presentPopovers()` wherever you want to render all popovers from the
        /// respective view subtree
        #if os(watchOS)
        .presentPopovers()
        #else
        .presentPopovers(padding: .init(size: 4))
        #endif
    }
    
    @ViewBuilder var toolbarButton: some View {
        Button {
            withAnimation { showToolbarMenu = true }
        } label: {
            Image(systemName: "ellipsis")
        }
        .buttonStyle(.automatic)
        .swiftUIPopover(
            isPresented: $showToolbarMenu,
            disableDelay: true,
            isExclusive: true,
            isDismissible: true
        ) {
            toolbarMenu
        }
    }
    
    @ViewBuilder var toolbarMenu: some View {
        #if os(macOS)
        let color: Color = .white
        #elseif os(visionOS)
        let color: Color = .white.opacity(0.2)
        #else
        let color: Color = .clear
        #endif

        PopoverMessageBubble(fill: color, enableGlassEffect: true) {
            VStack(alignment: .leading) {
                MenuButton(systemImage: "bolt.fill", title: "Lightning")
                MenuButton(systemImage: "moon.fill", title: "Sleep")
            }
            .padding(.vertical, 4)
        }
    }
    
    struct MenuButton: View {
        let systemImage: String
        let title: LocalizedStringKey
        
        var action: (@MainActor () -> Void)?
        
        var body: some View {
            Button { action?() } label: {
                
                
                Label(title, systemImage: systemImage)
                    .frame(height: 30)
                    .padding(.horizontal, 6)

                
            }
            .buttonStyle(.plain)
        }
    }
}

extension EdgeInsets {
    init(size: CGFloat) {
        self.init(top: size, leading: size, bottom: size, trailing: size)
    }
}

#Preview {
    ContentView()
}
