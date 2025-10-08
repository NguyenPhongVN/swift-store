import SwiftUI
import StoreKit

#Preview("StoreView compact") {
    StoreView(ids: Constants.products) { product in
        ProductImage(productId: product.id)
    }
    .productViewStyle(ModernCardProductViewStyle())
    .storeButton(.visible, for: .restorePurchases)
}

#Preview("StoreView regular") {
    StoreView(ids: Constants.products) { product in
        ProductImage(productId: product.id)
    }
    .productViewStyle(ModernCardProductViewStyle())
    .storeButton(.visible, for: .restorePurchases)
}

#Preview("StoreView large") {
    StoreView(ids: Constants.products) { product in
        ProductImage(productId: product.id)
    }
    .productViewStyle(.large)
    .storeButton(.visible, for: .restorePurchases)
}
