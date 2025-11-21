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
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                /// Attaching the popover
                .swiftUIPopover(isPresented: $showPopover, preferredAttachmentEdge: .top) {
                    PopoverMessageBubble(fill: Color.blue) {
                        Text("This is a system symbol:\n`Image(systemName: \"globe\")` ! 🙂")
                            .foregroundStyle(Color.white)
                    }
                }
            
            Text("Hello, world!")
        }
        .offset(x: dragOffset.width, y: dragOffset.height)
        .animation(
            .spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0),
            value: dragOffset
        )
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                }
        )
        /// Make sure we actually fill the screen with our view...
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        /// ...to present the popovers of the contained view hierarchy
        .presentPopovers()
        .padding(4)
    }
}

#Preview {
    ContentView()
}
