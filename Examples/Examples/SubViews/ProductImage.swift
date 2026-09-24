import SwiftUI

struct ProductImage: View {
    
    let productId: String
    
    var body: some View {
        Image(systemName: "crown")
            .resizable()
            .scaledToFit()
            .foregroundStyle(color)
    }
    
    var color: Color {
        return hexColor(for: productId)
    }
    
    /// Generates a deterministic color based on the product ID using hex values
    private func hexColor(for productId: String) -> Color {
        let hexColors: [String] = [
            "#FF6B6B", // Coral Red
            "#4ECDC4", // Turquoise
            "#45B7D1", // Sky Blue
            "#96CEB4", // Mint Green
            "#FFEAA7", // Soft Yellow
            "#DDA0DD", // Plum
            "#98D8C8", // Seafoam
            "#F7DC6F", // Golden Yellow
            "#BB8FCE", // Light Purple
            "#85C1E9", // Light Blue
            "#F8C471", // Peach
            "#82E0AA", // Light Green
            "#F1948A", // Light Red
            "#85C1E9", // Powder Blue
            "#D7BDE2", // Lavender
            "#AED6F1", // Baby Blue
            "#A9DFBF", // Light Mint
            "#F9E79F", // Cream
            "#FADBD8", // Rose
            "#E8DAEF"  // Lilac
        ]

        // Generate a deterministic index based on the product ID's stable hash.
        let index = Int(fnv1aHash(productId) % UInt64(hexColors.count))
        let selectedHex = hexColors[index]

        return Color(hex: selectedHex)
    }

    /// FNV-1a hash: stable across launches and processes, unlike `String.hashValue`,
    /// which is seeded per process and would re-randomize the color on every launch.
    private func fnv1aHash(_ string: String) -> UInt64 {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in string.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return hash
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    /// Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
