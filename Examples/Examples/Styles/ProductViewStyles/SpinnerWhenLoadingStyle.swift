import SwiftUI
import StoreKit

/// A beautiful, modern ProductViewStyle with enhanced loading animations
/// Features gradient spinners, smooth transitions, and elegant visual effects
struct SpinnerWhenLoadingStyle: ProductViewStyle {
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var isPressed = false
    @State private var showSuccessAnimation = false
    
    func makeBody(configuration: Configuration) -> some View {
        //        let state: Product.TaskState = .loading
        let state = configuration.state
        switch state {
            case .loading:
                VStack(spacing: 16) {
                    // Enhanced Spinner with Gradient
                    ZStack {
                        // Outer rotating ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(
                                .linear(duration: 2)
                                .repeatForever(autoreverses: false),
                                value: rotationAngle
                            )
                        
                        // Inner pulsing circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 16, height: 16)
                            .scaleEffect(pulseScale)
                            .animation(
                                .easeInOut(duration: 1)
                                .repeatForever(autoreverses: true),
                                value: pulseScale
                            )
                    }
                    
                    // Loading Text with Typography
                    VStack(spacing: 4) {
                        Text("Loading Product")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text("Fetching the latest details...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .onAppear {
                    rotationAngle = 360
                    pulseScale = 1.2
                }
                
            case .success(let product):
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        // Product Icon with Success Animation
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [.green.opacity(0.1), .mint.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                
                                .scaleEffect(showSuccessAnimation ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.6).delay(0.2), value: showSuccessAnimation)
                            
                            configuration.icon
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .frame(width: 24, height: 24)
                        // Product Information
                        VStack(alignment: .leading, spacing: 6) {
                            Text(product.displayName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                                .opacity(showSuccessAnimation ? 1 : 0)
                                .offset(y: showSuccessAnimation ? 0 : 10)
                                .animation(.easeOut(duration: 0.5).delay(0.4), value: showSuccessAnimation)
                            
                            Text(product.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .opacity(showSuccessAnimation ? 1 : 0)
                                .offset(y: showSuccessAnimation ? 0 : 10)
                                .animation(.easeOut(duration: 0.5).delay(0.6), value: showSuccessAnimation)
                        }
                        
                        Spacer()
                        
                        // Price with Badge
                        VStack(alignment: .trailing, spacing: 6) {
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
                                .opacity(showSuccessAnimation ? 1 : 0)
                                .scaleEffect(showSuccessAnimation ? 1 : 0.8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: showSuccessAnimation)
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    LinearGradient(
                                        colors: [.green.opacity(0.3), .mint.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
                .shadow(color: .green.opacity(0.1), radius: 20, x: 0, y: 10)
                .onAppear {
                    withAnimation {
                        showSuccessAnimation = true
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
                ProductView(configuration)
        }
    }
}

#Preview("Spinner Loading Style") {
    VStack(spacing: 16) {
        
        // Multiple Products Preview
        VStack(spacing: 12) {
            ForEach(Array(Constants.products.enumerated()), id: \.offset) { offset, id in
                ProductView(id: id) {
                    ProductImage(productId: id)
                }
                .productViewStyle(SpinnerWhenLoadingStyle())
                .padding(.horizontal, 24)
            }
        }
    }
}
