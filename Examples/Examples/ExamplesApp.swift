import SwiftUI
import SwiftStore

/// Demo app entry point: configures the shared store before any screen loads.
@main
struct ExamplesApp: App {

    // MARK: - Store Configuration

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

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
