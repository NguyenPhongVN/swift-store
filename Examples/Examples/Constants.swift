import Foundation

enum Constants {
    
    static let subscriptionIDs = [
        "AP004.sub.week.code",
        "AP004.sub.month.code",
        "AP004.sub.year.code"
    ]
    static let lifetimeIDs = [
        "AP004.sub.lifetime.code"
    ]
    
    static let subscriptionSaleIDs = [
        "AP004.sub.week.code.sale",
        "AP004.sub.month.code.sale",
        "AP004.sub.year.code.sale"
    ]
    static let lifetimeSaleIDs = [
        "AP004.sub.lifetime.code.sale"
    ]
    
    static let products = subscriptionIDs + lifetimeIDs
    
    static let saleProducts = subscriptionSaleIDs + lifetimeSaleIDs
    
    static let allProducts = products + saleProducts
    
    static let productId = products.first!
    
    static let groupID = "21768032"
    
    static let termsString = "https://github.com/revenuecat"
    static let privacyString = "https://github.com/revenuecat"
    
    static let termsURL = URL(string: termsString)!
    static let privacyURL = URL(string: privacyString)!
    
}
