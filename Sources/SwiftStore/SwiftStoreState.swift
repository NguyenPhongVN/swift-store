import SwiftUI

/// A property wrapper that provides access to the SwiftStore shared instance within SwiftUI views.
/// 
/// `SwiftStoreState` acts as a bridge between the `SwiftStore` singleton and SwiftUI's state management system.
/// It provides a convenient way to access StoreKit transaction data, consumable counts, subscription status,
/// and other in-app purchase related state within SwiftUI views.
///
/// ## Features
/// - **Property Wrapper**: Use with `@SwiftStoreState` to access store state in views
/// - **Dynamic Member Lookup**: Access store properties directly without explicit property access
/// - **Binding Support**: Provides two-way binding for mutable store properties
/// - **Main Actor Compliance**: Ensures UI updates happen on the main thread
///
/// ## Usage Examples
///
/// ### Basic Property Access
/// ```swift
/// struct MyView: View {
///     @SwiftStoreState private var store
///     
///     var body: some View {
///         VStack {
///             Text("Consumables: \(store.consumableCount)")
///             Text("Premium Active: \(store.boughtNonConsumable ? "Yes" : "No")")
///             if let subscription = store.activeSubscription {
///                 Text("Subscription: \(subscription)")
///             }
///         }
///     }
/// }
/// ```
///
/// ### Using Dynamic Member Lookup
/// ```swift
/// struct MyView: View {
///     @SwiftStoreState private var store
///     
///     var body: some View {
///         // Direct property access through dynamic member lookup
///         VStack {
///             Text("Count: \(consumableCount)")
///             Text("Premium: \(boughtNonConsumable)")
///         }
///     }
/// }
/// ```
///
/// ### Two-Way Binding
/// ```swift
/// struct SettingsView: View {
///     @SwiftStoreState private var store
///     
///     var body: some View {
///         Toggle("Enable Premium", isOn: $boughtNonConsumable)
///     }
/// }
/// ```
///
/// ## Store Properties
/// The wrapped `SwiftStore` instance provides access to:
/// - `consumableCount: Int` - Number of consumable items purchased
/// - `boughtNonConsumable: Bool` - Whether non-consumable items have been purchased
/// - `activeSubscription: String?` - Currently active subscription product ID
@propertyWrapper
@dynamicMemberLookup
@MainActor
public struct SwiftStoreState: DynamicProperty {

    /// The underlying SwiftStore view model instance
    @State private var viewModel = SwiftStore.shared
    
    
    public init(_ viewModel: SwiftStore = .shared) {
        self.viewModel = viewModel
    }
    
    /// Returns the wrapped SwiftStore instance
    /// 
    /// This provides direct access to the SwiftStore singleton and all its properties
    /// including consumable counts, subscription status, and purchase history.
    public var wrappedValue: SwiftStore {
        viewModel
    }

    /// Returns a binding to the SwiftStore instance for two-way data binding
    /// 
    /// Use this when you need to create bindings for mutable properties in SwiftUI views.
    /// This is particularly useful for toggles, text fields, and other controls that need
    /// to modify store state.
    public var projectedValue: Binding<SwiftStore> {
        return $viewModel
    }

    /// Provides dynamic member lookup for read-only properties
    /// 
    /// This allows direct access to SwiftStore properties without explicitly accessing
    /// the wrapped value. For example, `consumableCount` instead of `store.consumableCount`.
    /// 
    /// - Parameter keyPath: A KeyPath to a property on SwiftStore
    /// - Returns: The value at the specified key path
    public subscript<U>(dynamicMember keyPath: KeyPath<SwiftStore, U>) -> U {
        return viewModel[keyPath: keyPath]
    }

    /// Provides dynamic member lookup for writable properties with two-way binding support
    /// 
    /// This allows both reading and writing to SwiftStore properties through dynamic member lookup.
    /// Changes made through this subscript will automatically trigger UI updates.
    /// 
    /// - Parameter keyPath: A WritableKeyPath to a mutable property on SwiftStore
    /// - Returns: A getter/setter pair for the property at the specified key path
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<SwiftStore, U>) -> U {
        get { return viewModel[keyPath: keyPath] }
        set { viewModel[keyPath: keyPath] = newValue }
    }
}
