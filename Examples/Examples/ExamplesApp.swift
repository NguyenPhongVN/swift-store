//
//  ExamplesApp.swift
//  Examples
//
//  Created by Computer on 10/6/25.
//

import SwiftUI
import SwiftStore

@main
struct ExamplesApp: App {
    
    init() {
        let subscriptionIDs = [
            "AP004.sub.week.code",
            "AP004.sub.month.code",
            "AP004.sub.year.code"
        ]
        let lifetimeIDs = [
            "AP004.sub.lifetime.code"
        ]
        
        let configuration = SSConfiguration()
            .setLifetimeIDs(lifetimeIDs)
            .setSubscriptionIDs(subscriptionIDs)
            .setTermsURL("https://github.com/RevenueCat")
            .setPrivacyURL("https://github.com/RevenueCat")
        
        SwiftStore.shared.initialize(configuration: configuration)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
