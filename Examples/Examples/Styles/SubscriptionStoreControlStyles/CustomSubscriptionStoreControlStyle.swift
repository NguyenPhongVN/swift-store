import SwiftUI
import StoreKit

struct CustomSubscriptionStoreControlStyle: SubscriptionStoreControlStyle {
    typealias Placement = ButtonsSubscriptionStoreControlStyle.Placement
    
    @State private var selectedOption: SubscriptionStoreControlStyleConfiguration.Option?
    
    func makeBody(configuration: Configuration) -> some View {
        SubscriptionPicker(configuration) { pickerOption in
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(pickerOption.displayName)
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                    
                    Text(pickerOption.displayPrice)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                    
                    Text(pickerOption.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                SelectionIndicator(pickerOption.isSelected)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                pickerOption.isSelected ? .blue : .gray,
                                lineWidth: pickerOption.isSelected ? 2 : 1
                            )
                    )
            )
//            .scaleEffect(pickerOption.isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pickerOption.isSelected)
            .background(Color.clear)
        } confirmation: { option in
            SubscribeButton(option)
        }
    }
}

// MARK: - Selection Indicator Component
struct SelectionIndicator: View {
    let isSelected: Bool
    
    init(_ isSelected: Bool) {
        self.isSelected = isSelected
    }
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    isSelected ? .blue : .gray.opacity(0.3),
                    lineWidth: isSelected ? 3 : 2
                )
                .frame(width: 24, height: 24)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            
            if isSelected {
                Circle()
                    .fill(.blue)
                    .frame(width: 12, height: 12)
                    .scaleEffect(isSelected ? 1.0 : 0.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            }
        }
    }
}

extension SubscriptionStoreControlStyle where Self == CustomSubscriptionStoreControlStyle {
    static var priceComparisonButtons: Self { Self() }
}

#Preview("price comparison buttons") {
    VStack {
        Text("Choose your plan")
            .font(.title2.bold())
        SubscriptionStoreView(groupID: Constants.groupID)
            .subscriptionStoreControlStyle(.priceComparisonButtons)
            .subscriptionStorePolicyDestination(for: .termsOfService) {
                Text("Terms of Service")
            }
            .subscriptionStorePolicyDestination(for: .privacyPolicy) {
                Text("Privacy Policy")
            }
    }
    
}

#Preview("prominent picker") {
    SubscriptionStoreView(productIDs: Constants.products) {
        MarketingPaywallContent()
    }
    .subscriptionStorePolicyDestination(for: .termsOfService) {
        Text("Terms of Service")
    }
    .subscriptionStorePolicyDestination(for: .privacyPolicy) {
        Text("Privacy Policy")
    }
    .subscriptionStorePolicyForegroundStyle(.white)
    .subscriptionStorePickerItemBackground(.thinMaterial)
    .subscriptionStoreControlStyle(.prominentPicker)
//    .subscriptionStoreControlBackground(
//        LinearGradient(colors: [.purple, .blue, .pink],
//                       startPoint: .top,
//                       endPoint: .bottom)
//    )
    .storeButton(.visible, for: .redeemCode)
    .storeButton(.visible, for: .restorePurchases)
    .storeButton(.visible, for: .cancellation)
    .tint(.indigo)
    
}
