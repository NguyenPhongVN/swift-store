//
//  ContentView.swift
//  Examples
//
//  Created by Computer on 10/6/25.
//

import SwiftUI
import SwiftStore

struct ContentView: View {
    
    @State private var isPresented: Bool = false
    
    @SwiftStoreState
    private var ssState
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(ssState.isPremium ? "Premium" : "Free")
        }
        .padding()
        .onTapGesture {
            isPresented = true
        }
        .fullScreenCover(isPresented: $isPresented) {
            PaywallView()
        }
    }
}

#Preview {
    ContentView()
}
