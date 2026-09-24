import SwiftUI

/// A property wrapper that provides access to the SwiftStore shared instance within SwiftUI views.
///
/// `SwiftStoreState` acts as a bridge between the `SwiftStore` singleton and SwiftUI's state management system.
/// It provides a convenient way to access premium status, active subscription state,
/// and other in-app purchase related state within SwiftUI views.
///
/// ## Features
/// - **Property Wrapper**: Use with `@SwiftStoreState` to access store state in views
/// - **Dynamic Member Lookup**: Access store properties directly without explicit property access
/// - **Binding Support**: Provides a `Binding` to the underlying store instance via the projected value
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
///             Text("Premium Active: \(store.isPremium ? "Yes" : "No")")
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
///             Text("Premium: \(isPremium)")
///             Text("Products: \(productIDs.count)")
///         }
///     }
/// }
/// ```
///
/// ### Projected Value
/// The projected value (`$store`) is a `Binding<SwiftStore>` to the underlying
/// store instance — useful when an API requires a binding to the store itself:
/// ```swift
/// struct SettingsView: View {
///     @SwiftStoreState private var store
///
///     var body: some View {
///         StoreDetailsView($store)
///     }
/// }
/// ```
///
/// ## Store Properties
/// The wrapped `SwiftStore` instance provides access to:
/// - `isPremium: Bool` - Whether the user has premium access (lifetime or subscription)
/// - `activeLifeTime: Bool` - Whether a lifetime purchase is active
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
    /// This provides direct access to the SwiftStore singleton and all its
    /// properties including premium status, lifetime purchase state, and
    /// subscription status.
    public var wrappedValue: SwiftStore {
        viewModel
    }

    /// Returns a binding to the SwiftStore instance
    ///
    /// The projected value is a `Binding<SwiftStore>` to the underlying store
    /// instance, for APIs that require a binding to the store itself. To read or
    /// write individual store properties, use the wrapped value or dynamic member
    /// lookup instead.
    public var projectedValue: Binding<SwiftStore> {
        return $viewModel
    }

    /// Provides dynamic member lookup for read-only properties
    ///
    /// This allows direct access to SwiftStore properties without explicitly accessing
    /// the wrapped value. For example, `isPremium` instead of `store.isPremium`.
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
