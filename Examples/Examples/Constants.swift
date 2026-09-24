import Foundation

/// Static identifiers and links used across the demo app.
enum Constants {

    // MARK: - Products

    static let subscriptionIDs = [
        "AP004.sub.week.code",
        "AP004.sub.month.code",
        "AP004.sub.year.code"
    ]
    static let lifetimeIDs = [
        "AP004.sub.lifetime.code"
    ]

    // MARK: - Sale Products

    static let subscriptionSaleIDs = [
        "AP004.sub.week.code.sale",
        "AP004.sub.month.code.sale",
        "AP004.sub.year.code.sale"
    ]
    static let lifetimeSaleIDs = [
        "AP004.sub.lifetime.code.sale"
    ]

    // MARK: - Derived Collections

    static let products = subscriptionIDs + lifetimeIDs
    static let saleProducts = subscriptionSaleIDs + lifetimeSaleIDs
    static let allProducts = products + saleProducts

    // MARK: - Convenience

    static let productId = products.first!
    static let groupID = "21768032"

    // MARK: - Legal Links

    static let termsString = "https://github.com/revenuecat"
    static let privacyString = "https://github.com/revenuecat"
    static let termsURL = URL(string: termsString)!
    static let privacyURL = URL(string: privacyString)!
}
