import SwiftUI
import StoreKit

#Preview("SubscriptionStoreView — all relationships") {
    SubscriptionStoreView(groupID: Constants.groupID, visibleRelationships: .all) {
        MarketingPaywallContent()
        
            .onInAppPurchaseStart { product in
                print(product.displayName)
            }
            .onInAppPurchaseCompletion { product, result in
                
            }
            .padding()
            .foregroundColor(.white)
        //    .containerBackground(Color.orange, for: .subscriptionStoreHeader)
        //    .containerBackground(Color.red, for: .subscriptionStoreFullHeight)
        //    .containerBackground(for: .subscriptionStoreHeader) {
        //      Color.green
        //    }
        //    .containerBackground(for: .subscriptionStoreFullHeight) {
        //      Color.cyan
        //    }
        
    }
    .subscriptionStoreControlIcon { product, subscriptionInfo in
    }
    .subscriptionStoreControlStyle(.compactPicker, placement: .bottomBar)
    .subscriptionStoreButtonLabel(.multiline)
    .storeButton(.visible, for: .restorePurchases)
    .storeButton(.visible, for: .redeemCode)
    .storeButton(.visible, for: .policies)
    .storeButton(.visible, for: .cancellation)
    .storeButton(.visible, for: .signIn)
    .subscriptionStorePolicyDestination(url: Constants.privacyURL, for: .privacyPolicy)
    .subscriptionStorePolicyDestination(url: Constants.termsURL, for: .termsOfService)
    .backgroundStyle(.clear)
    .subscriptionStorePickerItemBackground(.thinMaterial)
}

#Preview("SubscriptionStoreView — upgrade") {
    SubscriptionStoreView(groupID: Constants.groupID, visibleRelationships: .upgrade) {
        MarketingPaywallContent()
            .foregroundStyle(.white)
            .containerBackground(.blue.gradient, for: .subscriptionStore)
    }
    .storeButton(.visible, for: .restorePurchases, .redeemCode)
    .subscriptionStoreControlStyle(.prominentPicker)
}

#Preview("SubscriptionStoreView — current + sign-in") {
    @Previewable @State var showingSignIn = false
    SubscriptionStoreView(groupID:  Constants.groupID, visibleRelationships: .current) {
        MarketingPaywallContent()
            .foregroundStyle(.white)
            .containerBackground(.blue.gradient, for: .subscriptionStore)
    }
    .storeButton(.visible, for: .restorePurchases, .redeemCode, .policies, .signIn)
    .subscriptionStorePolicyDestination(for: .privacyPolicy) {
        Text("Privacy policy here")
    }
    .subscriptionStorePolicyDestination(for: .termsOfService) {
        Text("Terms of service here")
    }
    .subscriptionStoreSignInAction {
        showingSignIn = true
    }
    .sheet(isPresented: $showingSignIn) {
        Text("Sign in here")
    }
    .subscriptionStoreControlStyle(.prominentPicker)
}

