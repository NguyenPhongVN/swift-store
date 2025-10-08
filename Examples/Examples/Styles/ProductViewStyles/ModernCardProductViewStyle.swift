import SwiftUI
import StoreKit

/// A premium, glassmorphism-inspired product view style with stunning visual effects
/// Features gradient backgrounds, sophisticated shadows, and smooth animations
struct ModernCardProductViewStyle: ProductViewStyle {
    @State private var isPressed = false
    
    func makeBody(configuration: Configuration) -> some View {
//        let state: Product.TaskState = .loading
        let state = configuration.state
        switch state {
            case .loading:
                HStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.2)
                        .tint(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Loading product...")
                            .font(.headline)
                            .fontWeight(.medium)
                        Text("Please wait while we fetch the details")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
            case .success(let product):
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 20) {
                        // Enhanced Product Icon with Gradient Background
                        configuration.icon
                            .font(.body)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .background {
                                LinearGradient(
                                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .clipShape(.circle)
                            }
                            .frame(width: 24, height: 24)
                        // Enhanced Product Info
                        VStack(alignment: .leading, spacing: 6) {
                            Text(product.displayName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                            
                            Text(product.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        // Enhanced Price with Badge Design
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(product.displayPrice)
                                .font(.title2)
                                .fontWeight(.black)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Premium")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.green, .mint],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = false
                        }
                    }
                }

            case .failure(let error):
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange.opacity(0.2), .red.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Unable to Load Product")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button("Retry") {
                        // Retry logic would be handled by the parent view
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.orange.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: .orange.opacity(0.2), radius: 15, x: 0, y: 8)
                
            case .unavailable:
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.red.opacity(0.2), .pink.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Product Unavailable")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("This product is currently not available for purchase.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.red.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: .red.opacity(0.2), radius: 15, x: 0, y: 8)
                
            @unknown default:
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.gray.opacity(0.2), .secondary.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Unknown State")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("An unexpected state occurred while loading the product.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.gray.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: .gray.opacity(0.2), radius: 15, x: 0, y: 8)
        }
    }
}

#Preview("Modern Card Style") {
    VStack(spacing: 12) {
        ForEach(Array(Constants.products.enumerated()), id: \.offset) { offset, id in
            ProductView(id: id) {
                ProductImage(productId: id)
            }
            .productViewStyle(ModernCardProductViewStyle())
            .padding(.horizontal, 24)
        }
    }
}
