import SwiftUI
import StoreKit

struct PurchaseExample: View {
    @Environment(\.purchase) private var purchase: PurchaseAction
    let product: Product
    let purchaseOptions: Set<Product.PurchaseOption> = []
    
    
    var body: some View {
        Button {
            Task {
                let purchaseResult = try await purchase(product, options: purchaseOptions)
                // Process the purchase result.
                switch purchaseResult {
                    case .success(_):
                        break
                    case .userCancelled:
                        break
                    case .pending:
                        break
                    @unknown default:
                        break
                }
            }
        } label: {
            Text(product.displayName)
        }
    }
}
