import SwiftUI
import StoreKit

struct PreviewView: View {
    var body: some View {
        ScrollView {
            VStack {
                MarketingPaywallContent()
                StoreView(ids: Constants.products) { product in
                    ProductImage(productId: product.id)
                }
                .productViewStyle(ModernCardProductViewStyle())
                .storeButton(.visible, for: .restorePurchases)
                .storeButton(.visible, for: .redeemCode)
                .storeButton(.hidden, for: .cancellation)
            }

        }
        .scrollIndicators(.hidden)
    }
}
