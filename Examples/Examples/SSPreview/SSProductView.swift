import SwiftUI
import StoreKit

#Preview("compact") {
    ProductView(id: Constants.productId) {
        ProductImage(productId: Constants.productId)
    }
    .productViewStyle(.compact)
    .padding()
    .background(.thinMaterial, in: .rect(cornerRadius: 20))
    .productViewStyle(.compact)
    .foregroundColor(.black)
    .padding(.horizontal)
}

#Preview("regular") {
    ProductView(id: Constants.productId) {
        ProductImage(productId: Constants.productId)
    }
    .productViewStyle(.regular)
    .padding()
    .background(.thinMaterial, in: .rect(cornerRadius: 20))
    .productViewStyle(.compact)
    .foregroundColor(.black)
    .padding(.horizontal)
}

#Preview("regular") {
    ProductView(id: Constants.productId) {
        ProductImage(productId: Constants.productId)
    }
    .productViewStyle(.regular)
    .padding()
    .background(.thinMaterial, in: .rect(cornerRadius: 20))
    .productViewStyle(.large)
    .foregroundColor(.black)
    .padding(.horizontal)
}

#Preview("ProductView onInAppPurchase") {
    ProductView(id: Constants.productId) {
        Image(systemName: "crown")
    }
    .productViewStyle(.compact)
    .padding()
    .onInAppPurchaseStart { product in
        print("User has started buying \(product.id)")
    }
    .onInAppPurchaseCompletion { product, result in
        if case .success(.success(let transaction)) = result {
            print("Purchased successfully: \(transaction.signedDate)")
        } else {
            print("Something else happened")
        }
    }
}

#Preview("ScrollView") {
    ScrollView {
        ProductView(id: Constants.lifetimeSaleIDs.first!) { _ in
            Image(systemName: "crown")
                .resizable()
                .scaledToFit()
        } placeholderIcon: {
            ProgressView()
        }
        .productViewStyle(.large)
        
        VStack(spacing: 16) {
            ForEach(Constants.products, id: \.self) { id in
                ProductView(id: id)
                    .productViewStyle(.compact)
            }
        }
        .padding()
    }
}
