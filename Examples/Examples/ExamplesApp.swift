import SwiftUI
import SwiftStore

@main
struct ExamplesApp: App {
    
    init() {
        //        let subscriptionIDs = [
        //            "AP004.sub.week.code",
        //            "AP004.sub.month.code",
        //            "AP004.sub.year.code"
        //        ]
        //        let lifetimeIDs = [
        //            "AP004.sub.lifetime.code"
        //        ]
        
        let configuration = SSConfiguration()
            .setLifetimeIDs(Constants.lifetimeIDs)
            .setSubscriptionIDs(Constants.subscriptionIDs)
            .setTermsURL(Constants.termsString)
            .setPrivacyURL(Constants.privacyString)
        
        SwiftStore.shared
            .initialize(configuration: configuration)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
